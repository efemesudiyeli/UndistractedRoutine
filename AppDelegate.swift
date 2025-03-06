import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Uygulama başlatıldı")
        
        // Bildirim merkezinin delegate'ini ayarla
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // Bildirim geldiğinde uygulama ön planda ise
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Uygulama ön plandayken bildirimleri göster
        completionHandler([.banner, .sound, .badge])
    }
    
    // Kullanıcı bildirime tıkladığında
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Bildirime tıklandığında yapılacak işlemler
        completionHandler()
    }
} 