// TaskCard.swift
// TaskPulse
//
// Created by AI Assistant.

import SwiftUI

struct TaskCard: View {
    @ObservedObject var task: Task
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var onToggleComplete: (() -> Void)? = nil
    var onToggleSubtask: ((UUID) -> Void)? = nil
    @State private var isExpanded = false
    
    var borderColor: Color {
        if task.isOverdue { return .red }
        if task.isNearDue { return .yellow }
        if task.completed { return .green }
        switch task.priority {
        case .high: return .red.opacity(0.7)
        case .medium: return .orange.opacity(0.7)
        case .low: return .green.opacity(0.7)
        }
    }
    var bgColor: Color {
        if task.completed { return .green.opacity(0.08) }
        if task.isOverdue { return .red.opacity(0.08) }
        if task.isNearDue { return .yellow.opacity(0.08) }
        switch task.priority {
        case .high: return .red.opacity(0.04)
        case .medium: return .orange.opacity(0.04)
        case .low: return .green.opacity(0.04)
        }
    }
    var statusIcon: String {
        if task.completed { return "checkmark" }
        if task.isOverdue { return "exclamationmark.triangle" }
        if task.isNearDue { return "clock" }
        return "circle"
    }
    var statusColor: Color {
        if task.completed { return .green }
        if task.isOverdue { return .red }
        if task.isNearDue { return .yellow }
        return .gray
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(task.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(task.priority.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(task.priority.color.opacity(0.8))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    if let desc = task.description, !desc.isEmpty {
                        Text(desc)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack(spacing: 8) {
                if let due = task.dueDate {
                    HStack(spacing: 2) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(due, style: .date)
                            .font(.caption)
                            .foregroundColor(task.isOverdue ? .red : .gray)
                    }
                }
                if task.completed {
                    Label("已完成", systemImage: "checkmark.seal.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                } else if task.isOverdue {
                    Label("逾期", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                } else if task.isNearDue {
                    Label("即将截止", systemImage: "clock.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                } else {
                    Label("进行中", systemImage: "hourglass")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                Spacer()
                
                // 使用更好的按钮样式，增大触摸区域
                HStack(spacing: 12) {
                if let onEdit = onEdit {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44) // 增大触摸区域
                        }
                        .buttonStyle(BorderlessButtonStyle())
                }
                    
                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 44, height: 44) // 增大触摸区域
                        }
                        .buttonStyle(BorderlessButtonStyle())
                }
                    
                if let onToggleComplete = onToggleComplete {
                    Button(action: onToggleComplete) {
                        Image(systemName: task.completed ? "arrow.uturn.left" : "checkmark")
                                .foregroundColor(task.completed ? .orange : .green)
                                .frame(width: 44, height: 44) // 增大触摸区域
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            .padding(.top, 4)

            // DNA Progress Bar
            HStack {
                Text("进度")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                // 使用常规进度条，色相随进度变化
                ColorfulProgressView(progress: task.progress)
                    .frame(height: 8)
                
                Text("\(Int(task.progress * 100))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Subtasks Expander
            if !task.subtasks.isEmpty {
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    HStack {
                        Label("子任务: \(task.subtasks.filter { $0.completed }.count)/\(task.subtasks.count)", systemImage: "checklist")
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(minHeight: 44) // 增大触摸区域
                }
                .buttonStyle(BorderlessButtonStyle())

                if isExpanded {
                    ForEach(task.subtasks) { subtask in
                        HStack {
                            Text(subtask.title)
                            Spacer()
                            Button(action: { onToggleSubtask?(subtask.id) }) {
                                Image(systemName: subtask.completed ? "checkmark.square.fill" : "square")
                                    .foregroundColor(subtask.completed ? .green : .gray)
                                    .frame(width: 44, height: 44) // 增大触摸区域
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(.leading)
                    }
                }
            }
        }
        .padding()
        .background(bgColor)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 2)
        )
        .cornerRadius(12)
        .shadow(color: borderColor.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

extension Priority {
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

struct ColorfulProgressView: View {
    let progress: Double
    
    // 根据进度计算色相值 (0.0 = 红色, 0.33 = 绿色, 0.66 = 蓝色)
    private var progressColor: Color {
        let hue = progress * 0.33 // 从红色(0)到绿色(0.33)
        return Color(hue: hue, saturation: 0.8, brightness: 0.9)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景轨道
                RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                // 进度条
                RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                progressColor.opacity(0.8),
                                progressColor,
                                progressColor.opacity(0.9)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: geometry.size.height)
                    .shadow(color: progressColor.opacity(0.4), radius: 2, x: 0, y: 1)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
    }
}



#Preview {
    TaskCard(task: Task(title: "示例任务", description: "任务描述", dueDate: Date(), priority: .high, completed: false))
} 