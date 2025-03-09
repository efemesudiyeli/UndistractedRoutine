import Foundation

struct FeatureFlags {
    // Ücretsiz Sürüm Limitleri
    static let maxTasksInFree = 7
    static let maxNotificationTimesInFree = 2
    
    // Premium Özellikler
    static let customThemesArePremium = true
    static let advancedStatisticsArePremium = true
    static let dataExportIsPremium = true
    static let customCategoriesArePremium = true
} 