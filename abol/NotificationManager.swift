//
//  NotificationManager.swift
//  abol
//
//  Created by TJ Bindseil on 11/18/25.
//

import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    @Published var notificationsEnabled = false
    
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
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                print("TJTAG - checkNotificationPermission, setting to true")
                self.notificationsEnabled = true
            case .denied:
                print("TJTAG - checkNotificationPermission, setting to false")
                self.notificationsEnabled = false
            case .notDetermined:
                print("TJTAG - checkNotificationPermission, setting to false")
                self.notificationsEnabled = false
            @unknown default:
                print("TJTAG - checkNotificationPermission, setting to false")
                self.notificationsEnabled = false
            }
        }
    }
}
