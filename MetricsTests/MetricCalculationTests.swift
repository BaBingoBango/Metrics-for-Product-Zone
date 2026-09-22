//
//  MetricCalculationTests.swift
//  MetricsTests
//
//  Created by Ethan Marshall on 9/22/26.
//

import CloudKit
import Foundation
import Testing
@testable import Metrics

/// Tests for the metric math that every screen in the app relies on.
@MainActor
struct MetricCalculationTests {
    /// A fixed calendar and clock so results do not depend on the machine running the tests.
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        calendar.firstWeekday = 1
        return calendar
    }()

    /// Tuesday, September 22, 2026 at 3 PM.
    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: 22, hour: 15))!
    }

    private func services(_ records: [TransactionRecord]) -> TransactionServices {
        TransactionServices(records, calendar: calendar, now: now)
    }

    private func transaction(
        _ device: DeviceType = .iPhone,
        appleCare: Bool = false,
        standalone: Bool = false,
        lead: Bool = false,
        connected: Bool = false,
        tradeIn: Bool = false,
        accessory: Bool = false,
        daysAgo: Int = 0
    ) -> TransactionRecord {
        TransactionRecord(
            date: calendar.date(byAdding: .day, value: -daysAgo, to: now)!,
            deviceType: device,
            boughtAppleCare: appleCare,
            isAppleCareStandalone: standalone,
            gotLead: lead,
            connected: connected,
            tradedIn: tradeIn,
            boughtAccessory: accessory
        )
    }

    // MARK: - AppleCare+

    @Test func appleCareAttachCountsStandalonePlansAsUnitsButNotDevices() {
        let data = services([
            transaction(appleCare: true),
            transaction(),
            transaction(appleCare: true, standalone: true),
        ])
        #expect(data.appleCareUnits == 2)
        #expect(data.appleCareEligibleDevices == 2)
        #expect(data.appleCarePercent == 100)
    }

    @Test func appleCareAttachIsZeroWithoutPlans() {
        #expect(services([transaction(), transaction(.iPad)]).appleCarePercent == 0)
        #expect(services([]).appleCarePercent == 0)
    }

    @Test func appleCareAttachIsReportedPerDeviceType() {
        let data = services([
            transaction(.iPhone, appleCare: true),
            transaction(.iPhone),
            transaction(.iPad),
        ])
        #expect(data.appleCarePercent(for: .iPhone) == 50)
        #expect(data.appleCarePercent(for: .iPad) == 0)
        #expect(data.appleCarePercent(for: .mac) == 0)
    }

    // MARK: - Connectivity

    @Test func connectivityOnlyCountsiPhones() {
        let data = services([
            transaction(.iPhone, connected: true),
            transaction(.iPhone),
            transaction(.iPad),
        ])
        #expect(data.connectedUnits == 1)
        #expect(data.iPhonesTransacted == 2)
        #expect(data.connectivityPercent == 50)
    }

    // MARK: - Trade-In and Accessories

    @Test func tradeInRateIsMeasuredAgainstDeviceSales() {
        let data = services([
            transaction(.iPhone, tradeIn: true),
            transaction(.iPad),
            transaction(.mac, appleCare: true, standalone: true),
            transaction(.noDevice, lead: true),
        ])
        #expect(data.deviceSales.count == 2)
        #expect(data.tradeIns == 1)
        #expect(data.tradeInPercent == 50)
    }

    @Test func accessoryAttachIsMeasuredAgainstDeviceSales() {
        let data = services([
            transaction(.iPhone, accessory: true),
            transaction(.appleWatch, accessory: true),
            transaction(.iPad),
            transaction(.mac, appleCare: true, standalone: true),
        ])
        #expect(data.accessoriesAttached == 2)
        #expect(data.accessoryPercent == 66)
    }

    @Test func rateMetricsAreZeroWithoutDeviceSales() {
        let data = services([transaction(.noDevice, lead: true)])
        for metric in Metric.allCases where metric.isRate {
            #expect(data.percent(for: metric) == 0, "\(metric.title) should be 0% with no device sales")
        }
    }

    // MARK: - Business Leads

    @Test func leadsAreCountedAcrossEveryTransactionAndAveragedPerDay() {
        let data = services([
            transaction(.noDevice, lead: true),
            transaction(.iPhone, lead: true, daysAgo: 1),
            transaction(.iPhone, daysAgo: 1),
            transaction(.iPad, lead: true, daysAgo: 3),
        ])
        #expect(data.businessLeads == 3)
        #expect(data.uniqueDays == 3)
        #expect(data.averageLeadsPerDay == 1)
        #expect(data.value(for: .businessLeads) == 3)
    }

    // MARK: - Dates

    @Test func todayAndWeekSubsetsUseTheCalendar() {
        let data = services([
            transaction(daysAgo: 0),
            transaction(daysAgo: 1),
            transaction(daysAgo: 8),
            transaction(daysAgo: 40),
        ])
        #expect(data.today.transactions.count == 1)
        #expect(data.week().transactions.count == 2)
        #expect(data.week(offset: 1).transactions.count == 1)
        #expect(data.month().transactions.count == 3)
        #expect(data.month(offset: 1).transactions.count == 1)
    }

    @Test func weekdayBucketsStartOnTheCalendarsFirstWeekday() {
        // September 22, 2026 is a Tuesday, so the current week began on Sunday the 20th.
        let data = services([transaction(daysAgo: 0), transaction(daysAgo: 2)])
        let buckets = data.byWeekday()
        #expect(buckets.count == 7)
        #expect(buckets[0].transactions.count == 1)
        #expect(buckets[2].transactions.count == 1)
        #expect(calendar.orderedVeryShortWeekdaySymbols == ["S", "M", "T", "W", "T", "F", "S"])
    }

    // MARK: - CloudKit

    @Test func cloudKitRecordsDecodeAndTreatMissingFieldsAsFalse() throws {
        let id = UUID()
        let cloudRecord = CKRecord(recordType: "CD_Transaction")
        cloudRecord["CD_id"] = id.uuidString
        cloudRecord["CD_date"] = now
        cloudRecord["CD_deviceType"] = "Apple Watch"
        cloudRecord["CD_boughtAppleCare"] = 1 as Int64
        cloudRecord["CD_gotLead"] = 0 as Int64

        let record = try #require(TransactionRecord(cloudKitRecord: cloudRecord))
        #expect(record.id == id)
        #expect(record.date == now)
        #expect(record.deviceType == .appleWatch)
        #expect(record.boughtAppleCare)
        #expect(!record.gotLead)
        #expect(!record.tradedIn)
        #expect(!record.boughtAccessory)
    }

    @Test func cloudKitRecordsWithoutADateAreSkipped() {
        let cloudRecord = CKRecord(recordType: "CD_Transaction")
        cloudRecord["CD_deviceType"] = "iPhone"
        #expect(TransactionRecord(cloudKitRecord: cloudRecord) == nil)
    }

    // MARK: - Drafting

    @Test func draftOffersOnlyTheAdditionsThatApply() {
        var draft = TransactionDraft()
        #expect(draft.availableAdditions == [.businessLeads])

        draft.select(.iPad)
        #expect(draft.availableAdditions == [.appleCare, .businessLeads, .tradeIn, .accessory])

        draft.select(.iPhone)
        #expect(draft.availableAdditions == Metric.allCases)
    }

    @Test func draftClearsAdditionsThatNoLongerApply() {
        var draft = TransactionDraft()
        draft.select(.iPhone)
        draft.toggle(.connectivity)
        draft.toggle(.tradeIn)
        #expect(draft.record.connected)

        draft.select(.iPad)
        #expect(!draft.record.connected)
        #expect(draft.record.tradedIn)

        draft.select(.iPad)
        #expect(draft.record.deviceType == .noDevice)
        #expect(!draft.record.tradedIn)
    }

    @Test func draftCyclesAppleCareThroughStandalone() {
        var draft = TransactionDraft()
        draft.select(.mac)
        draft.toggle(.accessory)

        draft.toggle(.appleCare)
        #expect(draft.record.boughtAppleCare && !draft.record.isAppleCareStandalone)
        #expect(draft.record.boughtAccessory)

        draft.toggle(.appleCare)
        #expect(draft.record.boughtAppleCare && draft.record.isAppleCareStandalone)
        #expect(!draft.record.boughtAccessory, "standalone AppleCare+ is not a device sale")
        #expect(!draft.availableAdditions.contains(.accessory))

        draft.toggle(.appleCare)
        #expect(!draft.record.boughtAppleCare && !draft.record.isAppleCareStandalone)
    }
}
