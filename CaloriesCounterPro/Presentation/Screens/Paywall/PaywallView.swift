import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeService = StoreKitService.shared
    @ObservedObject private var usageManager = UsageLimitManager.shared
    
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingXL) {
                    headerSection
                    
                    featuresSection
                    
                    pricingSection
                    
                    purchaseButton
                    
                    footerSection
                }
                .padding()
            }
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.textTertiary)
                            .font(.title2)
                    }
                }
            }
            .alert(String(localized: "store.error.title"), isPresented: $showError) {
                Button(String(localized: "common.ok"), role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: Theme.spacingL) {
            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Circle()
                    .fill(Theme.accent.opacity(0.08))
                    .frame(width: 130, height: 130)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Theme.accentGradient)
            }
            
            VStack(spacing: Theme.spacingS) {
                Text(String(localized: "paywall.title"))
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                Text(String(localized: "paywall.subtitle"))
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: Theme.spacingS) {
                Image(systemName: "clock.fill")
                    .foregroundStyle(Theme.accent)
                
                Text(String(format: NSLocalizedString("paywall.reset_time", comment: ""), usageManager.formattedTimeUntilReset()))
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(.horizontal, Theme.spacingM)
            .padding(.vertical, Theme.spacingS)
            .background(Theme.accentBackground)
            .clipShape(Capsule())
        }
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            HStack(spacing: 12) {
                Image(systemName: "fork.knife")
                    .foregroundColor(.accentColor)
                Text(String(localized: "paywall.feature_unlimited_scans"))
            }
            HStack(spacing: 12) {
                Image(systemName: "chart.bar.doc.horizontal")
                    .foregroundColor(.accentColor)
                Text(String(localized: "paywall.feature_history"))
            }
            HStack(spacing: 12) {
                Image(systemName: "lock.shield")
                    .foregroundColor(.accentColor)
                Text(String(localized: "paywall.feature_privacy"))
            }
        }
        .font(.body)
        .padding(.vertical, Theme.spacingM)
    }
    
    private var pricingSection: some View {
        VStack(spacing: Theme.spacingS) {
            if let product = storeService.products.first {
                Text(product.displayPrice)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(Theme.accent)
                
                Text(String(localized: "paywall.per_month"))
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                Text("$11.99")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(Theme.accent)
                
                Text(String(localized: "paywall.per_month"))
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }
    
    private var purchaseButton: some View {
        Button {
            Task { await purchase() }
        } label: {
            HStack {
                if isPurchasing || storeService.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "crown.fill")
                    Text(String(localized: "paywall.subscribe"))
                        .fontWeight(.semibold)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.accentGradient)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
            .shadow(color: Theme.accent.opacity(0.3), radius: 8, y: 4)
        }
        .disabled(isPurchasing || storeService.isLoading || storeService.products.isEmpty)
    }
    
    private var footerSection: some View {
        VStack(spacing: Theme.spacingM) {
            Button {
                Task { await storeService.restorePurchases() }
            } label: {
                Text(String(localized: "paywall.restore"))
                    .font(.subheadline)
                    .foregroundStyle(Theme.accent)
            }
            
            Text(String(localized: "paywall.terms"))
                .font(.caption2)
                .foregroundStyle(Theme.textTertiary)
                .multilineTextAlignment(.center)
        }
    }
    
    private func purchase() async {
        guard let product = storeService.products.first else { return }
        
        isPurchasing = true
        
        do {
            let transaction = try await storeService.purchase(product)
            
            if transaction != nil {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isPurchasing = false
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: Theme.spacingM) {
            ZStack {
                Circle()
                    .fill(Theme.accentBackground)
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundStyle(Theme.accent)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }
}

#Preview {
    PaywallView()
}
