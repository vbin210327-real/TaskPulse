//
//  HeartbeatProgressView.swift
//  TaskPulse
//
//  Created by AI Assistant on 2024/7/16.
//

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
    
    var body: some View {
        VStack {
            Text("平均进度")
                .font(.headline)
            
            TimelineView(.animation(minimumInterval: 0.05, paused: progress == 0)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let beat = sin(time * 5) * (progress > 0 ? 3 : 0) + 1
                
                ZStack {
                    // Background track
                    HeartCurveShape()
                        .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    
                    // Actual progress, trimmed
                    HeartCurveShape()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [.cyan, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                        )
                        .shadow(color: .cyan.opacity(0.8), radius: beat, x: 0, y: 0)
                }
                .frame(height: 120)
                .padding(.horizontal)
            }
            
            Text("\(Int(progress * 100))%")
                .font(.title)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    HeartbeatProgressView(progress: 0.75)
} 