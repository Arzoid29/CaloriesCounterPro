import Foundation

protocol CalorieEstimationRepository {
    func estimateCalories(from menuText: String) async throws -> [Dish]
}
