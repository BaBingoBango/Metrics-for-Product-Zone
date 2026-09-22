//
//  MetricsApp.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/30/21.
//

import CoreData
import CloudKit
import SwiftUI
import os
#if os(iOS)
import UIKit
#endif

@main
struct MetricsApp: App {
    @Environment(\.scenePhase) private var scenePhase
    #if os(iOS)
    @UIApplicationDelegateAdaptor private var delegate: MetricsAppDelegate
    #endif

    private let persistenceController = PersistenceController.shared
    @State private var sharingStore = SharingStore()

    /// The UserDefaults keys that sync across the user's devices through iCloud.
    static let syncedDefaultsKeys = ["showSharingInTodayView", "showGoalsInTodayView"] + Metric.allCases.map(\.goalKey)

    var body: some Scene {
        WindowGroup {
            #if os(watchOS)
            WatchMainTabView()
            #else
            MainTabView()
                .environment(ShareAcceptance.shared)
            #endif
        }
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environment(sharingStore)
        .onChange(of: scenePhase) { _, phase in
            #if !os(watchOS)
            // Zephyr mirrors the synced preferences to and from iCloud's key-value store.
            if phase == .active || phase == .inactive {
                Zephyr.sync(keys: Self.syncedDefaultsKeys)
            }
            #endif
        }
    }
}

#if os(iOS)
/// Accepts CloudKit share invitations the user opens and tracks the acceptance for the UI.
@MainActor @Observable
final class ShareAcceptance {
    static let shared = ShareAcceptance()

    private static let logger = Logger(subsystem: "Ethan.Metrics", category: "ShareAcceptance")

    /// Whether an invitation is being accepted, during which the app shows a progress sheet.
    var isAccepting = false

    /// Accepts a pending invitation.
    func accept(_ metadata: CKShare.Metadata) {
        guard metadata.participantStatus == .pending else { return }
        isAccepting = true
        Task {
            defer { isAccepting = false }
            do {
                _ = try await SharingStore.container.accept(metadata)
                Self.logger.notice("Share accepted.")
            } catch {
                Self.logger.error("Failed to accept share: \(error.localizedDescription)")
            }
        }
    }
}

/// Routes application-level CloudKit share invitations and installs the app's scene delegate.
final class MetricsAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = MetricsSceneDelegate.self
        return configuration
    }

    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        ShareAcceptance.shared.accept(cloudKitShareMetadata)
    }
}

/// Handles CloudKit share invitations that arrive while the app is running or that launch it.
final class MetricsSceneDelegate: NSObject, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let metadata = connectionOptions.cloudKitShareMetadata {
            ShareAcceptance.shared.accept(metadata)
        }
    }

    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        ShareAcceptance.shared.accept(cloudKitShareMetadata)
    }
}
#endif
