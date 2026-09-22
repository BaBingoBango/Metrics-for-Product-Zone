//
//  WatchSharingRectangleView.swift
//  WatchMetrics
//
//  Created by Ethan Marshall on 7/16/22.
//

import SwiftUI

/// A card summarizing one person's metrics for the current day.
struct WatchSharingRectangleView: View {
    /// The person's transactions for today, carrying their name as `owner`.
    let person: TransactionServices

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(person.owner ?? "Name Not Provided", systemImage: "person.crop.circle")
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Metric.allCases) { metric in
                    ProgressRing(progress: metric.isRate ? Double(person.percent(for: metric)) / 100 : 0, color: metric.color, lineWidth: 6) {
                        if metric.isRate {
                            Image(systemName: metric.symbolName)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(metric.color)
                        } else {
                            Text("\(person.count(for: metric))")
                                .font(.headline)
                                .foregroundStyle(metric.color)
                        }
                    }
                }
            }
        }
        .padding(10)
        .cardBackground(cornerRadius: 14)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        let numbers = Metric.allCases.map { "\($0.title) \(person.formattedValue(for: $0))" }.joined(separator: ", ")
        return "\(person.owner ?? "Name Not Provided"): \(numbers)"
    }
}

#Preview {
    WatchSharingRectangleView(person: TransactionServices(TransactionRecord.sampleData, owner: "Sam Appleseed").today)
}
