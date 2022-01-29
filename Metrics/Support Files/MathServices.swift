//
//  MathServices.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/11/21.
//

import Foundation

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
