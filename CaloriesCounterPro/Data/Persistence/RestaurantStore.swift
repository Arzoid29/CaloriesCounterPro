import Foundation
import SwiftData

final class RestaurantStore: RestaurantRepository {

    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }

    func saveRestaurant(_ restaurant: Restaurant) async throws {
        modelContext.insert(restaurant)
        try modelContext.save()
    }

    func fetchAllRestaurants() async throws -> [Restaurant] {
        let descriptor = FetchDescriptor<Restaurant>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    func findRestaurant(byName name: String) async throws -> Restaurant? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptor = FetchDescriptor<Restaurant>(
            predicate: #Predicate<Restaurant> { restaurant in
                restaurant.name == trimmedName
            }
        )
        return try modelContext.fetch(descriptor).first
    }

    func findOrCreateRestaurant(name: String) async throws -> Restaurant {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let existing = try await findRestaurant(byName: trimmedName) {
            return existing
        }
        let newRestaurant = Restaurant(name: trimmedName)
        modelContext.insert(newRestaurant)
        try modelContext.save()
        return newRestaurant
    }

    func deleteRestaurant(_ restaurant: Restaurant) async throws {
        modelContext.delete(restaurant)
        try modelContext.save()
    }
}
