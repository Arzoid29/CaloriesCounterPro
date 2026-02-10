import Foundation
import SwiftData

@Model
final class Restaurant {
    @Attribute(.unique) var id: UUID
    var name: String
    var address: String
    var notes: String
    var dateAdded: Date

    @Relationship(deleteRule: .cascade, inverse: \MenuScan.restaurant)
    var scans: [MenuScan]

    var scanCount: Int {
        scans.count
    }

    var totalCalories: Int {
        scans.reduce(0) { $0 + $1.totalCalories }
    }

    var lastScanDate: Date? {
        scans.map(\.date).max()
    }

    init(
        id: UUID = UUID(),
        name: String,
        address: String = "",
        notes: String = "",
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.notes = notes
        self.dateAdded = dateAdded
        self.scans = []
    }
}
