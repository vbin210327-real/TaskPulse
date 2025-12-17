// DashboardView.swift
// TaskPulse
//
// Cosmic Minimalism Dashboard

import SwiftUI
import Charts

struct DashboardView: View {
    @ObservedObject var taskManager: TaskManager
    @Binding var taskToAnimate: Task?
    var onCardTapped: ((FilterView.TaskStatus) -> Void)? = nil
    @AppStorage("enableCompletionEffect") private var enableCompletionEffect = true

    var totalTasks: Int { taskManager.tasks.count }
    var completedTasks: Int { taskManager.tasks.filter { $0.completed }.count }
    var inProgressTasks: Int { taskManager.tasks.filter { !$0.completed && !$0.isOverdue }.count }
    var overdueTasks: Int { taskManager.tasks.filter { $0.isOverdue }.count }
    var nearDueTasks: Int { taskManager.tasks.filter { $0.isNearDue }.count }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                headerSection
                    .staggeredAppear(index: 0)

                // Stats Grid
                statsGridSection
                    .staggeredAppear(index: 1)

                // Progress Section
                progressSection
                    .staggeredAppear(index: 2)

                // Near Due Section
                if !taskManager.tasks.filter({ $0.isNearDue }).isEmpty {
                    nearDueSection
                        .staggeredAppear(index: 3)
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greetingText)
                .font(.cosmicCaption)
                .foregroundColor(.cosmicTextSecondary)
                .textCase(.uppercase)
                .tracking(1.5)

            Text("TaskPulse")
                .font(.cosmicLargeTitle)
                .foregroundColor(.cosmicTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 6 { return "深夜了" }
        if hour < 12 { return "早安" }
        if hour < 18 { return "午安" }
        return "晚安"
    }

    // MARK: - Stats Grid
    private var statsGridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            StatsCard(
                icon: "square.stack.3d.up.fill",
                color: .electricCyan,
                value: totalTasks,
                label: "总任务",
                subtitle: "All Tasks"
            )

            StatsCard(
                icon: "checkmark.seal.fill",
                color: .pulseSuccess,
                value: completedTasks,
                label: "已完成",
                subtitle: "Completed"
            )

            StatsCard(
                icon: "bolt.fill",
                color: .cosmicAmber,
                value: inProgressTasks,
                label: "进行中",
                subtitle: "In Progress"
            )

            StatsCard(
                icon: "exclamationmark.octagon.fill",
                color: .pulseDanger,
                value: overdueTasks,
                label: "逾期",
                subtitle: "Overdue"
            )
        }
    }

    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: 20) {
            // Heartbeat Progress
            HeartbeatProgressView(progress: taskManager.averageProgress)
                .cosmicCard(padding: 20)

            // Planet Completion Rate
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("完成率")
                            .font(.cosmicTitle3)
                            .foregroundColor(.cosmicTextPrimary)
                        Text("Completion Rate")
                            .font(.cosmicCaption)
                            .foregroundColor(.cosmicTextMuted)
                            .textCase(.uppercase)
                            .tracking(1)
                    }
                    Spacer()
                }

                PlanetProgressView(progress: taskManager.completionRate)
            }
            .cosmicCard(padding: 20)
        }
    }

    // MARK: - Near Due Section
    private var nearDueSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.badge.exclamationmark.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.cosmicAmber)

                Text("即将逾期")
                    .font(.cosmicTitle3)
                    .foregroundColor(.cosmicTextPrimary)

                Spacer()

                Text("\(nearDueTasks)")
                    .font(.cosmicMonoLarge)
                    .foregroundColor(.cosmicAmber)
            }
            .padding(.horizontal, 4)

            ForEach(Array(taskManager.tasks.filter { $0.isNearDue }.enumerated()), id: \.element.id) { index, task in
                TaskCard(
                    task: task,
                    onEdit: nil,
                    onDelete: { taskManager.deleteTask(task) },
                    onToggleComplete: {
                        if enableCompletionEffect && !task.completed {
                            taskToAnimate = task
                        } else {
                            withAnimation {
                                taskManager.toggleCompletion(for: task)
                            }
                        }
                    }
                )
                .staggeredAppear(index: index, baseDelay: 0.3)
            }
        }
    }

    var notStartedTasks: Int {
        taskManager.tasks.filter { !$0.completed && $0.progress == 0 && !$0.isOverdue }.count
    }
}

#Preview {
    ZStack {
        AnimatedCosmicBackground()
        DashboardView(taskManager: TaskManager(), taskToAnimate: .constant(nil))
    }
    .preferredColorScheme(.dark)
}
