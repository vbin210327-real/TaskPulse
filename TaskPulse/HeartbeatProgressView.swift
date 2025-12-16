//
//  HeartbeatProgressView.swift
//  TaskPulse
//
//  Cosmic Minimalism Progress View

import SwiftUI

struct HeartCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let midY = h * 0.5

        // Start
        path.move(to: CGPoint(x: 0, y: midY))
        path.addLine(to: CGPoint(x: w * 0.08, y: midY))

        // Left EKG Waves
        path.addLine(to: CGPoint(x: w * 0.11, y: midY - h * 0.08)) // p wave
        path.addLine(to: CGPoint(x: w * 0.14, y: midY))
        path.addLine(to: CGPoint(x: w * 0.17, y: midY))
        path.addLine(to: CGPoint(x: w * 0.20, y: midY + h * 0.12)) // q wave
        path.addLine(to: CGPoint(x: w * 0.23, y: midY - h * 0.25)) // r wave
        path.addLine(to: CGPoint(x: w * 0.26, y: midY + h * 0.2)) // s wave
        path.addLine(to: CGPoint(x: w * 0.29, y: midY))
        path.addLine(to: CGPoint(x: w * 0.35, y: midY))

        // Heart shape
        path.addCurve(to: CGPoint(x: w * 0.5, y: h * 0.3),
                      control1: CGPoint(x: w * 0.38, y: h * 0.1),
                      control2: CGPoint(x: w * 0.45, y: h * 0.15))
        path.addCurve(to: CGPoint(x: w * 0.65, y: midY),
                      control1: CGPoint(x: w * 0.55, y: h * 0.15),
                      control2: CGPoint(x: w * 0.62, y: h * 0.1))

        // Right EKG Waves (symmetrical)
        path.addLine(to: CGPoint(x: w * 0.71, y: midY))
        path.addLine(to: CGPoint(x: w * 0.74, y: midY + h * 0.2)) // s wave
        path.addLine(to: CGPoint(x: w * 0.77, y: midY - h * 0.25)) // r wave
        path.addLine(to: CGPoint(x: w * 0.80, y: midY + h * 0.12)) // q wave
        path.addLine(to: CGPoint(x: w * 0.83, y: midY))
        path.addLine(to: CGPoint(x: w * 0.86, y: midY - h * 0.08)) // t wave
        path.addLine(to: CGPoint(x: w * 0.89, y: midY))
        path.addLine(to: CGPoint(x: w, y: midY))

        return path
    }
}


struct HeartbeatProgressView: View {
    var progress: Double

    @State private var animateGlow = false

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("平均进度")
                        .font(.cosmicTitle3)
                        .foregroundColor(.cosmicTextPrimary)

                    Text("Average Progress")
                        .font(.cosmicCaption2)
                        .foregroundColor(.cosmicTextMuted)
                        .textCase(.uppercase)
                        .tracking(1)
                }

                Spacer()

                // Progress Value
                Text("\(Int(progress * 100))%")
                    .font(.cosmicMonoLarge)
                    .foregroundColor(.electricCyan)
                    .contentTransition(.numericText(value: progress * 100))
            }

            // Heartbeat Line
            TimelineView(.animation(minimumInterval: 0.03, paused: progress == 0)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let pulse = sin(time * 4) * (progress > 0 ? 1 : 0)
                let glowIntensity = 4 + pulse * 2

                ZStack {
                    // Background track
                    HeartCurveShape()
                        .stroke(
                            Color.cosmicSurface,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        )

                    // Actual progress with glow
                    HeartCurveShape()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [.electricCyan, .cosmicLavender],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        )
                        .shadow(color: .electricCyan.opacity(0.8), radius: glowIntensity)
                        .shadow(color: .electricCyan.opacity(0.4), radius: glowIntensity * 2)

                    // Leading edge glow point
                    if progress > 0 {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                            .shadow(color: .electricCyan, radius: 6)
                            .shadow(color: .white.opacity(0.8), radius: 3)
                            .position(getPointOnPath(at: progress))
                            .animation(.easeInOut(duration: 0.3), value: progress)
                    }
                }
                .frame(height: 100)
            }

            // Mini stats
            HStack(spacing: 20) {
                miniStat(icon: "waveform.path.ecg", label: "活跃", color: .electricCyan)
                miniStat(icon: "heart.fill", label: "健康", color: .pulseDanger)
                miniStat(icon: "bolt.fill", label: "高效", color: .cosmicAmber)
            }
        }
    }

    private func miniStat(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)

            Text(label)
                .font(.cosmicCaption2)
                .foregroundColor(.cosmicTextMuted)
        }
    }

    private func getPointOnPath(at progress: Double) -> CGPoint {
        // Approximate position based on progress
        // This is a simplified calculation - for perfect accuracy you'd trace the actual path
        let x = progress * UIScreen.main.bounds.width * 0.85
        let baseY: CGFloat = 50

        // Add variation based on the EKG pattern
        var yOffset: CGFloat = 0
        if progress > 0.2 && progress < 0.3 {
            yOffset = -25 * sin((progress - 0.2) * 10 * .pi)
        } else if progress > 0.35 && progress < 0.65 {
            yOffset = -20 * sin((progress - 0.35) * 3.33 * .pi)
        } else if progress > 0.74 && progress < 0.84 {
            yOffset = -25 * sin((progress - 0.74) * 10 * .pi)
        }

        return CGPoint(x: x + 30, y: baseY + yOffset)
    }
}

#Preview {
    ZStack {
        Color.cosmicBlack.ignoresSafeArea()
        HeartbeatProgressView(progress: 0.75)
            .cosmicCard(padding: 20)
            .padding()
    }
    .preferredColorScheme(.dark)
}
