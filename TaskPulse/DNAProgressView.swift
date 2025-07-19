//
//  DNAProgressView.swift
//  TaskPulse
//
//  Created by AI Assistant.
//

import SwiftUI

struct DNAProgressView: View {
    let progress: Double
    @State private var rotation: Double = 0
    @State private var particleAnimation: Double = 0
    
    private let segments = 20
    private let glowColor = Color.cyan
    private let completedColor = Color.green
    private let incompleteColor = Color.gray
    
    var body: some View {
        VStack {
            Text("任务进度")
                .font(.headline)
                .foregroundColor(.primary)
            
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let segmentHeight = height / CGFloat(segments)
                
                ZStack {
                    // DNA双螺旋链
                    ForEach(0..<segments, id: \.self) { index in
                        let segmentProgress = Double(index) / Double(segments - 1)
                        let isCompleted = segmentProgress <= progress
                        
                        DNASegmentView(
                            segmentProgress: segmentProgress,
                            segmentHeight: segmentHeight,
                            width: width,
                            isCompleted: isCompleted,
                            rotation: rotation,
                            particleAnimation: particleAnimation
                        )
                        .offset(y: CGFloat(index) * segmentHeight - height/2 + segmentHeight/2)
                    }
                    
                    // 进度百分比
                    VStack {
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                    }
                }
            }
            .frame(height: 300)
            .onAppear {
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        // 持续旋转动画
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        
        // 粒子流动动画
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            particleAnimation = 1.0
        }
    }
}

struct DNASegmentView: View {
    let segmentProgress: Double
    let segmentHeight: CGFloat
    let width: CGFloat
    let isCompleted: Bool
    let rotation: Double
    let particleAnimation: Double
    
    private let spiralRadius: CGFloat = 30
    
    var body: some View {
        ZStack {
            // 左螺旋链
            leftSpiral
            
            // 右螺旋链
            rightSpiral
            
            // 连接梯子
            connectionLadder
            
            // 粒子效果（仅在已完成部分）
            if isCompleted {
                particleEffects
            }
        }
        .rotation3DEffect(
            .degrees(rotation),
            axis: (x: 0, y: 1, z: 0)
        )
    }
    
    private var leftSpiral: some View {
        let angle = segmentProgress * 360 * 2 // 2圈螺旋
        let x = spiralRadius * cos(angle * .pi / 180)
        
        return Circle()
            .fill(isCompleted ? Color.green : Color.gray.opacity(0.3))
            .frame(width: 8, height: 8)
            .offset(x: x)
            .shadow(color: isCompleted ? .green : .clear, radius: isCompleted ? 4 : 0)
            .scaleEffect(isCompleted ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.5), value: isCompleted)
    }
    
    private var rightSpiral: some View {
        let angle = segmentProgress * 360 * 2 + 180 // 相位差180度
        let x = spiralRadius * cos(angle * .pi / 180)
        
        return Circle()
            .fill(isCompleted ? Color.blue : Color.gray.opacity(0.3))
            .frame(width: 8, height: 8)
            .offset(x: x)
            .shadow(color: isCompleted ? .blue : .clear, radius: isCompleted ? 4 : 0)
            .scaleEffect(isCompleted ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.5), value: isCompleted)
    }
    
    private var connectionLadder: some View {
        let angle = segmentProgress * 360 * 2
        let leftX = spiralRadius * cos(angle * .pi / 180)
        let rightX = spiralRadius * cos((angle + 180) * .pi / 180)
        
        return Rectangle()
            .fill(isCompleted ? 
                  LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing) :
                  LinearGradient(colors: [.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
            )
            .frame(width: abs(rightX - leftX), height: 2)
            .offset(x: (leftX + rightX) / 2)
            .shadow(color: isCompleted ? .cyan : .clear, radius: isCompleted ? 2 : 0)
            .opacity(isCompleted ? 1.0 : 0.3)
            .animation(.easeInOut(duration: 0.5), value: isCompleted)
    }
    
    private var particleEffects: some View {
        ForEach(0..<3, id: \.self) { particleIndex in
            let angle = segmentProgress * 360 * 2 + Double(particleIndex) * 120
            let radius = spiralRadius * (0.8 + 0.4 * particleAnimation)
            let x = radius * cos(angle * .pi / 180)
            
            Circle()
                .fill(Color.cyan.opacity(0.6))
                .frame(width: 4, height: 4)
                .offset(x: x)
                .scaleEffect(0.5 + 0.5 * particleAnimation)
                .opacity(0.7 + 0.3 * particleAnimation)
                .blur(radius: 1)
        }
    }
}

#Preview {
    VStack {
        DNAProgressView(progress: 0.7)
        Spacer()
    }
    .preferredColorScheme(.dark)
    .padding()
} 