// MainView.swift
// TaskPulse
//
// Created by AI Assistant.

import SwiftUI

struct MainView: View {
    @State private var taskManager = TaskManager()
    @State private var selectedTab = 0
    @State private var taskToAnimate: Task? = nil
    @State private var filterToApply: FilterView.TaskStatus? = nil
    @State private var showingFilteredTasks = false

    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 0) {
                    Button(action: { selectedTab = 0 }) {
                        HStack {
                            Image(systemName: "chart.pie")
                            Text("概览")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedTab == 0 ? Color.lightBlue.opacity(0.3) : Color.clear)
                    }
                    Button(action: { selectedTab = 1 }) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("任务")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedTab == 1 ? Color.lightBlue.opacity(0.3) : Color.clear)
                    }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)

                if selectedTab == 0 {
                    DashboardView(taskManager: taskManager, taskToAnimate: $taskToAnimate) { status in
                        filterToApply = status
                        showingFilteredTasks = true
                    }
                } else {
                    TaskListView(taskManager: taskManager, taskToAnimate: $taskToAnimate, applyFilter: $filterToApply)
                }
            }
            .accentColor(.lightBlue)
            .environmentObject(taskManager)
            .overlay {
                if let task = taskToAnimate {
                    CompletionEffect(
                        task: task,
                        taskToAnimate: $taskToAnimate,
                        onCompletion: {
                            taskManager.toggleCompletion(for: task)
                        }
                    )
                }
            }
            .sheet(isPresented: $showingFilteredTasks) {
                NavigationStack {
                    TaskListView(taskManager: taskManager, taskToAnimate: $taskToAnimate, applyFilter: $filterToApply)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("完成") {
                                    showingFilteredTasks = false
                                }
                            }
                        }
                        .overlay {
                            if let task = taskToAnimate {
                                CompletionEffect(
                                    task: task,
                                    taskToAnimate: $taskToAnimate,
                                    onCompletion: {
                                        taskManager.toggleCompletion(for: task)
                                    }
                                )
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    MainView()
} 