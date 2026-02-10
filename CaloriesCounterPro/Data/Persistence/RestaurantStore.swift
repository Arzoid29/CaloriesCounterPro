import Foundation
import SwiftData

final class RestaurantStore: RestaurantRepository {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    @MainActor
    func saveRestaurant(_ restaurant: Restaurant) async throws {
        modelContainer.mainContext.insert(restaurant)
        try modelContainer.mainContext.save()
    }

    @MainActor
    func getAllRestaurants() async throws -> [Restaurant] {
        let descriptor = FetchDescriptor<Restaurant>(
            sortBy: [SortDescriptor(\Restaurant.name, order: .forward)]
        )
        return try modelContainer.mainContext.fetch(descriptor)
    }

    @MainActor
    func findRestaurant(byName name: String) async throws -> Restaurant? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptor = FetchDescriptor<Restaurant>(
            predicate: #Predicate<Restaurant> { restaurant in
                restaurant.name == trimmedName
            }
        )
        return try modelContainer.mainContext.fetch(descriptor).first
    }

    @MainActor
    func findOrCreateRestaurant(name: String) async throws -> Restaurant {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let existing = try await findRestaurant(byName: trimmedName) {
            return existing
        }
        let newRestaurant = Restaurant(name: trimmedName)
        modelContainer.mainContext.insert(newRestaurant)
        try modelContainer.mainContext.save()
        return newRestaurant
    }

    @MainActor
    func deleteRestaurant(_ restaurant: Restaurant) async throws {
        modelContainer.mainContext.delete(restaurant)
        try modelContainer.mainContext.save()
    }
}
