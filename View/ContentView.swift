//
//  ContentView.swift
//  UndistractedRoutine
//
//  Created by Efe Mesudiyeli on 5.03.2025.
//

import SwiftUI

struct PetsScrollView: View {
    let pets: [Pet]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                if pets.isEmpty {
                    ForEach(0..<4) { _ in
                        EmptyPetCard()
                    }
                } else {
                    ForEach(pets) { pet in
                        PetCardView(pet: pet, isCompact: true)
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 100)
        .padding(.vertical, 8)
    }
}

struct EmptyPetCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
                .opacity(0.5)
                .offset(y: isAnimating ? -3 : 3)
                .animation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            Text("Yakında")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(width: 80)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 3)
                .opacity(0.5)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct TaskListView: View {
    @EnvironmentObject private var viewModel: TaskViewModel
    @Binding var days: [WeekDay]
    
    var body: some View {
        List {
            ForEach(days, id: \.rawValue) { day in
                Section {
                    ForEach(viewModel.tasksForDay(day)) { task in
                        TaskItemView(task: task, day: day)
                    }
                } header: {
                    TaskSectionHeader(day: day)
                        .textCase(nil)
                        .foregroundStyle(.primary)
                        .listRowInsets(EdgeInsets())
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
    }
}

struct TaskSectionHeader: View {
    @EnvironmentObject private var viewModel: TaskViewModel
    let day: WeekDay
    
    var body: some View {
        HStack(spacing: 12) {
            Text(day.displayName)
                .font(.title3)
                .fontWeight(.bold)
            
            if viewModel.showStreaks {
                let completedCount = viewModel.completedTasksCount(for: day)
                let totalCount = viewModel.totalTasksCount(for: day)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(completedCount == totalCount ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    
                    Text("\(completedCount)/\(totalCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    Capsule()
                        .fill(Color(.systemGray6))
                }
            }
            
            Spacer()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @StateObject private var petViewModel = PetViewModel()
    @State private var showingNewTask = false
    @State private var showingSettings = false
    @State private var days: [WeekDay] = []
    @State private var isPetsExpanded = true
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 20) {
                    // Petler kartı
                    VStack(spacing: 0) {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isPetsExpanded.toggle()
                            }
                        } label: {
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "pawprint.fill")
                                        .foregroundStyle(.orange)
                                    
                                    Text("Petlerim")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                }
                                
                                Spacer()
                                
                                Image(systemName: isPetsExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                    .foregroundStyle(.secondary)
                                    .imageScale(.large)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding()
                        
                        if isPetsExpanded {
                            Divider()
                                .padding(.horizontal)
                            
                            PetsScrollView(pets: petViewModel.pets)
                        }
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    // Görevler listesi
                    TaskListView(days: $days)
                        .environmentObject(viewModel)
                }
                .padding(.top)
                
                // Yeni görev ekleme butonu
                Button {
                    showingNewTask = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background {
                            Circle()
                                .fill(Color.blue)
                                .shadow(radius: 5, x: 0, y: 3)
                        }
                }
                .padding(.bottom, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .foregroundStyle(.primary)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Undistracted")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $showingNewTask) {
                NewTaskView()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(viewModel)
                    .environmentObject(petViewModel)
            }
        }
        .environmentObject(viewModel)
        .environmentObject(petViewModel)
        .onAppear {
            updateDays()
        }
        .onChange(of: viewModel.tasks) { _ in
            withAnimation {
                updateDays()
                petViewModel.checkWeeklyProgress(taskViewModel: viewModel)
            }
        }
    }
    
    private func updateDays() {
        var updatedDays = WeekDay.allCases.filter { viewModel.tasksForDay($0).count > 0 }
        
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: Date())
        if let today = WeekDay.allCases.first(where: { $0.weekdayNumber == currentWeekday }),
           updatedDays.contains(today) {
            updatedDays.removeAll { $0 == today }
            updatedDays.insert(today, at: 0)
        }
        
        days = updatedDays
    }
}

#Preview {
    ContentView()
        .environmentObject(TaskViewModel())
        .environmentObject(PetViewModel())
}
