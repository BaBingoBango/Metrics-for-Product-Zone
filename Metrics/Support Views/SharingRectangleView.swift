//
//  SharingRectangleView.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/15/22.
//

import SwiftUI

/// A card summarizing one person's metrics for the current day.
struct SharingRectangleView: View {
    /// The person's transactions for today, carrying their name as `owner`.
    let person: TransactionServices

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "person.crop.circle")
                    .font(.title)

                Text(person.owner ?? "Name Not Provided")
                    .font(.title3.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()
            }

            HStack(spacing: 12) {
                ForEach(Metric.allCases) { metric in
                    ProgressRing(progress: metric.isRate ? Double(person.percent(for: metric)) / 100 : 0, color: metric.color) {
                        if metric.isRate {
                            RingSymbol(name: metric.symbolName, color: metric.color)
                        } else {
                            Text("\(person.count(for: metric))")
                                .font(.title2.bold())
                                .foregroundStyle(metric.color)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                    }
                }
            }
        }
        .padding()
        .cardBackground()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        let numbers = Metric.allCases.map { "\($0.title) \(person.formattedValue(for: $0))" }.joined(separator: ", ")
        return "\(person.owner ?? "Name Not Provided"): \(numbers)"
    }
}

#Preview {
    SharingRectangleView(person: TransactionServices(TransactionRecord.sampleData, owner: "Sam Appleseed").today)
        .padding()
}
