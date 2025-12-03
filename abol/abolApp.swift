//
//  abolApp.swift
//  abol
//
//  Created by TJ Bindseil on 11/18/25.
//

import SwiftUI

@main
struct MyApp: App {
    // 1. Create the manager here (Single Source of Truth)
    @StateObject private var alarmManager = AlarmManager()
    
    // 2. Watch the scene phase (Background vs Active)
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Inject the manager into the environment so ContentView can use it
                .environmentObject(alarmManager)
        }
        // 3. The Sync Trigger
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                // The app just came to the foreground!
                // Check if the Widget changed anything while we were sleeping.
                alarmManager.checkForExternalChanges()
                
                NotificationManager.shared.checkNotificationPermission()
            }
        }
    }
}
