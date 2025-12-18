// CompletionEffect.swift
// TaskPulse
//
// Cosmic Minimalism Completion Effect

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct CompletionEffect: View {
    let task: Task
    @Binding var taskToAnimate: Task?
    @ObservedObject var taskManager: TaskManager
    var onCompletion: () -> Void

    // Animation states
    @State private var cardPiecesFlyOff = false
    @State private var congratulatoryTextVisible = false
    @State private var particlesVisible = false

    var body: some View {
        ZStack {
            // Cosmic background
            Color.cosmicBlack.opacity(0.98).ignoresSafeArea()

            // Particle effects
            if particlesVisible {
                ForEach(0..<30) { i in
                    ParticleView(index: i)
                }
            }

            if let animatingTask = taskToAnimate, animatingTask.id == self.task.id,
               let currentTask = taskManager.tasks.first(where: { $0.id == animatingTask.id }) {
                VStack {
                    Spacer()

                    GeometryReader { geo in
                        ZStack {
                            let cardView = TaskCard(task: currentTask)
                                .frame(width: geo.size.width, height: geo.size.height)

                            // Bottom-left piece
                            cardView
                                .clipShape(BottomLeftPiece())
                                .offset(x: cardPiecesFlyOff ? -geo.size.width * 0.8 : 0, y: cardPiecesFlyOff ? geo.size.height * 0.5 : 0)
                                .rotation3DEffect(
                                    .degrees(cardPiecesFlyOff ? -60 : 0),
                                    axis: (x: 0, y: 1, z: 0.2),
                                    anchor: .center
                                )
                                .opacity(cardPiecesFlyOff ? 0 : 1)

                            // Top-right piece
                            cardView
                                .clipShape(TopRightPiece())
                                .offset(x: cardPiecesFlyOff ? geo.size.width * 0.8 : 0, y: cardPiecesFlyOff ? -geo.size.height * 0.5 : 0)
                                .rotation3DEffect(
                                    .degrees(cardPiecesFlyOff ? 60 : 0),
                                    axis: (x: 0.2, y: -1, z: 0),
                                    anchor: .center
                                )
                                .opacity(cardPiecesFlyOff ? 0 : 1)
                        }
                    }
                    .padding(.horizontal, 40)
                    .aspectRatio(1.5, contentMode: .fit)

                    // Congratulatory message...
                    if congratulatoryTextVisible {
                        VStack(spacing: 16) {
                            Text("🎉")
                                .font(.system(size: 64))

                            VStack(spacing: 8) {
                                Text("干得漂亮！")
                                    .font(.cosmicTitle)
                                    .foregroundColor(.cosmicTextPrimary)

                                Text("气运 +1")
                                    .font(.cosmicHeadline)
                                    .foregroundColor(.electricCyan)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.electricCyan.opacity(0.2))
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.electricCyan.opacity(0.5), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.5).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }

                    Spacer()
                    Spacer()
                }
                .transition(.opacity)
                .onAppear(perform: runAnimationSequence)
            }
        }
        .ignoresSafeArea()
    }

    private func runAnimationSequence() {
        Haptics.prepare()

        // 1. First, show the static card and some subtle background particles
        withAnimation(.easeIn(duration: 0.3)) {
            particlesVisible = true
        }

        // 2. Wait for exactly 0.5s - the perfect "registration" pause
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 3. Now start the self-breakup
            Haptics.impact(.medium)
            withAnimation(.easeOut(duration: 2.2)) {
                cardPiecesFlyOff = true
            }

            // 4. Burst the message out almost immediately (0.15s delay)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                Haptics.notification(.success)
                withAnimation(.spring(response: 0.8, dampingFraction: 0.65, blendDuration: 1.0)) {
                    congratulatoryTextVisible = true
                }
            }
        }

        // 5. Final dismissal
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
            withAnimation {
                onCompletion()
                taskToAnimate = nil
            }
        }
    }
}

@MainActor
private enum Haptics {
#if canImport(UIKit)
    private static let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private static let heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private static let notificationGenerator = UINotificationFeedbackGenerator()
#endif

    static func prepare() {
#if canImport(UIKit)
        lightImpactGenerator.prepare()
        notificationGenerator.prepare()
#endif
    }

    static func impact(_ style: ImpactStyle) {
#if canImport(UIKit)
        let generator: UIImpactFeedbackGenerator
        switch style {
        case .light:
            generator = lightImpactGenerator
        case .medium:
            generator = mediumImpactGenerator
        case .heavy:
            generator = heavyImpactGenerator
        }
        generator.prepare()
        generator.impactOccurred()
#endif
    }

    static func notification(_ type: NotificationType) {
#if canImport(UIKit)
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(type.uiKitType)
#endif
    }

    enum ImpactStyle {
        case light
        case medium
        case heavy
    }

    enum NotificationType {
        case success
        case warning
        case error

#if canImport(UIKit)
        fileprivate var uiKitType: UINotificationFeedbackGenerator.FeedbackType {
            switch self {
            case .success: return .success
            case .warning: return .warning
            case .error: return .error
            }
        }
#endif
    }
}

// MARK: - Particle View
struct ParticleView: View {
    let index: Int

    @State private var position: CGPoint = .zero
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0

    var body: some View {
        Circle()
            .fill(index % 2 == 0 ? Color.electricCyan : Color.cosmicLavender)
            .frame(width: CGFloat.random(in: 2...6), height: CGFloat.random(in: 2...6))
            .position(position)
            .opacity(opacity)
            .scaleEffect(scale)
            .blur(radius: 0.5)
            .onAppear {
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height

                position = CGPoint(
                    x: CGFloat.random(in: 0...screenWidth),
                    y: CGFloat.random(in: 0...screenHeight)
                )

                withAnimation(.easeOut(duration: Double.random(in: 0.5...1.5)).delay(Double(index) * 0.05)) {
                    opacity = Double.random(in: 0.3...0.8)
                    scale = CGFloat.random(in: 0.5...1.5)
                }

                withAnimation(.easeInOut(duration: Double.random(in: 1...2)).repeatForever(autoreverses: true).delay(Double(index) * 0.05)) {
                    position = CGPoint(
                        x: position.x + CGFloat.random(in: -30...30),
                        y: position.y + CGFloat.random(in: -30...30)
                    )
                }
            }
    }
}

// Shape for the top-right triangular piece of the card
struct TopRightPiece: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// Shape for the bottom-left triangular piece of the card
struct BottomLeftPiece: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct CompletionEffect_Previews: PreviewProvider {
    static var previews: some View {
        let task = Task(title: "Preview Task", description: "A task for previewing.", dueDate: Date(), priority: .medium)
        let taskManager = TaskManager()
        CompletionEffect(task: task, taskToAnimate: .constant(task), taskManager: taskManager, onCompletion: {})
            .preferredColorScheme(.dark)
    }
}
