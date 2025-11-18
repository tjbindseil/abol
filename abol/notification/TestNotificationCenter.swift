//
//  TestNotificationCenter.swift
//  abol
//
//  Created by TJ Bindseil on 11/18/25.
//

import Foundation

class TestNotificationCenter: NotificationService {
    static var delivered: [String] = []

    func scheduleExitNotification(note: String) {
        print("TestNotificationCenter:: delivered: \(note)")
        TestNotificationCenter.delivered.append(note)
    }
}
