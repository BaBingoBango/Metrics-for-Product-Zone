//
//  MetricsApp.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/30/21.
//

import SwiftUI

@main
struct MetricsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
