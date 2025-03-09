import SwiftUI
import StoreKit

class PremiumManager: ObservableObject {
    static let shared = PremiumManager()
    
    @Published var isPremium = false
    @Published var showPremiumPrompt = false
    
    private let userDefaults = UserDefaults.standard
    private let premiumKey = "isPremium"
    
    init() {
        isPremium = userDefaults.bool(forKey: premiumKey)
    }
    
    func unlockPremium() {
        isPremium = true
        userDefaults.set(true, forKey: premiumKey)
    }
    
    func canAddMoreTasks(currentCount: Int) -> Bool {
        if isPremium { return true }
        return currentCount < FeatureFlags.maxTasksInFree
    }
    
    func canAddMoreNotificationTimes(currentCount: Int) -> Bool {
        if isPremium { return true }
        return currentCount < FeatureFlags.maxNotificationTimesInFree
    }
    
    func showPremiumFeaturePrompt() {
        showPremiumPrompt = true
    }
} 