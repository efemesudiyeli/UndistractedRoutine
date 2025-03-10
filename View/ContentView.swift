//
//  ContentView.swift
//  UndistractedRoutine
//
//  Created by Efe Mesudiyeli on 5.03.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: TaskViewModel
    @State private var showingNewTask = false
    @State private var showingSettings = false
    
    var daysWithTasks: [WeekDay] {
        let days = WeekDay.allCases.filter { !viewModel.tasksForDay($0).isEmpty }
        return days.sorted { day1, day2 in
            if isCurrentDay(day1) { return true }
            if isCurrentDay(day2) { return false }
            return day1.weekdayNumber < day2.weekdayNumber
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Undistracted Routine")
                .font(.title)
                .fontWeight(.black)
                .padding(.top)
                .padding(.horizontal)
            
            if daysWithTasks.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "checklist")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text("No tasks yet")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("Start by adding a new task")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Button {
                        showingNewTask = true
                    } label: {
                        Label("Add Task", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List {
                    ForEach(daysWithTasks, id: \.self) { day in
                        Section {
                            ForEach(viewModel.tasksForDay(day)) { task in
                                TaskItemView(task: task, day: day)
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .scale.combined(with: .opacity)
                                    ))
                            }
                        } header: {
                            HStack {
                                Text(day.rawValue)
                                    .font(isCurrentDay(day) ? .title3 : .headline)
                                    .fontWeight(isCurrentDay(day) ? .bold : .regular)
                                    .foregroundStyle(isCurrentDay(day) ? Color.blue : Color.primary)
                                Spacer()
                                Text("\(viewModel.tasksForDay(day).count) tasks")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            
            HStack {
                Button {
                    showingNewTask = true
                } label: {
                    Label("New Task", systemImage: "plus.circle.fill")
                }
                
                Spacer()
                
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .padding(.bottom, 8)
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 5, y: -2)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingNewTask) {
            NewTaskView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    private func isCurrentDay(_ day: WeekDay) -> Bool {
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: Date())
        return day.weekdayNumber == currentWeekday
    }
}

#Preview {
    ContentView()
        .environmentObject(TaskViewModel())
}
