import Foundation

enum PetType: String, Codable, CaseIterable {
    case cat = "Kedi"
    case dog = "Köpek"
    case rabbit = "Tavşan"
    case hamster = "Hamster"
    case bird = "Kuş"
    case fish = "Balık"
    case turtle = "Kaplumbağa"
    case unicorn = "Unicorn"
    case dragon = "Ejderha"
    
    var emoji: String {
        switch self {
        case .cat: return "🐱"
        case .dog: return "🐶"
        case .rabbit: return "🐰"
        case .hamster: return "🐹"
        case .bird: return "🦜"
        case .fish: return "🐠"
        case .turtle: return "🐢"
        case .unicorn: return "🦄"
        case .dragon: return "🐲"
        }
    }
    
    var rarity: PetRarity {
        switch self {
        case .cat, .dog, .rabbit, .hamster:
            return .common
        case .bird, .fish, .turtle:
            return .rare
        case .unicorn, .dragon:
            return .legendary
        }
    }
}

enum PetRarity: String, Codable {
    case common = "Yaygın"
    case rare = "Nadir"
    case legendary = "Efsanevi"
}

struct Pet: Identifiable, Codable {
    let id: UUID
    let type: PetType
    var name: String
    var level: Int
    var experience: Int
    var happiness: Int
    var isAnimating: Bool = false
    
    init(id: UUID = UUID(), type: PetType, name: String, level: Int = 1, experience: Int = 0, happiness: Int = 100) {
        self.id = id
        self.type = type
        self.name = name
        self.level = level
        self.experience = experience
        self.happiness = happiness
        self.isAnimating = false
    }
    
    var displayName: String {
        "\(name) the \(type.rawValue)"
    }
    
    var rarityBadge: String {
        switch type.rarity {
        case .common:
            return "⭐️"
        case .rare:
            return "⭐️⭐️"
        case .legendary:
            return "⭐️⭐️⭐️"
        }
    }
    
    var happinessEmoji: String {
        switch happiness {
        case 80...100:
            return "😊"
        case 60..<80:
            return "🙂"
        case 40..<60:
            return "😐"
        case 20..<40:
            return "☹️"
        default:
            return "😢"
        }
    }
    
    mutating func addExperience(_ amount: Int) {
        experience += amount
        while experience >= experienceNeededForNextLevel {
            levelUp()
        }
    }
    
    mutating func updateHappiness(_ amount: Int) {
        happiness = max(0, min(100, happiness + amount))
    }
    
    private mutating func levelUp() {
        level += 1
        experience -= experienceNeededForNextLevel
    }
    
    var experienceNeededForNextLevel: Int {
        return level * 100
    }
} 

