// TaskListView.swift
// TaskPulse
//
// Created by AI Assistant.

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
        case .none, .some(.all):
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
        NavigationStack {
            VStack {
                HStack {
                    Button(action: { showingFilterView = true }) {
                        Label("筛选", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    Text("共 \(filteredTasks.count) 个任务")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }.padding(.horizontal)
                
                taskContent
            }
            .navigationTitle("任务列表")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加") { showingAddTask = true }
                }
            }
            .sheet(isPresented: $showingAddTask) { AddTaskView(taskManager: taskManager) }
            .sheet(isPresented: $showingFilterView) {
                FilterView(priority: $filterPriority, status: $activeFilter, startDate: $filterStartDate, endDate: $filterEndDate)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(item: $selectedTaskForEdit) { task in
                EditTaskView(task: task, taskManager: taskManager)
            }
        }
        .onAppear {
            if let filter = applyFilter {
                activeFilter = filter
                applyFilter = nil
            } else {
                // 恢复保存的状态
                activeFilter = savedActiveFilter ?? .inProgress
            }
        }
        .onChange(of: activeFilter) { oldValue, newValue in
            // 保存状态变更
            savedActiveFilterRaw = newValue?.rawValue ?? "inProgress"
        }
    }

    @ViewBuilder
    private var taskContent: some View {
        if filteredTasks.isEmpty {
            VStack {
                Spacer()
                let status = activeFilter ?? .inProgress
                if status == .overdue {
                    Text("🎉")
                        .font(.system(size: 80))
                    Text("零逾期！Perfect")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.top)
                } else if taskManager.tasks.isEmpty {
                    LogoView()
                        .scaleEffect(0.8)
                        .opacity(0.7)
                    Text("创建您的第一个任务开始管理工作吧！")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.top)
                } else {
                    Text("还没有任务哦")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
        } else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(filteredTasks) { task in
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
                        .id(task.id)
                    }
                }
                .padding()
            }
        }
    }
} 
 
#Preview {
    TaskListView(taskManager: TaskManager(), taskToAnimate: .constant(nil), applyFilter: .constant(nil))
}
