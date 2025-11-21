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
    func placeholder(in context: Context) -> SimpleEntry {
        // 1. Read from the shared group
        let sharedDefaults = UserDefaults(suiteName: "group.tj.abol")
        let isArmed = sharedDefaults?.bool(forKey: "isArmed") ?? false // Default to false

        return SimpleEntry(date: Date(), emoji: "😀", isArmed: isArmed)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        // 1. Read from the shared group
        let sharedDefaults = UserDefaults(suiteName: "group.tj.abol")
        let isArmed = sharedDefaults?.bool(forKey: "isArmed") ?? false // Default to false

        let entry = SimpleEntry(date: Date(), emoji: "😀", isArmed: isArmed)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // 1. Read from the shared group
        let sharedDefaults = UserDefaults(suiteName: "group.tj.abol")
        let isArmed = sharedDefaults?.bool(forKey: "isArmed") ?? false // Default to false

        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀", isArmed: isArmed)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
    let isArmed: Bool
}

struct LockScreenWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .accessoryInline:
            Text(entry.isArmed ? "armed" : "unarmed")

        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                Text(entry.isArmed ? "armed" : "unarmed")
            }

        case .accessoryRectangular:
            VStack {
                Text("Time:")
                Text(entry.date, style: .time)
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
