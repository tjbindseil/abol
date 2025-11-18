//
//  NotificationService.swift
//  abol
//
//  Created by TJ Bindseil on 11/18/25.
//

import Foundation
import UserNotifications

protocol NotificationService {
    func scheduleExitNotification(note: String)
}

class RealNotificationService: NotificationService {
    func scheduleExitNotification(note: String) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = note
        content.sound = .defaultCritical

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
