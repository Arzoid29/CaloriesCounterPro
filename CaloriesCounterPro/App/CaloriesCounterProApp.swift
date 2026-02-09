import SwiftUI
import SwiftData

@main
struct CaloriesCounterProApp: App {

    @AppStorage("hasRunRestaurantMigration") private var hasMigrated = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                HomeView()
                    .tint(Theme.accent)
                    .task {
                        if !hasMigrated {
                            await migrateOrphanScans()
                            hasMigrated = true
                        }
                    }
            } else {
                OnboardingView()
            }
        }
        .modelContainer(for: [MenuScan.self, Restaurant.self])
    }

    private func migrateOrphanScans() async {
        do {
            let container = try ModelContainerProvider.shared.container
            let store = ScanHistoryStore(modelContainer: container)
            try await store.migrateOrphanScans()
        } catch {
            print("Error migrating orphan scans: \(error)")
        }
    }
}
