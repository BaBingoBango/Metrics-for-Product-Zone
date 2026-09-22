//
//  TransactionServices.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/6/21.
//

import Foundation

/// A set of transactions together with the calculations every metric in the app is built on.
///
/// The type is a plain value so the same math serves Core Data results, CloudKit sharing data, previews
/// and unit tests.
struct TransactionServices: Identifiable, Sendable {
    /// A stable identity, so lists of people sharing their data can be diffed.
    var id = UUID()
    /// The name of the person whose transactions these are, when they came from Sharing.
    var owner: String?
    /// The transactions, in no particular order.
    var transactions: [TransactionRecord]
    /// The calendar used for all date math. Weeks follow the device's first-day-of-week setting, which users
    /// can change in Settings under Language & Region.
    var calendar: Calendar
    /// The moment that "today" and "this week" are relative to.
    var now: Date

    init(_ transactions: [TransactionRecord], owner: String? = nil, calendar: Calendar = .current, now: Date = .now) {
        self.transactions = transactions
        self.owner = owner
        self.calendar = calendar
        self.now = now
    }

    // MARK: - Subsets

    /// A copy of this set containing only the transactions that satisfy `isIncluded`.
    private func filtered(_ isIncluded: (TransactionRecord) -> Bool) -> TransactionServices {
        var copy = self
        copy.transactions = transactions.filter(isIncluded)
        return copy
    }

    /// The transactions logged today.
    var today: TransactionServices {
        filtered { calendar.isDate($0.date, inSameDayAs: now) }
    }

    /// The transactions logged within `interval`.
    func inInterval(_ interval: DateInterval) -> TransactionServices {
        filtered { interval.contains($0.date) }
    }

    /// The transactions from the week `offset` weeks ago, where 0 is the current week.
    func week(offset: Int = 0) -> TransactionServices {
        guard let interval = calendar.weekInterval(containing: now, weeksAgo: offset) else { return filtered { _ in false } }
        return inInterval(interval)
    }

    /// The transactions from the month `offset` months ago, where 0 is the current month.
    func month(offset: Int = 0) -> TransactionServices {
        guard let interval = calendar.monthInterval(containing: now, monthsAgo: offset) else { return filtered { _ in false } }
        return inInterval(interval)
    }

    /// The transactions of a week split by weekday, ordered from the calendar's first weekday.
    func byWeekday(weekOffset: Int = 0) -> [TransactionServices] {
        var buckets = Array(repeating: [TransactionRecord](), count: 7)
        for transaction in week(offset: weekOffset).transactions {
            buckets[calendar.weekdayIndex(for: transaction.date)].append(transaction)
        }
        return buckets.map { bucket in
            var copy = self
            copy.transactions = bucket
            return copy
        }
    }

    // MARK: - Devices

    /// The transactions that involved a device, including standalone AppleCare+ for an existing device.
    var withDevice: [TransactionRecord] { transactions.filter(\.hasDevice) }

    /// The transactions in which a new device was sold.
    var deviceSales: [TransactionRecord] { transactions.filter(\.isDeviceSale) }

    /// The number of transactions that involved a device.
    var devicesTransacted: Int { withDevice.count }

    // MARK: - AppleCare+

    /// The number of AppleCare+ plans sold, including standalone plans.
    var appleCareUnits: Int { withDevice.count(where: \.boughtAppleCare) }

    /// The number of device sales that AppleCare+ could have been attached to.
    var appleCareEligibleDevices: Int { deviceSales.count }

    /// The AppleCare+ attach rate as a whole percentage.
    var appleCarePercent: Int { Self.attachPercent(units: appleCareUnits, devices: appleCareEligibleDevices) }

    /// The AppleCare+ attach rate for one device type as a whole percentage.
    func appleCarePercent(for device: DeviceType) -> Int {
        let ofDevice = withDevice.filter { $0.deviceType == device }
        let units = ofDevice.count(where: \.boughtAppleCare)
        let standalone = ofDevice.count { $0.boughtAppleCare && $0.isAppleCareStandalone }
        return Self.attachPercent(units: units, devices: ofDevice.count - standalone)
    }

    /// AppleCare+ units over device sales. Standalone plans count as units without a device sale, which
    /// mirrors how attach is reported in store and means the rate can exceed 100%.
    private static func attachPercent(units: Int, devices: Int) -> Int {
        if units == 0 { return 0 }
        if devices == 0 { return units * 100 }
        return Int(Double(units) / Double(devices) * 100)
    }

    // MARK: - Business Leads

    /// The number of business leads recorded.
    var businessLeads: Int { transactions.count(where: \.gotLead) }

    /// The number of distinct days with at least one transaction.
    var uniqueDays: Int { Set(transactions.map { calendar.startOfDay(for: $0.date) }).count }

    /// The average number of business leads per day with transactions, or 0 when there are none.
    var averageLeadsPerDay: Double { uniqueDays == 0 ? 0 : Double(businessLeads) / Double(uniqueDays) }

    // MARK: - Connectivity

    /// The number of iPhone transactions.
    var iPhonesTransacted: Int { withDevice.count { $0.deviceType == .iPhone } }

    /// The number of iPhones activated with a carrier.
    var connectedUnits: Int { withDevice.count { $0.deviceType == .iPhone && $0.connected } }

    /// The share of iPhones that were connected, as a whole percentage.
    var connectivityPercent: Int { Self.ratePercent(connectedUnits, of: iPhonesTransacted) }

    // MARK: - Trade-In

    /// The number of device sales that included a trade-in.
    var tradeIns: Int { deviceSales.count(where: \.tradedIn) }

    /// The share of device sales with a trade-in, as a whole percentage.
    var tradeInPercent: Int { Self.ratePercent(tradeIns, of: deviceSales.count) }

    // MARK: - Accessories

    /// The number of device sales that included an accessory.
    var accessoriesAttached: Int { deviceSales.count(where: \.boughtAccessory) }

    /// The share of device sales with an accessory, as a whole percentage.
    var accessoryPercent: Int { Self.ratePercent(accessoriesAttached, of: deviceSales.count) }

    private static func ratePercent(_ part: Int, of whole: Int) -> Int {
        whole == 0 ? 0 : Int(Double(part) / Double(whole) * 100)
    }

    // MARK: - Metric-generic access

    /// The number of units counted by `metric`: plans, leads, connected iPhones, trade-ins or accessories.
    func count(for metric: Metric) -> Int {
        switch metric {
        case .appleCare: appleCareUnits
        case .businessLeads: businessLeads
        case .connectivity: connectedUnits
        case .tradeIn: tradeIns
        case .accessory: accessoriesAttached
        }
    }

    /// The population that `metric`'s rate is measured against.
    func denominator(for metric: Metric) -> Int {
        switch metric {
        case .appleCare: appleCareEligibleDevices
        case .businessLeads: uniqueDays
        case .connectivity: iPhonesTransacted
        case .tradeIn, .accessory: deviceSales.count
        }
    }

    /// The rate for `metric` as a whole percentage. Business Leads are a count and always report 0 here.
    func percent(for metric: Metric) -> Int {
        switch metric {
        case .appleCare: appleCarePercent
        case .businessLeads: 0
        case .connectivity: connectivityPercent
        case .tradeIn: tradeInPercent
        case .accessory: accessoryPercent
        }
    }

    /// The headline number for `metric`: its rate for rate metrics, or its count for Business Leads.
    func value(for metric: Metric) -> Int {
        metric.isRate ? percent(for: metric) : count(for: metric)
    }

    /// The headline number for `metric`, formatted for display.
    func formattedValue(for metric: Metric) -> String {
        metric.isRate ? "\(percent(for: metric))%" : "\(count(for: metric))"
    }
}
