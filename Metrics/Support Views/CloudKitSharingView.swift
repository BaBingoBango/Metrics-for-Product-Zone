//
//  CloudKitSharingView.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/2/22.
//

import Foundation
import SwiftUI
import UIKit
import CloudKit

/// A SwiftUI view for displaying the Game Center dashboard via a modal.
struct CloudKitSharingView: UIViewControllerRepresentable {
    // MARK: View Variables
    var cloudKitShare: CKShare
    var cloudKitContainer: CKContainer
    
    // MARK: View Controller Generator
    func makeUIViewController(context: Context) -> UICloudSharingController {
        // MARK: Sharing View Settings
        let cloudSharingController = UICloudSharingController(share: cloudKitShare, container: cloudKitContainer)
        cloudSharingController.title = "Share Title!"
        cloudSharingController.availablePermissions = [.allowPrivate, .allowReadOnly, .allowPublic]
        
        return cloudSharingController
    }
    
    // MARK: View Controller Updater
    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {}
    
    // MARK: Coordinator Generator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: Coordinator Class
    class Coordinator: NSObject, UICloudSharingControllerDelegate {
        var parent: CloudKitSharingView
        
        init(_ sharingController: CloudKitSharingView) {
            self.parent = sharingController
        }
        
        // MARK: Sharing View Delegate Functions
        func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
            print("Share save error!")
        }
        
        func itemTitle(for csc: UICloudSharingController) -> String? {
            return "Untitled...?"
        }
        
        func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
            let icon = NSDataAsset(name: "Old App Icon")!
            return icon.data
        }
    }
}
