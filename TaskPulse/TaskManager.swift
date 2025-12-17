// TaskManager.swift
// TaskPulse
//
// Created by AI Assistant.

import Foundation
import SwiftUI
import Combine
import UserNotifications
import _Concurrency

@MainActor
class TaskManager: ObservableObject {
    @Published var tasks: [Task] = [] {
        didSet {
            saveTasks()
            syncDueSoonNotifications()
        }
    }
    @Published var recentlyDeletedTasks: [Task] = [] {
        didSet {
            saveRecentlyDeletedTasks()
        }
    }
    
    // Filter states
    @Published var filterPriority: Priority? = nil
    @Published var filterStatus: FilterView.TaskStatus? = .inProgress
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
        
        // Get the actual task
        let actualTask = tasks[taskIndex]
        let wasTaskCompleted = actualTask.completed
        
        // Toggle subtask completion immediately
        actualTask.subtasks[subtaskIndex].completed.toggle()
        
        // Check if all subtasks are completed
        let allSubtasksCompleted = actualTask.subtasks.allSatisfy { $0.completed }
        let willCompleteParentTask = allSubtasksCompleted && !wasTaskCompleted
        
        // Update parent task completion status
        if allSubtasksCompleted && !actualTask.completed {
            // Complete the parent task
            actualTask.completed = true
        } else if !allSubtasksCompleted && actualTask.completed {
            // If not all subtasks are completed but parent is, uncomplete the parent
            actualTask.completed = false
        }
        
        // Ensure we're on the main thread for UI updates
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Trigger change notifications
            actualTask.objectWillChange.send()
            self.objectWillChange.send()
            
            // Force array update to trigger @Published
            self.tasks[taskIndex] = actualTask
        }
        
        // Return if parent task was just completed by subtask completion
        return willCompleteParentTask
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

    func syncDueSoonNotifications() {
        _Concurrency.Task { @MainActor in
            await TaskDueSoonNotifications.sync(tasks: tasks)
        }
    }

    @discardableResult
    func requestDueSoonNotificationsAuthorizationAndSync() async -> Bool {
        guard TaskDueSoonNotifications.isEnabled() else {
            await TaskDueSoonNotifications.removeAllManagedNotifications()
            return true
        }

        let granted = await TaskDueSoonNotifications.requestAuthorizationIfNeeded()
        await TaskDueSoonNotifications.sync(tasks: tasks)
        return granted
    }
} 

// MARK: - Due Soon Notifications
@MainActor
private enum TaskDueSoonNotifications {
    private static let enableKey = "enableDueSoonNotifications"
    private static let identifierPrefix = "taskpulse.dueSoon."
    private static let maxScheduledNotifications = 60
    private static let leadTimeWithTime: TimeInterval = 60 * 60 // 1 hour
    private static let fireHourWithoutTime = 18 // 18:00 on due day

    private static let center = UNUserNotificationCenter.current()

    static func isEnabled() -> Bool {
        UserDefaults.standard.object(forKey: enableKey) as? Bool ?? true
    }

    static func requestAuthorizationIfNeeded() async -> Bool {
        let settings = await notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return await requestAuthorization()
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    static func sync(tasks: [Task]) async {
        let enabled = isEnabled()
        guard enabled else {
            await removeAllManagedNotifications()
            return
        }

        let settings = await notificationSettings()
        let isAuthorized = settings.authorizationStatus == .authorized
            || settings.authorizationStatus == .provisional
            || settings.authorizationStatus == .ephemeral

        guard isAuthorized else {
            await removeAllManagedNotifications()
            return
        }

        await removeAllManagedNotifications()

        let plans = buildPlans(tasks: tasks)
            .sorted { $0.fireDate < $1.fireDate }
            .prefix(maxScheduledNotifications)

        for plan in plans {
            await add(plan.request)
        }
    }

    static func removeAllManagedNotifications() async {
        let pending = await pendingNotificationRequests()
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(identifierPrefix) }
        guard !ids.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }

    private struct Plan {
        let fireDate: Date
        let request: UNNotificationRequest
    }

    private static func buildPlans(tasks: [Task]) -> [Plan] {
        let now = Date()
        let calendar = Calendar.current

        return tasks.compactMap { task in
            guard !task.completed, let dueDate = task.dueDate else { return nil }

            guard let schedule = scheduleDates(
                dueDate: dueDate,
                dueDateHasTime: task.dueDateHasTime,
                now: now,
                calendar: calendar
            ) else {
                return nil
            }

            let identifier = identifierPrefix + task.id.uuidString
            let content = makeContent(taskTitle: task.title, dueDateHasTime: task.dueDateHasTime, dueDate: schedule.dueDate)

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: schedule.fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            return Plan(fireDate: schedule.fireDate, request: request)
        }
    }

    private static func scheduleDates(
        dueDate: Date,
        dueDateHasTime: Bool,
        now: Date,
        calendar: Calendar
    ) -> (fireDate: Date, dueDate: Date)? {
        let dueMoment: Date
        if dueDateHasTime {
            dueMoment = dueDate
        } else {
            let start = calendar.startOfDay(for: dueDate)
            dueMoment = start.addingTimeInterval(86399)
        }

        guard dueMoment > now else { return nil }

        let minimumLead: TimeInterval = 5
        let fireDate: Date

        if dueDateHasTime {
            let desired = dueMoment.addingTimeInterval(-leadTimeWithTime)
            fireDate = max(desired, now.addingTimeInterval(minimumLead))
        } else {
            let start = calendar.startOfDay(for: dueDate)
            let desired = calendar.date(bySettingHour: fireHourWithoutTime, minute: 0, second: 0, of: start)
                ?? start.addingTimeInterval(TimeInterval(fireHourWithoutTime) * 3600)
            fireDate = max(desired, now.addingTimeInterval(minimumLead))
        }

        guard fireDate < dueMoment else { return nil }
        return (fireDate: fireDate, dueDate: dueMoment)
    }

    private static func makeContent(taskTitle: String, dueDateHasTime: Bool, dueDate: Date) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = "TaskPulse"

        if dueDateHasTime {
            let timeString = DateFormatter.localizedString(from: dueDate, dateStyle: .none, timeStyle: .short)
            content.body = "任务即将逾期：“\(taskTitle)” 将在 \(timeString) 截止"
        } else {
            content.body = "任务即将逾期：“\(taskTitle)” 今天结束前到期"
        }

        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
        }

        return content
    }

    private static func notificationSettings() async -> UNNotificationSettings {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }

    private static func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }

    private static func pendingNotificationRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }

    private static func add(_ request: UNNotificationRequest) async {
        await withCheckedContinuation { continuation in
            center.add(request) { _ in
                continuation.resume()
            }
        }
    }
}
