// MainView.swift
// TaskPulse
//
// Cosmic Minimalism Redesign

import SwiftUI

struct MainView: View {
    @State private var taskManager = TaskManager()
    @State private var selectedTab = 0
    @State private var taskToAnimate: Task? = nil
    @State private var filterToApply: FilterView.TaskStatus? = nil
    @State private var showingFilteredTasks = false

    var body: some View {
        ZStack {
            // Animated cosmic background
            AnimatedCosmicBackground()
            NoiseOverlay()

            TabView(selection: $selectedTab) {
                NavigationStack {
                    DashboardView(taskManager: taskManager, taskToAnimate: $taskToAnimate) { status in
                        filterToApply = status
                        showingFilteredTasks = true
                    }
                    .toolbar(.hidden, for: .navigationBar)
                }
                .tabItem {
                    Label("概览", systemImage: "chart.pie.fill")
                }
                .tag(0)

                NavigationStack {
                    TaskListView(taskManager: taskManager, taskToAnimate: $taskToAnimate, applyFilter: $filterToApply)
                        .toolbar(taskToAnimate != nil ? .hidden : .visible, for: .navigationBar)
                }
                .tabItem {
                    Label("任务", systemImage: "list.bullet.rectangle.fill")
                }
                .tag(1)
            }
            .tint(.electricCyan)
        }
        .environmentObject(taskManager)
        .preferredColorScheme(.dark)
        .overlay {
            if let task = taskToAnimate {
                CompletionEffect(
                    task: task,
                    taskToAnimate: $taskToAnimate,
                    taskManager: taskManager,
                    onCompletion: {
                        if !task.completed {
                            withAnimation {
                                taskManager.toggleCompletion(for: task)
                            }
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showingFilteredTasks) {
            NavigationStack {
                ZStack {
                    Color.cosmicBlack.ignoresSafeArea()
                    TaskListView(taskManager: taskManager, taskToAnimate: $taskToAnimate, applyFilter: $filterToApply)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") {
                            showingFilteredTasks = false
                        }
                        .font(.cosmicHeadline)
                        .foregroundColor(.electricCyan)
                    }
                }
                .overlay {
                    if let task = taskToAnimate {
                        CompletionEffect(
                            task: task,
                            taskToAnimate: $taskToAnimate,
                            taskManager: taskManager,
                            onCompletion: {
                                withAnimation {
                                    taskManager.toggleCompletion(for: task)
                                }
                            }
                        )
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    MainView()
}
