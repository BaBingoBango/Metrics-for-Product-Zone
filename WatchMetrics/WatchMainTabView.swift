//
//  WatchMainTabView.swift
//  WatchMetrics
//
//  Created by Ethan Marshall on 7/16/22.
//

import SwiftUI

/// The entry point for the watch app: vertically paged Today and Sharing views.
struct WatchMainTabView: View {
    var body: some View {
        TabView {
            WatchTodayView()
            WatchSharingView()
        }
        .tabViewStyle(.verticalPage)
    }
}

#Preview {
    WatchMainTabView()
        .previewEnvironment()
}
