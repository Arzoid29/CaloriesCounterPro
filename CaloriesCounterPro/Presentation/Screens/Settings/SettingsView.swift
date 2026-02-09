import SwiftUI

struct SettingsView: View {
    @ObservedObject private var storeService = StoreKitService.shared
    @ObservedObject private var usageManager = UsageLimitManager.shared
    
    @State private var showPaywall = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    subscriptionStatusRow
                }
                
                if !storeService.isSubscribed {
                    Section(String(localized: "settings.usage_section")) {
                        usageStatsRow
                    }
                }
                
                Section(String(localized: "settings.about_section")) {
                    LabeledContent(String(localized: "settings.version")) {
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    }
                    NavigationLink {
                        PrivacyView()
                    } label: {
                        Label(String(localized: "settings.privacy"), systemImage: "hand.raised.fill")
                    }
                    NavigationLink {
                        TermsView()
                    } label: {
                        Label(String(localized: "settings.terms"), systemImage: "doc.text.fill")
                    }
                }
                
                Section {
                    Button {
                        Task { await storeService.restorePurchases() }
                    } label: {
                        HStack {
                            Label(String(localized: "settings.restore"), systemImage: "arrow.clockwise")
                            Spacer()
                            if storeService.isLoading {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(storeService.isLoading)
                }
            }
            .navigationTitle(String(localized: "settings.title"))
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .task {
            await storeService.loadProducts()
            await storeService.updateSubscriptionStatus()
        }
    }
    
    private var subscriptionStatusRow: some View {
        Button {
            if !storeService.isSubscribed {
                showPaywall = true
            }
        } label: {
            HStack(spacing: Theme.spacingM) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusTiny)
                        .fill(storeService.isSubscribed ? Color.yellow.opacity(0.2) : Theme.accentBackground)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: storeService.isSubscribed ? "crown.fill" : "sparkles")
                        .font(.title3)
                        .foregroundStyle(storeService.isSubscribed ? .yellow : Theme.accent)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(storeService.isSubscribed ? String(localized: "settings.premium_active") : String(localized: "settings.premium_inactive"))
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Text(storeService.isSubscribed ? String(localized: "settings.premium_desc_active") : String(localized: "settings.premium_desc_inactive"))
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                
                Spacer()
                
                if !storeService.isSubscribed {
                    Text(String(localized: "settings.upgrade"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, Theme.spacingM)
                        .padding(.vertical, Theme.spacingS)
                        .background(Theme.accentGradient)
                        .clipShape(Capsule())
                }
            }
            .padding(.vertical, Theme.spacingXS)
        }
    }
    
    private var usageStatsRow: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            HStack {
                Text(String(localized: "settings.free_scans"))
                    .font(.subheadline)
                Spacer()
                Text("\(usageManager.remainingFreeScans()) / \(UsageLimitManager.freeScansPerDay)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(usageManager.canScanForFree ? Theme.accent : .red)
            }
            
            ProgressView(value: Double(UsageLimitManager.freeScansPerDay - usageManager.remainingFreeScans()), total: Double(UsageLimitManager.freeScansPerDay))
                .tint(usageManager.canScanForFree ? Theme.accent : .red)
            
            if !usageManager.canScanForFree {
                Text(String(format: NSLocalizedString("settings.reset_time", comment: ""), usageManager.formattedTimeUntilReset()))
                    .font(.caption)
                    .foregroundStyle(Theme.textTertiary)
            }
        }
    }
}

#Preview {
    SettingsView()
}
