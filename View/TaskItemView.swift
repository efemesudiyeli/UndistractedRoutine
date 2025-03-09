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
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .foregroundStyle(Color.primary)
                    if !task.notificationTimes.isEmpty {
                        Text(notificationTimesString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
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
    
    private var notificationTimesString: String {
        task.notificationTimes.map { time in
            let hour = time / 60
            let minute = time % 60
            return String(format: "%02d:%02d", hour, minute)
        }.joined(separator: ", ")
    }
}

#Preview {
    List {
        TaskItemView(task: TaskItem(title: "Laundry", notificationTimes: [540, 780]), day: .monday)
            .preferredColorScheme(.dark)
    }
}
