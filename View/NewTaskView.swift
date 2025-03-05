import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: TaskViewModel
    
    @State private var taskTitle = ""
    @State private var isFlagged = false
    @State private var selectedDays: Set<WeekDay> = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Görev başlığı", text: $taskTitle)
                }
                
                Section {
                    Toggle("Önemli", isOn: $isFlagged)
                }
                
                Section("Günler") {
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
            .navigationTitle("Yeni Görev")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ekle") {
                        viewModel.addTask(title: taskTitle, isFlagged: isFlagged, weekDays: selectedDays)
                        dismiss()
                    }
                    .disabled(taskTitle.isEmpty || selectedDays.isEmpty)
                }
            }
        }
    }
} 