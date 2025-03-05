//
//  TaskItemView.swift
//  UndistractedRoutine
//
//  Created by Efe Mesudiyeli on 5.03.2025.
//

import SwiftUI

struct TaskItemView: View {
    @EnvironmentObject private var viewModel: TaskViewModel
    let task: TaskItem
    let day: WeekDay
    
    var body: some View {
        Button {
            viewModel.toggleTaskCompletion(taskItem: task, for: day)
        } label: {
            HStack {
                Image(systemName: task.isCompleted(for: day) ? "checkmark.circle.fill" : "circle")
                Text(task.title)
                    .foregroundStyle(Color.primary)
                Spacer()
                Image(systemName: "flag")
                    .foregroundStyle(task.isFlagged ? .red : .gray)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                    viewModel.deleteTask(at: IndexSet([index]))
                }
            } label: {
                Label("Sil", systemImage: "trash")
            }
            
            if !task.isCompleted(for: day) {
                Button {
                    viewModel.toggleTaskCompletion(taskItem: task, for: day)
                } label: {
                    Label("Tamamla", systemImage: "checkmark.circle")
                }
                .tint(.green)
            }
        }
    }
}

#Preview {
    List {
        TaskItemView(task: TaskItem(title: "Laundry"), day: .monday)
            .preferredColorScheme(.dark)
    }
}
