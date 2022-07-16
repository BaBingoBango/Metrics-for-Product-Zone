//
//  MainTabView.swift
//  WatchMetrics Extension
//
//  Created by Ethan Marshall on 7/16/22.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            WatchTodayView()
            
            WatchSharingView()
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
