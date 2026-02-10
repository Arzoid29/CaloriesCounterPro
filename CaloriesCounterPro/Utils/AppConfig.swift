import Foundation

enum AppConfig {

    // MARK: - API Keys

    static var geminiAPIKey: String {
        guard let key = Bundle.main.infoDictionary?["GEMINI_API_KEY"] as? String, !key.isEmpty else {
            #if DEBUG
            return "AIzaSyD-28to3JW1aAlbjG_dsuXOjPd719HJKJY"
            #else
            fatalError("GEMINI_API_KEY not configured in Info.plist")
            #endif
        }
        return key
    }

    static let nutritionixAppId = ""
    static let nutritionixAPIKey = ""

    // MARK: - App Settings

    static let appName = "Calories Counter Pro"

    static let maxHistoryItems = 100

    static let ocrLanguages = ["es", "en"]

    static let supportEmail = "arzoid29@gmail.com"

    // MARK: - Calorie Gauge

    static let calorieGaugeMax: CGFloat = 1200

    enum CalorieRange {
        static let low = 0..<200
        static let moderate = 200..<500
        static let high = 500..<800
    }

    // MARK: - Validation

    static var isGeminiConfigured: Bool {
        !geminiAPIKey.isEmpty
    }
}
