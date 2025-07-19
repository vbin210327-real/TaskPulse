// SettingsView.swift
// TaskPulse
//
// Created by AI Assistant.

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("enableCompletionEffect") private var enableCompletionEffect = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("视觉效果")) {
                    Toggle("完成任务特效", isOn: $enableCompletionEffect)
                }
                
                Section(header: Text("数据管理")) {
                    NavigationLink(destination: RecentlyDeletedView()) {
                        Label("最近删除", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("设置")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
} 