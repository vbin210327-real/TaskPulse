// WelcomeView.swift
// TaskPulse
//
// Created by AI Assistant.

import SwiftUI

struct WelcomeView: View {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @State private var isStarted = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.white, .lightBlue.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    LogoView()
                        .scaleEffect(0.9) // Slightly smaller logo
                    
                    VStack(spacing: 20) {
                        Text("欢迎使用 TaskPulse")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.lightBlue)
                        
                        Text("通过 TaskPulse，您可以高效管理任务和目标，追踪进度，并获得及时提醒。")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            BulletPoint(text: "进度可视化")
                            BulletPoint(text: "子任务分层")
                            BulletPoint(text: "优先级筛选")
                            BulletPoint(text: "逾期提醒")
                            BulletPoint(text: "完成特效")
                        }
                    }
                    
                    Spacer()
                    
                    Button("开始使用") {
                        hasSeenWelcome = true
                        isStarted = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.lightBlue)
                    .font(.title2)
                    .padding(.bottom, 50)
                }
            }
            .navigationDestination(isPresented: $isStarted) {
                MainView()
            }
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.lightBlue)
                .frame(width: 8, height: 8)
            Text(text)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    WelcomeView()
} 
