// StatsCard.swift
// TaskPulse
//
// Created by AI Assistant.

import SwiftUI

struct StatsCard: View {
    let icon: String
    let color: Color
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            Text("\(value)")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 80, height: 100)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    StatsCard(icon: "list.bullet", color: .blue, value: 5, label: "总任务")
} 