// StatsCard.swift
// TaskPulse
//
// Cosmic Minimalism Stats Card

import SwiftUI

struct StatsCard: View {
    let icon: String
    let color: Color
    let value: Int
    let label: String

    @State private var isAnimated = false
    @State private var displayedValue = 0

    var body: some View {
        VStack(spacing: 12) {
            // Icon with glow
            ZStack {
                // Pulsing background
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                    .scaleEffect(isAnimated ? 1.1 : 1.0)
                    .opacity(isAnimated ? 0.5 : 0.8)
                    .animation(
                        .easeInOut(duration: 2).repeatForever(autoreverses: true),
                        value: isAnimated
                    )

                // Icon
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
                    .shadow(color: color.opacity(0.5), radius: 4)
            }

            // Value
            Text("\(displayedValue)")
                .font(.cosmicMonoLarge)
                .foregroundColor(.cosmicTextPrimary)
                .contentTransition(.numericText(value: Double(displayedValue)))

            // Labels
            VStack(spacing: 2) {
                Text(label)
                    .font(.cosmicCaption)
                    .foregroundColor(.cosmicTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.cosmicCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.12),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.3),
                                    color.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: color.opacity(0.15), radius: 12, x: 0, y: 6)
        .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
        .onAppear {
            isAnimated = true
            animateValue()
        }
        .onChange(of: value) {
            animateValue()
        }
    }

    private func animateValue() {
        let steps = 20
        let stepDuration = 0.5 / Double(steps)

        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                withAnimation(.easeOut(duration: 0.05)) {
                    displayedValue = Int(Double(value) * Double(step) / Double(steps))
                }
            }
        }
    }
}

// MARK: - Mini Stats Card (for inline use)
struct MiniStatsCard: View {
    let icon: String
    let color: Color
    let value: Int
    let label: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("\(value)")
                    .font(.cosmicHeadline)
                    .foregroundColor(.cosmicTextPrimary)

                Text(label)
                    .font(.cosmicCaption2)
                    .foregroundColor(.cosmicTextMuted)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cosmicSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ZStack {
        Color.cosmicBlack.ignoresSafeArea()
        VStack(spacing: 16) {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                StatsCard(icon: "square.stack.3d.up.fill", color: .electricCyan, value: 24, label: "总任务")
                StatsCard(icon: "checkmark.seal.fill", color: .pulseSuccess, value: 18, label: "已完成")
                StatsCard(icon: "bolt.fill", color: .cosmicAmber, value: 4, label: "进行中")
                StatsCard(icon: "exclamationmark.octagon.fill", color: .pulseDanger, value: 2, label: "逾期")
            }
            .padding()

            HStack(spacing: 8) {
                MiniStatsCard(icon: "bolt.fill", color: .cosmicAmber, value: 4, label: "进行中")
                MiniStatsCard(icon: "checkmark", color: .pulseSuccess, value: 18, label: "完成")
            }
            .padding(.horizontal)
        }
    }
    .preferredColorScheme(.dark)
}
