// RecentlyDeletedView.swift
// TaskPulse
//
// Created by AI Assistant

import SwiftUI

struct RecentlyDeletedView: View {
    @EnvironmentObject var taskManager: TaskManager

    var body: some View {
        NavigationStack {
            VStack {
                if taskManager.recentlyDeletedTasks.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "trash.slash.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("没有最近删除的任务")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.top)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(taskManager.recentlyDeletedTasks) { task in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(task.title)
                                    .font(.headline)
                                
                                if let description = task.description, !description.isEmpty {
                                    Text(description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Button(action: {
                                        taskManager.restoreTask(task)
                                    }) {
                                        Label("恢复", systemImage: "arrow.uturn.backward")
                                    }
                                    .buttonStyle(.bordered)
                                    
                                    Spacer()
                                    
                                    Button(role: .destructive, action: {
                                        taskManager.permanentlyDeleteTask(task)
                                    }) {
                                        Label("永久删除", systemImage: "trash.fill")
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("最近删除")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !taskManager.recentlyDeletedTasks.isEmpty {
                        Button(role: .destructive, action: {
                            // Optional: Add a confirmation dialog before clearing all
                            taskManager.recentlyDeletedTasks.removeAll()
                        }) {
                            Text("全部清空")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let taskManager = TaskManager()
    taskManager.recentlyDeletedTasks = [
        Task(title: "Deleted Task 1", description: "This is a deleted task.", priority: .high),
        Task(title: "Deleted Task 2", priority: .low)
    ]
    return RecentlyDeletedView().environmentObject(taskManager)
} 