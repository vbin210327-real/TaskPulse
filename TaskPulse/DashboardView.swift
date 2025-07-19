// DashboardView.swift
// TaskPulse
//
// Created by AI Assistant.

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
        ScrollView {
            VStack(spacing: 20) {
                // Title and Cards
                HStack(spacing: 10) {
                    StatsCard(icon: "list.bullet", color: .lightBlue, value: totalTasks, label: "总任务")
                    StatsCard(icon: "checkmark.circle", color: .green, value: completedTasks, label: "已完成")
                    StatsCard(icon: "arrow.right.circle", color: .orange, value: inProgressTasks, label: "进行中")
                    StatsCard(icon: "exclamationmark.triangle", color: .red, value: overdueTasks, label: "逾期")
                }

                // Completion Rate and Average Progress in a Vertical Stack
                VStack(spacing: 20) {
                    // Average Progress
                    HeartbeatProgressView(progress: taskManager.averageProgress)
                    
                    // Completion Rate
                    VStack {
                        Text("完成率").font(.headline)
                        PlanetProgressView(progress: taskManager.completionRate)
                    }
                }
                .padding(.vertical)

                // Upcoming Tasks
                Section(header: Text("即将逾期").font(.headline)) {
                    ForEach(taskManager.tasks.filter { $0.isNearDue }) { task in
                        TaskCard(
                            task: task,
                            onEdit: { /* Add edit action if needed */ },
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
                    }
                }
            }
            .padding()
        }
        .navigationTitle("概览")
    }
    
    var notStartedTasks: Int {
        taskManager.tasks.filter { !$0.completed && $0.progress == 0 && !$0.isOverdue }.count
    }
}

#Preview {
    // Note: This preview will not show navigation, as it relies on the parent's NavigationStack.
    // To test navigation, preview the MainView.
    DashboardView(taskManager: TaskManager(), taskToAnimate: .constant(nil))
} 