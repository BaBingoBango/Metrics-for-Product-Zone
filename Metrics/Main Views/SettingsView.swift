//
//  SettingsView.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/6/21.
//

import SwiftUI

struct SettingsView: View {
    
    // Modal variable
    @State var showingTransactionData = false
    
    var body: some View {
        NavigationView {
            Form {
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
