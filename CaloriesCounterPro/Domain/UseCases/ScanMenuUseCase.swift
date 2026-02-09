import Foundation
import UIKit

final class ScanMenuUseCase {
    private let textRecognition: TextRecognitionRepository
    private let calorieEstimation: CalorieEstimationRepository
    private let scanHistory: ScanHistoryRepository
    private let restaurantRepository: RestaurantRepository?

    init(
        textRecognition: TextRecognitionRepository,
        calorieEstimation: CalorieEstimationRepository,
        scanHistory: ScanHistoryRepository,
        restaurantRepository: RestaurantRepository? = nil
    ) {
        self.textRecognition = textRecognition
        self.calorieEstimation = calorieEstimation
        self.scanHistory = scanHistory
        self.restaurantRepository = restaurantRepository
    }

    func execute(image: UIImage, restaurantName: String = "", restaurant: Restaurant? = nil) async throws -> MenuScan {
        let menuText = try await textRecognition.recognizeText(from: image)
        guard !menuText.isEmpty else {
            throw ScanError.noTextFound
        }
        let dishes = try await calorieEstimation.estimateCalories(from: menuText)
        guard !dishes.isEmpty else {
            throw ScanError.noDishesFound
        }
        let resolvedRestaurant = try await resolveRestaurant(
            provided: restaurant,
            name: restaurantName
        )
        let scan = MenuScan(
            restaurantName: resolvedRestaurant?.name ?? restaurantName,
            rawText: menuText,
            dishes: dishes,
            restaurant: resolvedRestaurant
        )
        try await scanHistory.saveScan(scan)
        return scan
    }

    func estimateFromText(_ menuText: String, restaurantName: String = "", restaurant: Restaurant? = nil) async throws -> MenuScan {
        let dishes = try await calorieEstimation.estimateCalories(from: menuText)
        guard !dishes.isEmpty else {
            throw ScanError.noDishesFound
        }
        let resolvedRestaurant = try await resolveRestaurant(
            provided: restaurant,
            name: restaurantName
        )
        let scan = MenuScan(
            restaurantName: resolvedRestaurant?.name ?? restaurantName,
            rawText: menuText,
            dishes: dishes,
            restaurant: resolvedRestaurant
        )
        try await scanHistory.saveScan(scan)
        return scan
    }

    private static var defaultRestaurantName: String {
        return NSLocalizedString("default.restaurant_name", comment: "Default restaurant name for unknown restaurant")
    }

    private func resolveRestaurant(provided: Restaurant?, name: String) async throws -> Restaurant? {
        if let provided = provided {
            return provided
        }
        guard let repo = restaurantRepository else {
            return nil
        }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            return try await repo.findRestaurant(byName: trimmedName)
        }
        return try await repo.findOrCreateRestaurant(name: Self.defaultRestaurantName)
    }
}

enum ScanError: LocalizedError {
    case noTextFound
    case noDishesFound
    case cameraNotAvailable
    case apiError(String)
    case tooManyRequests

    var errorDescription: String? {
        switch self {
        case .noTextFound:
            return String(localized: "error.no_text")
        case .noDishesFound:
            return String(localized: "error.no_dishes")
        case .cameraNotAvailable:
            return String(localized: "error.no_camera")
        case .apiError(let message):
            let format = NSLocalizedString("error.api", comment: "API error with message")
            return String(format: format, message)
        case .tooManyRequests:
            return String(localized: "error.too_many_requests")
        }
    }
}
