//
//  TransactionRecord.swift
//  Metrics
//
//  Created by Ethan Marshall on 9/22/26.
//

import CloudKit
import CoreData
import Foundation

/// An immutable snapshot of a transaction, independent of where it came from.
///
/// The app's own data lives in Core Data, while other people's data arrives as CloudKit records. Both are
/// converted to this value type so the metric calculations, previews and tests share one code path.
struct TransactionRecord: Identifiable, Hashable, Sendable {
    var id: UUID
    var date: Date
    var deviceType: DeviceType
    var boughtAppleCare: Bool
    var isAppleCareStandalone: Bool
    var gotLead: Bool
    var connected: Bool
    var tradedIn: Bool
    var boughtAccessory: Bool

    init(
        id: UUID = UUID(),
        date: Date = .now,
        deviceType: DeviceType = .noDevice,
        boughtAppleCare: Bool = false,
        isAppleCareStandalone: Bool = false,
        gotLead: Bool = false,
        connected: Bool = false,
        tradedIn: Bool = false,
        boughtAccessory: Bool = false
    ) {
        self.id = id
        self.date = date
        self.deviceType = deviceType
        self.boughtAppleCare = boughtAppleCare
        self.isAppleCareStandalone = isAppleCareStandalone
        self.gotLead = gotLead
        self.connected = connected
        self.tradedIn = tradedIn
        self.boughtAccessory = boughtAccessory
    }

    /// Whether a device was part of the transaction.
    var hasDevice: Bool { deviceType != .noDevice }

    /// Whether a new device was sold. Standalone AppleCare+ covers a device the customer already owns.
    var isDeviceSale: Bool { hasDevice && !(boughtAppleCare && isAppleCareStandalone) }

    /// Whether the transaction includes the addition tracked by `metric`.
    func includes(_ metric: Metric) -> Bool {
        switch metric {
        case .appleCare: boughtAppleCare
        case .businessLeads: gotLead
        case .connectivity: connected
        case .tradeIn: tradedIn
        case .accessory: boughtAccessory
        }
    }
}

// MARK: - Core Data

extension Transaction {
    /// A value-type snapshot of this managed object.
    var record: TransactionRecord {
        TransactionRecord(
            id: id ?? UUID(),
            date: date ?? .distantPast,
            deviceType: DeviceType(storedValue: deviceType),
            boughtAppleCare: boughtAppleCare,
            isAppleCareStandalone: isAppleCareStandalone,
            gotLead: gotLead,
            connected: connected,
            tradedIn: tradedIn,
            boughtAccessory: boughtAccessory
        )
    }

    /// Copies every field of `record` into this managed object.
    func apply(_ record: TransactionRecord) {
        id = record.id
        date = record.date
        deviceType = record.deviceType.rawValue
        boughtAppleCare = record.boughtAppleCare
        isAppleCareStandalone = record.isAppleCareStandalone
        gotLead = record.gotLead
        connected = record.connected
        tradedIn = record.tradedIn
        boughtAccessory = record.boughtAccessory
    }
}

// MARK: - CloudKit

extension TransactionRecord {
    /// Creates a record from a `CD_Transaction` CloudKit record mirrored by `NSPersistentCloudKitContainer`.
    ///
    /// Fields added after a record was uploaded, such as trade-in and accessory, are absent from older
    /// records and read as `false`.
    init?(cloudKitRecord record: CKRecord) {
        guard let date = record["CD_date"] as? Date else { return nil }
        let storedID = (record["CD_id"] as? String).flatMap(UUID.init(uuidString:))
        self.init(
            id: storedID ?? UUID(),
            date: date,
            deviceType: DeviceType(storedValue: record["CD_deviceType"] as? String),
            boughtAppleCare: record.boolValue(forKey: "CD_boughtAppleCare"),
            isAppleCareStandalone: record.boolValue(forKey: "CD_isAppleCareStandalone"),
            gotLead: record.boolValue(forKey: "CD_gotLead"),
            connected: record.boolValue(forKey: "CD_connected"),
            tradedIn: record.boolValue(forKey: "CD_tradedIn"),
            boughtAccessory: record.boolValue(forKey: "CD_boughtAccessory")
        )
    }
}

private extension CKRecord {
    /// Reads a Boolean attribute, which CloudKit stores as a number, defaulting to `false` when missing.
    func boolValue(forKey key: String) -> Bool {
        (self[key] as? NSNumber)?.boolValue ?? false
    }
}

// MARK: - Sample data

extension TransactionRecord {
    /// A deterministic three weeks of realistic transactions for previews and tests.
    static var sampleData: [TransactionRecord] {
        var generator = SeededGenerator(seed: 2026)
        let calendar = Calendar.current
        var records: [TransactionRecord] = []
        for daysAgo in 0..<21 {
            guard let day = calendar.date(byAdding: .day, value: -daysAgo, to: .now) else { continue }
            let transactionsToday = Int.random(in: 1...5, using: &generator)
            for index in 0..<transactionsToday {
                let hour = 10 + index * 2
                let scheduled = calendar.date(bySettingHour: hour, minute: Int.random(in: 0..<60, using: &generator), second: 0, of: day) ?? day
                let date = min(scheduled, .now)
                let device = Bool.random(using: &generator) ? DeviceType.iPhone : DeviceType.sellable.randomElement(using: &generator) ?? .iPhone
                let hasDevice = Int.random(in: 0..<10, using: &generator) < 9
                records.append(
                    TransactionRecord(
                        date: date,
                        deviceType: hasDevice ? device : .noDevice,
                        boughtAppleCare: hasDevice && Int.random(in: 0..<10, using: &generator) < 6,
                        isAppleCareStandalone: hasDevice && Int.random(in: 0..<10, using: &generator) < 1,
                        gotLead: !hasDevice || Int.random(in: 0..<10, using: &generator) < 2,
                        connected: hasDevice && device == .iPhone && Int.random(in: 0..<10, using: &generator) < 7,
                        tradedIn: hasDevice && Int.random(in: 0..<10, using: &generator) < 4,
                        boughtAccessory: hasDevice && Int.random(in: 0..<10, using: &generator) < 5
                    )
                )
            }
        }
        return records
    }
}

/// A small, repeatable random number generator (SplitMix64) so sample data is stable between runs.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

// MARK: - Drafting

/// A transaction being composed in the logging UI, with the rules for which additions apply.
struct TransactionDraft: Equatable {
    var record = TransactionRecord()

    /// The additions that make sense for the current device and AppleCare+ selection.
    var availableAdditions: [Metric] {
        Metric.allCases.filter { metric in
            if metric.requiresDevice, !record.hasDevice { return false }
            if metric == .connectivity, !record.deviceType.supportsConnectivity { return false }
            if metric.requiresDeviceSale, !record.isDeviceSale { return false }
            return true
        }
    }

    /// Whether the draft includes `metric`'s addition.
    func includes(_ metric: Metric) -> Bool {
        record.includes(metric)
    }

    /// Selects a device, or clears the selection when tapping the selected device again.
    mutating func select(_ device: DeviceType) {
        record.deviceType = record.deviceType == device ? .noDevice : device
        pruneAdditions()
    }

    /// Toggles an addition. AppleCare+ cycles from off, to attached, to standalone, and back to off.
    mutating func toggle(_ metric: Metric) {
        switch metric {
        case .appleCare:
            if !record.boughtAppleCare {
                record.boughtAppleCare = true
            } else if record.isAppleCareStandalone {
                record.boughtAppleCare = false
                record.isAppleCareStandalone = false
            } else {
                record.isAppleCareStandalone = true
            }
        case .businessLeads:
            record.gotLead.toggle()
        case .connectivity:
            record.connected.toggle()
        case .tradeIn:
            record.tradedIn.toggle()
        case .accessory:
            record.boughtAccessory.toggle()
        }
        pruneAdditions()
    }

    /// The finished transaction, stamped with a fresh ID and the current time.
    func finalized(at date: Date = .now) -> TransactionRecord {
        var finished = record
        finished.id = UUID()
        finished.date = date
        return finished
    }

    /// Clears additions that no longer apply after the device or AppleCare+ selection changed.
    private mutating func pruneAdditions() {
        if !record.hasDevice {
            record.boughtAppleCare = false
            record.isAppleCareStandalone = false
        }
        if !record.deviceType.supportsConnectivity {
            record.connected = false
        }
        if !record.isDeviceSale {
            record.tradedIn = false
            record.boughtAccessory = false
        }
    }
}
