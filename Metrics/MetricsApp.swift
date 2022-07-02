//
//  MetricsApp.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/30/21.
//

import SwiftUI
import UIKit

#if os(iOS)
var shortcutItemToProcess: UIApplicationShortcutItem?
#endif

@main
struct MetricsApp: App {
    #if os(iOS)
    /// A custom app delegate which launches the root view.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    /// The persistence controller for Core Data.
    let persistenceController = PersistenceController.shared
    /// Whether or not the transaction adder is being presented.
    @State var isShowingAdder = false
    @Environment(\.scenePhase) var phase

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: phase) { (newPhase) in
            switch newPhase {
            case .active :
                print("App is active!")
            case .inactive:
                // inactive
                 print("App is inactive!")
            case .background:
                print("App in background!")
            @unknown default:
                print("default")
            }
        }
    }
}

#if os(iOS)

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            shortcutItemToProcess = shortcutItem
        }
        
        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = CustomSceneDelegate.self
        
        return sceneConfiguration
    }
}

class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        shortcutItemToProcess = shortcutItem
    }
}

#endif
