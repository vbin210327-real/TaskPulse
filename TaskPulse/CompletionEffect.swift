// CompletionEffect.swift
// TaskPulse
//
// Created by AI Assistant.

import SwiftUI

struct CompletionEffect: View {
    let task: Task
    @Binding var taskToAnimate: Task?
    var onCompletion: () -> Void // Add a callback for when the animation finishes

    // Animation states
    @State private var showLaser = false
    @State private var laserPathProgress: CGFloat = 0.0
    @State private var cardPiecesFlyOff = false
    @State private var congratulatoryTextVisible = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.95).edgesIgnoringSafeArea(.all)

            if let task = taskToAnimate, task.id == self.task.id {
                VStack {
                    Spacer()
                    
                    GeometryReader { geo in
                        ZStack {
                            let cardView = TaskCard(task: task)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .foregroundColor(.white)
                            
                            // Bottom-left piece
                            cardView
                                .clipShape(BottomLeftPiece())
                                .offset(x: cardPiecesFlyOff ? -geo.size.width * 0.8 : 0, y: cardPiecesFlyOff ? geo.size.height * 0.5 : 0)
                                .rotation3DEffect(
                                    .degrees(cardPiecesFlyOff ? -60 : 0),
                                    axis: (x: 0, y: 1, z: 0.2),
                                    anchor: .center
                                )

                            // Top-right piece
                            cardView
                                .clipShape(TopRightPiece())
                                .offset(x: cardPiecesFlyOff ? geo.size.width * 0.8 : 0, y: cardPiecesFlyOff ? -geo.size.height * 0.5 : 0)
                                .rotation3DEffect(
                                    .degrees(cardPiecesFlyOff ? 60 : 0),
                                    axis: (x: 0.2, y: -1, z: 0),
                                    anchor: .center
                                )

                            // The laser beam that follows the cut line
                            LaserPath()
                                .trim(from: 0, to: laserPathProgress)
                                .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                                .shadow(color: .cyan, radius: 8, x: 0, y: 0)
                                .shadow(color: .white, radius: 5, x: 0, y: 0)
                                .opacity(showLaser ? 1 : 0)
                        }
                    }
                    .padding(.horizontal, 40) // Give some horizontal padding
                    .aspectRatio(1.5, contentMode: .fit) // Make it a bit taller than default card aspect ratio

                    // Congratulatory message appears after the split
                    if congratulatoryTextVisible {
                        Text("🎉 干得漂亮！气运加一 🎉")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .transition(AnyTransition.opacity.combined(with: .scale))
                            .id("congratsText")
                    }
                    
                    Spacer()
                    Spacer()
                }
                .transition(.opacity)
                .onAppear(perform: runAnimationSequence)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    private func runAnimationSequence() {
        // 1. Show the laser and animate its path across the card
        withAnimation(.linear(duration: 0.5)) {
            showLaser = true
            laserPathProgress = 1.0
        }

        // 2. A moment after the laser starts, make the pieces fly apart and show the text
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 1.2)) {
                cardPiecesFlyOff = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 1.0)) {
                 congratulatoryTextVisible = true
            }
        }

        // 3. Hide the laser after it has crossed the card
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation {
                showLaser = false
            }
        }

        // 4. After the animation is complete, dismiss the effect view and notify the parent
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                onCompletion() // Actually mark the task as completed
                taskToAnimate = nil
            }
        }
    }
}

// Shape for the laser's path (a diagonal line)
struct LaserPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}

// Shape for the top-right triangular piece of the card
struct TopRightPiece: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY)) // Top-left corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY)) // Top-right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Bottom-right corner
        path.closeSubpath()
        return path
    }
}

// Shape for the bottom-left triangular piece of the card
struct BottomLeftPiece: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY)) // Top-left corner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // Bottom-left corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Bottom-right corner
        path.closeSubpath()
        return path
    }
}

struct CompletionEffect_Previews: PreviewProvider {
    static var previews: some View {
        let task = Task(title: "Preview Task", description: "A task for previewing.", dueDate: Date(), priority: .medium)
        CompletionEffect(task: task, taskToAnimate: .constant(task), onCompletion: {})
    }
} 