import Foundation
import Combine

final class UsageLimitManager: ObservableObject {
    
    static let shared = UsageLimitManager()
    
    static let freeScansPerDay = 1
    
    private enum Keys {
        static let lastScanDate = "lastFreeScanDate"
        static let dailyScanCount = "dailyFreeScanCount"
    }
    
    @Published private(set) var scansUsedToday: Int = 0
    @Published private(set) var canScanForFree: Bool = true
    
    private let defaults = UserDefaults.standard
    private let calendar = Calendar.current
    
    private init() {
        resetIfNewDay()
        loadUsage()
    }
    
    func canPerformScan(isSubscribed: Bool) -> Bool {
        if isSubscribed {
            return true
        }
        
        resetIfNewDay()
        return scansUsedToday < Self.freeScansPerDay
    }
    
    func recordScan() {
        resetIfNewDay()
        
        scansUsedToday += 1
        defaults.set(scansUsedToday, forKey: Keys.dailyScanCount)
        defaults.set(Date(), forKey: Keys.lastScanDate)
        
        updateCanScanForFree()
    }
    
    func remainingFreeScans() -> Int {
        resetIfNewDay()
        return max(0, Self.freeScansPerDay - scansUsedToday)
    }
    
    func timeUntilReset() -> TimeInterval {
        let now = Date()
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) else {
            return 0
        }
        return tomorrow.timeIntervalSince(now)
    }
    
    func formattedTimeUntilReset() -> String {
        let seconds = Int(timeUntilReset())
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return String(format: NSLocalizedString("usage.time_hours", comment: ""), hours, minutes)
        } else {
            return String(format: NSLocalizedString("usage.time_minutes", comment: ""), minutes)
        }
    }
    
    private func loadUsage() {
        scansUsedToday = defaults.integer(forKey: Keys.dailyScanCount)
        updateCanScanForFree()
    }
    
    private func resetIfNewDay() {
        guard let lastDate = defaults.object(forKey: Keys.lastScanDate) as? Date else {
            scansUsedToday = 0
            canScanForFree = true
            return
        }
        
        if !calendar.isDateInToday(lastDate) {
            scansUsedToday = 0
            defaults.set(0, forKey: Keys.dailyScanCount)
            updateCanScanForFree()
        }
    }
    
    private func updateCanScanForFree() {
        canScanForFree = scansUsedToday < Self.freeScansPerDay
    }
}
