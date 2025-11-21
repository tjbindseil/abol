//
//  AlarmData.swift
//  abol
//
//  Created by TJ Bindseil on 11/21/25.
//

import Foundation
import WidgetKit

struct AlarmData {
    // Private constants (No one else needs to know these string keys exist)
    private static let appGroup = "group.tj.abol"
    private static let keyIsArmed = "isArmed"
    
    // A convenient accessor for UserDefaults
    private static var defaults: UserDefaults? {
        return UserDefaults(suiteName: appGroup)
    }
    
    // The Public Interface
    // We use a "Computed Property" with a getter and a setter
    static var isArmed: Bool {
        get {
            // Read the value (Default to false if missing)
            return defaults?.bool(forKey: keyIsArmed) ?? false
        }
        set {
            // 1. Save the new value
            defaults?.set(newValue, forKey: keyIsArmed)
            
            // 2. The "Magic": Auto-reload the widget immediately
            // Now you never have to remember to call this manually!
            WidgetCenter.shared.reloadAllTimelines()
            
            print("💾 Alarm state saved: \(newValue). Widget reload requested.")
        }
    }
}
