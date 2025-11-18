//
//  ContentView.swift
//  abol
//
//  Created by TJ Bindseil on 11/18/25.
//

import SwiftUI
import CoreLocation

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

        isArmed = true
    }
}
