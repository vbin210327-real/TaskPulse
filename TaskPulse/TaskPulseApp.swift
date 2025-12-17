//
//  TaskPulseApp.swift
//  TaskPulse
//
//  Created by 林凡滨 on 2025/7/14.
//

import SwiftUI
import UserNotifications

#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
}
#endif

@main
struct TaskPulseApp: App {
#if canImport(UIKit)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
#endif

    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false

    init() {
        UserDefaults.standard.register(defaults: [
            "enableDueSoonNotifications": true
        ])
    }

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
