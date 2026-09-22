//
//  ThisWeekView.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/5/21.
//

import CoreData
import SwiftUI

/// Bar charts for the current week's transactions, one per metric, each opening a detailed graph.
struct ThisWeekView: View {
    /// The navigation title, which names the person when viewing shared data.
    var navigationTitleText = "This Week"
    /// Transactions that replace the user's own, when viewing someone who shares with them.
    var customTransactions: TransactionServices?

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)], animation: .default)
    private var transactions: FetchedResults<Transaction>
    @State private var selectedMetric: Metric?

    private var data: TransactionServices {
        customTransactions ?? TransactionServices(transactions.map(\.record))
    }

    /// The first and last day of the current week, as in "SEP 20, 2026 – SEP 26, 2026".
    private var weekRange: String {
        guard let week = data.calendar.weekInterval(containing: data.now),
              let lastDay = data.calendar.date(byAdding: .day, value: -1, to: week.end) else { return "" }
        let start = week.start.formatted(date: .abbreviated, time: .omitted)
        let end = lastDay.formatted(date: .abbreviated, time: .omitted)
        return "\(start) – \(end)".uppercased()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(weekRange)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.secondary)

                ForEach(Metric.allCases) { metric in
                    Button {
                        selectedMetric = metric
                    } label: {
                        WeekMetricCard(metric: metric, data: data)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens the detailed graph")
                }
            }
            .padding()
        }
        .navigationTitle(navigationTitleText)
        .sheet(item: $selectedMetric) { metric in
            GraphDetailView(data: data, metric: metric)
        }
    }
}

/// A card with a metric's bar chart for the week and its total or average.
struct WeekMetricCard: View {
    let metric: Metric
    let data: TransactionServices

    private var week: TransactionServices { data.week() }

    private var headline: (label: String, value: String) {
        if metric.isRate {
            return ("TOTAL", "\(week.percent(for: metric))%")
        }
        return ("AVG", week.averageLeadsPerDay.formatted(.number.precision(.fractionLength(0...2))))
    }

    private var bars: [MetricBar] { MetricBarChart.weekdayBars(for: metric, in: data) }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label(metric.title, systemImage: metric.symbolName)
                    .font(.headline)
                    .foregroundStyle(metric.color)

                Spacer()

                HStack(spacing: 6) {
                    Text(headline.label)
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text(headline.value)
                        .font(.title3.bold())
                        .foregroundStyle(metric.color)
                        .contentTransition(.numericText())
                }
            }

            MetricBarChart(
                bars: bars,
                color: metric.color,
                maxValue: MetricBarChart.maxValue(for: metric, bars: bars, baseline: 5),
                isRate: metric.isRate
            )
            .frame(height: 200)
        }
        .padding()
        .cardBackground()
    }
}

#Preview {
    NavigationStack {
        ThisWeekView()
    }
    .previewEnvironment()
}
