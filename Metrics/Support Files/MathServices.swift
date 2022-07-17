//
//  MathServices.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/11/21.
//

import Foundation

extension Double {
    /// Truncates a given `Double` to the given amount of decimal places.
    func truncate(places : Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
