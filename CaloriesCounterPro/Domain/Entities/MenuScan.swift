import Foundation

struct MenuScan: Codable, Identifiable {
    let id: UUID
    let restaurantName: String
    let rawText: String
    let dishes: [Dish]
    let restaurant: Restaurant?
    let date: Date
}
