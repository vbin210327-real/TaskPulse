// FilterView.swift
// TaskPulse
//
// Created by AI Assistant.

import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var priority: Priority?
    @Binding var status: TaskStatus?
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    
    @State private var localStatus: TaskStatus?
    
    enum TaskStatus: String, CaseIterable {
        case all = "全部状态"
        case completed = "已完成"
        case inProgress = "进行中"
        case overdue = "逾期"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("筛选条件") {
                    Picker("优先级", selection: $priority) {
                        Text("全部优先级").tag(Priority?(nil))
                        ForEach(Priority.allCases, id: \.self) { p in
                            Text(p.rawValue).tag(Priority?(p))
                        }
                    }
                    Picker("状态", selection: $localStatus) {
                        Text("全部状态").tag(TaskStatus?(nil))
                        ForEach(TaskStatus.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(TaskStatus?(s))
                        }
                    }
                }
                Section("截止日期范围") {
                    DatePicker("开始日期", selection: Binding<Date>(get: { startDate ?? Date() }, set: { startDate = $0 }), displayedComponents: .date)
                    DatePicker("结束日期", selection: Binding<Date>(get: { endDate ?? Date() }, set: { endDate = $0 }), displayedComponents: .date)
                }
            }
            .navigationTitle("筛选条件")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { 
                        status = localStatus
                        dismiss() 
                    }
                }
            }
            .onAppear {
                // 设置初始值：如果当前状态为空，则默认为"进行中"
                localStatus = status ?? .inProgress
            }
        }
    }
}

#Preview {
    FilterView(priority: .constant(nil), status: .constant(nil), startDate: .constant(nil), endDate: .constant(nil))
} 