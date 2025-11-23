//
//  AlarmData.swift
//  abol
//
//  Created by TJ Bindseil on 11/21/25.
//

import Foundation
import Foundation
import WidgetKit
import SwiftUI
import Combine

// 1. Keep constants static so the Widget Extension can read them easily
struct AlarmKeys {
    static let appGroup = "group.tj.abol"
    static let keyIsArmed = "isArmed"
}

@MainActor
class AlarmManager: ObservableObject {
    
    // ... your shared instance and publisher ...
    @Published var isArmed: Bool = false {
        didSet {
            // Only save if the value is DIFFERENT from disk
            // (Prevents infinite loops when we load from disk)
            let currentDiskValue = UserDefaults(suiteName: AlarmKeys.appGroup)?.bool(forKey: AlarmKeys.keyIsArmed) ?? false
            if isArmed != currentDiskValue {
                UserDefaults(suiteName: AlarmKeys.appGroup)?.set(isArmed, forKey: AlarmKeys.keyIsArmed)
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    // ... init ...
    
    // ✅ NEW FUNCTION: Force a re-read from disk
    func checkForExternalChanges() {
        let latestValue = UserDefaults(suiteName: AlarmKeys.appGroup)?.bool(forKey: AlarmKeys.keyIsArmed) ?? false
        
        // If disk says False, but App says True -> Update App to False
        if self.isArmed != latestValue {
            self.isArmed = latestValue
            print("📲 App woke up and realized state changed externally to: \(latestValue)")
        }
    }
}

// Add this to the bottom of your AlarmManager file
extension AlarmManager {

    // 'nonisolated' tells Swift: "This function doesn't care about the UI thread."
    // It is safe to call from a background Widget Intent.
    nonisolated static func updateAlarmState(to newState: Bool) {

        // 1. Save to Disk
        let defaults = UserDefaults(suiteName: AlarmKeys.appGroup)
        defaults?.set(newState, forKey: AlarmKeys.keyIsArmed)

        // 2. Reload Widgets
        WidgetCenter.shared.reloadAllTimelines()

        print("🤖 Intent updated state to: \(newState)")
    }

    nonisolated static var currentArmedState: Bool {
        let defaults = UserDefaults(suiteName: AlarmKeys.appGroup)
        return defaults?.bool(forKey: AlarmKeys.keyIsArmed) ?? false
    }
}
