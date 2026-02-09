import Foundation

struct Dish: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let estimatedCalories: Int
    let confidence: CalorieConfidence
    let notes: String

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        estimatedCalories: Int,
        confidence: CalorieConfidence = .medium,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.estimatedCalories = estimatedCalories
        self.confidence = confidence
        self.notes = notes
    }
}

enum CalorieConfidence: String, Codable, CaseIterable {
    case high = "alta"
    case medium = "media"
    case low = "baja"

    var color: String {
        switch self {
        case .high: return "green"
        case .medium: return "orange"
        case .low: return "red"
        }
    }

    var label: String {
        switch self {
        case .high: return String(localized: "confidence.high")
        case .medium: return String(localized: "confidence.medium")
        case .low: return String(localized: "confidence.low")
        }
    }
}
