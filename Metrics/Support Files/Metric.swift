//
//  Metric.swift
//  Metrics
//
//  Created by Ethan Marshall on 9/22/26.
//

import SwiftUI

/// The Product Zone metrics the app tracks.
///
/// Each case knows how to present itself (name, symbol, color) and where its daily goal is stored, so the
/// views can be written once and driven by `Metric.allCases`.
enum Metric: String, CaseIterable, Identifiable, Hashable, Sendable {
    case appleCare
    case businessLeads
    case connectivity
    case tradeIn
    case accessory

    var id: String { rawValue }

    /// The full name used in headings.
    var title: String {
        switch self {
        case .appleCare: "AppleCare+"
        case .businessLeads: "Business Leads"
        case .connectivity: "Connectivity"
        case .tradeIn: "Trade-In"
        case .accessory: "Accessories"
        }
    }

    /// A shorter name for tight spaces such as cards.
    var shortTitle: String {
        switch self {
        case .appleCare: "AppleCare+"
        case .businessLeads: "Leads"
        case .connectivity: "Connected"
        case .tradeIn: "Trade-In"
        case .accessory: "Accessory"
        }
    }

    /// The label of the addition when logging a transaction.
    var additionTitle: String {
        switch self {
        case .appleCare: "AppleCare+"
        case .businessLeads: "Business Lead"
        case .connectivity: "Connected"
        case .tradeIn: "Trade-In"
        case .accessory: "Accessory"
        }
    }

    /// The SF Symbol that represents the metric.
    var symbolName: String {
        switch self {
        case .appleCare: "applelogo"
        case .businessLeads: "briefcase.fill"
        case .connectivity: "antenna.radiowaves.left.and.right"
        case .tradeIn: "arrow.triangle.2.circlepath"
        case .accessory: "cable.connector"
        }
    }

    /// The color used for the metric throughout the app.
    var color: Color {
        switch self {
        case .appleCare: .red
        case .businessLeads: .leadBrown
        case .connectivity: .blue
        case .tradeIn: .orange
        case .accessory: .purple
        }
    }

    /// Whether the metric is a rate (a percentage of device sales) rather than a count.
    var isRate: Bool { self != .businessLeads }

    /// A description of the metric's rate, such as "Attach Rate".
    var rateDescription: String {
        switch self {
        case .appleCare: "Attach Rate"
        case .businessLeads: "Average Per Day"
        case .connectivity: "Connectivity Rate"
        case .tradeIn: "Trade-In Rate"
        case .accessory: "Attach Rate"
        }
    }

    /// Whether the addition only makes sense when a device is part of the transaction.
    var requiresDevice: Bool { self != .businessLeads }

    /// Whether the addition only makes sense when a new device is sold, which rules out standalone AppleCare+.
    var requiresDeviceSale: Bool { self == .tradeIn || self == .accessory }

    /// The UserDefaults key storing the daily goal. The original keys are kept so existing goals survive the update.
    var goalKey: String {
        switch self {
        case .appleCare: "appleCareGoal"
        case .businessLeads: "businessLeadsGoal"
        case .connectivity: "connectivityGoal"
        case .tradeIn: "tradeInGoal"
        case .accessory: "accessoryGoal"
        }
    }

    /// The daily goal used until the user sets their own.
    var defaultGoal: Int {
        switch self {
        case .appleCare: 60
        case .businessLeads: 2
        case .connectivity: 75
        case .tradeIn: 35
        case .accessory: 50
        }
    }

    /// Formats a goal for display, such as "60%" or "2 Leads".
    func formattedGoal(_ goal: Int) -> String {
        isRate ? "\(goal)%" : "\(goal) \(unitName(for: goal))"
    }

    /// The name of one counted unit, pluralized for `count`.
    func unitName(for count: Int) -> String {
        let singular = count == 1
        switch self {
        case .appleCare: return singular ? "AppleCare+ Unit" : "AppleCare+ Units"
        case .businessLeads: return singular ? "Lead" : "Leads"
        case .connectivity: return singular ? "Connected iPhone" : "Connected iPhones"
        case .tradeIn: return singular ? "Trade-In" : "Trade-Ins"
        case .accessory: return singular ? "Accessory" : "Accessories"
        }
    }
}
