//
//  DateServices.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/9/21.
//

import Foundation

extension Calendar {
    /// The week that contains `date`, moved `offset` weeks into the past.
    func weekInterval(containing date: Date, weeksAgo offset: Int = 0) -> DateInterval? {
        guard let reference = self.date(byAdding: .weekOfYear, value: -offset, to: date) else { return nil }
        return dateInterval(of: .weekOfYear, for: reference)
    }

    /// The month that contains `date`, moved `offset` months into the past.
    func monthInterval(containing date: Date, monthsAgo offset: Int = 0) -> DateInterval? {
        guard let reference = self.date(byAdding: .month, value: -offset, to: date) else { return nil }
        return dateInterval(of: .month, for: reference)
    }

    /// The position of `date`'s weekday within a week that starts on `firstWeekday`, from 0 to 6.
    func weekdayIndex(for date: Date) -> Int {
        (component(.weekday, from: date) - firstWeekday + 7) % 7
    }

    /// Single-letter weekday symbols, starting from `firstWeekday`.
    var orderedVeryShortWeekdaySymbols: [String] {
        let symbols = veryShortWeekdaySymbols
        let start = firstWeekday - 1
        return Array(symbols[start...] + symbols[..<start])
    }
}
