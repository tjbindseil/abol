//
//  NotificationManager.swift
//  abol
//
//  Created by TJ Bindseil on 11/18/25.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func triggerExitNotification(note: String) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = note.isEmpty ? "You left the area." : note
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // deliver immediately
        )

        UNUserNotificationCenter.current().add(request)
    }
}
