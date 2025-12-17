// EditTaskView.swift
// TaskPulse
//
// Cosmic Minimalism Edit Task View

import SwiftUI

struct EditTaskView: View {
    @ObservedObject var task: Task
    @ObservedObject var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date?
    @State private var dueDateHasTime: Bool
    @State private var priority: Priority
    @State private var subtasks: [Subtask]
    @State private var newSubtaskTitle = ""

    @FocusState private var isTitleFocused: Bool

    init(task: Task, taskManager: TaskManager) {
        self.task = task
        self.taskManager = taskManager
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.description ?? "")
        _dueDate = State(initialValue: task.dueDate)
        _dueDateHasTime = State(initialValue: task.dueDateHasTime)
        _priority = State(initialValue: task.priority)
        _subtasks = State(initialValue: task.subtasks)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cosmicBlack.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        taskDetailsSection
                        prioritySection
                        dueDateSection
                        subtasksSection

                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("编辑任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .font(.cosmicBody)
                        .foregroundColor(.cosmicTextSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        saveTask()
                        dismiss()
                    }) {
                        Text("保存")
                            .font(.cosmicHeadline)
                            .foregroundColor(title.isEmpty ? .cosmicTextMuted : .electricCyan)
                    }
                    .disabled(title.isEmpty)
                }
            }
            .toolbarBackground(Color.cosmicDeep, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Task Details Section
    private var taskDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "任务详情", icon: "pencil.and.outline")

            // Title Input
            VStack(alignment: .leading, spacing: 8) {
                Text("标题")
                    .font(.cosmicCaption)
                    .foregroundColor(.cosmicTextMuted)

                ZStack(alignment: .leading) {
                    if title.isEmpty {
                        Text("描述你的任务标题...")
                            .font(.cosmicBody)
                            .foregroundColor(.cosmicTextMuted)
                    }
                    TextField("", text: $title)
                        .font(.cosmicBody)
                        .foregroundColor(.cosmicTextPrimary)
                        .focused($isTitleFocused)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.cosmicSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isTitleFocused ? Color.electricCyan.opacity(0.5) : Color.clear, lineWidth: 1)
                        )
                )
            }

            // Description Input
            VStack(alignment: .leading, spacing: 8) {
                Text("描述（可选）")
                    .font(.cosmicCaption)
                    .foregroundColor(.cosmicTextMuted)

                ZStack(alignment: .topLeading) {
                    if description.isEmpty {
                        Text("添加更多细节或注意事项...")
                            .font(.cosmicSubheadline)
                            .foregroundColor(.cosmicTextMuted)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                    TextEditor(text: $description)
                        .font(.cosmicSubheadline)
                        .foregroundColor(.cosmicTextPrimary)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 80)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.cosmicSurface)
                )
            }
        }
    }

    // MARK: - Priority Section
    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "优先级", icon: "flag.fill")

            HStack(spacing: 10) {
                ForEach(Priority.allCases, id: \.self) { p in
                    PriorityButton(priority: p, isSelected: priority == p) {
                        withAnimation(.spring(response: 0.3)) {
                            priority = p
                        }
                    }
                }
            }
        }
    }

    // MARK: - Due Date Section
    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "截止日期", icon: "calendar.badge.clock")

            HStack {
                Text("设置截止时间")
                    .font(.cosmicSubheadline)
                    .foregroundColor(.cosmicTextSecondary)

                Spacer()

                Toggle("", isOn: Binding(
                    get: { dueDate != nil },
                    set: { enabled in setDueDate(enabled: enabled) }
                ))
                .tint(.electricCyan)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.cosmicSurface)
            )

            if dueDate != nil {
                VStack(spacing: 12) {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { dueDate ?? Date() },
                            set: { dueDate = $0 }
                        ),
                        displayedComponents: dueDateHasTime ? [.date, .hourAndMinute] : .date
                    )
                    .datePickerStyle(.graphical)
                    .tint(.electricCyan)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cosmicSurface)
                    )

                    HStack {
                        Text("设置特定时间")
                            .font(.cosmicSubheadline)
                            .foregroundColor(.cosmicTextSecondary)

                        Spacer()

                        Toggle("", isOn: $dueDateHasTime.animation())
                            .tint(.cosmicLavender)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.cosmicSurface)
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Subtasks Section
    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "子任务", icon: "checklist")

            ForEach(subtasks.indices, id: \.self) { index in
                HStack(spacing: 12) {
                    Image(systemName: "circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.cosmicTextMuted)

                    TextField("子任务", text: $subtasks[index].title)
                        .font(.cosmicSubheadline)
                        .foregroundColor(.cosmicTextPrimary)

                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            _ = subtasks.remove(at: index)
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.pulseDanger.opacity(0.8))
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.cosmicSurface)
                )
            }

            HStack(spacing: 12) {
                ZStack(alignment: .leading) {
                    if newSubtaskTitle.isEmpty {
                        Text("添加子任务...")
                            .font(.cosmicSubheadline)
                            .foregroundColor(.cosmicTextMuted)
                    }
                    TextField("", text: $newSubtaskTitle)
                        .font(.cosmicSubheadline)
                        .foregroundColor(.cosmicTextPrimary)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.cosmicSurface)
                )

                Button(action: {
                    if !newSubtaskTitle.isEmpty {
                        withAnimation(.spring(response: 0.3)) {
                            subtasks.append(Subtask(title: newSubtaskTitle))
                            newSubtaskTitle = ""
                        }
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.electricCyan)
                }
                .disabled(newSubtaskTitle.isEmpty)
                .opacity(newSubtaskTitle.isEmpty ? 0.5 : 1)
            }
        }
    }

    // MARK: - Section Header
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.electricCyan)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.cosmicHeadline)
                    .foregroundColor(.cosmicTextPrimary)
            }
        }
    }

    // MARK: - Save
    private func saveTask() {
        if !newSubtaskTitle.isEmpty {
            subtasks.append(Subtask(title: newSubtaskTitle))
            newSubtaskTitle = ""
        }

        subtasks.removeAll { $0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let finalDescription = description.isEmpty ? nil : description

        let updatedTask = Task(
            id: task.id,
            title: title,
            description: finalDescription,
            dueDate: dueDate,
            dueDateHasTime: dueDateHasTime,
            priority: priority,
            subtasks: subtasks,
            completed: task.completed
        )

        taskManager.updateTask(updatedTask)
    }

    private func setDueDate(enabled: Bool) {
        withAnimation(.spring(response: 0.3)) {
            if !enabled {
                dueDate = nil
                dueDateHasTime = false
            } else {
                dueDate = Date()
            }
        }
    }
}

#Preview {
    EditTaskView(task: Task(title: "示例", priority: .medium), taskManager: TaskManager())
        .preferredColorScheme(.dark)
}
