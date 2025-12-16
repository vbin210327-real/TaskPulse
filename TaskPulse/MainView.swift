// MainView.swift
// TaskPulse
//
// Cosmic Minimalism Redesign

import SwiftUI

struct MainView: View {
    @State private var taskManager = TaskManager()
    @State private var selectedTab = 0
    @State private var taskToAnimate: Task? = nil
    @State private var filterToApply: FilterView.TaskStatus? = nil
    @State private var showingFilteredTasks = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated cosmic background
                AnimatedCosmicBackground()
                NoiseOverlay()

                VStack(spacing: 0) {
                    // Content
                    TabView(selection: $selectedTab) {
                        DashboardView(taskManager: taskManager, taskToAnimate: $taskToAnimate) { status in
                            filterToApply = status
                            showingFilteredTasks = true
                        }
                        .tag(0)

                        TaskListView(taskManager: taskManager, taskToAnimate: $taskToAnimate, applyFilter: $filterToApply)
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        cosmicTabBar
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
            }
            .environmentObject(taskManager)
            .navigationBarHidden(taskToAnimate != nil)
            .preferredColorScheme(.dark)
            .overlay {
                if let task = taskToAnimate {
                    CompletionEffect(
                        task: task,
                        taskToAnimate: $taskToAnimate,
                        taskManager: taskManager,
                        onCompletion: {
                            if !task.completed {
                                withAnimation {
                                    taskManager.toggleCompletion(for: task)
                                }
                            }
                        }
                    )
                }
            }
            .sheet(isPresented: $showingFilteredTasks) {
                NavigationStack {
                    ZStack {
                        Color.cosmicBlack.ignoresSafeArea()
                        TaskListView(taskManager: taskManager, taskToAnimate: $taskToAnimate, applyFilter: $filterToApply)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("完成") {
                                showingFilteredTasks = false
                            }
                            .font(.cosmicHeadline)
                            .foregroundColor(.electricCyan)
                        }
                    }
                    .overlay {
                        if let task = taskToAnimate {
                            CompletionEffect(
                                task: task,
                                taskToAnimate: $taskToAnimate,
                                taskManager: taskManager,
                                onCompletion: {
                                    withAnimation {
                                        taskManager.toggleCompletion(for: task)
                                    }
                                }
                            )
                        }
                    }
                }
                .preferredColorScheme(.dark)
            }
        }
    }

    // MARK: - Cosmic Tab Bar
    private var cosmicTabBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<2) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = index
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: index == 0 ? "chart.pie.fill" : "list.bullet.rectangle.fill")
                            .font(.system(size: 16, weight: .semibold))

                        Text(index == 0 ? "概览" : "任务")
                            .font(.cosmicHeadline)
                    }
                    .foregroundColor(selectedTab == index ? .cosmicBlack : .cosmicTextSecondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Group {
                            if selectedTab == index {
                                Capsule()
                                    .fill(Color.electricCyan)
                                    .cosmicGlow(.electricCyan, radius: 6)
                            }
                        }
                    )
                }
                .buttonStyle(.plain)

                if index == 0 {
                    Spacer()
                }
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(Color.cosmicSurface)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

#Preview {
    MainView()
}
