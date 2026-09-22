//
//  GraphDetailView.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/5/21.
//

import SwiftUI

/// A detailed graph for one metric across a week, a span of seven weeks or a span of seven months.
struct GraphDetailView: View {
    /// The time scale of the graph.
    enum Scale: String, CaseIterable, Identifiable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"

        var id: String { rawValue }

        /// The smallest count the y axis shows for Business Leads at this scale, so light weeks still read well.
        var leadsBaseline: Double {
            switch self {
            case .weekly: 5
            case .monthly: 35
            case .yearly: 100
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    let data: TransactionServices
    let metric: Metric

    @State private var scale: Scale = .weekly
    /// How far back the user has paged at each scale, where 0 is the current period.
    @State private var offsets: [Scale: Int] = [:]

    private var offset: Int { offsets[scale] ?? 0 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("Scale", selection: $scale) {
                        ForEach(Scale.allCases) { scale in
                            Text(scale.rawValue).tag(scale)
                        }
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Button("Earlier", systemImage: "chevron.left") {
                            offsets[scale] = offset + 1
                        }

                        Spacer()

                        Text(periodTitle)
                            .font(.headline)
                            .numericContentTransition()

                        Spacer()

                        Button("Later", systemImage: "chevron.right") {
                            offsets[scale] = max(0, offset - 1)
                        }
                        .disabled(offset == 0)
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    .tint(metric.color)
                    .fontWeight(.bold)

                    MetricBarChart(bars: bars, color: metric.color, maxValue: maxValue, isRate: metric.isRate, showsYAxis: true)
                        .frame(height: 260)
                        .animateUnlessReduced(bars)

                    HighlightsCard(metric: metric, period: periodData)
                }
                .padding()
            }
            .navigationTitle(metric.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", role: .confirm) { dismiss() }
                }
            }
        }
    }

    // MARK: - Data

    private var periodTitle: String {
        switch scale {
        case .weekly:
            offset == 0 ? "This Week" : offset == 1 ? "1 Week Ago" : "\(offset) Weeks Ago"
        case .monthly:
            offset == 0 ? "Last 7 Weeks" : "\(offset * 7) – \(offset * 7 + 6) Weeks Ago"
        case .yearly:
            offset == 0 ? "Last 7 Months" : "\(offset * 7) – \(offset * 7 + 6) Months Ago"
        }
    }

    /// The seven periods on the graph, oldest first, each with its axis label.
    private var periods: [(label: String, data: TransactionServices)] {
        let calendar = data.calendar
        switch scale {
        case .weekly:
            return Array(zip(calendar.orderedVeryShortWeekdaySymbols, data.byWeekday(weekOffset: offset)))
        case .monthly:
            return (0...6).reversed().map { index in
                let weeksAgo = offset * 7 + index
                let start = calendar.weekInterval(containing: data.now, weeksAgo: weeksAgo)?.start
                return (start?.formatted(.dateTime.month(.defaultDigits).day()) ?? "", data.week(offset: weeksAgo))
            }
        case .yearly:
            return (0...6).reversed().map { index in
                let monthsAgo = offset * 7 + index
                let start = calendar.monthInterval(containing: data.now, monthsAgo: monthsAgo)?.start
                return (start?.formatted(.dateTime.month(.abbreviated)) ?? "", data.month(offset: monthsAgo))
            }
        }
    }

    private var bars: [MetricBar] {
        periods.enumerated().map { index, period in
            MetricBar(id: index, label: period.label, value: Double(period.data.value(for: metric)))
        }
    }

    private var maxValue: Double {
        MetricBarChart.maxValue(for: metric, bars: bars, baseline: scale.leadsBaseline)
    }

    /// Every transaction across the seven periods, for the highlights.
    private var periodData: TransactionServices {
        var combined = data
        combined.transactions = periods.flatMap(\.data.transactions)
        return combined
    }
}

/// Totals for the period on display.
struct HighlightsCard: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let metric: Metric
    let period: TransactionServices

    private var denominatorName: String {
        let count = period.denominator(for: metric)
        switch metric {
        case .appleCare: return count == 1 ? "Total Device" : "Total Devices"
        case .businessLeads: return count == 1 ? "Day" : "Days"
        case .connectivity: return count == 1 ? "Total iPhone" : "Total iPhones"
        case .tradeIn, .accessory: return count == 1 ? "Device Sale" : "Device Sales"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Highlights")
                .font(.title2.bold())

            let stats = dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: 16)) : AnyLayout(HStackLayout())
            stats {
                Spacer()
                HighlightStat(value: period.count(for: metric).formatted(), caption: metric.unitName(for: period.count(for: metric)), color: metric.color)
                Spacer()
                if metric.isRate {
                    HighlightStat(value: period.denominator(for: metric).formatted(), caption: denominatorName, color: metric.color)
                } else {
                    HighlightStat(value: period.averageLeadsPerDay.formatted(.number.precision(.fractionLength(0...2))), caption: "Average Per Day", color: metric.color)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)

            if metric.isRate {
                HighlightStat(value: "\(period.percent(for: metric))%", caption: "Total \(metric.rateDescription)", color: metric.color)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .cardBackground()
    }
}

/// A large colored number with a caption beneath it.
struct HighlightStat: View {
    let value: String
    let caption: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.largeTitle.weight(.heavy))
                .foregroundStyle(color)
                .numericContentTransition()

            Text(caption)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    GraphDetailView(data: TransactionServices(TransactionRecord.sampleData), metric: .tradeIn)
}
