//
//  PlanetProgressView.swift
//  TaskPulse
//
//  Cosmic Minimalism Planet Progress

import SwiftUI

struct PlanetProgressView: View {
    let progress: Double

    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Outer glow rings
            ForEach(0..<3) { i in
                Circle()
                    .stroke(Color.electricCyan.opacity(0.1 - Double(i) * 0.03), lineWidth: 1)
                    .frame(width: 170 + CGFloat(i) * 20, height: 170 + CGFloat(i) * 20)
                    .scaleEffect(pulseScale + CGFloat(i) * 0.02)
            }

            // Background ring
            Circle()
                .stroke(Color.cosmicSurface, lineWidth: 12)
                .frame(width: 150, height: 150)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            .electricCyan,
                            .cosmicLavender,
                            .electricCyan
                        ]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 150, height: 150)
                .rotationEffect(.degrees(-90))
                .shadow(color: .electricCyan.opacity(0.6), radius: 8)
                .shadow(color: .electricCyan.opacity(0.3), radius: 16)

            // Orbiting particle
            if progress > 0 {
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .shadow(color: .white, radius: 4)
                    .shadow(color: .electricCyan, radius: 8)
                    .offset(y: -75)
                    .rotationEffect(.degrees(progress * 360 - 90))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progress)
            }

            // Planet
            ZStack {
                // Planet base
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.15, green: 0.25, blue: 0.45),
                                Color(red: 0.08, green: 0.12, blue: 0.25)
                            ]),
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 100, height: 100)

                // Planet atmosphere glow
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.electricCyan.opacity(0.2),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 30,
                            endRadius: 55
                        )
                    )
                    .frame(width: 110, height: 110)

                // Planet rings
                Ellipse()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.electricCyan.opacity(0.4),
                                Color.cosmicLavender.opacity(0.3),
                                Color.electricCyan.opacity(0.4)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 130, height: 35)
                    .rotationEffect(.degrees(-15))
                    .rotation3DEffect(.degrees(60), axis: (x: 1, y: 0, z: 0))

                // Planet surface details
                Circle()
                    .fill(Color.electricCyan.opacity(0.1))
                    .frame(width: 25, height: 25)
                    .offset(x: -20, y: -15)
                    .blur(radius: 8)

                Circle()
                    .fill(Color.cosmicLavender.opacity(0.1))
                    .frame(width: 15, height: 15)
                    .offset(x: 15, y: 20)
                    .blur(radius: 5)

                // Percentage text
                VStack(spacing: 2) {
                    Text("\(Int(progress * 100))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.cosmicTextPrimary)

                    Text("%")
                        .font(.cosmicCaption)
                        .foregroundColor(.cosmicTextSecondary)
                }
            }
            .scaleEffect(pulseScale)

            // Orbiting stars
            ForEach(0..<5) { i in
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 2, height: 2)
                    .offset(x: CGFloat.random(in: -100...100), y: CGFloat.random(in: -100...100))
                    .opacity(Double.random(in: 0.3...0.8))
            }
        }
        .frame(width: 200, height: 200)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseScale = 1.02
            }
        }
    }
}

// MARK: - Alternative Minimal Progress Ring
struct MinimalProgressRing: View {
    let progress: Double
    let color: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.cosmicSurface, lineWidth: size * 0.08)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: size * 0.08,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(0.5), radius: 4)

            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                .foregroundColor(.cosmicTextPrimary)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        Color.cosmicBlack.ignoresSafeArea()
        VStack(spacing: 40) {
            PlanetProgressView(progress: 0.75)

            HStack(spacing: 20) {
                MinimalProgressRing(progress: 0.65, color: .electricCyan, size: 80)
                MinimalProgressRing(progress: 0.85, color: .pulseSuccess, size: 80)
                MinimalProgressRing(progress: 0.45, color: .cosmicAmber, size: 80)
            }
        }
    }
    .preferredColorScheme(.dark)
}
