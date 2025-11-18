//
//  abolApp.swift
//  abol
//
//  Created by TJ Bindseil on 11/18/25.
//

import SwiftUI

@main
struct ForgetAboutForgettingApp: App {
    @StateObject private var locationController = LocationController(
        useTestManager: ProcessInfo.processInfo.arguments.contains("UI_TEST_MODE")
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationController)
        }
    }
}
