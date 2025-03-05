import Foundation

enum WeekDay: String, Codable, CaseIterable {
    case monday = "Pazartesi"
    case tuesday = "Salı"
    case wednesday = "Çarşamba"
    case thursday = "Perşembe"
    case friday = "Cuma"
    case saturday = "Cumartesi"
    case sunday = "Pazar"
    
    var shortName: String {
        switch self {
        case .monday: return "Pzt"
        case .tuesday: return "Sal"
        case .wednesday: return "Çar"
        case .thursday: return "Per"
        case .friday: return "Cum"
        case .saturday: return "Cmt"
        case .sunday: return "Paz"
        }
    }
    
    func hasTasks(in tasks: [TaskItem]) -> Bool {
        tasks.contains { $0.weekDays.contains(self) }
    }
}

struct TaskItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isFlagged: Bool
    var createdAt: Date
    var weekDays: Set<WeekDay>
    var completedDays: Set<WeekDay>
    
    init(id: UUID = UUID(), 
         title: String, 
         isFlagged: Bool = false, 
         createdAt: Date = Date(),
         weekDays: Set<WeekDay> = [],
         completedDays: Set<WeekDay> = []) {
        self.id = id
        self.title = title
        self.isFlagged = isFlagged
        self.createdAt = createdAt
        self.weekDays = weekDays
        self.completedDays = completedDays
    }
    
    func isCompleted(for day: WeekDay) -> Bool {
        completedDays.contains(day)
    }
} 