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
    
    var daysWithTasks: [WeekDay] {
        WeekDay.allCases.filter { !viewModel.tasksForDay($0).isEmpty }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Undistracted Routine")
                .font(.title)
                .fontWeight(.black)
                .padding(.top)
            
            if daysWithTasks.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "checklist")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text("Henüz görev yok")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("Yeni bir görev ekleyerek başlayın")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Button {
                        showingNewTask = true
                    } label: {
                        Label("Görev Ekle", systemImage: "plus.circle.fill")
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
                            }
                        } header: {
                            HStack {
                                Text(day.rawValue)
                                    .font(.headline)
                                Spacer()
                                Text("\(viewModel.tasksForDay(day).count) görev")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
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
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingNewTask) {
            NewTaskView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TaskViewModel())
}
