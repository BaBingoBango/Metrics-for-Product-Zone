//
//  MainTabView.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/5/21.
//

import SwiftUI

/// The entry point for the app. It provides a "launchpad" for the other main views of the app by way of a tab view.
struct MainTabView: View {
    // MARK: - View Variables
    /// The custom scene delegate object for the app.
    @EnvironmentObject var sceneDelegate: MetricsSceneDelegate
    #if os(iOS)
    /// The horizontal size class of the current app environment.
    ///
    /// It is only relevant in iOS and iPadOS, since macOS and tvOS feature a consistent layout experience.
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    /// The currently selected sidebar tab.
    @State var selection: Int? = 1
    
    // MARK: - View Body
    var body: some View {
        ZStack {
            if horizontalSizeClass == .compact {
                TabView {
                    NavigationView { TodayTabView() }
                        .tabItem {
                            Image(systemName: "sun.max.fill"); Text("Today")
                        }
                    
                    NavigationView { ThisWeekView() }
                        .tabItem {
                            Image(systemName: "calendar"); Text("This Week")
                        }
                    
                    NavigationView { LifetimeView() }
                        .tabItem {
                            Image(systemName: "crown.fill"); Text("Lifetime")
                        }
                    
                    NavigationView { SettingsView() }
                        .tabItem {
                            Image(systemName: "gear"); Text("Settings")
                        }
                }
            } else {
                NavigationView {
                    List(selection: $selection) {
                        NavigationLink(destination: TodayTabView(), tag: 1, selection: $selection) {
                            Label("Today", systemImage: "sun.max.fill")
                        }
                        
                        NavigationLink(destination: ThisWeekView(), tag: 2, selection: $selection) {
                            Label("This Week", systemImage: "calendar")
                        }
                        
                        NavigationLink(destination: LifetimeView(), tag: 3, selection: $selection) {
                            Label("Lifetime", systemImage: "crown.fill")
                        }
                        
                        NavigationLink(destination: SettingsView(), tag: 4, selection: $selection) {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                    .listStyle(SidebarListStyle())
                    
                    .navigationTitle("Metrics")
                }
            }
        }
        .sheet(isPresented: $sceneDelegate.isAcceptingShare) {
            VStack {
                HStack {
                    Image("sharing image")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .hidden()
                    
                    Image("sharing image")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .scaleEffect(0.8)
                    
                    Image("sharing image")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .hidden()
                }
                
                Text("Accepting Shared Data")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .padding([.leading, .bottom, .trailing])
                
                ProgressView()
                    .scaleEffect(1.5)
                
                Spacer()
            }
            .padding(.top)
            .interactiveDismissDisabled(true)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
