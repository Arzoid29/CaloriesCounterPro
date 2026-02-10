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
            fatalError("No se pudo crear el ModelContainer: \(error)")
        }
    }
}
