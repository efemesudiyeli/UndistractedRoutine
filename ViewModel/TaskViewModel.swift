//
//  TaskViewModel.swift
//  UndistractedRoutine
//
//  Created by Efe Mesudiyeli on 5.03.2025.
//

import Foundation
import SwiftUI
import UserNotifications

class TaskViewModel: ObservableObject {
    static var shared: TaskViewModel?
    
    @Published var tasks: [TaskItem] = [] {
        didSet {
            saveTasks()
        }
    }
    
    @Published var showStreaks: Bool {
        didSet {
            UserDefaults.standard.set(showStreaks, forKey: "showStreaks")
        }
    }
    
    private let tasksKey = "tasks"
    
    init() {
        self.showStreaks = UserDefaults.standard.bool(forKey: "showStreaks")
        TaskViewModel.shared = self
        loadTasks()
        requestNotificationPermission()
    }
    
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Bildirim izni verildi")
                    self.rescheduleAllNotifications()
                } else {
                    print("Bildirim izni reddedildi: \(String(describing: error))")
                }
            }
        }
        
        center.getNotificationSettings { settings in
            print("Bildirim ayarları: \(settings)")
        }
    }
    
    func scheduleNotification(for task: TaskItem, on weekday: WeekDay) {
        let center = UNUserNotificationCenter.current()
        
        print("Bildirimler planlanıyor: \(task.title) için \(weekday.rawValue). gün")
        print("Bildirim saatleri: \(task.notificationTimes)")
        
        guard task.notificationEnabled else {
            print("Bildirimler kapalı: \(task.title)")
            return
        }
        
        // Önce bu görev için tüm eski bildirimleri temizle
        let identifiersToRemove = task.weekDays.flatMap { day in
            task.notificationTimes.map { time in
                "\(task.id)-\(day.rawValue)-\(time)"
            }
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        print("Eski bildirimler temizlendi: \(identifiersToRemove)")
        
        // Yeni bildirimleri planla
        for timeInMinutes in task.notificationTimes {
            let content = UNMutableNotificationContent()
            content.title = "Görev Hatırlatması"
            content.body = "Tamamlanmamış görev: \(task.title)"
            content.sound = .default
            content.badge = 1
            
            var dateComponents = DateComponents()
            dateComponents.weekday = weekday.weekdayNumber
            dateComponents.hour = timeInMinutes / 60
            dateComponents.minute = timeInMinutes % 60
            
            print("Bildirim planlanıyor: \(task.title) - Gün \(weekday.weekdayNumber), Saat \(timeInMinutes/60):\(timeInMinutes%60)")
            
            // Bildirimin tekrarlanması için gerekli ayarlar
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let notificationIdentifier = "\(task.id)-\(weekday.rawValue)-\(timeInMinutes)"
            
            let request = UNNotificationRequest(
                identifier: notificationIdentifier,
                content: content,
                trigger: trigger
            )
            
            center.add(request) { error in
                if let error = error {
                    print("Bildirim planlama hatası: \(error)")
                } else {
                    print("Bildirim başarıyla planlandı: \(notificationIdentifier)")
                    
                    // Bildirimin gerçekten planlandığını kontrol et
                    center.getPendingNotificationRequests { requests in
                        let matchingRequests = requests.filter { $0.identifier == notificationIdentifier }
                        if matchingRequests.isEmpty {
                            print("UYARI: Bildirim planlanamadı: \(notificationIdentifier)")
                        } else {
                            print("Bildirim başarıyla planlandı ve doğrulandı: \(notificationIdentifier)")
                            if let trigger = matchingRequests[0].trigger as? UNCalendarNotificationTrigger {
                                print("Bildirim zamanı: \(trigger.dateComponents)")
                            }
                        }
                    }
                }
            }
        }
        
        // Tüm planlanan bildirimleri kontrol et
        center.getPendingNotificationRequests { requests in
            let taskNotifications = requests.filter { $0.identifier.contains(task.id.uuidString) }
            print("\(task.title) için planlanan bildirim sayısı: \(taskNotifications.count)")
            for request in taskNotifications {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("Planlanan bildirim: \(request.identifier)")
                    print("Zaman: \(trigger.dateComponents)")
                    
                    // Bildirimin ne zaman tetikleneceğini hesapla
                    if let nextTriggerDate = trigger.nextTriggerDate() {
                        print("Bir sonraki bildirim zamanı: \(nextTriggerDate)")
                    }
                }
            }
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey) {
            do {
                let decoded = try JSONDecoder().decode([TaskItem].self, from: data)
                tasks = decoded
                print("Successfully loaded \(tasks.count) tasks")
            } catch {
                print("Error decoding tasks: \(error)")
                tasks = []
            }
        } else {
            print("No saved tasks found")
            tasks = []
        }
    }
    
    func rescheduleAllNotifications() {
        print("\n=== Tüm bildirimler yeniden planlanıyor ===")
        let center = UNUserNotificationCenter.current()
        
        center.removeAllPendingNotificationRequests()
        print("Tüm eski bildirimler temizlendi")
        
        for task in tasks {
            print("\nGörev bildirimleri planlanıyor: \(task.title)")
            for weekday in task.weekDays {
                scheduleNotification(for: task, on: weekday)
            }
        }
    }
    
    func updateNotificationsForTask(_ task: TaskItem) {
        print("Görev bildirimleri güncelleniyor: \(task.title)")
        let center = UNUserNotificationCenter.current()
        
        let identifiersToRemove = task.weekDays.flatMap { weekday in
            task.notificationTimes.map { time in
                "\(task.id)-\(weekday.rawValue)-\(time)"
            }
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        print("Eski bildirimler temizlendi: \(identifiersToRemove)")
        
        for weekday in task.weekDays {
            scheduleNotification(for: task, on: weekday)
        }
    }
    
    func toggleNotification(for task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].notificationEnabled.toggle()
            if tasks[index].notificationEnabled {
                // Bildirimleri yeniden planla
                for weekday in tasks[index].weekDays {
                    scheduleNotification(for: tasks[index], on: weekday)
                }
            } else {
                // Bildirimleri temizle
                let center = UNUserNotificationCenter.current()
                let identifiersToRemove = tasks[index].weekDays.flatMap { day in
                    tasks[index].notificationTimes.map { time in
                        "\(tasks[index].id)-\(day.rawValue)-\(time)"
                    }
                }
                center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            }
        }
    }
    
    func updateNotificationTimes(for task: TaskItem, times: [Int]) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].notificationTimes = times
            // Bildirimleri güncelle
            for weekday in tasks[index].weekDays {
                scheduleNotification(for: tasks[index], on: weekday)
            }
        }
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    func tasksForDay(_ day: WeekDay) -> [TaskItem] {
        let dayTasks = tasks.filter { $0.weekDays.contains(day) }
        return dayTasks.sorted { task1, task2 in
            // First sort by completion status
            if task1.isCompleted(for: day) != task2.isCompleted(for: day) {
                return !task1.isCompleted(for: day)
            }
            // Then by flag status
            if task1.isFlagged(for: day) != task2.isFlagged(for: day) {
                return task1.isFlagged(for: day)
            }
            // Then by earliest notification time
            let task1Time = task1.notificationTimes.first ?? Int.max
            let task2Time = task2.notificationTimes.first ?? Int.max
            if task1Time != task2Time {
                return task1Time < task2Time
            }
            // Finally by creation date
            return task1.createdAt < task2.createdAt
        }
    }
    
    func addTask(_ task: TaskItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            tasks.append(task)
            // Yeni görev eklendiğinde bildirimleri planla
            for weekday in task.weekDays {
                scheduleNotification(for: task, on: weekday)
            }
        }
    }
    
    func deleteTask(taskItem: TaskItem, from day: WeekDay) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if let index = tasks.firstIndex(where: { $0.id == taskItem.id }) {
                if tasks[index].weekDays.count == 1 {
                    // Görevin tüm bildirimlerini temizle
                    let center = UNUserNotificationCenter.current()
                    let identifiersToRemove = tasks[index].weekDays.flatMap { day in
                        tasks[index].notificationTimes.map { time in
                            "\(tasks[index].id)-\(day.rawValue)-\(time)"
                        }
                    }
                    center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
                    tasks.remove(at: index)
                } else {
                    tasks[index].weekDays.remove(day)
                    tasks[index].completedDays.remove(day)
                    tasks[index].flaggedDays.remove(day)
                    // Sadece o gün için bildirimleri temizle
                    let center = UNUserNotificationCenter.current()
                    let identifiersToRemove = tasks[index].notificationTimes.map { time in
                        "\(tasks[index].id)-\(day.rawValue)-\(time)"
                    }
                    center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
                }
            }
        }
    }
    
    func toggleTaskCompletion(taskItem: TaskItem, for day: WeekDay) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if let index = tasks.firstIndex(where: { $0.id == taskItem.id }) {
                if tasks[index].completedDays.contains(day) {
                    tasks[index].completedDays.remove(day)
                    tasks[index].streak = max(0, tasks[index].streak - 1)
                } else {
                    tasks[index].completedDays.insert(day)
                    tasks[index].streak += 1
                }
            }
        }
    }
    
    func toggleTaskFlag(taskItem: TaskItem, for day: WeekDay) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if let index = tasks.firstIndex(where: { $0.id == taskItem.id }) {
                if tasks[index].flaggedDays.contains(day) {
                    tasks[index].flaggedDays.remove(day)
                } else {
                    tasks[index].flaggedDays.insert(day)
                }
            }
        }
    }
    
    func completedTasksCount(for day: WeekDay) -> Int {
        tasks.filter { $0.isCompleted(for: day) }.count
    }
    
    func totalTasksCount(for day: WeekDay) -> Int {
        tasks.filter { $0.weekDays.contains(day) }.count
    }
    
    func completionRate(for day: WeekDay) -> Double {
        let total = totalTasksCount(for: day)
        guard total > 0 else { return 0 }
        return Double(completedTasksCount(for: day)) / Double(total)
    }
    
    func removeAllTasks() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            tasks.removeAll()
        }
    }
}
