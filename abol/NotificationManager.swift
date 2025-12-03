//
//  NotificationManager.swift
//  abol
//
//  Created by TJ Bindseil on 11/18/25.
//

import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    @Published var notificationsEnabled: Bool = false
    
    static let shared = NotificationManager()

    init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func triggerExitNotification(note: String) {
        print("TJTAG - NotificationManager.triggerExitNotification")
        
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

    func checkNotificationPermission() {
        print("TJTAG - checkNotificationPermission")
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let enabled: Bool
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                enabled = true
            default:
                enabled = false
            }

            DispatchQueue.main.async {
                self.notificationsEnabled = enabled
            }
        }
    }
}
