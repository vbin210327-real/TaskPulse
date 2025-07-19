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
        
        // Ensure we're on the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Double-check the index is still valid
            guard index < self.tasks.count, self.tasks[index].id == task.id else { return }
            
            // Get the actual task from the array (not the parameter)
            let actualTask = self.tasks[index]
            
            // Directly modify the task properties to trigger @Published
            actualTask.completed.toggle()
            
            // Also update subtasks if the parent task is marked as complete
            if actualTask.completed {
                for i in actualTask.subtasks.indices {
                    actualTask.subtasks[i].completed = true
                }
            }
            
            // Manually trigger change notifications
            actualTask.objectWillChange.send()
            self.objectWillChange.send()
            
            // Force array update by reassigning the same object to trigger @Published
            self.tasks[index] = actualTask
        }
    }

    func toggleSubtaskCompletion(taskId: UUID, subtaskId: UUID) -> Bool {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == taskId }),
              let subtaskIndex = tasks[taskIndex].subtasks.firstIndex(where: { $0.id == subtaskId }) else {
            return false
        }
        
        // Ensure we're on the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Double-check the indices are still valid
            guard taskIndex < self.tasks.count,
                  subtaskIndex < self.tasks[taskIndex].subtasks.count else { return }
            
            // Get the actual task and subtask
            let actualTask = self.tasks[taskIndex]
            
            // Toggle subtask completion
            actualTask.subtasks[subtaskIndex].completed.toggle()
            
            // Check if all subtasks are completed
            let allSubtasksCompleted = actualTask.subtasks.allSatisfy { $0.completed }
            let wasTaskCompleted = actualTask.completed
            
            if allSubtasksCompleted && !actualTask.completed {
                // Complete the parent task
                actualTask.completed = true
            } else if !allSubtasksCompleted && actualTask.completed {
                // If not all subtasks are completed but parent is, uncomplete the parent
                actualTask.completed = false
            }
            
            // Trigger change notifications
            actualTask.objectWillChange.send()
            self.objectWillChange.send()
            
            // Force array update to trigger @Published
            self.tasks[taskIndex] = actualTask
        }
        
        // Return synchronously based on current state for UI logic
        let allSubtasksCompleted = tasks[taskIndex].subtasks.allSatisfy { $0.completed }
        if allSubtasksCompleted && !tasks[taskIndex].completed {
            return true // Indicates parent task will be completed
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