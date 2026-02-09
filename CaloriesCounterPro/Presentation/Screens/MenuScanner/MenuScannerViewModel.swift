import Foundation
import SwiftUI
import UIKit
import Combine
import StoreKit

@MainActor
final class MenuScannerViewModel: ObservableObject {
    @Published var scannedText: String = ""
    @Published var dishes: [Dish] = []
    @Published var isLoading = false
    @Published var isAnalyzing = false
    @Published var errorMessage: String?
    @Published var showResults = false
    @Published var restaurantName: String = ""
    @Published var showManualInput = false
    @Published var manualMenuText: String = ""
    @Published var selectedRestaurant: Restaurant?
    @Published var showPaywall = false

    enum ScanPhase {
        case idle
        case scanning
        case analyzing
        case done
        var localizedText: String {
            switch self {
            case .idle: return ""
            case .scanning: return String(localized: "phase.scanning")
            case .analyzing: return String(localized: "phase.analyzing")
            case .done: return String(localized: "phase.done")
            }
        }
    }
    @Published var currentPhase: ScanPhase = .idle
    private let scanMenuUseCase: ScanMenuUseCase
    private let usageManager = UsageLimitManager.shared
    private let storeService = StoreKitService.shared
    init(scanMenuUseCase: ScanMenuUseCase) {
        self.scanMenuUseCase = scanMenuUseCase
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
    var scanSucceeded: Bool {
        currentPhase == .done && !dishes.isEmpty
    }
    func checkAndRequestScan() -> Bool {
        if canScan {
            return true
        } else {
            showPaywall = true
            requestReviewIfNeeded()
            return false
        }
    }
    private func requestReviewIfNeeded() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    func processImage(_ image: UIImage) async {
        guard !isLoading else { return }
        guard checkAndRequestScan() else { return }
        isLoading = true
        isAnalyzing = true
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
            scannedText = scan.rawText
            dishes = scan.dishes
            currentPhase = .done
            showResults = true
        } catch {
            errorMessage = error.localizedDescription
            currentPhase = .idle
        }
        isLoading = false
        isAnalyzing = false
    }
    func analyzeManualText() async {
        guard !manualMenuText.isEmpty else {
            errorMessage = String(localized: "error.empty_text")
            return
        }
        guard checkAndRequestScan() else { return }
        isLoading = true
        isAnalyzing = true
        errorMessage = nil
        currentPhase = .analyzing
        do {
            let scan = try await scanMenuUseCase.estimateFromText(
                manualMenuText,
                restaurantName: selectedRestaurant?.name ?? restaurantName,
                restaurant: selectedRestaurant
            )
            usageManager.recordScan()
            scannedText = scan.rawText
            dishes = scan.dishes
            currentPhase = .done
            showResults = true
        } catch {
            errorMessage = error.localizedDescription
            currentPhase = .idle
        }
        isLoading = false
        isAnalyzing = false
    }
    func selectRestaurant(_ restaurant: Restaurant?) {
        selectedRestaurant = restaurant
        if let restaurant = restaurant {
            restaurantName = restaurant.name
        }
    }
    func resetScan() {
        scannedText = ""
        dishes = []
        errorMessage = nil
        showResults = false
        currentPhase = .idle
        manualMenuText = ""
        restaurantName = ""
        selectedRestaurant = nil
    }
}
