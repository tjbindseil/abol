//
//  ContentView.swift
//  abol
//
//  Created by TJ Bindseil on 11/18/25.
//

import SwiftUI
import CoreLocation

import os

// Create a "logger" instance
let logger = Logger(subsystem: "tj.abol", category: "App-General")

struct ContentView: View {
    // Receive the shared manager
    @EnvironmentObject var alarmManager: AlarmManager

    @State private var note = UserDefaults.standard.string(forKey: "note") ?? ""

    @StateObject private var locationManager = LocationManager()
    @StateObject private var sharedNotificationManager = NotificationManager.shared

    @State private var armedLocation: CLLocation?

    @State private var notificationStatus = "Loading..."
    
    @State private var showAbout = false
    
    // 2. The Focus State (The remote control for the keyboard)
    @FocusState private var isNoteFieldFocused: Bool

    var body: some View {
        VStack(spacing: 24) {

            Text("Reminder Based on Location")
                .font(.title)
                .bold()

            TextField("Reminder note...", text: $note)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .disabled(alarmManager.isArmed)
                // Bind the focus state here
                .focused($isNoteFieldFocused)
                .onChange(of: note) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "note")
                }
                .overlay(
                    HStack {
                        Spacer()
                        if !note.isEmpty && !alarmManager.isArmed {
                            Button(action: { note = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                )

            Toggle(isOn: $alarmManager.isArmed) {
                Text(alarmManager.isArmed ? "Armed - Toggle to Disarm" : "Disarmed - Toggle to Arm")
            }
            .padding()
            .onChange(of: alarmManager.isArmed) { newValue in
                if newValue {
                    armAlarm()
                } else {
                    armedLocation = nil
                    locationManager.stopMonitoring()
                }
            }
            if alarmManager.isArmed, let loc = armedLocation {
                Text("Armed at: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            
            DisclosureGroup("About", isExpanded: $showAbout) {
                Text("This app utilizes your location and allows you to set a reminder that goes off when you leave an area. The purpose of this is to help you remember to do a task that needs to be done before leaving an area.")
                    .font(.body)
                    .padding(.top, 4)
                Text("In order for this to work, the app must have location always enabled, and it must have notifications enabled. The status of these two are indicated below.")
                    .font(.body)
                    .padding(.top, 4)

                Text("")

                Text("Location enabled correctly: \(locationManager.isLocationAlwyasEnabled() ? "✅" : "❌")")
                    .font(.caption)
                Text("Notifications enabled correctly: \(sharedNotificationManager.notificationsEnabled ? "✅" : "❌")")
                    .font(.caption)

                Text("")

                Text("Contact me via email at tjbindseil@gmail.com with any questions or concerns")
                    .font(.caption)
            }

            Spacer()
        }
        .padding()
        .onChange(of: locationManager.lastKnownLocation) { newLocation in
            if alarmManager.isArmed && armedLocation == nil {
                armedLocation = newLocation
                
                if let loc = newLocation {
                    locationManager.startMonitoring(location: loc)
                }
            }
        }
        .onChange(of: locationManager.exitEventTriggered) { didExit in
            // TODO the fact that content view is managing this is whack
            print("TJTAG onchange, didExit event is: \(didExit)")
            if didExit {
                
                // get note from UserDefaults
                
                NotificationManager.shared.triggerExitNotification(note: note)
                armedLocation = nil
                locationManager.stopMonitoring()
            }
        }
        // 4. The Deep Link Handler
        .onOpenURL { url in
            print("🚀 App opened with URL: \(url)")
            
            // Check if the URL matches your specific command
            if url.scheme == "abol" && url.host == "alarm" && url.path == "/reminder_note" {
                handleDeepLink()
            }
        }
    }

    private func armAlarm() {
        // Request permission if needed
        NotificationManager.shared.requestPermission()
        locationManager.requestLocationPermission()
        locationManager.requestCurrentLocation()

        alarmManager.isArmed = true
    }
    
    func handleDeepLink() {
        // 5. THE TRICK: Add a slight delay.
        // If you try to focus immediately while the app is zooming in,
        // iOS will ignore it. We wait 0.5 seconds for the animation to settle.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // This triggers the keyboard!
            isNoteFieldFocused = true
        }
    }
}
