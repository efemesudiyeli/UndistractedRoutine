import SwiftUI

struct NotificationTimeRow: View {
    let time: Int
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(timeString(from: time))
            Spacer()
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "minus.circle.fill")
            }
        }
    }
    
    private func timeString(from minutes: Int) -> String {
        let hour = minutes / 60
        let minute = minutes % 60
        return String(format: "%02d:%02d", hour, minute)
    }
}

struct AddTimeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var newHour: Int
    @Binding var newMinute: Int
    let onAdd: () -> Void
    let isDisabled: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Hour", selection: $newHour) {
                        ForEach(0..<24) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    
                    Picker("Minute", selection: $newMinute) {
                        ForEach(0..<60) { minute in
                            Text("\(minute)").tag(minute)
                        }
                    }
                }
            }
            .navigationTitle("Add Notification Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd()
                        dismiss()
                    }
                    .disabled(isDisabled)
                }
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: TaskViewModel
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Show Streaks", isOn: $viewModel.showStreaks)
                } footer: {
                    Text("Streaks show your consecutive task completions with plant emojis (🌱 → 🌿 → 🌳). Turn this off if you find it distracting.")
                        .foregroundStyle(.secondary)
                }
                
                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Remove All Tasks", systemImage: "trash")
                    }
                } footer: {
                    Text("This will permanently delete all your tasks. This action cannot be undone.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Remove All Tasks?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    viewModel.removeAllTasks()
                }
            } message: {
                Text("Are you sure you want to remove all tasks? This action cannot be undone.")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(TaskViewModel())
} 
