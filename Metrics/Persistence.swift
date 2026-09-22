//
//  Persistence.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/30/21.
//

import CoreData
import SwiftUI
import os

/// Owns the Core Data stack, which `NSPersistentCloudKitContainer` keeps in sync with the user's iCloud account.
struct PersistenceController {
    static let shared = PersistenceController()

    /// An in-memory stack populated with sample transactions for previews.
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        for record in TransactionRecord.sampleData {
            Transaction(context: context).apply(record)
        }
        try? context.save()
        return controller
    }()

    let container: NSPersistentCloudKitContainer

    private static let logger = Logger(subsystem: "Ethan.Metrics", category: "Persistence")

    /// The data model, loaded once so every container (including in-memory ones for tests) shares it.
    private static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Metrics", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("The Metrics data model is missing from the app bundle.")
        }
        return model
    }()

    /// - Parameter inMemory: When `true`, data is never written to disk or synced, which suits previews and tests.
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Metrics", managedObjectModel: Self.model)
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("The Metrics data model has no persistent store description.")
        }
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
            description.cloudKitContainerOptions = nil
        }

        container.loadPersistentStores { _, error in
            if let error {
                // The app cannot work without its store, so this is deliberately fatal to produce a crash log.
                fatalError("Failed to load the Metrics store: \(error)")
            }
        }

        // Show changes that arrive from iCloud without requiring a relaunch.
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        #if DEBUG
        // Pushes the Core Data model to the CloudKit development schema. Run once with this argument after
        // changing the model, then deploy the schema to production in CloudKit Console before shipping.
        if !inMemory, CommandLine.arguments.contains("-initializeCloudKitSchema") {
            do {
                try container.initializeCloudKitSchema(options: [])
                Self.logger.notice("CloudKit development schema initialized.")
            } catch {
                Self.logger.error("CloudKit schema initialization failed: \(error.localizedDescription)")
            }
        }

        // Fills an empty store with sample transactions, for exercising the UI and taking screenshots.
        if !inMemory, CommandLine.arguments.contains("-seedSampleData") {
            seedSampleDataIfEmpty()
        }
        #endif
    }

    #if DEBUG
    private func seedSampleDataIfEmpty() {
        let context = container.viewContext
        let request = Transaction.fetchRequest()
        request.fetchLimit = 1
        guard (try? context.count(for: request)) == 0 else { return }
        for record in TransactionRecord.sampleData {
            Transaction(context: context).apply(record)
        }
        do {
            try context.save()
            Self.logger.notice("Seeded sample data.")
        } catch {
            Self.logger.error("Failed to seed sample data: \(error.localizedDescription)")
        }
    }
    #endif
}

extension View {
    /// Supplies the environment the app's views expect, backed by in-memory sample data, for previews.
    func previewEnvironment() -> some View {
        environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environment(SharingStore())
    }
}
