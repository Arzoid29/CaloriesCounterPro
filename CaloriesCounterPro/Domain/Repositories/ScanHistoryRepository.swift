import Foundation

protocol ScanHistoryRepository {
    func saveScan(_ scan: MenuScan) async throws
    func getAllScans() async throws -> [MenuScan]
    func deleteScan(_ scan: MenuScan) async throws
}
