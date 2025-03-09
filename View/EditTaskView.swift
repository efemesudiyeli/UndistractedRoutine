import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: TaskViewModel
    
    let task: TaskItem
    @State private var taskTitle: String
    @State private var isImportant: Bool
    @State private var selectedDays: Set<WeekDay>
    @State private var notificationTimes: [Int]
    @State private var showingAddTime = false
    @State private var newHour = 9
    @State private var newMinute = 0
    
    init(task: TaskItem) {
        self.task = task
        _taskTitle = State(initialValue: task.title)
        _isImportant = State(initialValue: !task.flaggedDays.isEmpty)
        _selectedDays = State(initialValue: task.weekDays)
        _notificationTimes = State(initialValue: task.notificationTimes)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task title", text: $taskTitle)
                }
                
                Section {
                    Toggle("Important", isOn: $isImportant)
                }
                
                Section("Days") {
                    ForEach(WeekDay.allCases, id: \.self) { day in
                        Toggle(day.rawValue, isOn: Binding(
                            get: { selectedDays.contains(day) },
                            set: { isSelected in
                                if isSelected {
                                    selectedDays.insert(day)
                                } else {
                                    selectedDays.remove(day)
                                }
                            }
                        ))
                    }
                }
                
                Section("Notification Times") {
                    ForEach(notificationTimes.indices, id: \.self) { index in
                        HStack {
                            Text(timeString(from: notificationTimes[index]))
                            Spacer()
                            Button(role: .destructive) {
                                notificationTimes.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                            }
                        }
                    }
                    
                    Button {
                        showingAddTime = true
                    } label: {
                        Label("Add Time", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updatedTask = TaskItem(
                            id: task.id,
                            title: taskTitle,
                            createdAt: task.createdAt,
                            weekDays: selectedDays,
                            completedDays: task.completedDays,
                            flaggedDays: isImportant ? selectedDays : [],
                            streak: task.streak,
                            notificationEnabled: task.notificationEnabled,
                            notificationTimes: notificationTimes
                        )
                        viewModel.updateTask(updatedTask)
                        dismiss()
                    }
                    .disabled(taskTitle.isEmpty || selectedDays.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddTime) {
                AddTimeSheet(
                    newHour: $newHour,
                    newMinute: $newMinute,
                    onAdd: {
                        let minutes = newHour * 60 + newMinute
                        if !notificationTimes.contains(minutes) {
                            notificationTimes.append(minutes)
                            notificationTimes.sort()
                        }
                    },
                    isDisabled: false
                )
            }
        }
    }
    
    private func timeString(from minutes: Int) -> String {
        let hour = minutes / 60
        let minute = minutes % 60
        return String(format: "%02d:%02d", hour, minute)
    }
}

#Preview {
    EditTaskView(task: TaskItem(title: "Test Task"))
        .environmentObject(TaskViewModel())
} 