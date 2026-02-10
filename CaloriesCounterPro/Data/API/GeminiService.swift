import Foundation

final class GeminiService: CalorieEstimationRepository {

    private let apiKey: String
    private let model = "gemini-2.5-flash-lite"

    private var baseURL: String {
        "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)"
    }

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func estimateCalories(from menuText: String) async throws -> [Dish] {
        let request = try buildRequest(menuText: menuText)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ScanError.apiError(String(localized: "error.invalid_response"))
        }

        if httpResponse.statusCode == 429 {
            throw ScanError.tooManyRequests
        }

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No details"
            throw ScanError.apiError("HTTP \(httpResponse.statusCode): \(errorBody)")
        }

        return try parseResponse(data: data)
    }

    private func buildRequest(menuText: String) throws -> URLRequest {
        guard let url = URL(string: baseURL) else {
            throw ScanError.apiError(String(localized: "error.invalid_url"))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let prompt = """
        Eres un nutricionista experto. Analiza el siguiente texto de un menú de restaurante \
        y estima las calorías aproximadas de cada plato que identifiques.

        Responde ÚNICAMENTE con un JSON válido (sin markdown, sin bloques de código) con esta estructura exacta:
        [
          {
            "name": "Nombre del plato",
            "description": "Breve descripción del plato",
            "estimatedCalories": 450,
            "confidence": "alta",
            "notes": "Incluye arroz y ensalada"
          }
        ]

        Reglas:
        - "confidence" solo puede ser: "alta", "media", o "baja"
        - Si un plato tiene descripción en el menú, úsala para mejor estimación
        - Incluye TODOS los platos que encuentres
        - Las calorías deben ser por porción individual estándar
        - Si no puedes estimar, usa confianza "baja"

        MENÚ:
        \(menuText)
        """

        let body: [String: Any] = [
            "contents": [
                ["role": "user", "parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 0.3,
                "maxOutputTokens": 4096,
                "responseMimeType": "application/json"
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    private func parseResponse(data: Data) throws -> [Dish] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw ScanError.apiError(String(localized: "error.unexpected_format"))
        }

        let cleanedText = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let dishData = cleanedText.data(using: .utf8) else {
            throw ScanError.apiError(String(localized: "error.data_conversion"))
        }

        let rawDishes: [RawDishResponse]
        do {
            rawDishes = try JSONDecoder().decode([RawDishResponse].self, from: dishData)
        } catch {
            throw ScanError.apiError(String(localized: "error.json_parsing"))
        }

        guard !rawDishes.isEmpty else {
            throw ScanError.noDishesFound
        }

        return rawDishes.compactMap { raw in
            guard !raw.name.isEmpty, raw.estimatedCalories >= 0 else { return nil }
            return Dish(
                name: raw.name,
                description: raw.description ?? "",
                estimatedCalories: max(0, raw.estimatedCalories),
                confidence: CalorieConfidence(rawValue: raw.confidence ?? "media") ?? .medium,
                notes: raw.notes ?? ""
            )
        }
    }
}

private struct RawDishResponse: Codable {
    let name: String
    let description: String?
    let estimatedCalories: Int
    let confidence: String?
    let notes: String?
}
