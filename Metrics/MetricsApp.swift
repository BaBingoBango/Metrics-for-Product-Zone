//
//  MetricsApp.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/30/21.
//

import SwiftUI
import UIKit

@main
struct MetricsApp: App {
    #if os(iOS)
    /// A custom app delegate which launches the root view.
    @UIApplicationDelegateAdaptor(MyAppDelegate.self) var appDelegate
    #endif
    /// The persistence controller for Core Data.
    let persistenceController = PersistenceController.shared
    /// Whether or not the transaction adder is being presented.
    @State var isShowingAdder = false

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
#if os(iOS)

/// A custom app delegate class.
///
/// This class was downloaded from https://stackoverflow.com/questions/57260051/iphone-x-home-indicator-dimming-undimming
class MyAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "My Scene Delegate", sessionRole: connectingSceneSession.role)
        config.delegateClass = MySceneDelegate.self
        return config
    }
}

/// A custom scene delegate class.
///
/// This class was downloaded from https://stackoverflow.com/questions/57260051/iphone-x-home-indicator-dimming-undimming
class MySceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    @Environment(\.openURL) private var openURL: OpenURLAction
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let _ = connectionOptions.shortcutItem {
            openURL(URL(string: "Ethan.Metrics://logTransaction")!)
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        openURL(URL(string: "Ethan.Metrics://logTransaction")!) { completed in
              completionHandler(completed)
        }
    }
}

#endif

}
