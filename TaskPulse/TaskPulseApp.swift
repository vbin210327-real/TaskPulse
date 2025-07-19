//
//  TaskPulseApp.swift
//  TaskPulse
//
//  Created by 林凡滨 on 2025/7/14.
//

import SwiftUI

@main
struct TaskPulseApp: App {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    var body: some Scene {
        WindowGroup {
            if hasSeenWelcome {
                MainView()
            } else {
                WelcomeView()
            }
        }
    }
}
