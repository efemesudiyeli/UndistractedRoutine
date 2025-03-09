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
    private let lastResetKey = "lastResetDate"
    
    init() {
        self.showStreaks = UserDefaults.standard.bool(forKey: "showStreaks")
        TaskViewModel.shared = self
        loadTasks()
        requestNotificationPermission()
        checkAndResetWeekly()
    }
    
    private func checkAndResetWeekly() {
        let calendar = Calendar.current
        let now = Date()
        
        // Son sıfırlama tarihini kontrol et
        if let lastReset = UserDefaults.standard.object(forKey: lastResetKey) as? Date {
            // Eğer son sıfırlamadan bu yana yeni bir hafta başladıysa
            if !calendar.isDate(lastReset, equalTo: now, toGranularity: .weekOfYear) {
                resetWeeklyTasks()
            }
        } else {
            // İlk kez çalıştırılıyorsa
            resetWeeklyTasks()
        }
    }
    
    private func resetWeeklyTasks() {
        let calendar = Calendar.current
        let now = Date()
        
        // Tüm görevlerin tamamlanma durumlarını sıfırla
        for index in tasks.indices {
            // Streak'i koru, sadece completedDays'i temizle
            tasks[index].completedDays.removeAll()
        }
        
        // Son sıfırlama tarihini güncelle
        UserDefaults.standard.set(now, forKey: lastResetKey)
        
        print("Weekly tasks reset completed at \(now)")
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
    
    func scheduleNotification(for task: TaskItem, on day: WeekDay) {
        print("📅 Scheduling notifications for task: \(task.title) on \(day.rawValue)")
        print("⏰ Notification times: \(task.notificationTimes)")
        
        // Clear old notifications for this task
        let identifiersToRemove = task.notificationTimes.map { time in
            "\(task.id)_\(time)"
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        
        // Schedule new notifications
        for time in task.notificationTimes {
            let content = UNMutableNotificationContent()
            content.title = task.title
            content.body = task.isFlagged(for: day) ? "⚠️ Important task: Time to complete!" : "Time to complete your task!"
            
            // Set notification sound and priority based on importance
            if task.isFlagged(for: day) {
                content.sound = .default
                content.interruptionLevel = .timeSensitive
                content.badge = 1
                content.categoryIdentifier = "IMPORTANT_TASK"
                content.threadIdentifier = "important_tasks"
                content.relevanceScore = 1.0
                content.targetContentIdentifier = "important_task"
                
                // Set notification subtitle for important tasks
                content.subtitle = "High Priority"
                
                // Set user info for important tasks
                content.userInfo = ["isImportant": true]
            } else {
                content.sound = .default
                content.interruptionLevel = .active
                content.categoryIdentifier = "REGULAR_TASK"
                content.threadIdentifier = "regular_tasks"
                content.relevanceScore = 0.5
            }
            
            let calendar = Calendar.current
            var components = DateComponents()
            components.weekday = day.weekdayNumber
            components.hour = time / 60
            components.minute = time % 60
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "\(task.id)_\(time)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("✅ Notification scheduled for \(task.title) at \(components.hour!):\(components.minute!) on \(day.rawValue)")
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
        return sortTasks(dayTasks, for: day)
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
    
    private func sortTasks(_ tasks: [TaskItem], for day: WeekDay) -> [TaskItem] {
        return tasks.sorted { task1, task2 in
            // First sort by importance
            if task1.isFlagged(for: day) != task2.isFlagged(for: day) {
                return task1.isFlagged(for: day)
            }
            
            // Then by earliest notification time
            let time1 = task1.notificationTimes.min() ?? Int.max
            let time2 = task2.notificationTimes.min() ?? Int.max
            return time1 < time2
        }
    }
    
    func updateTask(_ updatedTask: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
            // Eski bildirimleri temizle
            let center = UNUserNotificationCenter.current()
            let identifiersToRemove = tasks[index].weekDays.flatMap { day in
                tasks[index].notificationTimes.map { time in
                    "\(tasks[index].id)-\(day.rawValue)-\(time)"
                }
            }
            center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            
            // Görevi güncelle
            tasks[index] = updatedTask
            
            // Yeni bildirimleri planla
            for weekday in updatedTask.weekDays {
                scheduleNotification(for: updatedTask, on: weekday)
            }
        }
    }
}
