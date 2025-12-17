// Task.swift
// TaskPulse
//
// Created by AI Assistant.

import Foundation
import SwiftUI
import Combine

class Task: Identifiable, Codable, ObservableObject, Equatable {
    @Published var id = UUID()
    @Published var title: String
    @Published var description: String?
    @Published var dueDate: Date?
    @Published var dueDateHasTime: Bool = false
    @Published var priority: Priority
    @Published var subtasks: [Subtask] = []
    @Published var completed: Bool = false

    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, dueDate, dueDateHasTime, priority, subtasks, completed
    }

    init(id: UUID = UUID(), title: String, description: String? = nil, dueDate: Date? = nil, dueDateHasTime: Bool = false, priority: Priority, subtasks: [Subtask] = [], completed: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.dueDateHasTime = dueDateHasTime
        self.priority = priority
        self.subtasks = subtasks
        self.completed = completed
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        dueDateHasTime = try container.decodeIfPresent(Bool.self, forKey: .dueDateHasTime) ?? false
        priority = try container.decode(Priority.self, forKey: .priority)
        subtasks = try container.decode([Subtask].self, forKey: .subtasks)
        completed = try container.decode(Bool.self, forKey: .completed)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(dueDateHasTime, forKey: .dueDateHasTime)
        try container.encode(priority, forKey: .priority)
        try container.encode(subtasks, forKey: .subtasks)
        try container.encode(completed, forKey: .completed)
    }
    
    var progress: Double {
        if completed {
            return 1.0
        }
        
        if subtasks.isEmpty {
            return 0.0
        } else {
            let completedCount = subtasks.filter { $0.completed }.count
            let calculated = Double(completedCount) / Double(subtasks.count)
            // If all subtasks are done but the parent task isn't marked as 'completed' yet,
            // cap it at 0.99 to avoid showing "100%" erroneously in the UI.
            return min(calculated, 0.99)
        }
    }
    
    var progressColor: Color {
        switch progress {
        case 0..<0.5: return .red
        case 0.5..<1.0: return .orange
        case 1.0: return .green
        default: return .gray
        }
    }
    
    var isOverdue: Bool {
        guard let due = dueDate else { return false }
        if completed { return false }

        if dueDateHasTime {
            return due < Date()
        } else {
            // If no time is set, consider it overdue after the end of the due day.
            return Calendar.current.startOfDay(for: due).addingTimeInterval(86399) < Date()
        }
    }
    
    var isNearDue: Bool {
        guard let due = dueDate else { return false }
        let oneDay = 86400.0 // 秒
        return due.timeIntervalSinceNow < oneDay && due.timeIntervalSinceNow > 0 && !completed
    }
}

let sampleTasks: [Task] = [
    Task(title: "完成 SwiftUI 教程", description: "观看 WWDC 视频并完成代码示例。", dueDate: Date().addingTimeInterval(86400 * 2), priority: .high, subtasks: [Subtask(title: "观看视频"), Subtask(title: "编写代码")]),
    Task(title: "准备项目演示", description: "创建幻灯片并练习演讲。", dueDate: Date().addingTimeInterval(86400 * 5), priority: .high, completed: false),
    Task(title: "健身房锻炼", description: "胸部和三头肌锻炼。", dueDate: Date().addingTimeInterval(86400 * -1), priority: .medium, completed: false),
    Task(title: "购买生活用品", description: "牛奶、鸡蛋、面包和水果。", dueDate: Date().addingTimeInterval(86400 * 1), priority: .low, completed: true),
    Task(title: "阅读新书", description: "读完《原子习惯》前三章。", dueDate: Date().addingTimeInterval(86400 * 3), priority: .medium)
] 