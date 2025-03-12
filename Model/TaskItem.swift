import Foundation
import SwiftUI

enum WeekDay: String, Codable, CaseIterable, Hashable {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    
    var displayName: String {
        switch self {
        case .sunday: return "Pazar"
        case .monday: return "Pazartesi"
        case .tuesday: return "Salı"
        case .wednesday: return "Çarşamba"
        case .thursday: return "Perşembe"
        case .friday: return "Cuma"
        case .saturday: return "Cumartesi"
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

struct TaskItem: Identifiable, Codable, Equatable {
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
    
    static func == (lhs: TaskItem, rhs: TaskItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.createdAt == rhs.createdAt &&
        lhs.weekDays == rhs.weekDays &&
        lhs.completedDays == rhs.completedDays &&
        lhs.flaggedDays == rhs.flaggedDays &&
        lhs.streak == rhs.streak &&
        lhs.notificationEnabled == rhs.notificationEnabled &&
        lhs.notificationTimes == rhs.notificationTimes
    }
    
    var streakEmoji: String {
        switch streak {
        case 0: return ""
        case 1...2: return "🔥 1"
        case 3...4: return "🔥 \(streak)"
        case 5...6: return "🔥🔥 \(streak)"
        case 7...13: return "🔥🔥 \(streak) 🎯"
        case 14...20: return "🔥🔥🔥 \(streak) 🎯"
        case 21...29: return "🔥🔥🔥 \(streak) 🎯 💪"
        case 30...59: return "🏆 \(streak) 🔥"
        case 60...89: return "👑 \(streak) 🔥🔥"
        case 90...119: return "⭐️ \(streak) 🔥🔥🔥"
        default: return "🌟 \(streak) 🔥🔥🔥 👑"
        }
    }
    
    var streakDescription: String {
        switch streak {
        case 0: return "Henüz streak yok"
        case 1...2: return "Harika başlangıç!"
        case 3...4: return "İyi gidiyorsun!"
        case 5...6: return "Muhteşem ilerleme!"
        case 7...13: return "Bir haftayı devirdin!"
        case 14...20: return "İki haftayı aştın!"
        case 21...29: return "Üç haftayı geçtin!"
        case 30...59: return "Bir ay oldu!"
        case 60...89: return "İki ay! İnanılmaz!"
        case 90...119: return "Üç ay! Efsane!"
        default: return "Artık bir efsanesin!"
        }
    }
    
    func isCompleted(for day: WeekDay) -> Bool {
        completedDays.contains(day)
    }
    
    func isFlagged(for day: WeekDay) -> Bool {
        flaggedDays.contains(day)
    }
} 