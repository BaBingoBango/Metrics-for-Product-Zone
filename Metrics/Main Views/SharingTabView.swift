//
//  SharingTabView.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/15/22.
//

import SwiftUI

/// The tabs presented when the user taps a person in the Sharing section of the Today view.
struct SharingTabView: View {
    @Environment(\.dismiss) private var dismiss
    /// The transactions of the person being viewed.
    let transactions: TransactionServices

    private var possessive: String {
        transactions.owner.map { "\($0)’s" } ?? "Their"
    }

    var body: some View {
        TabView {
            Tab("This Week", systemImage: "calendar") {
                NavigationStack {
                    ThisWeekView(navigationTitleText: "\(possessive) Week", customTransactions: transactions)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar { doneButton }
                }
            }

            Tab("Lifetime", systemImage: "crown.fill") {
                NavigationStack {
                    LifetimeView(navigationTitleText: "\(possessive) Lifetime", customTransactions: transactions)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar { doneButton }
                }
            }

            Tab("Transactions", systemImage: "doc.on.doc.fill") {
                NavigationStack {
                    DataViewer(titleText: "\(possessive) Transactions", customTransactions: transactions.transactions)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar { doneButton }
                }
            }
        }
    }

    private var doneButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Done", role: .confirm) { dismiss() }
        }
    }
}

#Preview {
    SharingTabView(transactions: TransactionServices(TransactionRecord.sampleData, owner: "Sam Appleseed"))
        .previewEnvironment()
}
