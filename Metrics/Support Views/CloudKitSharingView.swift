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
    var share: CKShare
    var container: CKContainer
    
    // MARK: View Controller Generator
    func makeUIViewController(context: Context) -> UICloudSharingController {
        // MARK: Sharing View Settings
        let cloudSharingController = UICloudSharingController(share: share, container: container)
        
        cloudSharingController.modalPresentationStyle = .pageSheet
        cloudSharingController.availablePermissions = [.allowPublic, .allowPrivate, .allowReadOnly]
        
        cloudSharingController.delegate = context.coordinator
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
        func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
            print("Share save complete!")
            csc.dismiss(animated: true)
        }
        
        func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
            print("Share save error!")
            csc.dismiss(animated: true)
        }
        
        func itemTitle(for csc: UICloudSharingController) -> String? {
            "Transaction History"
        }
        
        func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
            return NSDataAsset(name: "sharing thumbnail")!.data
        }
    }
}
