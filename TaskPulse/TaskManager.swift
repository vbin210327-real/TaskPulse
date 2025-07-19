// TaskManager.swift
// TaskPulse
//
// Created by AI Assistant.

import Foundation
import SwiftUI
import Combine

@MainActor
class TaskManager: ObservableObject {
    @Published var tasks: [Task] = [] {
        didSet {
            saveTasks()
        }
    }
    @Published var recentlyDeletedTasks: [Task] = [] {
        didSet {
            saveRecentlyDeletedTasks()
        }
    }
    
    // Filter states
    @Published var filterPriority: Priority? = nil
    @Published var filterStatus: FilterView.TaskStatus? = .all
    @Published var filterStartDate: Date? = nil
    @Published var filterEndDate: Date? = nil

    private let tasksKey = "savedTasks"
    private let recentlyDeletedTasksKey = "recentlyDeletedTasks"
    
    init() {
        loadTasks()
        loadRecentlyDeletedTasks()
        if tasks.isEmpty {
            tasks = sampleTasks
        }
    }
    
    func addTask(title: String, description: String?, dueDate: Date?, hasTime: Bool, priority: Priority) {
        let newTask = Task(title: title, description: description, dueDate: dueDate, dueDateHasTime: hasTime, priority: priority)
        tasks.append(newTask)
    }

    func updateTask(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        recentlyDeletedTasks.insert(task, at: 0) // Add to the top of the list
    }
    
    func restoreTask(_ task: Task) {
        recentlyDeletedTasks.removeAll { $0.id == task.id }
        tasks.append(task)
    }

    func permanentlyDeleteTask(_ task: Task) {
        recentlyDeletedTasks.removeAll { $0.id == task.id }
    }

    func toggleCompletion(for task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        
        // Directly modify the task to ensure immediate UI updates
        withAnimation {
            tasks[index].completed.toggle()
            
            // Also update subtasks if the parent task is marked as complete
            if tasks[index].completed {
                for i in tasks[index].subtasks.indices {
                    tasks[index].subtasks[i].completed = true
                }
            }
        }
        
        // Force an immediate update to ensure all observers are notified
        objectWillChange.send()
    }

    func toggleSubtaskCompletion(taskId: UUID, subtaskId: UUID) -> Bool {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == taskId }),
              let subtaskIndex = tasks[taskIndex].subtasks.firstIndex(where: { $0.id == subtaskId }) else {
            return false
        }
        
        tasks[taskIndex].subtasks[subtaskIndex].completed.toggle()

        let allSubtasksCompleted = tasks[taskIndex].subtasks.allSatisfy { $0.completed }
        if allSubtasksCompleted {
            if !tasks[taskIndex].completed {
                tasks[taskIndex].completed = true
                return true // Indicates parent task was just completed
            }
        } else {
            if tasks[taskIndex].completed {
                tasks[taskIndex].completed = false
            }
        }
        return false
    }

    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }

    private func loadTasks() {
        guard let data = UserDefaults.standard.data(forKey: tasksKey),
              let decodedTasks = try? JSONDecoder().decode([Task].self, from: data) else {
            return
        }
        tasks = decodedTasks
    }

    private func saveRecentlyDeletedTasks() {
        if let encoded = try? JSONEncoder().encode(recentlyDeletedTasks) {
            UserDefaults.standard.set(encoded, forKey: recentlyDeletedTasksKey)
        }
    }
    
    private func loadRecentlyDeletedTasks() {
        guard let data = UserDefaults.standard.data(forKey: recentlyDeletedTasksKey),
              let decodedTasks = try? JSONDecoder().decode([Task].self, from: data) else {
            return
        }
        recentlyDeletedTasks = decodedTasks
    }

    // Computed properties for dashboard
    var completionRate: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(tasks.filter { $0.completed }.count) / Double(tasks.count)
    }
    
    var averageProgress: Double {
        guard !tasks.isEmpty else { return 0 }
        let totalProgress = tasks.reduce(0) { $0 + $1.progress }
        return totalProgress / Double(tasks.count)
    }
} 