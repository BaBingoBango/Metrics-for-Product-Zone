//
//  MetricsApp.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/30/21.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif
import CloudKit

@main
struct MetricsApp: App {
    #if os(iOS)
    /// The custom app delegate for the app.
    @UIApplicationDelegateAdaptor var delegate: MetricsAppDelegate
    #endif
    /// The persistence controller for Core Data.
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
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
        // 2
    }
}
#endif
