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
    
    @Published var defaultNotificationTimes: [Int] {
        didSet {
            UserDefaults.standard.set(defaultNotificationTimes, forKey: "defaultNotificationTimes")
            rescheduleAllNotifications()
        }
    }
    
    private let tasksKey = "tasks"
    
    init() {
        self.showStreaks = UserDefaults.standard.bool(forKey: "showStreaks")
        
        if let savedTimes = UserDefaults.standard.array(forKey: "defaultNotificationTimes") as? [Int], !savedTimes.isEmpty {
            self.defaultNotificationTimes = savedTimes
        } else {
            self.defaultNotificationTimes = [540, 780, 1020, 1260]
        }
        
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
        print("Bildirim saatleri: \(defaultNotificationTimes)")
        
        guard task.notificationEnabled else {
            print("Bildirimler kapalı: \(task.title)")
            return
        }
        
        let identifiersToRemove = defaultNotificationTimes.map { time in
            "\(task.id)-\(weekday.rawValue)-\(time)"
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        print("Eski bildirimler temizlendi: \(identifiersToRemove)")
        
        for timeInMinutes in defaultNotificationTimes {
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
                }
            }
        }
        
        center.getPendingNotificationRequests { requests in
            let taskNotifications = requests.filter { $0.identifier.contains(task.id.uuidString) }
            print("\(task.title) için planlanan bildirim sayısı: \(taskNotifications.count)")
            for request in taskNotifications {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("Planlanan bildirim: \(request.identifier)")
                    print("Zaman: \(trigger.dateComponents)")
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
                let updatedTasks = decoded.map { task in
                    var updatedTask = task
                    if updatedTask.notificationTimes.isEmpty {
                        updatedTask.notificationTimes = defaultNotificationTimes
                    }
                    return updatedTask
                }
                tasks = updatedTasks
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
    
    func tasksForDay(_ day: WeekDay) -> [TaskItem] {
        let dayTasks = tasks.filter { $0.weekDays.contains(day) }
        return dayTasks.sorted { task1, task2 in
            if task1.isCompleted(for: day) != task2.isCompleted(for: day) {
                return !task1.isCompleted(for: day)
            }
            if task1.isFlagged(for: day) != task2.isFlagged(for: day) {
                return task1.isFlagged(for: day)
            }
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
                if tasks[index].weekDays.count == 1 {
                    tasks.remove(at: index)
                } else {
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
    
    func updateDefaultNotificationTimes(_ times: [Int]) {
        defaultNotificationTimes = times
        for index in tasks.indices {
            tasks[index].notificationTimes = times
        }
    }
    
    func addNotificationTime(_ minutes: Int) {
        print("Yeni bildirim saati ekleniyor: \(minutes/60):\(minutes%60)")
        
        if !defaultNotificationTimes.contains(minutes) {
            var updatedTimes = defaultNotificationTimes
            updatedTimes.append(minutes)
            updatedTimes.sort()
            
            defaultNotificationTimes = updatedTimes
            
            print("Güncellenmiş bildirim saatleri: \(defaultNotificationTimes.map { String(format: "%02d:%02d", $0/60, $0%60) })")
            
            rescheduleAllNotifications()
        }
    }
    
    func removeNotificationTime(at index: Int) {
        print("Bildirim saati kaldırılıyor: index \(index)")
        guard index < defaultNotificationTimes.count else { return }
        
        defaultNotificationTimes.remove(at: index)
        print("Kalan bildirim saatleri: \(defaultNotificationTimes.map { String(format: "%02d:%02d", $0/60, $0%60) })")
        
        rescheduleAllNotifications()
    }
    
    func updateNotificationTime(at index: Int, to time: Int) {
        var newTimes = defaultNotificationTimes
        newTimes[index] = time
        newTimes.sort()
        updateDefaultNotificationTimes(newTimes)
    }
    
    func rescheduleAllNotifications() {
        print("\n=== Tüm bildirimler yeniden planlanıyor ===")
        let center = UNUserNotificationCenter.current()
        
        center.removeAllPendingNotificationRequests()
        print("Tüm eski bildirimler temizlendi")
        
        guard !defaultNotificationTimes.isEmpty else {
            print("Hiç bildirim saati yok, planlama yapılmayacak")
            return
        }
        
        for task in tasks {
            print("\nGörev bildirimleri planlanıyor: \(task.title)")
            for weekday in task.weekDays {
                scheduleNotification(for: task, on: weekday)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            center.getPendingNotificationRequests { requests in
                print("\n=== Planlanan Bildirimler Özeti ===")
                print("Toplam planlanan bildirim sayısı: \(requests.count)")
                
                let groupedRequests = Dictionary(grouping: requests) { request -> String in
                    if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                        return "Gün: \(trigger.dateComponents.weekday ?? 0), Saat: \(trigger.dateComponents.hour ?? 0):\(trigger.dateComponents.minute ?? 0)"
                    }
                    return "Bilinmeyen"
                }
                
                for (key, requests) in groupedRequests.sorted(by: { $0.key < $1.key }) {
                    print("\n\(key)")
                    for request in requests {
                        print("- \(request.content.body)")
                    }
                }
                print("\n===============================")
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
}
