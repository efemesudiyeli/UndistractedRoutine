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
}

struct TaskItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var createdAt: Date
    var weekDays: Set<WeekDay>
    var completedDays: Set<WeekDay>
    var flaggedDays: Set<WeekDay>
    var reminderTime: Date?
    var streak: Int // Number of consecutive completions
    
    init(id: UUID = UUID(), 
         title: String,
         createdAt: Date = Date(),
         weekDays: Set<WeekDay> = [],
         completedDays: Set<WeekDay> = [],
         flaggedDays: Set<WeekDay> = [],
         reminderTime: Date? = nil,
         streak: Int = 0) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.weekDays = weekDays
        self.completedDays = completedDays
        self.flaggedDays = flaggedDays
        self.reminderTime = reminderTime
        self.streak = streak
    }
    
    func isCompleted(for day: WeekDay) -> Bool {
        completedDays.contains(day)
    }
    
    func isFlagged(for day: WeekDay) -> Bool {
        flaggedDays.contains(day)
    }
    
    var streakEmoji: String {
        switch streak {
        case 1: return "🌱"
        case 2...4: return "🌿"
        case 5...7: return "🌳"
        default: return "��"
        }
    }
} 