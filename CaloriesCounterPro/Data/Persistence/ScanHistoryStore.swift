import Foundation
import SwiftData

final class ScanHistoryStore: ScanHistoryRepository {

    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }

    func saveScan(_ scan: MenuScan) async throws {
        modelContext.insert(scan)
        try modelContext.save()
    }

    func fetchAllScans() async throws -> [MenuScan] {
        let descriptor = FetchDescriptor<MenuScan>(
            sortBy: [SortDescriptor(\.scanDate, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func deleteScan(_ scan: MenuScan) async throws {
        modelContext.delete(scan)
        try modelContext.save()
    }

    func migrateOrphanScans() async throws {
        let descriptor = FetchDescriptor<MenuScan>(
            predicate: #Predicate<MenuScan> { scan in
                scan.restaurant == nil && !scan.restaurantName.isEmpty
            }
        )

        let orphanScans = try modelContext.fetch(descriptor)

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

            let existingRestaurant = try modelContext.fetch(searchDescriptor).first

            let restaurant: Restaurant
            if let existing = existingRestaurant {
                restaurant = existing
            } else {
                restaurant = Restaurant(name: restaurantName)
                modelContext.insert(restaurant)
            }

            for scan in scans {
                scan.restaurant = restaurant
            }
        }

        try modelContext.save()
    }
}
