//
//  DeviceType.swift
//  Metrics
//
//  Created by Ethan Marshall on 9/22/26.
//

import Foundation

/// The kinds of device a transaction can involve.
///
/// Raw values are the strings stored in Core Data and mirrored to CloudKit, so they must never change.
enum DeviceType: String, CaseIterable, Identifiable, Hashable, Sendable {
    case iPhone = "iPhone"
    case iPad = "iPad"
    case mac = "Mac"
    case appleWatch = "Apple Watch"
    case appleTV = "Apple TV"
    case headphones = "Headphones"
    case noDevice = "No Device"

    var id: String { rawValue }

    /// The device types a customer can buy, in the order the app presents them.
    static let sellable: [DeviceType] = [.iPhone, .iPad, .mac, .appleWatch, .appleTV, .headphones]

    /// The user-facing name of the device type.
    var name: String { rawValue }

    /// The SF Symbol that represents the device type.
    var symbolName: String {
        switch self {
        case .iPhone: "iphone"
        case .iPad: "ipad.landscape"
        case .mac: "desktopcomputer"
        case .appleWatch: "applewatch"
        case .appleTV: "appletv"
        case .headphones: "headphones"
        case .noDevice: "briefcase.fill"
        }
    }

    /// Whether the device can be activated with a carrier, which is what the Connectivity metric tracks.
    var supportsConnectivity: Bool { self == .iPhone }

    /// Creates a device type from a stored string, treating unknown or missing values as no device.
    init(storedValue: String?) {
        self = storedValue.flatMap(DeviceType.init(rawValue:)) ?? .noDevice
    }
}
