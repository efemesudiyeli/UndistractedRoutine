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
    @Published var tasks: [TaskItem] = [] {
        didSet {
            saveTasks()
            scheduleNotifications()
        }
    }
    
    @Published var showStreaks: Bool {
        didSet {
            UserDefaults.standard.set(showStreaks, forKey: "showStreaks")
        }
    }
    
    @Published var defaultNotificationTimes: [Int] {
        didSet {
            UserDefaults.standard.set(defaultNotificationTimes, forKey: "defaultNotificationTimes")
        }
    }
    
    private let tasksKey = "savedTasks"
    
    init() {
        // Load settings
        self.showStreaks = UserDefaults.standard.bool(forKey: "showStreaks")
        
        // Load default notification times or use default values
        if let savedTimes = UserDefaults.standard.array(forKey: "defaultNotificationTimes") as? [Int], !savedTimes.isEmpty {
            self.defaultNotificationTimes = savedTimes
        } else {
            self.defaultNotificationTimes = [540, 780, 1020, 1260] // 9:00, 13:00, 17:00, 21:00
        }
        
        loadTasks()
        requestNotificationPermission()
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleNotifications() {
        // Remove all pending notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Schedule new notifications for incomplete tasks
        for task in tasks where task.notificationEnabled {
            for day in task.weekDays {
                if !task.isCompleted(for: day) {
                    scheduleNotification(for: task, on: day)
                }
            }
        }
    }
    
    private func scheduleNotification(for task: TaskItem, on day: WeekDay) {
        // Her bildirim zamanı için ayrı bildirim planla
        for time in task.notificationTimes {
            let content = UNMutableNotificationContent()
            content.title = "Task Reminder"
            content.body = "Don't forget to complete: \(task.title)"
            content.sound = .default
            
            // Bildirim zamanını hesapla
            let calendar = Calendar.current
            var components = DateComponents()
            components.hour = time / 60
            components.minute = time % 60
            components.weekday = day.weekdayNumber
            
            print("Scheduling notification for task: \(task.title) at \(components.hour ?? 0):\(components.minute ?? 0)")
            
            // Haftalık tekrarlayan bildirim ayarla
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            // Benzersiz tanımlayıcı oluştur
            let identifier = "\(task.id)-\(day.rawValue)-\(time)"
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Successfully scheduled notification with ID: \(identifier)")
                }
            }
        }
    }
    
    func toggleNotification(for task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].notificationEnabled.toggle()
        }
    }
    
    func updateNotificationTimes(for task: TaskItem, times: [Int]) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].notificationTimes = times
        }
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey) {
            do {
                let decoded = try JSONDecoder().decode([TaskItem].self, from: data)
                // Eski görevleri yeni notificationTimes yapısına uyarla
                let updatedTasks = decoded.map { task in
                    var updatedTask = task
                    // Eğer notificationTimes boşsa veya eski yapıdaysa, varsayılan zamanları kullan
                    if updatedTask.notificationTimes.isEmpty {
                        updatedTask.notificationTimes = defaultNotificationTimes
                    }
                    return updatedTask
                }
                tasks = updatedTasks
                print("Successfully loaded \(tasks.count) tasks")
            } catch {
                print("Error decoding tasks: \(error)")
                // Hata durumunda boş liste ile başla
                tasks = []
            }
        } else {
            print("No saved tasks found")
            tasks = []
        }
    }
    
    func tasksForDay(_ day: WeekDay) -> [TaskItem] {
        let dayTasks = tasks.filter { $0.weekDays.contains(day) }
        return dayTasks.sorted { task1, task2 in
            // First sort by completion status
            if task1.isCompleted(for: day) != task2.isCompleted(for: day) {
                return !task1.isCompleted(for: day)
            }
            // Then sort by flag status
            if task1.isFlagged(for: day) != task2.isFlagged(for: day) {
                return task1.isFlagged(for: day)
            }
            // Finally sort by creation date
            return task1.createdAt < task2.createdAt
        }
    }
    
    func addTask(_ task: TaskItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            tasks.append(task)
        }
    }
    
    func deleteTask(taskItem: TaskItem, from day: WeekDay) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if let index = tasks.firstIndex(where: { $0.id == taskItem.id }) {
                // If the task is only for this day, delete it completely
                if tasks[index].weekDays.count == 1 {
                    tasks.remove(at: index)
                } else {
                    // Otherwise, just remove this day
                    tasks[index].weekDays.remove(day)
                    tasks[index].completedDays.remove(day)
                    tasks[index].flaggedDays.remove(day)
                }
            }
        }
    }
    
    func toggleTaskCompletion(taskItem: TaskItem, for day: WeekDay) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if let index = tasks.firstIndex(where: { $0.id == taskItem.id }) {
                if tasks[index].completedDays.contains(day) {
                    tasks[index].completedDays.remove(day)
                    // Decrease streak when uncompleting
                    tasks[index].streak = max(0, tasks[index].streak - 1)
                } else {
                    tasks[index].completedDays.insert(day)
                    // Increase streak when completing
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
    
    // Get total completed tasks for a specific day
    func completedTasksCount(for day: WeekDay) -> Int {
        tasks.filter { $0.isCompleted(for: day) }.count
    }
    
    // Get total tasks for a specific day
    func totalTasksCount(for day: WeekDay) -> Int {
        tasks.filter { $0.weekDays.contains(day) }.count
    }
    
    // Get completion rate for a specific day
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
    
    func updateDefaultNotificationTimes(_ times: [Int]) {
        defaultNotificationTimes = times
        // Update all existing tasks with new default times
        for index in tasks.indices {
            tasks[index].notificationTimes = times
        }
    }
    
    func addNotificationTime(_ time: Int) {
        var newTimes = defaultNotificationTimes
        newTimes.append(time)
        newTimes.sort() // Keep times in order
        updateDefaultNotificationTimes(newTimes)
    }
    
    func removeNotificationTime(at index: Int) {
        var newTimes = defaultNotificationTimes
        newTimes.remove(at: index)
        updateDefaultNotificationTimes(newTimes)
    }
    
    func updateNotificationTime(at index: Int, to time: Int) {
        var newTimes = defaultNotificationTimes
        newTimes[index] = time
        newTimes.sort() // Keep times in order
        updateDefaultNotificationTimes(newTimes)
    }
}
