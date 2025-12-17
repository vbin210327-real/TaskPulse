// FilterView.swift
// TaskPulse
//
// Cosmic Minimalism Filter View

import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var priority: Priority?
    @Binding var status: TaskStatus?
    @Binding var startDate: Date?
    @Binding var endDate: Date?

    @State private var localStatus: TaskStatus?
    @State private var localPriority: Priority?
    @State private var hasDateRange = false

    init(priority: Binding<Priority?>, status: Binding<TaskStatus?>, startDate: Binding<Date?>, endDate: Binding<Date?>) {
        self._priority = priority
        self._status = status
        self._startDate = startDate
        self._endDate = endDate
        self._localStatus = State(initialValue: status.wrappedValue)
        self._localPriority = State(initialValue: priority.wrappedValue)
        self._hasDateRange = State(initialValue: startDate.wrappedValue != nil || endDate.wrappedValue != nil)
    }

    enum TaskStatus: String, CaseIterable {
        case completed = "已完成"
        case inProgress = "进行中"
        case overdue = "逾期"

        var icon: String {
            switch self {
            case .completed: return "checkmark.seal.fill"
            case .inProgress: return "bolt.fill"
            case .overdue: return "exclamationmark.triangle.fill"
            }
        }

        var color: Color {
            switch self {
            case .completed: return .pulseSuccess
            case .inProgress: return .cosmicAmber
            case .overdue: return .pulseDanger
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cosmicBlack.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Priority Section
                        filterSection(title: "优先级") {
                            priorityOptions
                        }

                        // Status Section
                        filterSection(title: "状态") {
                            statusOptions
                        }

                        // Date Range Section
                        filterSection(title: "截止日期范围") {
                            dateRangeOptions
                        }

                        // Reset Button
                        Button(action: resetFilters) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("重置筛选")
                            }
                            .font(.cosmicCaption)
                            .foregroundColor(.cosmicTextMuted)
                            .padding(.vertical, 12)
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("筛选条件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .font(.cosmicBody)
                    .foregroundColor(.cosmicTextSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("应用") {
                        applyFilters()
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

    // MARK: - Filter Section Container
    private func filterSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.cosmicHeadline)
                    .foregroundColor(.cosmicTextPrimary)
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Priority Options
    private var priorityOptions: some View {
        HStack(spacing: 8) {
            FilterOptionButton(
                title: "全部",
                isSelected: localPriority == nil,
                color: .electricCyan
            ) {
                withAnimation(.spring(response: 0.3)) {
                    localPriority = nil
                }
            }

            ForEach(Priority.allCases, id: \.self) { p in
                FilterOptionButton(
                    title: p.rawValue,
                    isSelected: localPriority == p,
                    color: p.cosmicColor
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        localPriority = p
                    }
                }
            }
        }
    }

    // MARK: - Status Options
    private var statusOptions: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                FilterOptionButton(
                    title: "全部",
                    icon: "square.stack.3d.up.fill",
                    isSelected: localStatus == nil,
                    color: .electricCyan
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        localStatus = nil
                    }
                }

                ForEach(TaskStatus.allCases, id: \.self) { s in
                    FilterOptionButton(
                        title: s.rawValue,
                        icon: s.icon,
                        isSelected: localStatus == s,
                        color: s.color
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            localStatus = s
                        }
                    }
                }
            }
        }
    }

    // MARK: - Date Range Options
    private var dateRangeOptions: some View {
        VStack(spacing: 12) {
            // Toggle
            HStack {
                Text("启用日期筛选")
                    .font(.cosmicSubheadline)
                    .foregroundColor(.cosmicTextSecondary)

                Spacer()

                Toggle("", isOn: $hasDateRange)
                    .tint(.electricCyan)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.cosmicSurface)
            )

            if hasDateRange {
                VStack(spacing: 12) {
                    // Start Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("开始日期")
                            .font(.cosmicCaption)
                            .foregroundColor(.cosmicTextMuted)

                        DatePicker(
                            "",
                            selection: Binding(
                                get: { startDate ?? Date() },
                                set: { startDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .tint(.electricCyan)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.cosmicSurface)
                        )
                    }

                    // End Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("结束日期")
                            .font(.cosmicCaption)
                            .foregroundColor(.cosmicTextMuted)

                        DatePicker(
                            "",
                            selection: Binding(
                                get: { endDate ?? Date() },
                                set: { endDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .tint(.electricCyan)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.cosmicSurface)
                        )
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Actions
    private func applyFilters() {
        status = localStatus
        priority = localPriority
        if !hasDateRange {
            startDate = nil
            endDate = nil
        }
    }

    private func resetFilters() {
        withAnimation(.spring(response: 0.3)) {
            localStatus = nil
            localPriority = nil
            hasDateRange = false
            startDate = nil
            endDate = nil
        }
    }
}

// MARK: - Filter Option Button
struct FilterOptionButton: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                }

                Text(title)
                    .font(.cosmicCaption)
            }
            .foregroundColor(isSelected ? .cosmicBlack : color)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color : color.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FilterView(priority: .constant(nil), status: .constant(nil), startDate: .constant(nil), endDate: .constant(nil))
        .preferredColorScheme(.dark)
}
