// SettingsView.swift
// TaskPulse
//
// Cosmic Minimalism Settings View

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

import _Concurrency

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var taskManager: TaskManager

    @AppStorage("enableCompletionEffect") private var enableCompletionEffect = true
    @AppStorage("enableDueSoonNotifications") private var enableDueSoonNotifications = true

    @State private var showingNotificationsPermissionAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cosmicBlack.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Visual Effects Section
                        settingsSection(title: "视觉效果", icon: "sparkles") {
                            SettingsToggleRow(
                                title: "完成任务特效",
                                icon: "bolt.fill",
                                color: .electricCyan,
                                isOn: $enableCompletionEffect
                            )
                        }

                        // Notifications Section
                        settingsSection(title: "通知", icon: "bell.badge.fill") {
                            SettingsToggleRow(
                                title: "即将逾期提醒",
                                icon: "bell.fill",
                                color: .cosmicAmber,
                                isOn: $enableDueSoonNotifications
                            )
                        }

                        // Data Management Section
                        settingsSection(title: "数据管理", icon: "externaldrive.fill") {
                            NavigationLink(destination: RecentlyDeletedView()) {
                                SettingsNavigationRow(
                                    title: "最近删除",
                                    icon: "trash.fill",
                                    color: .pulseDanger
                                )
                            }
                        }

                        // About Section
                        settingsSection(title: "关于", icon: "info.circle.fill") {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("版本")
                                        .font(.cosmicSubheadline)
                                        .foregroundColor(.cosmicTextSecondary)

                                    Spacer()

                                    Text("2.0.0")
                                        .font(.cosmicMono)
                                        .foregroundColor(.cosmicTextMuted)
                                }

                                Divider()
                                    .background(Color.cosmicSurface)

                                HStack {
                                    Text("设计")
                                        .font(.cosmicSubheadline)
                                        .foregroundColor(.cosmicTextSecondary)

                                    Spacer()

                                    Text("Cosmic Minimalism")
                                        .font(.cosmicCaption)
                                        .foregroundColor(.cosmicLavender)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.cosmicSurface)
                            )
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .font(.cosmicHeadline)
                    .foregroundColor(.electricCyan)
                }
            }
            .toolbarBackground(Color.cosmicDeep, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onChange(of: enableDueSoonNotifications) { _, newValue in
            _Concurrency.Task { @MainActor in
                if newValue {
                    let granted = await taskManager.requestDueSoonNotificationsAuthorizationAndSync()
                    if !granted {
                        enableDueSoonNotifications = false
                        showingNotificationsPermissionAlert = true
                    }
                } else {
                    taskManager.syncDueSoonNotifications()
                }
            }
        }
        .alert("无法启用通知", isPresented: $showingNotificationsPermissionAlert) {
            Button("打开设置") { openAppSettings() }
            Button("好", role: .cancel) {}
        } message: {
            Text("请在系统设置中允许 TaskPulse 发送通知。")
        }
    }

    private func openAppSettings() {
#if canImport(UIKit)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
#endif
    }

    // MARK: - Settings Section
    private func settingsSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
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

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Settings Toggle Row
struct SettingsToggleRow: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.cosmicSubheadline)
                    .foregroundColor(.cosmicTextPrimary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(.electricCyan)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.cosmicSurface)
        )
    }
}

// MARK: - Settings Navigation Row
struct SettingsNavigationRow: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.cosmicSubheadline)
                    .foregroundColor(.cosmicTextPrimary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.cosmicTextMuted)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.cosmicSurface)
        )
    }
}

#Preview {
    SettingsView()
        .environmentObject(TaskManager())
        .preferredColorScheme(.dark)
}
