//
//  ToggleAlarmIntent.swift
//  abol
//
//  Created by TJ Bindseil on 11/21/25.
//

import Foundation
import AppIntents // Required for interactions

struct DisarmAlarmIntent: AppIntent {
    
    // 1. Title: Required for Shortcuts and Siri
    static var title: LocalizedStringResource = "Toggle Alarm"
    static var description = IntentDescription("Arms or Disarms the security alarm.")

    // 2. Helper: This helps the system differentiate multiple widgets (not strictly needed here but good practice)
    init() {}

    // 3. The Action: What happens when the button is tapped?
    func perform() async throws -> some IntentResult {
        
        // A. Toggle the state
        // Note: This calls your 'AlarmData' setter, which AUTOMATICALLY reloads the timeline!
        // only disarm, as arming requires getting gps and gets a bit complicated
        if AlarmData.isArmed {
            AlarmData.isArmed = false
        }
        
        // B. Return success
        return .result()
    }
}
