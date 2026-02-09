import Foundation

protocol RestaurantRepository {
    func saveRestaurant(_ restaurant: Restaurant) async throws
    func getAllRestaurants() async throws -> [Restaurant]
    func findRestaurant(byName name: String) async throws -> Restaurant?
    func findOrCreateRestaurant(name: String) async throws -> Restaurant
    func deleteRestaurant(_ restaurant: Restaurant) async throws
}
