//
//  MainTabView.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/5/21.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        
        TabView {
            
            TodayView()
                .tabItem {
                    Image(systemName: "sun.max.fill"); Text("Today")
                }
            
            ThisWeekView()
                .tabItem {
                    Image(systemName: "calendar"); Text("This Week")
                }
            
            LifetimeView()
                .tabItem {
                    Image(systemName: "crown.fill"); Text("Lifetime")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear"); Text("Settings")
                }
            
        }
        
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
