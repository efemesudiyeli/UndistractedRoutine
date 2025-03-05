import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: TaskViewModel
    
    @State private var taskTitle = ""
    @State private var isImportant = false
    @State private var selectedDays: Set<WeekDay> = []
    
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
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let task = TaskItem(
                            title: taskTitle,
                            weekDays: selectedDays,
                            flaggedDays: isImportant ? selectedDays : []
                        )
                        viewModel.addTask(task)
                        dismiss()
                    }
                    .disabled(taskTitle.isEmpty || selectedDays.isEmpty)
                }
            }
        }
    }
} 