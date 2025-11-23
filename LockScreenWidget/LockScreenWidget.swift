//
//  LockScreenWidget.swift
//  LockScreenWidget
//
//  Created by TJ Bindseil on 11/19/25.
//

import WidgetKit
import SwiftUI
import AppIntents

import os

// Create a "logger" instance
let logger = Logger(subsystem: "tj.abol", category: "Widget")


struct Provider: TimelineProvider {

    // 1. Placeholder: Instant, generic dummy data.
    // Don't read DB here. Just show a neutral state.
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(isArmed: false)
    }

    // 2. Snapshot: The "Gallery" view.
    // We try to show real data, but keep it fast.
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(isArmed: AlarmManager.currentArmedState)
        completion(entry)
    }

    // 3. Timeline: The "Real" view.
    // NO LOOP NEEDED. We only know the state RIGHT NOW.
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // B. Create ONE entry for "Now"
        let entry = SimpleEntry(isArmed: AlarmManager.currentArmedState)

        // C. The Policy: .never
        // This tells iOS: "Display this entry forever until my App explicitly tells you to reload."
        // This is perfect for an Alarm app.
        let timeline = Timeline(entries: [entry], policy: .never)
        
        completion(timeline)
    }
}
struct SimpleEntry: TimelineEntry {
    let date: Date = Date()
    let isArmed: Bool
}

struct LockScreenWidgetEntryView : View {
    var entry: Provider.Entry
    
    // 1. Hook into the environment to detect the size
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {

        // C. THE RECTANGULAR WIDGET (Wide)
        // Constraint: Good for 2-3 lines of text.
        case .accessoryRectangular:
            if entry.isArmed {
                // STATE A: ARMED -> Show Button to Disarm
                Button(intent: DisarmAlarmIntent()) {
                    RectangularContent(isArmed: true)
                }
                .buttonStyle(.plain)
            } else {
                // STATE B: DISARMED -> Standard View (Opens App)
                RectangularContent(isArmed: false)
                    .widgetURL(URL(string: "abol://alarm/reminder_note"))
            }
        default:
            EmptyView()
        }
    }
}

struct RectangularContent: View {
    let isArmed: Bool
    var body: some View {
        HStack {
            Image(systemName: isArmed ? "lock.shield.fill" : "lock.slash")
                .font(.title)
            VStack(alignment: .leading) {
                Text("ABOL")
                    .font(.caption2)
                    .textCase(.uppercase)
                    .opacity(0.7)
                Text(isArmed ? "ARMED" : "TAP TO SET") // Contextual Text!
                    .font(.headline)
                    .bold()
            }
            Spacer()
        }
    }
}

struct LockScreenWidget: Widget {
    let kind: String = "LockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                LockScreenWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LockScreenWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("ABOL Widget")
        .description("See Alarm Based On Location status.")
        .supportedFamilies([
            .accessoryRectangular,
        ])
    }
}
