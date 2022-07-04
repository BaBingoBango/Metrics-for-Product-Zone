//
//  SettingsView.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/6/21.
//

import SwiftUI
import CloudKit

struct SettingsView: View {
    
    // MARK: - View Variables
    /// Whether or not the AppleCare+ goal viewer is being presented.
    @State var showingAppleCareGoalViewer = false
    /// Whether or not the business leads goal viewer is being presented.
    @State var showingBusinessLeadsGoalViewer = false
    /// Whether or not the connectivity goal viewer is being presented.
    @State var showingConnectivityGoalViewer = false
    /// Whether or not the transaction data viewer is being presented.
    @State var showingTransactionData = false
    /// The URL for the currently existing CloudKit share.
    @AppStorage("cloudKitShareURL") var cloudKitShareURL: String?
    /// The CloudKit share object for the Sharing view.
    @State var cloudKitShare: CKShare = CKShare(recordZoneID: CKRecordZone.ID(zoneName: "?", ownerName: "?"))
    /// Whether or not the Sharing progress indicator is being presented.
    @State var isShowingSharingProgress = false
    /// Whether or not the Sharing view is being presented.
    @State var isShowingSharingView = false
    /// Whether or not the Sharing failure indicator is being presented.
    @State var isShowingSharingFailure = false
    /// The error message from a failed share preperation, if there is one.
    @State var sharingErrorMessage: String?
    
    // Daily Goals variables
    /// Whether or not the user's daily goals should show in the Today view.
    @AppStorage("showGoalsInTodayView") var showGoalsInTodayView = true
    /// In percent, the user's daily AppleCare+ goal.
    @AppStorage("appleCareGoal") var appleCareGoal = 60
    /// The users daily business lead goal.
    @AppStorage("businessLeadsGoal") var businessLeadsGoal = 2
    /// In percent, the user's daily connectivity goal.
    @AppStorage("connectivityGoal") var connectivityGoal = 75
    
    // Sharing variable
    /// Whether or not the the Sharing section should show in the Today view.
    @AppStorage("showSharingInTodayView") var showSharingInTodayView = true
    
    // MARK: - View Variables
    var body: some View {
//        NavigationView {
            Form {
                Section(header: Text("Daily Goals")) {
                    Toggle(isOn: $showGoalsInTodayView) {
                        Text("Show Goals in Today")
                    }
                    
                    Button(action: {
                        showingAppleCareGoalViewer = true
                    }) {
                        HStack {
                            Text("AppleCare+ Goal")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(appleCareGoal)%")
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(Font.body.weight(.semibold))
                                .foregroundColor(.secondary)
                                .imageScale(.small)
                                .opacity(0.25)
                        }
                    }
                    .sheet(isPresented: $showingAppleCareGoalViewer) {
                        GoalEditorView(goalName: "AppleCare+", goal: $appleCareGoal)
                    }
                    
                    Button(action: {
                        showingBusinessLeadsGoalViewer = true
                    }) {
                        HStack {
                            Text("Business Leads Goal")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(businessLeadsGoal) Leads")
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(Font.body.weight(.semibold))
                                .foregroundColor(.secondary)
                                .imageScale(.small)
                                .opacity(0.25)
                        }
                    }
                    .sheet(isPresented: $showingBusinessLeadsGoalViewer) {
                        GoalEditorView(goalName: "Business Leads", goal: $businessLeadsGoal)
                    }
                    
                    Button(action: {
                        showingAppleCareGoalViewer = true
                    }) {
                        HStack {
                            Text("Connectivity Goal")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(connectivityGoal)%")
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(Font.body.weight(.semibold))
                                .foregroundColor(.secondary)
                                .imageScale(.small)
                                .opacity(0.25)
                        }
                    }
                    .sheet(isPresented: $showingAppleCareGoalViewer) {
                        GoalEditorView(goalName: "Connectivity", goal: $connectivityGoal)
                    }
                }
                
                Section(header: Text("Sharing")) {
                    Toggle(isOn: $showSharingInTodayView) {
                        Text("Show Sharing in Today")
                    }
                    
                    Button(action: {
                        isShowingSharingProgress = true
                        
                        let zoneFetchOperation = CKFetchRecordZonesOperation(recordZoneIDs: [CKRecordZone.ID(zoneName: "com.apple.coredata.cloudkit.zone", ownerName: CKCurrentUserDefaultName)])
                        zoneFetchOperation.perRecordZoneResultBlock = { (recordZoneID: CKRecordZone.ID, recordZoneResult: Result<CKRecordZone, Error>) -> Void in
                            switch recordZoneResult {
                            case .success(let result):
                                if let shareReference = result.share {
                                    CKContainer(identifier: "iCloud.Metrics").privateCloudDatabase.fetch(withRecordID: shareReference.recordID) { (record, error) in
                                        guard let shareRecord = record as? CKShare else {
                                            if let error = error {
                                                print(error.localizedDescription)
                                                isShowingSharingProgress = false
                                                isShowingSharingFailure = true
                                            }
                                            return
                                        }
                                    
                                        if let url = shareRecord.url {
                                            print("URL (Old): \(url)")
                                            
                                        }
                                        
                                        cloudKitShare = shareRecord
                                        cloudKitShare[CKShare.SystemFieldKey.title] = "Transaction History"
                                        cloudKitShare[CKShare.SystemFieldKey.shareType] = "Transaction History"
                                        cloudKitShare[CKShare.SystemFieldKey.thumbnailImageData] = NSDataAsset(name: "sharing thumbnail")!.data
                                        isShowingSharingProgress = false
                                        isShowingSharingView = true
                                    }
                                } else {
                                    cloudKitShare = CKShare(recordZoneID: CKRecordZone.ID(zoneName: "com.apple.coredata.cloudkit.zone", ownerName: CKCurrentUserDefaultName))
                                    cloudKitShare[CKShare.SystemFieldKey.title] = "Transaction History"
                                    cloudKitShare[CKShare.SystemFieldKey.shareType] = "Transaction History"
                                    cloudKitShare[CKShare.SystemFieldKey.thumbnailImageData] = NSDataAsset(name: "sharing thumbnail")!.data
                                    
                                    let saveOperation = CKModifyRecordsOperation(recordsToSave: [cloudKitShare])
                                    saveOperation.modifyRecordsResultBlock = { (_ result: Result<Void, Error>) -> Void in
                                        switch result {
                                        case .success():
                                            print("URL (Old): \(cloudKitShare.url?.description ?? "No URL")")
                                            isShowingSharingProgress = false
                                            isShowingSharingView = true
                                        case .failure(let error):
                                            print(error.localizedDescription)
                                            isShowingSharingProgress = false
                                            isShowingSharingFailure = true
                                        }
                                    }
                                    CKContainer(
                                        identifier: "iCloud.Metrics").privateCloudDatabase.add(saveOperation)
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                                isShowingSharingProgress = false
                                isShowingSharingFailure = true
                            }
                        }
                        CKContainer(identifier: "iCloud.Metrics").privateCloudDatabase.add(zoneFetchOperation)
                    }) {
                        Text("Share My Metrics...")
                    }
//                    .alert("Preparing to Share...", isPresented: $isShowingSharingProgress) {}
                    .sheet(isPresented: $isShowingSharingView) {
                        CloudKitSharingView(share: cloudKitShare, container: CKContainer(identifier: "iCloud.Metrics"))
                    }
//                    .alert(isPresented: $isShowingSharingFailure) {
//                        Alert(title: Text("Sharing Preperation Failed"), message: Text(sharingErrorMessage ?? "No error message was found."), dismissButton: .default(Text("Close")))
//                    }
                    
                    NavigationLink(destination: SharedWithYouView()) {
                        Text("Shared With You")
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
            
//        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
