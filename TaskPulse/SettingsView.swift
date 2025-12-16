// SettingsView.swift
// TaskPulse
//
// Cosmic Minimalism Settings View

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("enableCompletionEffect") private var enableCompletionEffect = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cosmicBlack.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Visual Effects Section
                        settingsSection(title: "视觉效果", subtitle: "Visual Effects", icon: "sparkles") {
                            SettingsToggleRow(
                                title: "完成任务特效",
                                subtitle: "任务完成时显示激光切割动画",
                                icon: "bolt.fill",
                                color: .electricCyan,
                                isOn: $enableCompletionEffect
                            )
                        }

                        // Data Management Section
                        settingsSection(title: "数据管理", subtitle: "Data Management", icon: "externaldrive.fill") {
                            NavigationLink(destination: RecentlyDeletedView()) {
                                SettingsNavigationRow(
                                    title: "最近删除",
                                    subtitle: "恢复已删除的任务",
                                    icon: "trash.fill",
                                    color: .pulseDanger
                                )
                            }
                        }

                        // About Section
                        settingsSection(title: "关于", subtitle: "About", icon: "info.circle.fill") {
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
    }

    // MARK: - Settings Section
    private func settingsSection<Content: View>(
        title: String,
        subtitle: String,
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

                    Text(subtitle)
                        .font(.cosmicCaption2)
                        .foregroundColor(.cosmicTextMuted)
                        .textCase(.uppercase)
                        .tracking(1)
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
    let subtitle: String
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

                Text(subtitle)
                    .font(.cosmicCaption2)
                    .foregroundColor(.cosmicTextMuted)
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
    let subtitle: String
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

                Text(subtitle)
                    .font(.cosmicCaption2)
                    .foregroundColor(.cosmicTextMuted)
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
        .preferredColorScheme(.dark)
}
