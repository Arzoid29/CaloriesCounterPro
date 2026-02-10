import Foundation
import StoreKit
import Combine

enum StoreProduct: String, CaseIterable {
    case unlimitedMonthly = "com.caloriesCounterPro.unlimited.monthly"

    var id: String { rawValue }
}

@MainActor
final class StoreKitService: ObservableObject {

    static let shared = StoreKitService()

    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isSubscribed = false

    private var updateListenerTask: Task<Void, Never>?

    private init() {
        updateListenerTask = listenForTransactions()
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let productIds = StoreProduct.allCases.map { $0.id }
            products = try await Product.products(for: productIds)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try Self.checkVerified(verification)
            await updateSubscriptionStatus()
            await transaction.finish()
            return transaction

        case .userCancelled, .pending:
            return nil

        @unknown default:
            return nil
        }
    }

    func restorePurchases() async {
        isLoading = true

        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func updateSubscriptionStatus() async {
        var hasActiveSubscription = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try Self.checkVerified(result)
                if transaction.productType == .autoRenewable {
                    hasActiveSubscription = true
                }
            } catch {
                // Skip unverified transactions
                continue
            }
        }

        isSubscribed = hasActiveSubscription
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                do {
                    let transaction = try Self.checkVerified(result)
                    await self?.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    // Transaction verification failed, still update status
                    await self?.updateSubscriptionStatus()
                }
            }
        }
    }

    nonisolated private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let item):
            return item
        }
    }
}

enum StoreError: LocalizedError {
    case failedVerification
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return String(localized: "store.error.verification")
        case .purchaseFailed:
            return String(localized: "store.error.purchase")
        }
    }
}
