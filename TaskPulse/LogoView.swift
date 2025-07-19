//
//  LogoView.swift
//  TaskPulse
//
//  Created by AI Assistant.
//

import SwiftUI

struct LogoView: View {
    private let glowColor = Color(red: 0.4, green: 0.9, blue: 1.0)

    var body: some View {
        // 直接使用清晰的AppLogo图像，不添加额外的背景圆圈
        Image("AppLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            .shadow(color: glowColor.opacity(0.5), radius: 15)
            .shadow(color: glowColor.opacity(0.3), radius: 5)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    LogoView()
        .background(Color.black) // 预览时使用黑色背景以便查看效果
} 