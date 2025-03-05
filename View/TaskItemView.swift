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
                HStack(spacing: 8) {
                    if viewModel.showStreaks && task.streak > 0 {
                        Text(task.streakEmoji)
                            .font(.caption)
                    }
                    if task.isFlagged(for: day) {
                        Image(systemName: "flag.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                viewModel.deleteTask(taskItem: task, from: day)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            if !task.isCompleted(for: day) {
                Button {
                    viewModel.toggleTaskCompletion(taskItem: task, for: day)
                } label: {
                    Label("Complete", systemImage: "checkmark.circle")
                }
                .tint(.green)
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                viewModel.toggleTaskFlag(taskItem: task, for: day)
            } label: {
                Label(task.isFlagged(for: day) ? "Remove Flag" : "Flag", 
                      systemImage: task.isFlagged(for: day) ? "flag.slash" : "flag")
            }
            .tint(.red)
        }
    }
}

#Preview {
    List {
        TaskItemView(task: TaskItem(title: "Laundry"), day: .monday)
            .preferredColorScheme(.dark)
    }
}
