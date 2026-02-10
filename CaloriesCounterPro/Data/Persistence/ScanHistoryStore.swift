import Foundation
import SwiftData

final class ScanHistoryStore: ScanHistoryRepository {

    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    @MainActor
    func saveScan(_ scan: MenuScan) async throws {
        modelContainer.mainContext.insert(scan)
        try modelContainer.mainContext.save()
    }

    @MainActor
    func getAllScans() async throws -> [MenuScan] {
        let descriptor = FetchDescriptor<MenuScan>(
            sortBy: [SortDescriptor(\MenuScan.date, order: .reverse)]
        )
        return try modelContainer.mainContext.fetch(descriptor)
    }

    @MainActor
    func deleteScan(_ scan: MenuScan) async throws {
        modelContainer.mainContext.delete(scan)
        try modelContainer.mainContext.save()
    }

    @MainActor
    func migrateOrphanScans() async throws {
        let context = modelContainer.mainContext

        let descriptor = FetchDescriptor<MenuScan>(
            predicate: #Predicate<MenuScan> { scan in
                scan.restaurant == nil && !scan.restaurantName.isEmpty
            }
        )

        let orphanScans = try context.fetch(descriptor)
        guard !orphanScans.isEmpty else { return }

        let groupedByName = Dictionary(grouping: orphanScans) { scan in
            scan.restaurantName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }

        for (_, scans) in groupedByName {
            guard let firstScan = scans.first else { continue }
            let restaurantName = firstScan.restaurantName.trimmingCharacters(in: .whitespacesAndNewlines)

            let searchDescriptor = FetchDescriptor<Restaurant>(
                predicate: #Predicate<Restaurant> { restaurant in
                    restaurant.name == restaurantName
                }
            )

            let existingRestaurant = try context.fetch(searchDescriptor).first

            let restaurant: Restaurant
            if let existing = existingRestaurant {
                restaurant = existing
            } else {
                restaurant = Restaurant(name: restaurantName)
                context.insert(restaurant)
            }

            for scan in scans {
                scan.restaurant = restaurant
            }
        }

        try context.save()
    }
}
