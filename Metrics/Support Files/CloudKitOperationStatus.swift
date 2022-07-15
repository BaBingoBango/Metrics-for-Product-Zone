//
//  CloudKitOperationStatus.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/15/22.
//

import Foundation

/// The status of a CloudKit operation, such as a query or modification.
enum CloudKitOperationStatus {
    /// The case in which the operation has not yet been attempted.
    case notStarted
    
    /// The case in which the operation is currently underway.
    case inProgress
    
    /// The case in which the operation has completed successfully.
    case success
    
    /// The case in which the operation is complete but has failed.
    case failure
}
