// FortuneMeterView.swift
// TaskPulse
//
// "气运值" meter shown on Dashboard.

import SwiftUI

struct FortuneMeterView: View {
    let luckValue: Int
    var isActive: Bool = true

    private let maxVisualValue = 100

    @State private var animatedProgress: Double = 0
    @State private var displayedLuck: Double = 0
    @State private var pendingLuck: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("气运值")
                        .font(.cosmicTitle3)
                        .foregroundColor(.cosmicTextPrimary)
                }

                Spacer()

                AnimatedLuckText(value: displayedLuck)
                    .font(.cosmicMonoLarge)
                    .foregroundColor(.cosmicAmber)
            }

            FortuneMeterBar(progress: animatedProgress, currentLuck: displayedLuck)
                .frame(height: 48)
        }
        .onAppear {
            guard isActive else { return }
            // Small delay for initial fill
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                updateAnimations(to: luckValue, animated: true)
            }
        }
        .onChange(of: luckValue) { _, newValue in
            if isActive {
                updateAnimations(to: newValue, animated: true)
            } else {
                pendingLuck = newValue
            }
        }
        .onChange(of: isActive) { _, newValue in
            guard newValue else { return }
            // Delay for tab/sheet transitions
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                let target = pendingLuck ?? luckValue
                pendingLuck = nil
                updateAnimations(to: target, animated: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("气运值 \(luckValue)")
    }

    private func updateAnimations(to newValue: Int, animated: Bool) {
        // Progress is relative to current level (every 500 points)
        // If at max level (V10, which starts at 4500), we could stay full or keep modulo logic.
        // Let's keep modulo for all levels for a consistent "filling up" experience.
        let levelProgress = newValue % maxVisualValue
        let targetProgress = progressValue(for: levelProgress)
        let targetLuck = Double(newValue)

        if animated {
            withAnimation(.easeInOut(duration: 0.55)) {
                animatedProgress = targetProgress
                displayedLuck = targetLuck
            }
        } else {
            animatedProgress = targetProgress
            displayedLuck = targetLuck
        }
    }

    private func progressValue(for value: Int) -> Double {
        guard maxVisualValue > 0 else { return 0 }
        let clamped = min(max(value, 0), maxVisualValue)
        return Double(clamped) / Double(maxVisualValue)
    }
}

private struct AnimatedLuckText: View, Animatable {
    var value: Double

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text("\(Int(value))")
    }
}

private struct FortuneMeterBar: View {
    let progress: Double
    let currentLuck: Double

    private let barHeight: CGFloat = 32
    private let badgeSize: CGFloat = 40

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let containerHeight = geo.size.height
            let clamped = min(max(progress, 0), 1)
            let barY = (containerHeight - barHeight) * 0.5

            ZStack(alignment: .topLeading) {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cosmicLavenderDim.opacity(0.55),
                                Color.cosmicDeep.opacity(0.95)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: barHeight)
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.cosmicLavender.opacity(0.75),
                                        Color.cosmicLavenderDim.opacity(0.35)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .overlay(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.22),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .padding(2)
                            .opacity(0.6)
                            .blendMode(.overlay)
                    )
                    .shadow(color: Color.cosmicLavender.opacity(0.25), radius: 10, x: 0, y: 0)
                    .offset(y: barY)

                let fillWidth = clamped > 0 ? badgeSize + (width - badgeSize) * clamped : 0
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.93, blue: 0.55),
                                Color.cosmicAmber,
                                Color(red: 1.0, green: 0.45, blue: 0.05)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: fillWidth, height: barHeight)
                    .overlay(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.35),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .padding(2)
                            .opacity(0.55)
                            .blendMode(.overlay)
                    )
                    .shadow(color: Color.cosmicAmber.opacity(0.35), radius: 10, x: 0, y: 0)
                    .offset(y: barY)

                FortuneFlameBadge(level: min((Int(currentLuck) / 100) + 1, 10))
                    .frame(width: badgeSize, height: badgeSize)
                    .offset(x: 0, y: (containerHeight - badgeSize) * 0.5)
            }
        }
    }
}

private struct FortuneFlameBadge: View {
    let level: Int
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.cosmicLavender.opacity(0.95),
                            Color.cosmicLavenderDim.opacity(0.55),
                            Color.cosmicDeep.opacity(0.95)
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.cosmicLavender.opacity(0.95),
                                    Color.cosmicLavenderDim.opacity(0.45)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
                .shadow(color: Color.cosmicLavender.opacity(0.35), radius: 12, x: 0, y: 0)

            Image(systemName: "flame.fill")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.93, blue: 0.55),
                            Color.cosmicAmber,
                            Color(red: 1.0, green: 0.35, blue: 0.08)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.cosmicAmber.opacity(0.55), radius: 8, x: 0, y: 0)
            
            // Level Overlay Badge
            Text("V\(level)")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.cosmicBlack)
                .frame(width: 18, height: 18)
                .background(
                    Circle()
                        .fill(Color.cosmicAmber)
                        .shadow(radius: 2)
                )
                .offset(x: 14, y: -14)
        }
    }
}

#Preview {
    ZStack {
        Color.cosmicBlack.ignoresSafeArea()
        FortuneMeterView(luckValue: 7)
            .cosmicCard(padding: 20, clipsContent: true)
            .padding()
    }
    .preferredColorScheme(.dark)
}
