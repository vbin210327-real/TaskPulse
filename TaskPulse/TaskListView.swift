// TaskListView.swift
// TaskPulse
//
// Cosmic Minimalism Task List

import SwiftUI

struct TaskListView: View {
    @ObservedObject var taskManager: TaskManager
    @State private var showingAddTask = false
    @State private var showingFilter = false
    @State private var showingSettings = false
    @State private var selectedTaskForEdit: Task?
    @Binding var taskToAnimate: Task?
    @Binding var applyFilter: FilterView.TaskStatus?
    @AppStorage("enableCompletionEffect") private var enableCompletionEffect = true

    @Namespace private var animationNamespace

    @State private var showingFilterView = false
    @State private var activeFilter: FilterView.TaskStatus? = .inProgress
    @State private var filterPriority: Priority? = nil
    @State private var filterStartDate: Date? = nil
    @State private var filterEndDate: Date? = nil
    @AppStorage("savedActiveFilter") private var savedActiveFilterRaw: String = "inProgress"

    private var savedActiveFilter: FilterView.TaskStatus? {
        get {
            FilterView.TaskStatus(rawValue: savedActiveFilterRaw)
        }
        set {
            savedActiveFilterRaw = newValue?.rawValue ?? "inProgress"
        }
    }

    var filteredTasks: [Task] {
        var tasksToFilter = taskManager.tasks

        if let priority = filterPriority {
            tasksToFilter = tasksToFilter.filter { $0.priority == priority }
        }

        if let startDate = filterStartDate {
            tasksToFilter = tasksToFilter.filter { $0.dueDate != nil && $0.dueDate! >= startDate }
        }

        if let endDate = filterEndDate {
            tasksToFilter = tasksToFilter.filter { $0.dueDate != nil && $0.dueDate! <= endDate }
        }

        switch activeFilter {
        case .none:
            break
        case .some(.completed):
            tasksToFilter = tasksToFilter.filter { $0.completed }
        case .some(.inProgress):
            tasksToFilter = tasksToFilter.filter { !$0.completed && !$0.isOverdue }
        case .some(.overdue):
            tasksToFilter = tasksToFilter.filter { $0.isOverdue }
        }

        return tasksToFilter
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

            // Quick Filter Pills
            quickFilterPills
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            // Task Content
            taskContent
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.cosmicTextSecondary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddTask = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text("添加")
                            .font(.cosmicCaption)
                    }
                    .foregroundColor(.cosmicBlack)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.electricCyan)
                    )
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(taskManager: taskManager)
                .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showingFilterView) {
            FilterView(priority: $filterPriority, status: $activeFilter, startDate: $filterStartDate, endDate: $filterEndDate)
                .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .preferredColorScheme(.dark)
        }
        .sheet(item: $selectedTaskForEdit) { task in
            EditTaskView(task: task, taskManager: taskManager)
                .preferredColorScheme(.dark)
        }
        .onAppear {
            if let filter = applyFilter {
                activeFilter = filter
                applyFilter = nil
            } else {
                activeFilter = savedActiveFilter ?? .inProgress
            }
        }
        .onChange(of: activeFilter) { _, newValue in
            savedActiveFilterRaw = newValue?.rawValue ?? "inProgress"
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("任务列表")
                    .font(.cosmicTitle2)
                    .foregroundColor(.cosmicTextPrimary)

                Text("\(filteredTasks.count) 个任务")
                    .font(.cosmicCaption)
                    .foregroundColor(.cosmicTextMuted)
            }

            Spacer()

            // Advanced Filter Button
            Button(action: { showingFilterView = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 14, weight: .medium))
                    Text("筛选")
                        .font(.cosmicCaption)
                }
                .foregroundColor(.cosmicLavender)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.cosmicLavender.opacity(0.15))
                        .overlay(
                            Capsule()
                                .stroke(Color.cosmicLavender.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }

    // MARK: - Quick Filter Pills
    private var quickFilterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterPill(
                    title: "进行中",
                    icon: "bolt.fill",
                    isSelected: activeFilter == .inProgress,
                    color: .cosmicAmber
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        activeFilter = .inProgress
                    }
                }

                FilterPill(
                    title: "已完成",
                    icon: "checkmark.seal.fill",
                    isSelected: activeFilter == .completed,
                    color: .pulseSuccess
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        activeFilter = .completed
                    }
                }

                FilterPill(
                    title: "逾期",
                    icon: "exclamationmark.triangle.fill",
                    isSelected: activeFilter == .overdue,
                    color: .pulseDanger
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        activeFilter = .overdue
                    }
                }

                FilterPill(
                    title: "全部",
                    icon: "square.stack.3d.up.fill",
                    isSelected: activeFilter == nil,
                    color: .electricCyan
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        activeFilter = nil
                    }
                }
            }
        }
    }

    // MARK: - Task Content
    @ViewBuilder
    private var taskContent: some View {
        if filteredTasks.isEmpty {
            emptyStateView
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(Array(filteredTasks.enumerated()), id: \.element.id) { index, task in
                        TaskCard(
                            task: task,
                            onEdit: { selectedTaskForEdit = task },
                            onDelete: { taskManager.deleteTask(task) },
                            onToggleComplete: {
                                if enableCompletionEffect && !task.completed {
                                    taskToAnimate = task
                                } else {
                                    withAnimation {
                                        taskManager.toggleCompletion(for: task)
                                    }
                                }
                            },
                            onToggleSubtask: { subtaskId in
                                let taskCompleted = taskManager.toggleSubtaskCompletion(taskId: task.id, subtaskId: subtaskId)
                                if taskCompleted && enableCompletionEffect {
                                    taskToAnimate = task
                                } else if taskCompleted {
                                    withAnimation {
                                        taskManager.toggleCompletion(for: task)
                                    }
                                }
                            }
                        )
                        .matchedGeometryEffect(id: task.id, in: animationNamespace, isSource: true)
                        .opacity(task.id == taskToAnimate?.id ? 0 : 1)
                        .staggeredAppear(index: index, baseDelay: 0.05)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            if activeFilter == .overdue {
                // Celebration for no overdue tasks
                Text("🎉")
                    .font(.system(size: 72))

                VStack(spacing: 8) {
                    Text("零逾期")
                        .font(.cosmicTitle2)
                        .foregroundColor(.cosmicTextPrimary)

                    Text("Perfect! 继续保持")
                        .font(.cosmicSubheadline)
                        .foregroundColor(.cosmicTextSecondary)
                }
            } else if taskManager.tasks.isEmpty {
                // First time empty state
                LogoView()
                    .scaleEffect(0.7)
                    .opacity(0.8)

                VStack(spacing: 8) {
                    Text("开始你的旅程")
                        .font(.cosmicTitle2)
                        .foregroundColor(.cosmicTextPrimary)

                    Text("创建第一个任务，掌控你的时间")
                        .font(.cosmicSubheadline)
                        .foregroundColor(.cosmicTextSecondary)
                }

                Button(action: { showingAddTask = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("创建任务")
                    }
                    .font(.cosmicHeadline)
                    .foregroundColor(.cosmicBlack)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.electricCyan)
                    )
                }
                .padding(.top, 8)
            } else {
                // No tasks in current filter
                Image(systemName: "tray")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(.cosmicTextMuted)

                VStack(spacing: 8) {
                    Text("暂无任务")
                        .font(.cosmicTitle3)
                        .foregroundColor(.cosmicTextPrimary)

                    Text("当前筛选条件下没有任务")
                        .font(.cosmicSubheadline)
                        .foregroundColor(.cosmicTextSecondary)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - Filter Pill Component
struct FilterPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))

                Text(title)
                    .font(.cosmicCaption)
            }
            .foregroundColor(isSelected ? .cosmicBlack : color)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? color : color.opacity(0.12))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        AnimatedCosmicBackground()
        NavigationStack {
            TaskListView(taskManager: TaskManager(), taskToAnimate: .constant(nil), applyFilter: .constant(nil))
        }
    }
    .preferredColorScheme(.dark)
}
