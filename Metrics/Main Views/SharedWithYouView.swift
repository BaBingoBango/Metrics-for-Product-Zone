//
//  SharedWithYouView.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/3/22.
//

import SwiftUI
import CloudKit

struct SharedWithYouView: View {
    
    @State var sharedWithYouList: [SharingUser] = []
    @State var isLoading = true
    @State var showingSharingView = false
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding(.top)
            } else {
                if sharedWithYouList.isEmpty {
                    Text("No People Found")
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                        .font(.title2)
                } else {
                    Form {
                        Section(header: Text("People Sharing With You")) {
                            ForEach(sharedWithYouList, id: \.id) { sharingUser in
                                Button(action: {
                                    showingSharingView = true
                                }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            if sharingUser.firstName == nil {
                                                Text("Name Not Provided")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.primary)
                                            } else {
                                                if sharingUser.lastName == nil {
                                                    Text(sharingUser.firstName!)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.primary)
                                                } else {
                                                    Text(sharingUser.firstName! + " " + sharingUser.lastName!)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.primary)
                                                }
                                            }
                                            
                                            if sharingUser.email != nil {
                                                Text(sharingUser.email!)
                                                    .foregroundColor(.primary)
                                            }
                                            
                                            if sharingUser.phoneNumber != nil {
                                                Text(sharingUser.phoneNumber!)
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(Font.body.weight(.semibold))
                                            .foregroundColor(.secondary)
                                            .imageScale(.small)
                                            .opacity(0.25)
                                    }
                                }
                                .sheet(isPresented: $showingSharingView) {
                                    CloudKitSharingView(share: sharingUser.cloudKitShare, container: CKContainer(identifier: "iCloud.Metrics"))
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Shared With You")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { input in
            updateSharedWithYouList()
        }
        .onAppear {
            isLoading = true
            updateSharedWithYouList()
        }
    }
    
    func updateSharedWithYouList() {
        var nameList: [SharingUser] = []
        var startedQueryOperation = false
        let zoneFetchOperation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
        zoneFetchOperation.perRecordZoneResultBlock = { (recordZoneID: CKRecordZone.ID, recordZoneResult: Result<CKRecordZone, Error>) -> Void in
            startedQueryOperation = true
            switch recordZoneResult {
                
            case .success(let result):
                let queryOperation = CKQueryOperation(query: CKQuery(recordType: "cloudkit.share", predicate: NSPredicate(value: true)))
                queryOperation.zoneID = result.zoneID
                queryOperation.recordMatchedBlock = { (_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void in
                    startedQueryOperation = true
                    switch recordResult {
                    case .success(let result):
                        if let shareRecord = result as? CKShare {
                            let ownerFirstName = shareRecord.owner.userIdentity.nameComponents?.givenName
                            let ownerLastName = shareRecord.owner.userIdentity.nameComponents?.familyName
                            let ownerEmail = shareRecord.owner.userIdentity.lookupInfo?.emailAddress
                            let ownerPhoneNumber = shareRecord.owner.userIdentity.lookupInfo?.phoneNumber
                            
                            nameList.append(SharingUser(cloudKitShare: shareRecord, firstName: ownerFirstName, lastName: ownerLastName, email: ownerEmail, phoneNumber: ownerPhoneNumber))
                        }
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                queryOperation.queryResultBlock = { (_ operationResult: Result<CKQueryOperation.Cursor?, Error>) -> Void in
                    switch operationResult {
                    case .success(_):
                        sharedWithYouList = nameList
                        isLoading = false
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        sharedWithYouList = nameList
                        isLoading = false
                    }
                }
                
                CKContainer(identifier: "iCloud.Metrics").sharedCloudDatabase.add(queryOperation)
                
            case .failure(let error):
                print(error.localizedDescription)
                sharedWithYouList = nameList
                isLoading = false
            }
        }
        zoneFetchOperation.fetchRecordZonesResultBlock = { (_ operationResult: Result<Void, Error>) -> Void in
            switch operationResult {
            case .success(_):
                sleep(1)
                if !startedQueryOperation {
                    sharedWithYouList = nameList
                    isLoading = false
                }

            case .failure(let error):
                print(error.localizedDescription)
                if !startedQueryOperation {
                    sharedWithYouList = nameList
                    isLoading = false
                }
            }
        }
        
        CKContainer(identifier: "iCloud.Metrics").sharedCloudDatabase.add(zoneFetchOperation)
    }
}

struct SharedWithYouView_Previews: PreviewProvider {
    static var previews: some View {
        SharedWithYouView()
    }
}

struct SharingUser {
    var id = UUID()
    var cloudKitShare: CKShare
    var firstName: String?
    var lastName: String?
    var email: String?
    var phoneNumber: String?
}
