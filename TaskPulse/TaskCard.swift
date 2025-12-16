// TaskCard.swift
// TaskPulse
//
// Cosmic Minimalism Task Card

import SwiftUI

struct TaskCard: View {
    @ObservedObject var task: Task
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var onToggleComplete: (() -> Void)? = nil
    var onToggleSubtask: ((UUID) -> Void)? = nil
    @State private var isExpanded = false
    @State private var isHovered = false

    // MARK: - Computed Properties
    private var accentColor: Color {
        if task.isOverdue { return .pulseDanger }
        if task.isNearDue { return .cosmicAmber }
        if task.completed { return .pulseSuccess }
        return task.priority.cosmicColor
    }

    private var statusIcon: String {
        if task.completed { return "checkmark.circle.fill" }
        if task.isOverdue { return "exclamationmark.triangle.fill" }
        if task.isNearDue { return "clock.badge.exclamationmark.fill" }
        return "circle"
    }

    private var statusText: String {
        if task.completed { return "已完成" }
        if task.isOverdue { return "逾期" }
        if task.isNearDue { return "即将截止" }
        return "进行中"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            headerRow

            // Description
            if let desc = task.description, !desc.isEmpty {
                Text(desc)
                    .font(.cosmicSubheadline)
                    .foregroundColor(.cosmicTextSecondary)
                    .lineLimit(2)
            }

            // Progress Bar
            progressRow

            // Footer Row
            footerRow

            // Subtasks
            if !task.subtasks.isEmpty {
                subtasksSection
            }
        }
        .padding(16)
        .background(cardBackground)
        .overlay(cardBorder)
        .shadow(color: accentColor.opacity(0.15), radius: 12, x: 0, y: 6)
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }

    // MARK: - Header Row
    private var headerRow: some View {
        HStack(alignment: .top, spacing: 12) {
            // Status Indicator
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: statusIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.cosmicHeadline)
                    .foregroundColor(.cosmicTextPrimary)
                    .lineLimit(2)

                // Priority Badge
                Text(task.priority.rawValue)
                    .font(.cosmicCaption2)
                    .foregroundColor(.cosmicBlack)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(task.priority.cosmicColor)
                    )
            }

            Spacer()

            // Due Date Badge
            if let due = task.dueDate {
                VStack(alignment: .trailing, spacing: 2) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.cosmicTextMuted)

                    Text(due, style: .date)
                        .font(.cosmicCaption2)
                        .foregroundColor(task.isOverdue ? .pulseDanger : .cosmicTextSecondary)
                }
            }
        }
    }

    // MARK: - Progress Row
    private var progressRow: some View {
        VStack(spacing: 8) {
            HStack {
                Text("进度")
                    .font(.cosmicCaption)
                    .foregroundColor(.cosmicTextMuted)

                Spacer()

                Text("\(Int(task.progress * 100))%")
                    .font(.cosmicMono)
                    .foregroundColor(accentColor)
            }

            // Custom Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.cosmicSurface)
                        .frame(height: 6)

                    // Progress Fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [accentColor, accentColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * task.progress, height: 6)
                        .shadow(color: accentColor.opacity(0.5), radius: 4, x: 0, y: 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: task.progress)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Footer Row
    private var footerRow: some View {
        HStack(spacing: 12) {
            // Status Label
            HStack(spacing: 4) {
                Circle()
                    .fill(accentColor)
                    .frame(width: 6, height: 6)

                Text(statusText)
                    .font(.cosmicCaption)
                    .foregroundColor(.cosmicTextSecondary)
            }

            Spacer()

            // Action Buttons
            HStack(spacing: 4) {
                if let onEdit = onEdit {
                    actionButton(icon: "pencil", color: .cosmicLavender, action: onEdit)
                }

                if let onDelete = onDelete {
                    actionButton(icon: "trash", color: .pulseDanger.opacity(0.8), action: onDelete)
                }

                if let onToggleComplete = onToggleComplete {
                    actionButton(
                        icon: task.completed ? "arrow.uturn.backward" : "checkmark",
                        color: task.completed ? .cosmicAmber : .pulseSuccess,
                        action: onToggleComplete
                    )
                }
            }
        }
    }

    private func actionButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color.opacity(0.12))
                )
        }
        .buttonStyle(BorderlessButtonStyle())
    }

    // MARK: - Subtasks Section
    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "checklist")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.cosmicLavender)

                    Text("子任务")
                        .font(.cosmicCaption)
                        .foregroundColor(.cosmicTextSecondary)

                    Text("\(task.subtasks.filter { $0.completed }.count)/\(task.subtasks.count)")
                        .font(.cosmicMono)
                        .foregroundColor(.cosmicLavender)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.cosmicTextMuted)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(BorderlessButtonStyle())

            if isExpanded {
                VStack(spacing: 6) {
                    ForEach(task.subtasks) { subtask in
                        HStack(spacing: 12) {
                            Button(action: { onToggleSubtask?(subtask.id) }) {
                                Image(systemName: subtask.completed ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(subtask.completed ? .pulseSuccess : .cosmicTextMuted)
                            }
                            .buttonStyle(BorderlessButtonStyle())

                            Text(subtask.title)
                                .font(.cosmicSubheadline)
                                .foregroundColor(subtask.completed ? .cosmicTextMuted : .cosmicTextSecondary)
                                .strikethrough(subtask.completed, color: .cosmicTextMuted)

                            Spacer()
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.cosmicSurface.opacity(0.5))
                        )
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Background & Border
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.cosmicCard)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                accentColor.opacity(0.08),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                LinearGradient(
                    colors: [
                        accentColor.opacity(0.4),
                        accentColor.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
}

// MARK: - Priority Extension
extension Priority {
    var color: Color {
        switch self {
        case .high: return .pulseDanger
        case .medium: return .cosmicAmber
        case .low: return .pulseSuccess
        }
    }
}

// MARK: - Colorful Progress View (Kept for compatibility)
struct ColorfulProgressView: View {
    let progress: Double

    private var progressColor: Color {
        let hue = progress * 0.33
        return Color(hue: hue, saturation: 0.8, brightness: 0.9)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .fill(Color.cosmicSurface)
                    .frame(width: geometry.size.width, height: geometry.size.height)

                RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .fill(
                        LinearGradient(
                            colors: [progressColor.opacity(0.8), progressColor],
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
    ZStack {
        Color.cosmicBlack.ignoresSafeArea()
        VStack(spacing: 16) {
            TaskCard(task: Task(title: "设计新功能", description: "完成应用的深色模式设计", dueDate: Date(), priority: .high, completed: false))
            TaskCard(task: Task(title: "代码审查", description: "审查团队提交的PR", dueDate: Date().addingTimeInterval(86400 * 3), priority: .medium, completed: false))
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
