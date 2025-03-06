import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func rescheduleAllNotifications() {
        // Önce tüm bekleyen bildirimleri temizle
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // TaskViewModel'den tüm görevleri al ve bildirimlerini yeniden planla
        if let viewModel = TaskViewModel.shared {
            for task in viewModel.tasks {
                for weekday in task.weekDays {
                    viewModel.scheduleNotification(for: task, on: weekday)
                }
            }
        }
    }
    
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification"
        content.sound = .default
        
        // 30 saniye sonra test bildirimi gönder
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Test notification error: \(error)")
            } else {
                print("Test notification scheduled successfully")
            }
        }
    }
} 