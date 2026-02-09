import Foundation
import SwiftData

final class ModelContainerProvider {

    static let shared = ModelContainerProvider()

    let container: ModelContainer

    private init() {
        let schema = Schema([MenuScan.self, Restaurant.self])
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
