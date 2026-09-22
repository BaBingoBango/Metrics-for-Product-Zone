//
//  DataViewer.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/13/21.
//

import CoreData
import SwiftUI

/// A list of every logged transaction, newest first.
struct DataViewer: View {
    /// The navigation title, which names the person when viewing shared data.
    var titleText = "Transaction Data"
    /// Transactions that replace the user's own, when viewing someone who shares with them.
    var customTransactions: [TransactionRecord]?

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)], animation: .default)
    private var transactions: FetchedResults<Transaction>

    var body: some View {
        Group {
            if let customTransactions {
                if customTransactions.isEmpty {
                    emptyState
                } else {
                    List(customTransactions.sorted { $0.date > $1.date }) { record in
                        NavigationLink {
                            TransactionDetailView(record: record)
                        } label: {
                            TransactionRow(record: record)
                        }
                    }
                }
            } else if transactions.isEmpty {
                emptyState
            } else {
                List(transactions) { transaction in
                    NavigationLink {
                        TransactionDetailView(record: transaction.record, transaction: transaction)
                    } label: {
                        TransactionRow(record: transaction.record)
                    }
                }
            }
        }
        .navigationTitle(titleText)
    }

    private var emptyState: some View {
        ContentUnavailableView("No Data Yet", systemImage: "figure.wave", description: Text("Nice to see you here though!"))
    }
}

/// One transaction in the list: its device, when it was logged and which additions it included.
struct TransactionRow: View {
    let record: TransactionRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: record.deviceType.symbolName)
                .font(.title2)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.deviceType.name)
                    .font(.headline)

                Text(record.date.formatted(date: .numeric, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 6) {
                ForEach(Metric.allCases.filter(record.includes)) { metric in
                    Image(systemName: metric.symbolName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(metric == .appleCare && record.isAppleCareStandalone ? .standaloneGold : metric.color)
                        .accessibilityLabel(metric.additionTitle)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        DataViewer()
    }
    .previewEnvironment()
}
