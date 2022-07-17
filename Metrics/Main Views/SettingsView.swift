//
//  SettingsView.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/6/21.
//

import SwiftUI
import CloudKit
import MessageUI

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
    /// Whether or not the mail sender view is being presented.
    @State var isShowingMailSender = false
    /// Whether or not the feedback email has been copied yet.
    @State var hasCopiedFeedbackEmail = false
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
    /// A timer for timing-out the network operations on this view.
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    /// The amount of time the app has been trying to connect to CloudKit.
    @State var connectTime = 0.0
    /// Whether or not the User Guide is being presented.
    @State var isShowingUserGuide = false
    
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
                        showingConnectivityGoalViewer = true
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
                    .sheet(isPresented: $showingConnectivityGoalViewer) {
                        GoalEditorView(goalName: "Connectivity", goal: $connectivityGoal)
                    }
                }
                
                Section(header: Text("Sharing")) {
                    Toggle(isOn: $showSharingInTodayView) {
                        Text("Show Sharing in Today")
                    }
                    
                    if isShowingSharingProgress {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding(.trailing, 1)
                            
                            Text("Preparing To Share...")
                                .foregroundColor(.secondary)
                        }
                    } else {
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
                                            cloudKitShare[CKShare.SystemFieldKey.title] = "Transaction Access"
                                            cloudKitShare[CKShare.SystemFieldKey.shareType] = "Transaction Access"
                                            cloudKitShare[CKShare.SystemFieldKey.thumbnailImageData] = NSDataAsset(name: "sharing thumbnail")!.data
                                            isShowingSharingProgress = false
                                            isShowingSharingView = true
                                        }
                                    } else {
                                        cloudKitShare = CKShare(recordZoneID: CKRecordZone.ID(zoneName: "com.apple.coredata.cloudkit.zone", ownerName: CKCurrentUserDefaultName))
                                        cloudKitShare[CKShare.SystemFieldKey.title] = "Transaction Access"
                                        cloudKitShare[CKShare.SystemFieldKey.shareType] = "Transaction Access"
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
                    }
                    
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
                
                Section(header: Text("Feedback")) {
                    if MFMailComposeViewController.canSendMail() {
                        Button(action: {
                            isShowingMailSender = true
                        }) {
                            HStack { Image(systemName: "exclamationmark.bubble.fill").imageScale(.large); Text("Send Feedback Mail") }
                        }
                        .sheet(isPresented: $isShowingMailSender) {
                            MailSenderView(recipients: ["proper.griffon-0s@icloud.com"], subject: "One Step Ahead Feedback", body: "Please provide your feedback below. Feature suggestions, bug reports, and more are all appreciated! :)\n\n(If applicable, you may be contacted for more information or for follow-up questions.)\n\n\n")
                        }
                    } else {
                        Button(action: {
                            UIPasteboard.general.string = "proper.griffon-0s@icloud.com"
                            hasCopiedFeedbackEmail = true
                        }) {
                            HStack { Image(systemName: "exclamationmark.bubble.fill").imageScale(.large); Text(!hasCopiedFeedbackEmail ? "Copy Feedback Email" : "Feedback Email Copied!") }
                        }
                    }
                    
                    Link(destination: URL(string: "https://apps.apple.com/us/app/metrics-for-product-zone/id1581284514?action=write-review")!) {
                        HStack { Image(systemName: "star.bubble.fill").imageScale(.large); Text("Review on the App Store") }
                    }
                }
                
                Section(header: Text("Resources")) {
                    Button(action: {
                        isShowingUserGuide = true
                    }) {
                        HStack { Image(systemName: "book.fill").imageScale(.large); Text("User Guide") }
                    }
                    .sheet(isPresented: $isShowingUserGuide) {
                        UserGuideView()
                    }
                    
                    Link(destination: URL(string: "https://github.com/BaBingoBango/Metrics-for-Product-Zone/wiki/Privacy-Policy")!) {
                        HStack { Image(systemName: "hand.raised.fill").imageScale(.large); Text("Privacy Policy") }
                    }
                    
                    Link(destination: URL(string: "https://github.com/BaBingoBango/Metrics-for-Product-Zone/wiki/Support-Center")!) {
                        HStack { Image(systemName: "questionmark.circle.fill").imageScale(.large); Text("Support Center") }
                    }
                    
                    Link(destination: URL(string: "https://github.com/BaBingoBango/Metrics-for-Product-Zone")!) {
                        HStack { Image(systemName: "curlybraces").imageScale(.large); Text("Metrics on GitHub") }
                    }
                }
                
                Section(header: Text("About")) {
                    NavigationLink(destination: EmptyView()) {
                        Text("Licensing and Credit")
                    }
                    
                    HStack { Text("App Version"); Spacer(); Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String).foregroundColor(.secondary) }
                    
                    HStack { Text("Build Number"); Spacer(); Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String).foregroundColor(.secondary) }
                }
            }
            .alert(isPresented: $isShowingSharingFailure) {
                Alert(title: Text("Sharing Failed"), message: Text(sharingErrorMessage ?? ""), dismissButton: .default(Text("Close")))
            }
            .sheet(isPresented: $isShowingSharingView) {
                CloudKitSharingView(share: cloudKitShare, container: CKContainer(identifier: "iCloud.Metrics"))
            }
            .onReceive(timer) { input in
                if isShowingSharingProgress {
                    connectTime += 1
                    
                    if connectTime >= 10 {
                        sharingErrorMessage = "The request timed out. Check that you are signed in to iCloud and connected to the Internet."
                        isShowingSharingProgress = false
                        isShowingSharingFailure = true
                        connectTime = 0
                    }
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
