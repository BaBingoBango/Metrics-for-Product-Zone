//
//  MetricBarChart.swift
//  Metrics
//
//  Created by Ethan Marshall on 9/22/26.
//

import Charts
import SwiftUI

/// One bar in a `MetricBarChart`.
struct MetricBar: Identifiable, Equatable {
    let id: Int
    let label: String
    let value: Double
}

/// A bar chart in a metric's color, built with Swift Charts so it is accessible and animates between values.
struct MetricBarChart: View {
    let bars: [MetricBar]
    let color: Color
    /// The top of the y axis. Bars are clamped to it so one outlier cannot flatten the rest.
    let maxValue: Double
    /// Whether values are percentages rather than counts, which affects labels and VoiceOver.
    var isRate = true
    var showsYAxis = false

    var body: some View {
        Chart(bars) { bar in
            BarMark(
                x: .value("Period", String(bar.id)),
                y: .value(isRate ? "Rate" : "Count", min(bar.value, maxValue))
            )
            .foregroundStyle(color)
            .cornerRadius(8)
            .accessibilityLabel(bar.label)
            .accessibilityValue(isRate ? "\(Int(bar.value)) percent" : "\(Int(bar.value))")
        }
        .chartYScale(domain: 0...max(maxValue, 1))
        .chartXAxis {
            AxisMarks(values: bars.map { String($0.id) }) { value in
                AxisValueLabel {
                    if let key = value.as(String.self), let bar = bars.first(where: { String($0.id) == key }) {
                        Text(bar.label)
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartYAxis(showsYAxis ? .automatic : .hidden)
    }

    /// The y-axis top for a set of bars: 100% for rates, or at least `baseline` for counts.
    static func maxValue(for metric: Metric, bars: [MetricBar], baseline: Double) -> Double {
        metric.isRate ? 100 : max(baseline, bars.map(\.value).max() ?? 0)
    }

    /// One bar per day of a week, labelled with the calendar's weekday initials.
    static func weekdayBars(for metric: Metric, in data: TransactionServices, weekOffset: Int = 0) -> [MetricBar] {
        let labels = data.calendar.orderedVeryShortWeekdaySymbols
        return zip(data.byWeekday(weekOffset: weekOffset), labels).enumerated().map { index, pair in
            MetricBar(id: index, label: pair.1, value: Double(pair.0.value(for: metric)))
        }
    }
}

#Preview {
    let data = TransactionServices(TransactionRecord.sampleData)
    let bars = MetricBarChart.weekdayBars(for: .appleCare, in: data)
    MetricBarChart(bars: bars, color: .red, maxValue: 100, showsYAxis: true)
        .frame(height: 240)
        .padding()
}
