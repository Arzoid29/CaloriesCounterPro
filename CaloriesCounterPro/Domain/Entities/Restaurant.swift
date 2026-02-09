import Foundation

struct Restaurant: Codable, Identifiable {
    let id: UUID
    let name: String
    let address: String?
    let notes: String?
    let scanCount: Int
    let totalCalories: Int
    let lastScanDate: Date?
    let scans: [MenuScan]
}
