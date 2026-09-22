//
//  SharingStore.swift
//  Metrics
//
//  Created by Ethan Marshall on 9/22/26.
//

import CloudKit
import Foundation
import Observation
import os

/// The status of a CloudKit operation, such as a query or modification.
enum CloudKitOperationStatus: Sendable {
    /// The operation has not been attempted yet.
    case notStarted
    /// The operation is underway.
    case inProgress
    /// The operation completed successfully.
    case success
    /// The operation completed but failed.
    case failure
}

/// Someone who is sharing their transactions with the current user.
struct SharingUser: Identifiable {
    let id: CKRecord.ID
    /// The share record, which the system sharing UI uses to show participants or leave the share.
    let share: CKShare
    let name: String?
    let email: String?
    let phoneNumber: String?

    var displayName: String { name ?? "Name Not Provided" }
}

/// Loads the transactions other people share with the current user, and prepares the user's own share.
///
/// Shared data lives in the shared CloudKit database with one record zone per person. Each zone holds the
/// person's mirrored Core Data transactions plus a share record that carries their name.
@MainActor @Observable
final class SharingStore {
    /// The CloudKit container the app syncs and shares through.
    static let containerIdentifier = "iCloud.Metrics"

    /// The zone that `NSPersistentCloudKitContainer` mirrors the user's own data into.
    static let coreDataZoneID = CKRecordZone.ID(zoneName: "com.apple.coredata.cloudkit.zone", ownerName: CKCurrentUserDefaultName)

    /// The CloudKit record type that `NSPersistentCloudKitContainer` uses for the `Transaction` entity.
    private static let transactionRecordType = "CD_Transaction"

    private static let logger = Logger(subsystem: "Ethan.Metrics", category: "Sharing")

    static var container: CKContainer { CKContainer(identifier: containerIdentifier) }

    /// The status of the most recent load.
    private(set) var status: CloudKitOperationStatus = .notStarted

    /// Everyone sharing with the current user, with their full transaction history.
    private(set) var people: [TransactionServices] = []

    /// Whether a load has finished, successfully or not.
    var hasLoaded: Bool { status == .success || status == .failure }

    private var refreshTask: Task<Void, Never>?

    /// Reloads everyone's shared transactions. Overlapping calls wait for the load already in progress.
    func refresh() async {
        if let refreshTask {
            await refreshTask.value
            return
        }
        let task = Task { await self.load() }
        refreshTask = task
        await task.value
        refreshTask = nil
    }

    private func load() async {
        status = .inProgress
        do {
            people = try await Self.sharedTransactions()
            status = .success
        } catch {
            Self.logger.error("Failed to load shared data: \(error.localizedDescription)")
            status = .failure
        }
    }

    // MARK: - Reading shared data

    /// Every person's shared transactions, one set per shared zone. Zones that fail to load are skipped.
    static func sharedTransactions() async throws -> [TransactionServices] {
        let database = container.sharedCloudDatabase
        var people: [TransactionServices] = []
        for zone in try await database.allRecordZones() {
            do {
                let records = try await allRecords(ofType: transactionRecordType, in: zone.zoneID, database: database)
                let share = try await share(for: zone, in: database)
                // Public-link shares hide the owner's identity; views fall back to a placeholder when this is nil.
                let owner = share.flatMap(ownerName(of:))
                people.append(TransactionServices(records.compactMap(TransactionRecord.init(cloudKitRecord:)), owner: owner))
            } catch {
                logger.error("Skipping shared zone \(zone.zoneID.zoneName): \(error.localizedDescription)")
            }
        }
        return people
    }

    /// The people sharing with the current user.
    static func sharingUsers() async throws -> [SharingUser] {
        let database = container.sharedCloudDatabase
        var users: [SharingUser] = []
        for zone in try await database.allRecordZones() {
            guard let share = try await share(for: zone, in: database) else { continue }
            let identity = share.owner.userIdentity
            users.append(
                SharingUser(
                    id: share.recordID,
                    share: share,
                    name: ownerName(of: share),
                    email: identity.lookupInfo?.emailAddress,
                    phoneNumber: identity.lookupInfo?.phoneNumber
                )
            )
        }
        return users
    }

    /// Fetches every record of a type in a zone, following the query cursor across pages.
    private static func allRecords(ofType recordType: String, in zoneID: CKRecordZone.ID, database: CKDatabase) async throws -> [CKRecord] {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        var (matches, cursor) = try await database.records(matching: query, inZoneWith: zoneID)
        var records = matches.compactMap { try? $0.1.get() }
        while let next = cursor {
            let page = try await database.records(continuingMatchFrom: next)
            records += page.matchResults.compactMap { try? $0.1.get() }
            cursor = page.queryCursor
        }
        return records
    }

    /// The share record for a zone. Zones from the shared database usually reference their share directly;
    /// a query is the fallback for zones that do not.
    private static func share(for zone: CKRecordZone, in database: CKDatabase) async throws -> CKShare? {
        if let reference = zone.share, let share = try await database.record(for: reference.recordID) as? CKShare {
            return share
        }
        let query = CKQuery(recordType: CKRecord.SystemType.share, predicate: NSPredicate(value: true))
        let (matches, _) = try await database.records(matching: query, inZoneWith: zone.zoneID, resultsLimit: 1)
        return matches.lazy.compactMap { try? $0.1.get() as? CKShare }.first
    }

    /// The share owner's name as they chose to share it, or `nil` if they did not.
    private static func ownerName(of share: CKShare) -> String? {
        guard let components = share.owner.userIdentity.nameComponents else { return nil }
        let name = components.formatted(.name(style: .medium))
        return name.isEmpty ? nil : name
    }

    // MARK: - Sharing your own data

    /// The share for the user's own transactions, created on first use.
    ///
    /// - Parameter thumbnail: Image data shown on the invitation.
    static func ownShare(thumbnail: Data?) async throws -> CKShare {
        let database = container.privateCloudDatabase
        let zone = try await database.recordZone(for: coreDataZoneID)
        if let reference = zone.share, let existing = try await database.record(for: reference.recordID) as? CKShare {
            configure(existing, thumbnail: thumbnail)
            return existing
        }
        let share = CKShare(recordZoneID: coreDataZoneID)
        configure(share, thumbnail: thumbnail)
        let results = try await database.modifyRecords(saving: [share], deleting: [])
        if let result = results.saveResults[share.recordID] {
            _ = try result.get()
        }
        return share
    }

    private static func configure(_ share: CKShare, thumbnail: Data?) {
        share[CKShare.SystemFieldKey.title] = "Transaction Access"
        share[CKShare.SystemFieldKey.shareType] = "Transaction Access"
        if let thumbnail {
            share[CKShare.SystemFieldKey.thumbnailImageData] = thumbnail
        }
    }
}
