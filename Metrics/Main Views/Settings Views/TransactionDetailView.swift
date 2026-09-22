//
//  TransactionDetailView.swift
//  Metrics
//
//  Created by Ethan Marshall on 6/21/22.
//

import CoreData
import SwiftUI
import os

/// Everything recorded about one transaction, with the option to delete it when it is the user's own.
struct TransactionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    /// The transaction to show.
    let record: TransactionRecord
    /// The managed object behind `record` when the transaction belongs to the user, which allows deletion.
    var transaction: Transaction?

    @State private var isConfirmingDelete = false

    private static let logger = Logger(subsystem: "Ethan.Metrics", category: "Transactions")

    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: record.deviceType.symbolName)
                        .font(.system(size: 64))
                        .foregroundStyle(.blue)
                        .frame(width: 150, height: 150)
                        .background(.fill.tertiary, in: .circle)

                    Text("\(record.deviceType.name) Transaction")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)

                    Text(record.date.formatted(date: .numeric, time: .shortened))
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }

            Section("Details") {
                DetailRow(isOn: record.boughtAppleCare, symbolName: Metric.appleCare.symbolName, text: record.boughtAppleCare ? "Purchased AppleCare+" : "Did Not Purchase AppleCare+")
                DetailRow(isOn: record.isAppleCareStandalone, symbolName: "sparkle", text: record.isAppleCareStandalone ? "AppleCare+ Is Standalone" : "AppleCare+ Is Not Standalone")
                DetailRow(isOn: record.connected, symbolName: Metric.connectivity.symbolName, text: record.connected ? "Connected" : "Did Not Connect")
                DetailRow(isOn: record.gotLead, symbolName: Metric.businessLeads.symbolName, text: record.gotLead ? "Recorded Business Lead" : "Did Not Record Business Lead")
                DetailRow(isOn: record.tradedIn, symbolName: Metric.tradeIn.symbolName, text: record.tradedIn ? "Traded In a Device" : "No Trade-In")
                DetailRow(isOn: record.boughtAccessory, symbolName: Metric.accessory.symbolName, text: record.boughtAccessory ? "Attached an Accessory" : "No Accessory Attached")

                LabeledContent("ID") {
                    Text(record.id.uuidString)
                        .font(.custom("Roboto Mono", size: 15, relativeTo: .subheadline))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .textSelection(.enabled)
                }
            }

            if transaction != nil {
                Section {
                    Button("Delete Transaction", role: .destructive) {
                        isConfirmingDelete = true
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete this transaction?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { delete() }
        } message: {
            Text("This removes it from all of your devices and from iCloud.")
        }
    }

    private func delete() {
        guard let transaction else { return }
        viewContext.delete(transaction)
        do {
            try viewContext.save()
        } catch {
            Self.logger.error("Failed to delete transaction: \(error.localizedDescription)")
        }
        dismiss()
    }
}

/// A detail line with a green or red badge showing whether the addition was part of the transaction.
struct DetailRow: View {
    let isOn: Bool
    let symbolName: String
    let text: String

    var body: some View {
        Label {
            Text(text)
                .fontWeight(.semibold)
        } icon: {
            Image(systemName: symbolName)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(isOn ? Color.green : Color.red, in: .circle)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        TransactionDetailView(record: TransactionRecord(deviceType: .iPhone, boughtAppleCare: true, gotLead: true, connected: true, tradedIn: true))
    }
    .previewEnvironment()
}
