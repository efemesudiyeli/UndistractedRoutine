import UIKit
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Bildirim merkezini ayarla
        UNUserNotificationCenter.current().delegate = self
        
        // Bildirim kategorilerini ayarla
        let completeAction = UNNotificationAction(identifier: "COMPLETE_TASK", title: "Complete Task", options: .foreground)
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE_TASK", title: "Snooze 5 min", options: .foreground)
        
        // Önemli görevler için kritik kategori
        let importantCategory = UNNotificationCategory(
            identifier: "IMPORTANT_TASK",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        // Normal görevler için varsayılan kategori
        let regularCategory = UNNotificationCategory(
            identifier: "REGULAR_TASK",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([importantCategory, regularCategory])
        
        // Bildirim izinlerini kontrol et
        checkNotificationSettings()
        
        return true
    }
    
    private func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("📱 Notification Settings:")
            print("Authorization Status: \(settings.authorizationStatus.rawValue)")
            print("Sound Setting: \(settings.soundSetting.rawValue)")
            print("Badge Setting: \(settings.badgeSetting.rawValue)")
            print("Alert Setting: \(settings.alertSetting.rawValue)")
            print("Notification Center Setting: \(settings.notificationCenterSetting.rawValue)")
            print("Lock Screen Setting: \(settings.lockScreenSetting.rawValue)")
            print("Car Play Setting: \(settings.carPlaySetting.rawValue)")
            print("Critical Alert Setting: \(settings.criticalAlertSetting.rawValue)")
            
            if settings.authorizationStatus != .authorized {
                self.requestNotificationPermission()
            }
        }
    }
    
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            } else {
                print("❌ Notification permission denied")
            }
        }
    }
    
    // Uzaktan bildirim kaydı başarılı olduğunda
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("✅ Remote notification registration successful")
    }
    
    // Uzaktan bildirim kaydı başarısız olduğunda
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Remote notification registration failed: \(error.localizedDescription)")
    }
    
    // Bildirim geldiğinde uygulama ön plandaysa
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("📱 Notification received while app is in foreground")
        let content = notification.request.content
        
        if content.categoryIdentifier == "IMPORTANT_TASK" {
            completionHandler([.banner, .sound, .badge, .list])
        } else {
            completionHandler([.banner, .sound, .badge])
        }
    }
    
    // Bildirime tıklandığında
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("👆 Notification tapped")
        print("Action Identifier: \(response.actionIdentifier)")
        print("Category Identifier: \(response.notification.request.content.categoryIdentifier)")
        
        if response.actionIdentifier == "COMPLETE_TASK" {
            // Görevi tamamla
            if let taskId = response.notification.request.identifier.split(separator: "_").first {
                print("Completing task: \(taskId)")
                // TaskViewModel'de görevi tamamla
            }
        } else if response.actionIdentifier == "SNOOZE_TASK" {
            // Görevi 5 dakika ertele
            if let taskId = response.notification.request.identifier.split(separator: "_").first {
                print("Snoozing task: \(taskId)")
                // TaskViewModel'de görevi ertele
            }
        }
        
        completionHandler()
    }
    
    // Uygulama arka plandan ön plana geldiğinde
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("Uygulama ön plana geldi")
        // Bildirimleri yeniden planla
        if let viewModel = TaskViewModel.shared {
            viewModel.rescheduleAllNotifications()
        }
    }
} 