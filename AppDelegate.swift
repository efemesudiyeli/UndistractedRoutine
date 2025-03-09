import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Uygulama başlatıldı")
        
        // Bildirim merkezinin delegate'ini ayarla
        UNUserNotificationCenter.current().delegate = self
        
        // Bildirim izinlerini kontrol et
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Bildirim ayarları: \(settings)")
            if settings.authorizationStatus != .authorized {
                print("Bildirim izni yok, izin isteniyor...")
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        print("Bildirim izni verildi")
                        // İzin verildikten sonra bildirimleri yeniden planla
                        if let viewModel = TaskViewModel.shared {
                            viewModel.rescheduleAllNotifications()
                        }
                    } else if let error = error {
                        print("Bildirim izni hatası: \(error)")
                    } else {
                        print("Bildirim izni reddedildi")
                    }
                }
            } else {
                print("Bildirim izni zaten var")
                // İzin varsa bildirimleri yeniden planla
                if let viewModel = TaskViewModel.shared {
                    viewModel.rescheduleAllNotifications()
                }
            }
        }
        
        return true
    }
    
    // Bildirim geldiğinde uygulama ön planda ise
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Bildirim geldi (ön planda): \(notification.request.identifier)")
        // Uygulama ön plandayken bildirimleri göster
        completionHandler([.banner, .sound, .badge])
    }
    
    // Kullanıcı bildirime tıkladığında
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Bildirime tıklandı: \(response.notification.request.identifier)")
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