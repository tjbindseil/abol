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
    @State private var armedLocation: CLLocation?

    // 2. The Focus State (The remote control for the keyboard)
    @FocusState private var isNoteFieldFocused: Bool

    var body: some View {
        VStack(spacing: 24) {

            Text("Set Alarm Based on Location!")
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

            if alarmManager.isArmed {
                // Show captured coordinates
                if let loc = armedLocation {
                    Text("Armed at: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }

                Button("Disarm") {
                    armedLocation = nil
                    locationManager.stopMonitoring()
                    
                    alarmManager.isArmed = false
                }
                .padding()
            } else {
                Button("Arm Alarm") {
                    armAlarm()
                }
                .padding()
            }

            // Permission alert
            if locationManager.permissionDenied {
                Text("Location permission denied. Enable it in Settings.")
                    .foregroundColor(.red)
                    .padding(.horizontal)
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
