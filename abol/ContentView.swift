//
//  ContentView.swift
//  abol
//
//  Created by TJ Bindseil on 11/18/25.
//

import SwiftUI
import CoreLocation
import WidgetKit

struct ContentView: View {
    @State private var note: String = ""
    @State private var isArmed: Bool = false

    @StateObject private var locationManager = LocationManager()
    @State private var armedLocation: CLLocation?

    var body: some View {
        VStack(spacing: 24) {

            Text("Set Alarm Based on Location!")
                .font(.title)
                .bold()

            TextField("Reminder note...", text: $note)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .disabled(isArmed)

            if isArmed {
                // Show captured coordinates
                if let loc = armedLocation {
                    Text("Armed at: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }

                Button("Disarm") {
                    isArmed = false
                    armedLocation = nil
                    locationManager.stopMonitoring()
                    
                    // 1. Save the data to the shared group
                    print("disarm - about to get sharedDefaults")
                    let sharedDefaults = UserDefaults(suiteName: "group.tj.abol")
                    print("disarm - in between")
                    sharedDefaults?.set(false, forKey: "isArmed")
                    print("disarm - done setting shareddefaults ")

                    // 2. KICK the widget so it updates immediately
                    WidgetCenter.shared.reloadAllTimelines()
                    print("disarm - done kicking ")
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
            if isArmed && armedLocation == nil {
                armedLocation = newLocation
                
                if let loc = newLocation {
                    locationManager.startMonitoring(location: loc)
                }
            }
        }
        .onChange(of: locationManager.exitEventTriggered) { didExit in
            if didExit {
                NotificationManager.shared.triggerExitNotification(note: note)
                isArmed = false
                armedLocation = nil
                locationManager.stopMonitoring()
            }
        }
    }

    private func armAlarm() {
        // Request permission if needed
        NotificationManager.shared.requestPermission()
        locationManager.requestLocationPermission()
        locationManager.requestCurrentLocation()

        print("armalarm, setting shared defaults")

        // 1. Save the data to the shared group
        let sharedDefaults = UserDefaults(suiteName: "group.tj.abol")
        print("armalarm in between, and sharedDefaults is: \(sharedDefaults === nil ? "yes" : "no")")
        sharedDefaults?.set(true, forKey: "isArmed") // TODO constant for key

        print("armalarm, done setting shared defaults")
        
        print("armalarm lets check it after we set it")
        if let readBackVal = sharedDefaults?.bool(forKey: "isArmed") {
            print("armalarm readbackval is: \(readBackVal)")
        } else {
            print("armalarm readbackval is: nil")
        }

        // 2. KICK the widget so it updates immediately
        WidgetCenter.shared.reloadAllTimelines()

        print("armalarm, done kicking widget center")

        isArmed = true
    }
}
