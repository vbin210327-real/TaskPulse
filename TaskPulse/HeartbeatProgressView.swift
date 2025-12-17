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
    var isActive: Bool

    @State private var displayedProgress: Double
    @State private var pendingProgress: Double? = nil
    @State private var isIncreaseBumping = false

    init(progress: Double, isActive: Bool = true) {
        self.progress = progress
        self.isActive = isActive
        _displayedProgress = State(initialValue: 0) // Start at 0 for initial filling animation
    }

    var body: some View {
        let clampedProgress = min(max(progress, 0), 1)

        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("平均进度")
                        .font(.cosmicTitle3)
                        .foregroundColor(.cosmicTextPrimary)
                }

                Spacer()

                // Progress Value
                AnimatedPercentageText(progress: displayedProgress)
                    .font(.cosmicMonoLarge)
                    .foregroundColor(Color(red: 0.63, green: 0.93, blue: 0.82)) // Teal from screenshot
                    .scaleEffect(isIncreaseBumping ? 1.08 : 1.0)
                    .shadow(color: Color(red: 0.63, green: 0.93, blue: 0.82).opacity(isIncreaseBumping ? 0.45 : 0.2), radius: isIncreaseBumping ? 18 : 10)
                    .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isIncreaseBumping)
            }

            // Heartbeat Line
            ZStack {
                // Background track
                HeartCurveShape()
                    .stroke(
                        Color.cosmicSurface,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )

                // Actual progress (no glow)
                HeartCurveShape()
                    .trim(from: 0, to: displayedProgress)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.63, green: 0.93, blue: 0.82), // Teal
                                Color(red: 1.0, green: 0.70, blue: 0.50),  // Peach
                                Color(red: 0.88, green: 0.69, blue: 1.0)   // Lavender
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
            }
            .frame(height: 100)

        }
        .onAppear {
            guard isActive else { return }
            // Add a small delay to avoid clashing with the screen's stagger entrance
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let target = pendingProgress ?? clampedProgress
                pendingProgress = nil
                guard target != displayedProgress else { return }
                applyProgressUpdate(to: target, animated: true)
            }
        }
        .onChange(of: clampedProgress) { _, newValue in
            if isActive {
                applyProgressUpdate(to: newValue, animated: true)
            } else {
                pendingProgress = newValue
            }
        }
        .onChange(of: isActive) { _, newValue in
            guard newValue else { return }
            // Add a small delay to ensure tab switching animation or sheet dismissal is done
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                let target = pendingProgress ?? clampedProgress
                pendingProgress = nil
                guard target != displayedProgress else { return }
                applyProgressUpdate(to: target, animated: true)
            }
        }
    }


    private func applyProgressUpdate(to newValue: Double, animated: Bool) {
        let clampedValue = min(max(newValue, 0), 1)
        let oldValue = displayedProgress

        if animated {
            withAnimation(.easeInOut(duration: 0.55)) {
                displayedProgress = clampedValue
            }
        } else {
            displayedProgress = clampedValue
        }

        guard clampedValue > oldValue else { return }
        triggerIncreaseBump()
    }

    private func triggerIncreaseBump() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
            isIncreaseBumping = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeOut(duration: 0.25)) {
                isIncreaseBumping = false
            }
        }
    }
}

private struct AnimatedPercentageText: View, Animatable {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        Text("\(Int((min(max(progress, 0), 1)) * 100))%")
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
