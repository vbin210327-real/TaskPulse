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
    @State private var glowPulse: Double = 0.5
    @State private var particleFlow: Double = 0
    
    private let segments = 25
    private let primaryGlow = Color.cyan
    private let secondaryGlow = Color.blue
    private let tertiaryGlow = Color.white
    
    var body: some View {
        VStack(spacing: 20) {
            Text("任务进度")
                .font(.headline)
                .foregroundColor(.primary)
            
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                
                ZStack {
                    // 背景星空效果
                    backgroundStars
                    
                    // DNA螺旋主体
                    dnaHelixView(width: width, height: height)
                    
                    // 进度百分比显示
                    progressLabel
                }
            }
            .frame(height: 350)
            .background(
                RadialGradient(
                    colors: [
                        Color.black.opacity(0.1),
                        Color.black.opacity(0.8)
                    ],
                    center: .center,
                    startRadius: 50,
                    endRadius: 200
                )
            )
            .cornerRadius(20)
            .onAppear {
                startAnimations()
            }
        }
    }
    
    private var backgroundStars: some View {
        ForEach(0..<30, id: \.self) { _ in
            Circle()
                .fill(Color.white.opacity(Double.random(in: 0.1...0.6)))
                .frame(width: Double.random(in: 1...3), height: Double.random(in: 1...3))
                .position(
                    x: Double.random(in: 0...300),
                    y: Double.random(in: 0...350)
                )
                .animation(
                    .easeInOut(duration: Double.random(in: 2...4))
                    .repeatForever(autoreverses: true),
                    value: glowPulse
                )
        }
    }
    
    private func dnaHelixView(width: CGFloat, height: CGFloat) -> some View {
        let segmentHeight = height / CGFloat(segments)
        
        return ZStack {
            ForEach(0..<segments, id: \.self) { index in
                let segmentProgress = Double(index) / Double(segments - 1)
                let isCompleted = segmentProgress <= progress
                
                DNASegmentView(
                    segmentProgress: segmentProgress,
                    isCompleted: isCompleted,
                    rotation: rotation,
                    glowPulse: glowPulse,
                    particleFlow: particleFlow,
                    width: width
                )
                .offset(y: CGFloat(index) * segmentHeight - height/2 + segmentHeight/2)
            }
        }
    }
    
    private var progressLabel: some View {
        VStack {
            Spacer()
            Text("\(Int(progress * 100))%")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(color: primaryGlow, radius: 10)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(primaryGlow.opacity(0.5), lineWidth: 1)
                        )
                )
                .scaleEffect(0.9 + 0.1 * glowPulse)
        }
        .padding(.bottom, 20)
    }
    
    private func startAnimations() {
        // 主旋转动画
        withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        
        // 发光脉动效果
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            glowPulse = 1.0
        }
        
        // 粒子流动效果
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            particleFlow = 1.0
        }
    }
}

struct DNASegmentView: View {
    let segmentProgress: Double
    let isCompleted: Bool
    let rotation: Double
    let glowPulse: Double
    let particleFlow: Double
    let width: CGFloat
    
    private let helixRadius: CGFloat = 40
    
    var body: some View {
        ZStack {
            // 主螺旋链条
            leftHelixChain
            rightHelixChain
            
            // 连接桥梁
            connectionBridge
            
            // 发光粒子效果
            if isCompleted {
                glowingParticles
            }
            
            // 能量脉冲效果
            if isCompleted {
                energyPulse
            }
        }
        .rotation3DEffect(
            .degrees(rotation * 0.3),
            axis: (x: 0, y: 1, z: 0)
        )
    }
    
    private var leftHelixChain: some View {
        let angle = segmentProgress * 720 // 2圈完整螺旋
        let x = helixRadius * cos(angle * .pi / 180)
        let z = sin(angle * .pi / 180) * 10 // 3D深度效果
        
        return ZStack {
            // 主要发光核心
            Circle()
                .fill(
                    RadialGradient(
                        colors: isCompleted ? 
                        [Color.cyan, Color.blue.opacity(0.3)] :
                        [Color.gray.opacity(0.2), Color.clear],
                        center: .center,
                        startRadius: 2,
                        endRadius: 8
                    )
                )
                .frame(width: 12, height: 12)
                .scaleEffect(isCompleted ? (1.0 + 0.3 * glowPulse) : 0.6)
            
            // 外层光晕
            if isCompleted {
                Circle()
                    .fill(Color.cyan.opacity(0.3))
                    .frame(width: 20, height: 20)
                    .blur(radius: 4)
                    .scaleEffect(0.8 + 0.4 * glowPulse)
            }
        }
        .offset(x: x)
        .shadow(
            color: isCompleted ? Color.cyan : Color.clear,
            radius: isCompleted ? (8 + 4 * glowPulse) : 0
        )
        .animation(.easeInOut(duration: 0.8), value: isCompleted)
    }
    
    private var rightHelixChain: some View {
        let angle = segmentProgress * 720 + 180 // 相位差180度
        let x = helixRadius * cos(angle * .pi / 180)
        
        return ZStack {
            // 主要发光核心
            Circle()
                .fill(
                    RadialGradient(
                        colors: isCompleted ? 
                        [Color.blue, Color.purple.opacity(0.3)] :
                        [Color.gray.opacity(0.2), Color.clear],
                        center: .center,
                        startRadius: 2,
                        endRadius: 8
                    )
                )
                .frame(width: 12, height: 12)
                .scaleEffect(isCompleted ? (1.0 + 0.3 * glowPulse) : 0.6)
            
            // 外层光晕
            if isCompleted {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 20, height: 20)
                    .blur(radius: 4)
                    .scaleEffect(0.8 + 0.4 * glowPulse)
            }
        }
        .offset(x: x)
        .shadow(
            color: isCompleted ? Color.blue : Color.clear,
            radius: isCompleted ? (8 + 4 * glowPulse) : 0
        )
        .animation(.easeInOut(duration: 0.8), value: isCompleted)
    }
    
    private var connectionBridge: some View {
        let angle = segmentProgress * 720
        let leftX = helixRadius * cos(angle * .pi / 180)
        let rightX = helixRadius * cos((angle + 180) * .pi / 180)
        let bridgeWidth = abs(rightX - leftX)
        
        return Rectangle()
            .fill(
                LinearGradient(
                    colors: isCompleted ? 
                    [
                        Color.cyan.opacity(0.8),
                        Color.white.opacity(0.9),
                        Color.blue.opacity(0.8)
                    ] :
                    [Color.gray.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: bridgeWidth, height: isCompleted ? 3 : 1)
            .offset(x: (leftX + rightX) / 2)
            .shadow(
                color: isCompleted ? Color.white : Color.clear,
                radius: isCompleted ? (4 + 2 * glowPulse) : 0
            )
            .scaleEffect(y: isCompleted ? (1.0 + 0.5 * glowPulse) : 1.0)
            .animation(.easeInOut(duration: 0.8), value: isCompleted)
    }
    
    private var glowingParticles: some View {
        ForEach(0..<4, id: \.self) { particleIndex in
            let angle = segmentProgress * 720 + Double(particleIndex) * 90 + particleFlow * 360
            let radius = helixRadius * (0.7 + 0.3 * sin(particleFlow * .pi * 2))
            let x = radius * cos(angle * .pi / 180)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white, Color.cyan.opacity(0.3)],
                        center: .center,
                        startRadius: 1,
                        endRadius: 4
                    )
                )
                .frame(width: 6, height: 6)
                .offset(x: x)
                .opacity(0.6 + 0.4 * sin(particleFlow * .pi * 2))
                .blur(radius: 1)
                .shadow(color: Color.white, radius: 3)
        }
    }
    
    private var energyPulse: some View {
        let angle = segmentProgress * 720
        let pulsePhase = particleFlow * 4 // 更快的脉冲
        
        return ZStack {
            // 能量环
            Circle()
                .stroke(
                    Color.white.opacity(0.6),
                    lineWidth: 2
                )
                .frame(width: helixRadius * 2, height: helixRadius * 2)
                .scaleEffect(0.3 + 0.7 * sin(pulsePhase * .pi))
                .opacity(0.4 + 0.6 * sin(pulsePhase * .pi))
                .blur(radius: 2)
            
            // 中心光点
            Circle()
                .fill(Color.white)
                .frame(width: 4, height: 4)
                .scaleEffect(0.5 + 1.5 * sin(pulsePhase * .pi * 2))
                .opacity(0.8 + 0.2 * sin(pulsePhase * .pi * 2))
                .shadow(color: Color.white, radius: 6)
        }
        .opacity(sin(pulsePhase * .pi).magnitude)
    }
}

#Preview {
    VStack {
        DNAProgressView(progress: 0.75)
        Spacer()
    }
    .preferredColorScheme(.dark)
    .padding()
    .background(Color.black)
} 