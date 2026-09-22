//
//  CloudKitSharingView.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/2/22.
//

import CloudKit
import SwiftUI
import UIKit
import os

/// The system CloudKit sharing UI, for inviting people, managing participants or leaving a share.
struct CloudKitSharingView: UIViewControllerRepresentable {
    let share: CKShare
    let container: CKContainer

    private static let logger = Logger(subsystem: "Ethan.Metrics", category: "Sharing")

    func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller = UICloudSharingController(share: share, container: container)
        controller.modalPresentationStyle = .pageSheet
        controller.availablePermissions = [.allowPublic, .allowPrivate, .allowReadOnly]
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, UICloudSharingControllerDelegate {
        func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
            CloudKitSharingView.logger.notice("Share saved.")
        }

        func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
            CloudKitSharingView.logger.error("Failed to save share: \(error.localizedDescription)")
        }

        func itemTitle(for csc: UICloudSharingController) -> String? {
            "Transaction Access"
        }

        func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
            NSDataAsset(name: "sharing thumbnail")?.data
        }
    }
}
