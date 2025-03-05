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
        WeekDay.allCases.filter { !viewModel.tasksForDay($0).isEmpty }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Undistracted Routine")
                    .font(.title)
                    .fontWeight(.black)
                Spacer()
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gear")
                        .font(.title3)
                }
            }
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
                                    .font(.headline)
                                Spacer()
                                Text("\(viewModel.tasksForDay(day).count) tasks")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                Button {
                    showingNewTask = true
                } label: {
                    Label("New Task", systemImage: "plus.circle.fill")
                }
                .padding(.bottom)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingNewTask) {
            NewTaskView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TaskViewModel())
}
