import Foundation
import SwiftData

@Model
final class MenuScan {
    @Attribute(.unique) var id: UUID
    var restaurantName: String
    var rawText: String
    var dishes: [Dish]
    var restaurant: Restaurant?
    var date: Date
    var isFavorite: Bool

    var totalCalories: Int {
        dishes.reduce(0) { $0 + $1.estimatedCalories }
    }

    init(
        id: UUID = UUID(),
        restaurantName: String = "",
        rawText: String = "",
        dishes: [Dish] = [],
        restaurant: Restaurant? = nil,
        date: Date = Date(),
        isFavorite: Bool = false
    ) {
        self.id = id
        self.restaurantName = restaurantName
        self.rawText = rawText
        self.dishes = dishes
        self.restaurant = restaurant
        self.date = date
        self.isFavorite = isFavorite
    }
}
