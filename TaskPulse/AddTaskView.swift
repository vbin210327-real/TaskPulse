// AddTaskView.swift
// TaskPulse
//
// Created by AI Assistant.

import SwiftUI

struct AddTaskView: View {
    @ObservedObject var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate: Date? = nil
    @State private var dueDateHasTime = false
    @State private var priority: Priority = .medium
    @State private var subtasks: [Subtask] = []
    @State private var newSubtaskTitle = ""
    
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
            .navigationTitle("添加新任务")
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
                    .disabled(title.isEmpty)
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
                if title.isEmpty {
                    Text("描述你的新任务")
                        .foregroundColor(.gray.opacity(0.75))
                        .opacity(title.isEmpty ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.3), value: title.isEmpty)
                }
                TextField("", text: $title)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            Section(header: Text("描述")) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $description)
                    .frame(minHeight: 100)
                    .padding(4)

                    if description.isEmpty {
                        Text("描述你的任务细节/注意事项")
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(8)
                            .allowsHitTesting(false)
                            .opacity(description.isEmpty ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.3), value: description.isEmpty)
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            
            Picker("优先级", selection: $priority) {
                ForEach(Priority.allCases, id: \.self) { p in
                    Text(p.rawValue)
                }
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
                    Image(systemName: "circle")
                    TextField("子任务", text: $subtasks[index].title)
                    Button(role: .destructive) {
                        subtasks.remove(at: index)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            HStack {
                ZStack(alignment: .leading) {
                    if newSubtaskTitle.isEmpty {
                        Text("新的子任务...")
                            .foregroundColor(.gray.opacity(0.6))
                            .opacity(newSubtaskTitle.isEmpty ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.3), value: newSubtaskTitle.isEmpty)
                    }
                    TextField("", text: $newSubtaskTitle)
                }
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
        if !newSubtaskTitle.isEmpty {
            subtasks.append(Subtask(title: newSubtaskTitle))
        }
        let finalDescription = description.isEmpty ? nil : description
        taskManager.addTask(
            title: title,
            description: finalDescription,
            dueDate: dueDate,
            hasTime: dueDateHasTime,
            priority: priority
        )
        
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
 