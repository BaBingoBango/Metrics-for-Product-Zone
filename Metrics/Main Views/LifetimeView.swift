//
//  LifetimeView.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/6/21.
//

import CoreData
import SwiftUI

/// Statistics about the user's entire transaction history.
struct LifetimeView: View {
    /// The navigation title, which names the person when viewing shared data.
    var navigationTitleText = "Lifetime"
    /// Transactions that replace the user's own, when viewing someone who shares with them.
    var customTransactions: TransactionServices?

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)], animation: .default)
    private var transactions: FetchedResults<Transaction>

    private var data: TransactionServices {
        customTransactions ?? TransactionServices(transactions.map(\.record))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                LifetimeStatCard(
                    color: .gray,
                    symbolName: "iphone",
                    primary: LifetimeStat(value: data.devicesTransacted.formatted(), description: data.devicesTransacted == 1 ? "Device Transacted" : "Devices Transacted")
                )

                ForEach(Metric.allCases) { metric in
                    Text(metric.title)
                        .font(.title.bold())
                        .padding(.top, 8)

                    LifetimeStatCard(color: metric.color, symbolName: metric.symbolName, primary: primaryStat(for: metric), secondary: secondaryStat(for: metric))
                }
            }
            .padding()
        }
        .navigationTitle(navigationTitleText)
    }

    private func primaryStat(for metric: Metric) -> LifetimeStat {
        let count = data.count(for: metric)
        let description: String = switch metric {
        case .appleCare: count == 1 ? "Unit Sold" : "Units Sold"
        case .businessLeads: count == 1 ? "Business Lead" : "Business Leads"
        case .connectivity: count == 1 ? "iPhone Connected" : "iPhones Connected"
        case .tradeIn: count == 1 ? "Trade-In" : "Trade-Ins"
        case .accessory: count == 1 ? "Accessory Attached" : "Accessories Attached"
        }
        return LifetimeStat(value: count.formatted(), description: description)
    }

    private func secondaryStat(for metric: Metric) -> LifetimeStat {
        if metric.isRate {
            return LifetimeStat(value: "\(data.percent(for: metric))%", description: metric.rateDescription)
        }
        return LifetimeStat(value: data.averageLeadsPerDay.formatted(.number.precision(.fractionLength(0...2))), description: "Average Per Day")
    }
}

/// A number and its description for a `LifetimeStatCard`.
struct LifetimeStat {
    let value: String
    let description: String
}

/// A tinted card showing one or two lifetime numbers over a faded symbol.
struct LifetimeStatCard: View {
    let color: Color
    let symbolName: String
    let primary: LifetimeStat
    var secondary: LifetimeStat? = nil

    var body: some View {
        HStack(spacing: 16) {
            stat(primary)

            if let secondary {
                stat(secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 125)
        .background(alignment: .leading) {
            Image(systemName: symbolName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(color.opacity(0.3))
                .padding(16)
        }
        .background(color.opacity(0.15), in: .rect(cornerRadius: 20, style: .continuous))
        .clipShape(.rect(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private func stat(_ stat: LifetimeStat) -> some View {
        VStack(spacing: 5) {
            Text(stat.value)
                .font(.largeTitle.weight(.heavy))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .contentTransition(.numericText())

            Text(stat.description)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        LifetimeView()
    }
    .previewEnvironment()
}
