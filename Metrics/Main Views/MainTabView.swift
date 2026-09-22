//
//  MainTabView.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/5/21.
//

import SwiftUI

/// The entry point for the app on iPhone and iPad: a tab bar that becomes a sidebar on larger displays.
struct MainTabView: View {
    @Environment(ShareAcceptance.self) private var shareAcceptance

    var body: some View {
        @Bindable var shareAcceptance = shareAcceptance

        TabView {
            Tab("Today", systemImage: "sun.max.fill") {
                NavigationStack { TodayTabView() }
            }

            Tab("This Week", systemImage: "calendar") {
                NavigationStack { ThisWeekView() }
            }

            Tab("Lifetime", systemImage: "crown.fill") {
                NavigationStack { LifetimeView() }
            }

            Tab("Settings", systemImage: "gear") {
                NavigationStack { SettingsView() }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .sheet(isPresented: $shareAcceptance.isAccepting) {
            AcceptingShareView()
        }
    }
}

/// The progress sheet shown while a Sharing invitation is accepted.
struct AcceptingShareView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(.sharing)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 220)

            Text("Accepting Shared Data")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            ProgressView()
                .controlSize(.large)

            Spacer()
        }
        .padding(.top, 40)
        .padding()
        .interactiveDismissDisabled()
    }
}

#Preview {
    MainTabView()
        .environment(ShareAcceptance())
        .previewEnvironment()
}
