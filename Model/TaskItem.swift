import Foundation
import SwiftUI

enum WeekDay: String, Codable, CaseIterable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    var shortName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }
    
    var weekdayNumber: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
}

struct TaskItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var createdAt: Date
    var weekDays: Set<WeekDay>
    var completedDays: Set<WeekDay>
    var flaggedDays: Set<WeekDay>
    var streak: Int
    var notificationEnabled: Bool
    var notificationTimes: [Int] // minutes after the day starts
    
    init(id: UUID = UUID(), title: String, createdAt: Date = Date(), weekDays: Set<WeekDay> = [], completedDays: Set<WeekDay> = [], flaggedDays: Set<WeekDay> = [], streak: Int = 0, notificationEnabled: Bool = true, notificationTimes: [Int] = [540, 780, 1020, 1260]) { // 9:00, 13:00, 17:00, 21:00
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.weekDays = weekDays
        self.completedDays = completedDays
        self.flaggedDays = flaggedDays
        self.streak = streak
        self.notificationEnabled = notificationEnabled
        self.notificationTimes = notificationTimes.sorted() // Ensure times are sorted
    }
    
    var streakEmoji: String {
        switch streak {
        case 1...2: return "🌱"
        case 3...6: return "🌿" 
        case 7: return "🌳"
        default: return "🌱"
        }
    }
    
    func isCompleted(for day: WeekDay) -> Bool {
        completedDays.contains(day)
    }
    
    func isFlagged(for day: WeekDay) -> Bool {
        flaggedDays.contains(day)
    }
} 