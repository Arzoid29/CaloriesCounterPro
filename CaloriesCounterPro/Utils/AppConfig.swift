import Foundation

enum AppConfig {

    // MARK: - API Keys

    static let geminiAPIKey = "AIzaSyD-28to3JW1aAlbjG_dsuXOjPd719HJKJY"

    static let nutritionixAppId = ""
    static let nutritionixAPIKey = ""

    // MARK: - App Settings

    static let appName = "Calories Counter Pro"

    static let maxHistoryItems = 100

    static let ocrLanguages = ["es", "en"]

    // MARK: - Validación

    static var isGeminiConfigured: Bool {
        !geminiAPIKey.isEmpty
    }
}
