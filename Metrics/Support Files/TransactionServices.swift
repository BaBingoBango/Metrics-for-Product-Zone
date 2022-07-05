//
//  TransactionServices.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/6/21.
//

import Foundation
import SwiftUI

class TransactionServices {
    
    // MARK: Setup
    
    // Unique ID
    var id = UUID()
    
    // List of transactions (parameter)
    var transactions: [Transaction]
    
    // Initializer
    init(_ transactions: [Transaction]) {
        self.transactions = transactions
    }
    
    // MARK: Methods that return transactions
    
    // Return today's transactions
    func today() -> [Transaction] {
        return transactions.filter({
            Calendar.current.isDateInToday($0.date!)
        })
    }
    
    // Return transactions on the specified weekday of the current week
    func thisWeek(_ day: Date.Weekday) -> [Transaction] {
        return transactions.filter({
            Calendar.current.isDate($0.date!, inSameDayAs: Date.today().previous(day))
        })
    }
    
    // Return all transactions from the current week
    func allWeek() -> [Transaction] {
        return transactions.filter({
            Calendar.current.isDayInCurrentWeek(date: $0.date!)!
        })
    }
    
    // Return transactions from a specified number of weeks ago
    func weekJump(_ weeks: Int) -> [Transaction] {
        return transactions.filter({
            ($0.date?.isInSameWeek(as: Calendar.current.date(byAdding: .weekOfYear, value: -weeks, to: Date())!))!
        })
    }
    
    // Return transactions from the current month
    func allMonth() -> [Transaction] {
        return transactions.filter({
            $0.date!.isInThisMonth
        })
    }
    
    // Return transactions from a specified number of months ago
    func monthJump(_ months: Int) -> [Transaction] {
        return transactions.filter({
            ($0.date?.isInSameMonth(as: Calendar.current.date(byAdding: .month, value: -months, to: Date())!))!
        })
    }
    
    // Return transactions attached to a device
    func withDevice() -> [Transaction] {
        var answer: [Transaction] = []
        for eachTransaction in transactions {
            if eachTransaction.deviceType != "No Device" {
                answer.append(eachTransaction)
            }
        }
        return answer
    }
    
    // MARK: Methods that return integers
    
    // Return the numerator for the AppleCare+ % calculation
    func appleCareNumerator() -> Int {
        var answer = 0
        for eachTransaction in withDevice() {
            if eachTransaction.boughtAppleCare {
                answer += 1
            }
        }
        return answer
    }
    
    // Return the denominator for the AppleCare+ % calculation
    func appleCareDenominator() -> Int {
        var numStandalone = 0
        for eachTransaction in withDevice() {
            if eachTransaction.isAppleCareStandalone && eachTransaction.boughtAppleCare {
                numStandalone += 1
            }
        }
        return withDevice().count - numStandalone
    }
    
    // Return AppleCare+ percentage (as an integer)
    func appleCarePercent() -> Int {
        if appleCareNumerator() == 0 {
            return 0
        } else if appleCareNumerator() > 0 && appleCareDenominator() == 0 {
            return appleCareNumerator() * 100
        } else {
            let answer = Double(appleCareNumerator()) / Double(appleCareDenominator())
            return Int(answer * 100)
        }
    }
    
    // Return the numerator for the AppleCare+ % calculation for a certain device
    func customAppleCareNumerator(_ deviceType: String) -> Int {
        var answer = 0
        for eachTransaction in withDevice() {
            if eachTransaction.boughtAppleCare && eachTransaction.deviceType == deviceType {
                answer += 1
            }
        }
        return answer
    }
    
    // Return the denominator for the AppleCare+ % calculation for a certain device
    func customAppleCareDenominator(_ deviceType: String) -> Int {
        var numStandalone = 0
        var numTotal = 0
        for eachTransaction in withDevice() {
            if eachTransaction.isAppleCareStandalone && eachTransaction.boughtAppleCare && eachTransaction.deviceType == deviceType {
                numStandalone += 1
            }
            if eachTransaction.deviceType == deviceType {
                numTotal += 1
            }
        }
        return numTotal - numStandalone
    }
    
    // Return AppleCare+ percentage (as an integer) for a certain device
    func customAppleCarePercent(_ deviceType: String) -> Int {
        if customAppleCareNumerator(deviceType) == 0 {
            return 0
        } else if customAppleCareNumerator(deviceType) > 0 && customAppleCareDenominator(deviceType) == 0 {
            return customAppleCareNumerator(deviceType) * 100
        } else {
            let answer = Double(customAppleCareNumerator(deviceType)) / Double(customAppleCareDenominator(deviceType))
            return Int(answer * 100)
        }
    }
    
    // Return the number of business leads
    func numBusinessLeads() -> Int {
        var answer = 0
        for eachTransaction in transactions {
            if eachTransaction.gotLead {
                answer += 1
            }
        }
        return answer
    }
    
    // Return number of connected devices
    func connectedUnits() -> Int {
        var answer = 0
        for eachTransaction in withDevice() {
            if eachTransaction.deviceType == "iPhone" && eachTransaction.connected {
                answer += 1
            }
        }
        return answer
    }
    
    // Return connectivity percentage (as an integer)
    func connectivityPercent() -> Int {
        var connected = 0
        var totalPhones = 0
        for eachTransaction in withDevice() {
            if eachTransaction.deviceType == "iPhone" && eachTransaction.connected {
                connected += 1
            }
            if eachTransaction.deviceType == "iPhone" {
                totalPhones += 1
            }
        }
        let answer = Double(connected) / Double(totalPhones)
        if totalPhones == 0 {
            return 0
        }
        return Int(answer * 100)
    }
    
    // Return number of unique days that have at least onetransaction
    func numUniqueDays() -> Int {
        var answer: [Date] = []
        for eachTransaction in transactions {
            var shouldAdd = true
            for eachDate in answer {
                if Calendar.current.isDate(eachDate, inSameDayAs: eachTransaction.date!) {
                    shouldAdd = false
                }
            }
            if shouldAdd {
                answer.append(eachTransaction.date!)
            }
        }
        return answer.count
    }
    
}
