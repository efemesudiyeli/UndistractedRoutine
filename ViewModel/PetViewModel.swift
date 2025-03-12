import Foundation
import SwiftUI

class PetViewModel: ObservableObject {
    @Published var pets: [Pet] = [] {
        didSet {
            savePets()
        }
    }
    
    private let petsKey = "savedPets"
    private let lastWeekCheckKey = "lastWeekCheck"
    private let weeklyTaskCompletionKey = "weeklyTaskCompletion"
    
    init() {
        loadPets()
    }
    
    private func loadPets() {
        if let data = UserDefaults.standard.data(forKey: petsKey) {
            if let decoded = try? JSONDecoder().decode([Pet].self, from: data) {
                self.pets = decoded
            }
        }
    }
    
    private func savePets() {
        if let encoded = try? JSONEncoder().encode(pets) {
            UserDefaults.standard.set(encoded, forKey: petsKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    // Haftalık görev tamamlama durumunu kontrol et
    func checkWeeklyProgress(taskViewModel: TaskViewModel) {
        let calendar = Calendar.current
        let now = Date()
        
        // Son kontrolün yapıldığı haftayı kontrol et
        if let lastCheck = UserDefaults.standard.object(forKey: lastWeekCheckKey) as? Date {
            // Eğer aynı haftadaysak, kontrol etme
            if calendar.isDate(lastCheck, equalTo: now, toGranularity: .weekOfYear) {
                return
            }
        }
        
        // Haftalık görev tamamlama oranını hesapla
        var totalTasks = 0
        var completedTasks = 0
        
        for day in WeekDay.allCases {
            let tasks = taskViewModel.tasksForDay(day)
            totalTasks += tasks.count
            completedTasks += tasks.filter { $0.isCompleted(for: day) }.count
        }
        
        if totalTasks > 0 {
            let completionRate = Double(completedTasks) / Double(totalTasks)
            
            // Eğer tamamlama oranı %80'den yüksekse yeni pet kazanma şansı
            if completionRate >= 0.8 {
                tryToGetNewPet()
            }
            
            // Mevcut petlere deneyim puanı ver
            let experienceGained = Int(completionRate * 100)
            DispatchQueue.main.async {
                for index in self.pets.indices {
                    self.pets[index].addExperience(experienceGained)
                    // Tamamlama oranına göre mutluluk güncelle
                    let happinessChange = Int((completionRate - 0.5) * 20)
                    self.pets[index].updateHappiness(happinessChange)
                }
                self.objectWillChange.send()
            }
        }
        
        // Son kontrol tarihini güncelle
        UserDefaults.standard.set(now, forKey: lastWeekCheckKey)
        UserDefaults.standard.synchronize()
    }
    
    private func tryToGetNewPet() {
        DispatchQueue.main.async {
            // Nadir pet kazanma şansları
            let random = Double.random(in: 0...1)
            let selectedType: PetType
            
            switch random {
            case 0...0.5: // 50% şans - Yaygın
                selectedType = [.cat, .dog, .rabbit, .hamster].randomElement()!
            case 0.5...0.8: // 30% şans - Nadir
                selectedType = [.bird, .fish, .turtle].randomElement()!
            default: // 20% şans - Efsanevi
                selectedType = [.unicorn, .dragon].randomElement()!
            }
            
            // Yeni pet oluştur
            let newPet = Pet(type: selectedType, name: "New \(selectedType.rawValue)")
            self.pets.append(newPet)
            self.objectWillChange.send()
        }
    }
    
    // Pet'in seviyesine göre animasyon boyutu
    func petScale(for pet: Pet) -> CGFloat {
        let baseScale: CGFloat = 1.0
        let levelBonus = CGFloat(pet.level) * 0.05 // Her seviye için %5 büyüme
        return baseScale + min(levelBonus, 0.5) // Maximum %50 büyüme
    }
    
    // TEST FONKSİYONLARI
    #if DEBUG
    func addTestPet(type: PetType? = nil) {
        let petType = type ?? PetType.allCases.randomElement()!
        let newPet = Pet(type: petType, name: "Test \(petType.rawValue)")
        withAnimation {
            pets.append(newPet)
        }
    }
    
    func addAllPetTypes() {
        withAnimation {
            for type in PetType.allCases {
                let newPet = Pet(type: type, name: "Test \(type.rawValue)")
                pets.append(newPet)
            }
        }
    }
    
    func levelUpAllPets() {
        withAnimation {
            for index in pets.indices {
                var updatedPet = pets[index]
                updatedPet.addExperience(100)
                pets[index] = updatedPet
            }
        }
    }
    
    func updateAllPetsHappiness(_ amount: Int) {
        withAnimation {
            for index in pets.indices {
                var updatedPet = pets[index]
                updatedPet.updateHappiness(amount)
                pets[index] = updatedPet
            }
        }
    }
    
    func removeAllPets() {
        withAnimation {
            pets.removeAll()
        }
    }
    #endif
} 