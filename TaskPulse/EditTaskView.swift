// EditTaskView.swift
// TaskPulse
//
// Created by AI Assistant.

import SwiftUI

struct EditTaskView: View {
    @ObservedObject var task: Task
    @ObservedObject var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss
    
    // Local state for editing
    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date?
    @State private var dueDateHasTime: Bool
    @State private var priority: Priority
    @State private var subtasks: [Subtask]
    @State private var newSubtaskTitle = ""
    
    init(task: Task, taskManager: TaskManager) {
        self.task = task
        self.taskManager = taskManager
        self._title = State(initialValue: task.title)
        self._description = State(initialValue: task.description ?? "")
        self._dueDate = State(initialValue: task.dueDate)
        self._dueDateHasTime = State(initialValue: task.dueDateHasTime)
        self._priority = State(initialValue: task.priority)
        self._subtasks = State(initialValue: task.subtasks)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    taskDetailsSection
                    dueDateSection
                    subtasksSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("编辑任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveTask()
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    // MARK: - View Sections
    private var taskDetailsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("任务详情", systemImage: "pencil.and.ruler.fill")
                .font(.title2.bold())
                .foregroundColor(.accentColor)
            
            ZStack(alignment: .leading) {
                if title.isEmpty { Text("描述你的任务标题").foregroundColor(.gray.opacity(0.75)) }
                TextField("", text: $title)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            ZStack(alignment: .topLeading) {
                if description.isEmpty {
                    Text("描述你的任务细节、注意事项等")
                        .foregroundColor(.gray.opacity(0.75))
                        .padding(.top, 8)
                }
                TextEditor(text: $description)
                    .frame(minHeight: 100)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Picker("优先级", selection: $priority) {
                ForEach(Priority.allCases, id: \.self) { p in Text(p.rawValue) }
            }
            .pickerStyle(.segmented)
        }
    }

    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("截止日期", systemImage: "calendar.badge.clock")
                .font(.title2.bold())
                .foregroundColor(.accentColor)

            Toggle("设置截止时间", isOn: Binding(
                get: { dueDate != nil },
                set: { enabled in setDueDate(enabled: enabled) }
            ))
            .tint(.accentColor)

            if dueDate != nil {
                DatePicker("截止日期", selection: Binding(
                    get: { dueDate ?? Date() },
                    set: { dueDate = $0 }
                ), displayedComponents: dueDateHasTime ? [.date, .hourAndMinute] : .date)
                .datePickerStyle(.graphical)
                
                Toggle("设置特定时间", isOn: $dueDateHasTime.animation())
                    .tint(.accentColor)
            }
        }
    }
    
    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("子任务", systemImage: "checklist")
                .font(.title2.bold())
                .foregroundColor(.accentColor)

            ForEach(subtasks.indices, id: \.self) { index in
                HStack {
                    Image(systemName: subtasks[index].completed ? "checkmark.circle.fill" : "circle")
                    TextField("子任务", text: $subtasks[index].title)
                    Button(role: .destructive) {
                        subtasks.remove(at: index)
                    } label: { Image(systemName: "minus.circle.fill") }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            HStack {
                TextField("新子任务...", text: $newSubtaskTitle)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                Button(action: {
                    if !newSubtaskTitle.isEmpty {
                        subtasks.append(Subtask(title: newSubtaskTitle))
                        newSubtaskTitle = ""
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
    
    // MARK: - Functions
    private func saveTask() {
        let finalDescription = description.isEmpty ? nil : description
        subtasks.removeAll { $0.title.isEmpty }
        
        // Create an updated task instance
        let updatedTask = Task(id: task.id, title: title, description: finalDescription, dueDate: dueDate, dueDateHasTime: dueDateHasTime, priority: priority, subtasks: subtasks, completed: task.completed)
        
        // Update the task in the manager
        taskManager.updateTask(updatedTask)
        
        // Dismiss the view
        dismiss()
    }
    
    private func setDueDate(enabled: Bool) {
        withAnimation {
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
} 