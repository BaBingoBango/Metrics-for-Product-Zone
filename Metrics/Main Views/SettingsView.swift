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
                Section(header: Text("Data Management")) {
                    
                    Button(action: { showingTransactionData.toggle() }) {
                        Text("View Transaction Data")
                    }
                    .sheet(isPresented: $showingTransactionData) {
                        DataViewer()
                    }
//                    Button(action: {}) {
//                        Text("Erase All Transaction Data...")
//                    }
                    
                }
                
                Section(header: Text("About")) {
                    
                    HStack {
                        Text("Version ID")
                        Spacer()
                        Text("Beta 1")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Version No.")
                        Spacer()
                        Text("1.0.1")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Build No.")
                        Spacer()
                        Text("2")
                            .foregroundColor(.secondary)
                    }
                    
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
