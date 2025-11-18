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
    @StateObject var controller =
        LocationController(useTestManager: ProcessInfo.processInfo.arguments.contains("UI_TEST_MODE"))

    @State private var text = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("ABOL")
                .font(.title)
                .bold()

            TextField("Reminder note...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .disabled(controller.armed)

            if controller.armed {
                Button("Disarm") {
                    controller.disarm()
                    
                    // clear widget
                    // AlarmStatusStore.setAlarmArmed(false)
                    // WidgetCenter.shared.reloadTimelines(ofKind: "AlarmStatusWidget")
                }
                .accessibilityIdentifier("DisarmAlarmButton")
                Text("Armed at: \(controller.armedAtLat), \(controller.armedAtLon)")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

            } else {
                Button("Arm Alarm") {
                    // TODO arm at current location again
                    let loc = CLLocation(latitude: 39.98564, longitude: -105.25260)
                    controller.armAlarm(note: text, at: loc.coordinate)
                    
                    // set widget
                    // AlarmStatusStore.setAlarmArmed(true)
                    // WidgetCenter.shared.reloadTimelines(ofKind: "AlarmStatusWidget")
                }
                .accessibilityIdentifier("ArmAlarmButton")
            }

            Text(controller.armed ? "Armed" : "Disarmed")

            // TODO - display warning when permissions missing

            Spacer()
        }
    }
}
