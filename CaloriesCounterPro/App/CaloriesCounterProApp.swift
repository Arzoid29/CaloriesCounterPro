import SwiftUI
import SwiftData

@main
struct CaloriesCounterProApp: App {

    @AppStorage("hasRunRestaurantMigration") private var hasMigrated = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    let container: ModelContainer

    init() {
        container = ModelContainerProvider.shared.container
    }

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
        .modelContainer(container)
    }

    private func migrateOrphanScans() async {
        let store = ScanHistoryStore(modelContainer: container)
        do {
            try await store.migrateOrphanScans()
        } catch {
            print("Error migrating orphan scans: \(error)")
        }
    }
}
