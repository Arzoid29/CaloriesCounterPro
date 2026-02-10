import Foundation
import SwiftUI
import UIKit
import Combine
import StoreKit

@MainActor
final class MenuScannerViewModel: ObservableObject {
    @Published var dishes: [Dish] = []
    @Published var errorMessage: String?
    @Published var showResults = false
    @Published var restaurantName: String = ""
    @Published var showManualInput = false
    @Published var manualMenuText: String = ""
    @Published var selectedRestaurant: Restaurant?
    @Published var showPaywall = false
    @Published var currentPhase: ScanPhase = .idle

    enum ScanPhase {
        case idle, scanning, analyzing, done
    }

    var isLoading: Bool {
        currentPhase == .scanning || currentPhase == .analyzing
    }

    var isAnalyzing: Bool {
        currentPhase == .analyzing
    }

    var scanSucceeded: Bool {
        currentPhase == .done && !dishes.isEmpty
    }

    var canScan: Bool {
        usageManager.canPerformScan(isSubscribed: storeService.isSubscribed)
    }

    var remainingFreeScans: Int {
        usageManager.remainingFreeScans()
    }

    var isSubscribed: Bool {
        storeService.isSubscribed
    }

    private let scanMenuUseCase: ScanMenuUseCase
    private let usageManager = UsageLimitManager.shared
    private let storeService = StoreKitService.shared

    init(scanMenuUseCase: ScanMenuUseCase) {
        self.scanMenuUseCase = scanMenuUseCase
    }

    func processImage(_ image: UIImage) async {
        guard !isLoading else { return }
        guard checkAndRequestScan() else { return }

        errorMessage = nil
        currentPhase = .scanning

        do {
            currentPhase = .analyzing
            let scan = try await scanMenuUseCase.execute(
                image: image,
                restaurantName: selectedRestaurant?.name ?? restaurantName,
                restaurant: selectedRestaurant
            )
            usageManager.recordScan()
            dishes = scan.dishes
            currentPhase = .done
            showResults = true
        } catch {
            errorMessage = error.localizedDescription
            currentPhase = .idle
        }
    }

    func analyzeManualText() async {
        guard !manualMenuText.isEmpty else {
            errorMessage = String(localized: "error.empty_text")
            return
        }
        guard checkAndRequestScan() else { return }

        errorMessage = nil
        currentPhase = .analyzing

        do {
            let scan = try await scanMenuUseCase.estimateFromText(
                manualMenuText,
                restaurantName: selectedRestaurant?.name ?? restaurantName,
                restaurant: selectedRestaurant
            )
            usageManager.recordScan()
            dishes = scan.dishes
            currentPhase = .done
            showResults = true
        } catch {
            errorMessage = error.localizedDescription
            currentPhase = .idle
        }
    }

    func selectRestaurant(_ restaurant: Restaurant?) {
        selectedRestaurant = restaurant
        if let restaurant {
            restaurantName = restaurant.name
        }
    }

    func resetScan() {
        dishes = []
        errorMessage = nil
        showResults = false
        currentPhase = .idle
        manualMenuText = ""
        restaurantName = ""
        selectedRestaurant = nil
    }

    private func checkAndRequestScan() -> Bool {
        if canScan { return true }
        showPaywall = true
        return false
    }
}
