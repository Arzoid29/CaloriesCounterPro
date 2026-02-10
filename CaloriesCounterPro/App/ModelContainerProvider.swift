import Foundation
import SwiftData

final class ModelContainerProvider {

    static let shared = ModelContainerProvider()

    let container: ModelContainer

    private init() {
        let schema = Schema([Restaurant.self, MenuScan.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            // Schema migration failed — delete old store and retry
            Self.deleteExistingStore()
            do {
                container = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
            } catch {
                fatalError("No se pudo crear el ModelContainer: \(error)")
            }
        }
    }

    /// Deletes the existing SwiftData store files when schema migration fails.
    private static func deleteExistingStore() {
        let fileManager = FileManager.default
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return }

        let storePath = appSupport.appendingPathComponent("default.store").path
        let suffixes = ["", "-wal", "-shm"]

        for suffix in suffixes {
            let fullPath = storePath + suffix
            if fileManager.fileExists(atPath: fullPath) {
                try? fileManager.removeItem(atPath: fullPath)
            }
        }
    }
}
