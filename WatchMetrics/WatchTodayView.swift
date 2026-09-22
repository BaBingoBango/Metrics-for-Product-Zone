//
//  WatchTodayView.swift
//  WatchMetrics
//
//  Created by Ethan Marshall on 8/14/21.
//

import CoreData
import SwiftUI

/// The watch app's main page: the Log Transaction button and today's numbers.
struct WatchTodayView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)], animation: .default)
    private var transactions: FetchedResults<Transaction>
    @State private var isShowingAdder = false

    private var todayData: TransactionServices {
        TransactionServices(transactions.map(\.record)).today
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    Button {
                        isShowingAdder = true
                    } label: {
                        Label("Log Transaction", systemImage: "plus")
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    WatchMetricRing(metric: .appleCare, data: todayData)
                        .frame(width: 84, height: 84)

                    HStack(spacing: 12) {
                        WatchMetricRing(metric: .businessLeads, data: todayData)
                        WatchMetricRing(metric: .connectivity, data: todayData)
                    }

                    HStack(spacing: 12) {
                        WatchMetricRing(metric: .tradeIn, data: todayData)
                        WatchMetricRing(metric: .accessory, data: todayData)
                    }
                }
                .padding(.horizontal, 4)
            }
            .navigationTitle("Today")
            .sheet(isPresented: $isShowingAdder) {
                WatchAdderView()
            }
        }
    }
}

/// A ring showing a metric's value for the day: its symbol for rates, or the count for Business Leads.
struct WatchMetricRing: View {
    let metric: Metric
    let data: TransactionServices

    var body: some View {
        ProgressRing(progress: metric.isRate ? Double(data.percent(for: metric)) / 100 : 0, color: metric.color, lineWidth: 9) {
            if metric.isRate {
                Image(systemName: metric.symbolName)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(metric.color)
            } else {
                Text("\(data.count(for: metric))")
                    .font(.title2.bold())
                    .foregroundStyle(metric.color)
            }
        }
        .frame(width: 72, height: 72)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(metric.title) today: \(data.formattedValue(for: metric))")
    }
}

#Preview {
    WatchTodayView()
        .previewEnvironment()
}
