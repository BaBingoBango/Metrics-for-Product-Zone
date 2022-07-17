//
//  MetricsApp.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/30/21.
//

import SwiftUI
import CloudKit
#if os(iOS)
import UIKit
#endif

@main
struct MetricsApp: App {
    /// The system-provided `ScenePhase` object  used for app launching.
    @Environment(\.scenePhase) var scenePhase
    #if os(iOS)
    /// The custom app delegate for the app.
    @UIApplicationDelegateAdaptor var delegate: MetricsAppDelegate
    #endif
    /// The persistence controller for Core Data.
    let persistenceController = PersistenceController.shared
    /// The names of the keys from UserDefaults that will sync across the user's devices via iCloud.
    var userDefaultsKeysToSync = [
        "showSharingInTodayView",
        "showGoalsInTodayView",
        "appleCareGoal",
        "businessLeadsGoal",
        "connectivityGoal"
    ]

    var body: some Scene {
        WindowGroup {
            // MARK: - App Entry Point
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            // MARK: Application Life Cycle Code
            case .active:
                print("[Application Life Cycle] The app is active!")
                
                #if !os(watchOS)
                // Use Zephyr to sync data across the user's devices with iCloud
                Zephyr.sync(keys: userDefaultsKeysToSync)
                #endif
                
            case .background:
                print("[Application Life Cycle] The app is in the background!")
                
            case .inactive:
                print("[Application Life Cycle] The app is inactive!")
                
                #if !os(watchOS)
                // Use Zephyr to sync data across the user's devices with iCloud
                Zephyr.sync(keys: userDefaultsKeysToSync)
                #endif
            
            default:
                print("[Application Life Cycle] Unknown application life cycle value received.")
            }
        }
    }
}

#if os(iOS)
/// The custom app delegate class for the app.
class MetricsAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    @Published var isAcceptingShare = false
    
    /// The function called to configure the app's custom scene delegate.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = MetricsSceneDelegate.self
        return sceneConfig
    }
    
    /// The function called when a user opens a CloudKit share link on macOS or an iOS app that does not use scenes.
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        if cloudKitShareMetadata.participantStatus == .pending {
            self.isAcceptingShare = true
            let acceptShareOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
            acceptShareOperation.acceptSharesResultBlock = { (_ result: Result<Void, Error>) -> Void in
                switch result {
                case .success():
                    print("Share accepted!")
                    self.isAcceptingShare = false
                case .failure(let error):
                    print(error.localizedDescription)
                    self.isAcceptingShare = false
                }
            }
            CKContainer(identifier: "iCloud.Metrics").add(acceptShareOperation)
        }
    }
}
#endif

#if os(iOS)
/// The custom scene delegate class for the app.
class MetricsSceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    @Published var isAcceptingShare = false
    
    /// The function called when a user opens a CloudKit share link on iOS when the app is running.
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        if cloudKitShareMetadata.participantStatus == .pending {
            self.isAcceptingShare = true
            let acceptShareOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
            acceptShareOperation.acceptSharesResultBlock = { (_ result: Result<Void, Error>) -> Void in
                switch result {
                case .success():
                    print("Share accepted!")
                    self.isAcceptingShare = false
                case .failure(let error):
                    print(error.localizedDescription)
                    self.isAcceptingShare = false
                }
            }
            CKContainer(identifier: "iCloud.Metrics").add(acceptShareOperation)
        }
    }
    
    /// The function called when a user opens a CloudKit share link on iOS when the app is not running.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if connectionOptions.cloudKitShareMetadata != nil {
            if connectionOptions.cloudKitShareMetadata!.participantStatus == .pending {
                self.isAcceptingShare = true
                let acceptShareOperation = CKAcceptSharesOperation(shareMetadatas: [connectionOptions.cloudKitShareMetadata!])
                acceptShareOperation.acceptSharesResultBlock = { (_ result: Result<Void, Error>) -> Void in
                    switch result {
                    case .success():
                        print("Share accepted!")
                        self.isAcceptingShare = false
                    case .failure(let error):
                        print(error.localizedDescription)
                        self.isAcceptingShare = false
                    }
                }
                CKContainer(identifier: "iCloud.Metrics").add(acceptShareOperation)
            }
        }
    }
}
#endif
