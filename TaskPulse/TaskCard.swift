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
                if let onEdit = onEdit {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                    }.buttonStyle(.plain)
                }
                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                    }.buttonStyle(.plain)
                }
                if let onToggleComplete = onToggleComplete {
                    Button(action: onToggleComplete) {
                        Image(systemName: task.completed ? "arrow.uturn.left" : "checkmark")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(task.completed ? .orange : .green)
                }
            }
            .padding(.top, 4)

            // DNA Progress Bar
            HStack {
                Text("进度")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                // 使用DNA螺旋进度条，水平交叉环绕版本
                MiniDNAProgressView(progress: task.progress)
                    .frame(width: 120, height: 20)
                
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
                }
                .buttonStyle(.plain)

                if isExpanded {
                    ForEach(task.subtasks) { subtask in
                        HStack {
                            Text(subtask.title)
                            Spacer()
                            Button(action: { onToggleSubtask?(subtask.id) }) {
                                Image(systemName: subtask.completed ? "checkmark.square.fill" : "square")
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(subtask.completed ? .green : .gray)
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

struct MiniDNAProgressView: View {
    let progress: Double
    @State private var rotation: Double = 0
    @State private var glowPulse: Double = 0.5
    
    private let segments = 15 // 更多段数用于水平布局
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let segmentWidth = width / CGFloat(segments)
            
            ZStack {
                // 背景微星效果
                ForEach(0..<8, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.3)))
                        .frame(width: 1, height: 1)
                        .position(
                            x: Double.random(in: 0...geometry.size.width),
                            y: Double.random(in: 0...geometry.size.height)
                        )
                }
                
                ForEach(0..<segments, id: \.self) { index in
                    let segmentProgress = Double(index) / Double(segments - 1)
                    let isCompleted = segmentProgress <= progress
                    
                    MiniDNASegmentView(
                        segmentProgress: segmentProgress,
                        isCompleted: isCompleted,
                        rotation: rotation,
                        glowPulse: glowPulse
                    )
                    .offset(x: CGFloat(index) * segmentWidth - width/2 + segmentWidth/2)
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                glowPulse = 1.0
            }
        }
    }
}

struct MiniDNASegmentView: View {
    let segmentProgress: Double
    let isCompleted: Bool
    let rotation: Double
    let glowPulse: Double
    
    private let helixHeight: CGFloat = 8 // 水平螺旋的高度
    
    var body: some View {
        ZStack {
            // 上螺旋链（水平交叉）
            topHelix
            
            // 下螺旋链（水平交叉）
            bottomHelix
            
            // 连接桥梁
            connectionBridge
            
            // 发光粒子（仅完成部分）
            if isCompleted {
                glowingParticle
            }
        }
    }
    
    private var topHelix: some View {
        let angle = segmentProgress * 720 + rotation // 水平螺旋波动
        let y = helixHeight * sin(angle * .pi / 180) // 垂直波动
        
        return ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: isCompleted ? 
                        [Color.cyan, Color.blue.opacity(0.3)] :
                        [Color.gray.opacity(0.2), Color.clear],
                        center: .center,
                        startRadius: 1,
                        endRadius: 3
                    )
                )
                .frame(width: isCompleted ? 4 : 3, height: isCompleted ? 4 : 3)
                .scaleEffect(isCompleted ? (1.0 + 0.2 * glowPulse) : 1.0)
            
            if isCompleted {
                Circle()
                    .fill(Color.cyan.opacity(0.4))
                    .frame(width: 6, height: 6)
                    .blur(radius: 1)
                    .scaleEffect(0.8 + 0.3 * glowPulse)
            }
        }
        .offset(y: y)
        .shadow(
            color: isCompleted ? Color.cyan : Color.clear,
            radius: isCompleted ? (2 + glowPulse) : 0
        )
    }
    
    private var bottomHelix: some View {
        let angle = segmentProgress * 720 + rotation + 180 // 相位差180度
        let y = helixHeight * sin(angle * .pi / 180) // 垂直波动
        
        return ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: isCompleted ? 
                        [Color.blue, Color.purple.opacity(0.3)] :
                        [Color.gray.opacity(0.2), Color.clear],
                        center: .center,
                        startRadius: 1,
                        endRadius: 3
                    )
                )
                .frame(width: isCompleted ? 4 : 3, height: isCompleted ? 4 : 3)
                .scaleEffect(isCompleted ? (1.0 + 0.2 * glowPulse) : 1.0)
            
            if isCompleted {
                Circle()
                    .fill(Color.blue.opacity(0.4))
                    .frame(width: 6, height: 6)
                    .blur(radius: 1)
                    .scaleEffect(0.8 + 0.3 * glowPulse)
            }
        }
        .offset(y: y)
        .shadow(
            color: isCompleted ? Color.blue : Color.clear,
            radius: isCompleted ? (2 + glowPulse) : 0
        )
    }
    
    private var connectionBridge: some View {
        let angle1 = segmentProgress * 720 + rotation
        let angle2 = segmentProgress * 720 + rotation + 180
        let y1 = helixHeight * sin(angle1 * .pi / 180)
        let y2 = helixHeight * sin(angle2 * .pi / 180)
        let bridgeHeight = abs(y2 - y1)
        
        return Rectangle()
            .fill(
                LinearGradient(
                    colors: isCompleted ? 
                    [Color.cyan.opacity(0.6), Color.white.opacity(0.8), Color.blue.opacity(0.6)] :
                    [Color.gray.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: isCompleted ? 1.5 : 0.8, height: max(bridgeHeight, 1))
            .offset(y: (y1 + y2) / 2)
            .shadow(
                color: isCompleted ? Color.white : Color.clear,
                radius: isCompleted ? (1 + 0.5 * glowPulse) : 0
            )
            .scaleEffect(x: isCompleted ? (1.0 + 0.3 * glowPulse) : 1.0)
    }
    
    private var glowingParticle: some View {
        let angle = segmentProgress * 720 + rotation * 3
        let y = helixHeight * 0.5 * sin(angle * .pi / 180)
        
        return Circle()
            .fill(Color.white)
            .frame(width: 2, height: 2)
            .offset(y: y)
            .opacity(0.6 + 0.4 * glowPulse)
            .shadow(color: Color.white, radius: 1)
    }
}

#Preview {
    TaskCard(task: Task(title: "示例任务", description: "任务描述", dueDate: Date(), priority: .high, completed: false))
} 