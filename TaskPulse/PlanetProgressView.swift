//
//  PlanetProgressView.swift
//  TaskPulse
//
//  Created by AI Assistant.
//

import SwiftUI

struct PlanetProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            // Planet
            Image(systemName: "globe.asia.australia.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue.opacity(0.6))

            // Background ring
            Circle()
                .stroke(lineWidth: 10)
                .foregroundColor(Color.gray.opacity(0.2))

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundColor(.cyan)
                .rotationEffect(.degrees(-90))

            // Glowing effect
            Circle()
                .trim(from: 0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundColor(.cyan)
                .rotationEffect(.degrees(-90))
                .blur(radius: 15)
                .shadow(color: .cyan, radius: 10 * progress)
            
            Text("\(Int(progress * 100))%")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(width: 150, height: 150)
    }
}

#Preview {
    PlanetProgressView(progress: 0.75)
        .preferredColorScheme(.dark)
} 