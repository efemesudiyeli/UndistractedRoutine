import SwiftUI

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