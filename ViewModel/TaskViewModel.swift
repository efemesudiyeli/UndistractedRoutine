//
//  TaskViewModel.swift
//  UndistractedRoutine
//
//  Created by Efe Mesudiyeli on 5.03.2025.
//

import Foundation
import SwiftUI

class TaskViewModel: ObservableObject {
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
    
    private let tasksKey = "savedTasks"
    
    init() {
        // Load streak visibility setting
        self.showStreaks = UserDefaults.standard.bool(forKey: "showStreaks")
        
        loadTasks()
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([TaskItem].self, from: data) {
            tasks = decoded
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
}
