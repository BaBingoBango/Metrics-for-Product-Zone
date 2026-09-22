//
//  MetricsTests.swift
//  MetricsTests
//
//  Created by Ethan Marshall on 7/30/21.
//

import CoreData
import Testing
@testable import Metrics

/// Tests for the Core Data stack.
@MainActor
struct PersistenceTests {
    @Test func transactionsRoundTripThroughCoreData() throws {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        let record = TransactionRecord(deviceType: .mac, boughtAppleCare: true, tradedIn: true, boughtAccessory: true)

        Transaction(context: context).apply(record)
        try context.save()

        let fetched = try context.fetch(Transaction.fetchRequest())
        #expect(fetched.count == 1)
        #expect(fetched.first?.record == record)
    }

    @Test func sampleDataIsStable() {
        #expect(TransactionRecord.sampleData.map(\.deviceType) == TransactionRecord.sampleData.map(\.deviceType))
        #expect(!TransactionRecord.sampleData.isEmpty)
    }
}
