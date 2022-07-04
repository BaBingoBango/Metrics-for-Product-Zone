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
    var sharedZoneName: String
    var sharedZoneOwnerName: String
    var containerID: String
    
    // MARK: View Controller Generator
    func makeUIViewController(context: Context) -> UICloudSharingController {
        // MARK: Sharing View Setup
        let cloudSharingController = UICloudSharingController { (controller, completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
            let cloudKitShare = CKShare(recordZoneID: CKRecordZone.ID(zoneName: sharedZoneName, ownerName: sharedZoneOwnerName))
            let cloudKitContainer = CKContainer(identifier: containerID)
            
            let saveOperation = CKModifyRecordsOperation(recordsToSave: [cloudKitShare])
            saveOperation.modifyRecordsResultBlock = { (_ result: Result<Void, Error>) -> Void in
                switch result {
                case .success():
                    completion(cloudKitShare, cloudKitContainer, nil)
                case .failure(let error):
                    completion(nil, nil, error)
                }
            }
            cloudKitContainer.privateCloudDatabase.add(saveOperation)
        }
        
        // MARK: Sharing View Settings
        cloudSharingController.title = "AAAEEEEAAAEEE"
        cloudSharingController.availablePermissions = [.allowPrivate, .allowReadOnly]
        
        cloudSharingController.delegate = context.coordinator
        cloudSharingController.modalPresentationStyle = .formSheet
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
            "Hellloooooooooooo"
        }
        
        func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
            let icon = NSDataAsset(name: "alien")!
            return icon.data
        }
    }
}
