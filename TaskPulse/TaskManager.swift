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
    private let luckValueKey = "luckValue"

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

    @Published private(set) var luckValue: Int = 0 {
        didSet {
            UserDefaults.standard.set(luckValue, forKey: luckValueKey)
        }
    }
    
    init() {
        luckValue = UserDefaults.standard.integer(forKey: luckValueKey)
        loadTasks()
        loadRecentlyDeletedTasks()
        if tasks.isEmpty {
            tasks = sampleTasks
        }
    }
    
    func addTask(title: String, description: String?, dueDate: Date?, hasTime: Bool, priority: Priority) {
        let newTask = Task(title: title, description: description, dueDate: dueDate, dueDateHasTime: hasTime, priority: priority)
        ensureCompletionConsistency(for: newTask)
        tasks.append(newTask)
    }

    func updateTask(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        ensureCompletionConsistency(for: task)
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
            let wasCompleted = actualTask.completed
            actualTask.completed.toggle()
            if !wasCompleted, actualTask.completed {
                self.awardLuck()
            }
            
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
            awardLuck()
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
        
        // Use a more robust average calculation.
        // If there are any incomplete tasks, the total average should naturally stay below 1.0
        // because each incomplete task contributes at most 0.99 to the sum.
        let totalProgress = tasks.reduce(0) { $0 + $1.progress }
        let average = totalProgress / Double(tasks.count)
        
        // Final safety check: if not all tasks are completed, average cannot be 1.0
        let allCompleted = tasks.allSatisfy { $0.completed }
        if !allCompleted && average >= 1.0 {
            return 0.99
        }
        
        return average
    }

    /// Ensures that if all subtasks are completed, the parent task is also marked as completed.
    func ensureCompletionConsistency(for task: Task) {
        if !task.subtasks.isEmpty && task.subtasks.allSatisfy({ $0.completed }) && !task.completed {
            task.completed = true
            awardLuck()
            
            // Trigger notifications
            task.objectWillChange.send()
            self.objectWillChange.send()
        }
    }

    private func awardLuck() {
        luckValue += 1
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
    private static let planKey = "dueSoonNotificationPlans"
    private static let maxScheduledNotifications = 60
    private static let leadTimeWithTime: TimeInterval = 60 * 60 // 1 hour
    private static let fireHourWithoutTime = 18 // 18:00 on due day
    private static let minimumScheduleDelay: TimeInterval = 5

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

        let now = Date()
        let calendar = Calendar.current

        var storedPlans = loadPlans()
        let existingTaskIds = Set(tasks.map { $0.id.uuidString })
        storedPlans = storedPlans.filter { existingTaskIds.contains($0.key) }

        let plansToSchedule = upsertPlansAndBuildRequests(
            tasks: tasks,
            now: now,
            calendar: calendar,
            storedPlans: &storedPlans
        )

        savePlans(storedPlans)

        await removeAllManagedNotifications()

        let plans = plansToSchedule
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
    }

    private struct Plan {
        let fireDate: Date
        let request: UNNotificationRequest
    }

    private struct StoredPlan: Codable {
        let dueTimestamp: TimeInterval
        let fireTimestamp: TimeInterval?
    }

    private static func upsertPlansAndBuildRequests(
        tasks: [Task],
        now: Date,
        calendar: Calendar,
        storedPlans: inout [String: StoredPlan]
    ) -> [Plan] {
        tasks.compactMap { task in
            let key = task.id.uuidString

            guard !task.completed, let dueDate = task.dueDate else {
                storedPlans.removeValue(forKey: key)
                return nil
            }

            guard let dueMoment = dueMoment(dueDate: dueDate, dueDateHasTime: task.dueDateHasTime, calendar: calendar) else {
                storedPlans.removeValue(forKey: key)
                return nil
            }

            guard dueMoment > now else {
                storedPlans.removeValue(forKey: key)
                return nil
            }

            let dueTimestamp = dueMoment.timeIntervalSince1970

            let planToUse: StoredPlan
            if let existing = storedPlans[key], existing.dueTimestamp == dueTimestamp {
                planToUse = existing
            } else {
                let desired = desiredFireDate(
                    dueDate: dueDate,
                    dueDateHasTime: task.dueDateHasTime,
                    dueMoment: dueMoment,
                    calendar: calendar
                )

                let fireDate: Date?
                if desired > now.addingTimeInterval(minimumScheduleDelay) {
                    fireDate = desired
                } else {
                    let immediate = now.addingTimeInterval(minimumScheduleDelay)
                    fireDate = immediate < dueMoment ? immediate : nil
                }

                let stored = StoredPlan(dueTimestamp: dueTimestamp, fireTimestamp: fireDate?.timeIntervalSince1970)
                storedPlans[key] = stored
                planToUse = stored
            }

            guard let fireTimestamp = planToUse.fireTimestamp else { return nil }
            let fireDate = Date(timeIntervalSince1970: fireTimestamp)

            guard fireDate > now else { return nil }

            let identifier = identifierPrefix + task.id.uuidString
            let content = makeContent(taskTitle: task.title, dueDateHasTime: task.dueDateHasTime, dueDate: dueMoment)

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            return Plan(fireDate: fireDate, request: request)
        }
    }

    private static func dueMoment(
        dueDate: Date,
        dueDateHasTime: Bool,
        calendar: Calendar
    ) -> Date? {
        if dueDateHasTime {
            return dueDate
        } else {
            let start = calendar.startOfDay(for: dueDate)
            return start.addingTimeInterval(86399)
        }
    }

    private static func desiredFireDate(
        dueDate: Date,
        dueDateHasTime: Bool,
        dueMoment: Date,
        calendar: Calendar
    ) -> Date {
        if dueDateHasTime {
            return dueMoment.addingTimeInterval(-leadTimeWithTime)
        } else {
            let start = calendar.startOfDay(for: dueDate)
            return calendar.date(bySettingHour: fireHourWithoutTime, minute: 0, second: 0, of: start)
                ?? start.addingTimeInterval(TimeInterval(fireHourWithoutTime) * 3600)
        }
    }

    private static func loadPlans() -> [String: StoredPlan] {
        guard let data = UserDefaults.standard.data(forKey: planKey),
              let decoded = try? JSONDecoder().decode([String: StoredPlan].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private static func savePlans(_ plans: [String: StoredPlan]) {
        guard let encoded = try? JSONEncoder().encode(plans) else {
            UserDefaults.standard.removeObject(forKey: planKey)
            return
        }
        UserDefaults.standard.set(encoded, forKey: planKey)
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
