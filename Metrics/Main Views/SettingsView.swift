//
//  SettingsView.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/6/21.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - View Variables
    /// Whether or not the transaction data viewer is being presented.
    @State var showingTransactionData = false
    
    // Daily Goals variables
    /// Whether or not the user's daily goals should show in the Today view.
    @AppStorage("showGoalsInTodayView") var showGoalsInTodayView = true
    /// In percent, the user's daily AppleCare+ goal.
    @AppStorage("appleCareGoal") var appleCareGoal = 60
    /// The users daily business lead goal.
    @AppStorage("businessLeadsGoal") var businessLeadsGoal = 2
    /// In percent, the user's daily connectivity goal.
    @AppStorage("connectivityGoal") var connectivityGoal = 75
    
    // MARK: - View Variables
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Goals")) {
                    Toggle(isOn: $showGoalsInTodayView) {
                        Text("Show Goals in Today")
                    }
                    
                    NavigationLink(destination: GoalEditorView(goalName: "AppleCare+", goal: $appleCareGoal)) {
                        HStack {
                            Text("AppleCare+ Goal")
                            
                            Spacer()
                            
                            Text("\(appleCareGoal)%")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    NavigationLink(destination: GoalEditorView(goalName: "Business Leads", goal: $businessLeadsGoal)) {
                        HStack {
                            Text("Business Leads Goal")
                            
                            Spacer()
                            
                            Text("\(businessLeadsGoal) Leads")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    NavigationLink(destination: GoalEditorView(goalName: "Connectivity", goal: $connectivityGoal)) {
                        HStack {
                            Text("Connectivity Goal")
                            
                            Spacer()
                            
                            Text("\(connectivityGoal)%")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Data Management"), footer: Text("Metrics stores your transaction data on-device and syncs it across your devices using iCloud. Deleting data here will remove it from all your devices as well as from iCloud.")) {
                    Button(action: { showingTransactionData.toggle() }) {
                        Text("View Transaction Data")
                    }
                    .sheet(isPresented: $showingTransactionData) {
                        DataViewer()
                    }
                }
                
                Section(header: Text("Permissions"), footer: Text("To grant or revoke Metrics permissions, tap to visit Settings.")) {
                    Button(action: {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, completionHandler: { _ in })
                    }) {
                        Text("Configure Metrics in Settings")
                    }
                }
                
                Section(header: Text("About")) {
                    
                    HStack { Text("App Version"); Spacer(); Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String).foregroundColor(.secondary) }
                    
                    HStack { Text("Build Number"); Spacer(); Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String).foregroundColor(.secondary) }
                    
                }
            }
            
            // MARK: Nav Bar Settings
            .navigationBarTitle(Text("Settings"))
            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
