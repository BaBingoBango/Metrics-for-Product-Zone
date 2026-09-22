//
//  MetricsComplication.swift
//  MetricsComplication
//
//  The watch face complication for Metrics. It replaces the app's original
//  ClockKit complication, which watchOS no longer supports, with a WidgetKit
//  accessory widget. Like the original, it is a launcher: tapping it opens the
//  app so a transaction can be logged.
//

import SwiftUI
import WidgetKit

/// A single, static timeline entry. The complication has no data of its own to display.
nonisolated struct MetricsComplicationEntry: TimelineEntry {
    let date: Date
}

/// Supplies the static entry to WidgetKit.
nonisolated struct MetricsComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> MetricsComplicationEntry {
        MetricsComplicationEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (MetricsComplicationEntry) -> Void) {
        completion(MetricsComplicationEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MetricsComplicationEntry>) -> Void) {
        completion(Timeline(entries: [MetricsComplicationEntry(date: .now)], policy: .never))
    }
}

/// The complication's content for each supported accessory family.
struct MetricsComplicationView: View {
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryInline:
            Label("Metrics", systemImage: "chart.bar.fill")

        case .accessoryRectangular:
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .widgetAccentable()
                VStack(alignment: .leading) {
                    Text("Metrics")
                        .font(.headline)
                    Text("Log a transaction")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

        default:
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .widgetAccentable()
            }
        }
    }
}

@main
struct MetricsComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MetricsComplication", provider: MetricsComplicationProvider()) { _ in
            MetricsComplicationView()
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Metrics")
        .description("Open Metrics to log a transaction.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline, .accessoryRectangular])
    }
}

#Preview(as: .accessoryCircular) {
    MetricsComplication()
} timeline: {
    MetricsComplicationEntry(date: .now)
}
