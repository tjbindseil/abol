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
    var entry: Provider.Entry
    
    // 1. Hook into the environment to detect the size
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        
        // A. THE INLINE WIDGET (Above the Clock)
        // Constraint: Can ONLY show Text and SF Symbols. No colors, no shapes.
        case .accessoryInline:
            Label(entry.isArmed ? "Alarm Armed" : "Alarm Off", systemImage: entry.isArmed ? "lock.fill" : "lock.open")
        
        // B. THE CIRCULAR WIDGET (Small Circle)
        // Constraint: Very small. Good for a single icon or gauge.
        case .accessoryCircular:
            ZStack {
                Circle()
                    .stroke(lineWidth: 2)
                    .opacity(0.3)
                
                Image(systemName: entry.isArmed ? "shield.fill" : "shield.slash")
                    .font(.title2)
            }
            // Note: Lock Screen widgets are always monochrome/tinted by the system
            .widgetLabel(entry.isArmed ? "Armed" : "Disarmed") // Shows text when user taps/holds
            
        // C. THE RECTANGULAR WIDGET (Wide)
        // Constraint: Good for 2-3 lines of text.
        case .accessoryRectangular:
            HStack {
                Image(systemName: entry.isArmed ? "lock.shield.fill" : "lock.slash")
                    .font(.title)
                VStack(alignment: .leading) {
                    Text("System Status")
                        .font(.caption2)
                        .textCase(.uppercase)
                        .opacity(0.7)
                    Text(entry.isArmed ? "ARMED" : "DISARMED")
                        .font(.headline)
                        .bold()
                }
                Spacer()
            }
            
        // D. FALLBACK (Home Screen / SystemSmall)
        default:
            VStack {
                Text(entry.isArmed ? "🛡️" : "🔓")
                    .font(.largeTitle)
                Text(entry.isArmed ? "Armed" : "Safe")
            }
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
