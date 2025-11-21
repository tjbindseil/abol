//
//  LockScreenWidget.swift
//  LockScreenWidget
//
//  Created by TJ Bindseil on 11/19/25.
//

import WidgetKit
import SwiftUI

import os

// Create a "logger" instance
let logger = Logger(subsystem: "tj.abol", category: "Widget")


struct Provider: TimelineProvider {

    // 1. Placeholder: Instant, generic dummy data.
    // Don't read DB here. Just show a neutral state.
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), emoji: "🛡️", isArmed: false)
    }

    // 2. Snapshot: The "Gallery" view.
    // We try to show real data, but keep it fast.
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.tj.abol")
        let isArmed = sharedDefaults?.bool(forKey: "isArmed") ?? false
        
        let entry = SimpleEntry(date: Date(), emoji: "🛡️", isArmed: isArmed)
        completion(entry)
    }

    // 3. Timeline: The "Real" view.
    // NO LOOP NEEDED. We only know the state RIGHT NOW.
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        // A. Read Data
        let sharedDefaults = UserDefaults(suiteName: "group.tj.abol")
        let isArmed = sharedDefaults?.bool(forKey: "isArmed") ?? false
        
        // B. Create ONE entry for "Now"
        let entry = SimpleEntry(date: Date(), emoji: "🛡️", isArmed: isArmed)

        // C. The Policy: .never
        // This tells iOS: "Display this entry forever until my App explicitly tells you to reload."
        // This is perfect for an Alarm app.
        let timeline = Timeline(entries: [entry], policy: .never)
        
        completion(timeline)
    }
}
struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String // TODO utilize or eliminate
    let isArmed: Bool
}

struct LockScreenWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .accessoryInline:
            Text(entry.isArmed ? "i-on" : "i-off")

        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                Text(entry.isArmed ? "c-on" : "c-off")
            }

        case .accessoryRectangular:
            VStack {
                Text(entry.isArmed ? "r-on" : "r-off")
            }

        default:
            Text("Default view")
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
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
