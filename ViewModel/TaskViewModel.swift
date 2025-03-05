//
//  TaskViewModel.swift
//  UndistractedRoutine
//
//  Created by Efe Mesudiyeli on 5.03.2025.
//

import Foundation

class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = [] {
        didSet {
            saveTasks()
        }
    }
    
    @Published var selectedDay: WeekDay = .monday
    
    private let tasksKey = "savedTasks"
    
    init() {
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
    
    var tasksForSelectedDay: [TaskItem] {
        tasks.filter { $0.weekDays.contains(selectedDay) }
    }
    
    func tasksForDay(_ day: WeekDay) -> [TaskItem] {
        tasks.filter { $0.weekDays.contains(day) }
    }
    
    func addTask(title: String, isFlagged: Bool = false, weekDays: Set<WeekDay>) {
        let task = TaskItem(title: title, isFlagged: isFlagged, weekDays: weekDays)
        tasks.append(task)
    }
    
    func deleteTask(at indexSet: IndexSet) {
        tasks.remove(atOffsets: indexSet)
    }
    
    func toggleTaskCompletion(taskItem: TaskItem, for day: WeekDay) {
        if let index = tasks.firstIndex(where: { $0.id == taskItem.id }) {
            if tasks[index].completedDays.contains(day) {
                tasks[index].completedDays.remove(day)
            } else {
                tasks[index].completedDays.insert(day)
            }
        }
    }
    
    func toggleTaskFlag(taskItem: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == taskItem.id }) {
            tasks[index].isFlagged.toggle()
        }
    }
    
    func setSelectedDay(_ day: WeekDay) {
        selectedDay = day
    }
}
