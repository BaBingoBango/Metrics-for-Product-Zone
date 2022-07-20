//
//  WatchSharingView.swift
//  WatchMetrics Extension
//
//  Created by Ethan Marshall on 7/16/22.
//

import SwiftUI
import CloudKit
import CoreData

struct WatchSharingView: View {
    // MARK: - View Variables
    @State var sharingServices: [TransactionServices] = []
    @State var todaySharingServices: [TransactionServices] = []
    /// Whether or not this view has performed an initial Sharing fetch operation.
    @State var hasCheckedSharing = false
    /// The status of a Sharing fetch operation taking place via this view.
    @State var fetchStatus = CloudKitOperationStatus.notStarted
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Button(action: {
                        getSharingData()
                    }) {
                        ZStack {
                            Rectangle()
                                .frame(height: 40)
                                .cornerRadius(10)
                                .foregroundColor(.green)
                            
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .font(Font.body.weight(.bold))
                                Text("Refresh")
                            }
                            
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .isHidden(fetchStatus == .inProgress, remove: fetchStatus == .inProgress)
                    
                    if fetchStatus == .inProgress {
                        WatchSharingRectangleView(isLoading: true)
                    } else if sharingServices.isEmpty {
                        WatchSharingRectangleView(isPlaceholder: true)
                    } else {
                        ForEach(sharingServices, id: \.id) { eachData in
                            WatchSharingRectangleView(eachTodayData: {
                                let todayTransactions = TransactionServices(eachData.today())
                                todayTransactions.owner = eachData.owner
                                return todayTransactions
                            }())
                            .padding(.horizontal)
                        }
                    }
                }
            }
            
            // MARK: Nav Bar Settings
            .navigationBarTitle(Text("Sharing"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            if !hasCheckedSharing {
                getSharingData()
                hasCheckedSharing = true
            }
        }
    }
    
    // MARK: - View Functions
    /// Connects to the Internet to download Sharing data from the server.
    func getSharingData() {
        fetchStatus = .inProgress
        sharingServices = []
        todaySharingServices = []
        
        let zoneFetchOperation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
        zoneFetchOperation.qualityOfService = .userInteractive
        zoneFetchOperation.perRecordZoneResultBlock = { (recordZoneID: CKRecordZone.ID, recordZoneResult: Result<CKRecordZone, Error>) -> Void in
            switch recordZoneResult {
                
            case .success(let fetchedZone):
                var newTransactionSet: [Transaction] = []
                
                // Zone Operation 1: Transaction Query
                let queryOperation = CKQueryOperation(query: CKQuery(recordType: "CD_Transaction", predicate: NSPredicate(value: true)))
                queryOperation.qualityOfService = .userInteractive
                queryOperation.zoneID = fetchedZone.zoneID
                
                queryOperation.recordMatchedBlock = { (_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void in
                    switch recordResult {
                        
                    case .success(let queriedRecord):
                        let transactionEntity = NSEntityDescription.entity(forEntityName: "Transaction", in: viewContext)!
                        let newTransaction = Transaction(entity: transactionEntity, insertInto: nil)
                        
                        newTransaction.id = queriedRecord.object(forKey: "CD_id") as? UUID
                        newTransaction.date = queriedRecord.object(forKey: "CD_date") as? Date
                        newTransaction.deviceType = queriedRecord.object(forKey: "CD_deviceType") as? String
                        newTransaction.boughtAppleCare = queriedRecord.object(forKey: "CD_boughtAppleCare") as! Int == 1 ? true : false
                        newTransaction.connected = queriedRecord.object(forKey: "CD_connected") as! Int == 1 ? true : false
                        newTransaction.gotLead = queriedRecord.object(forKey: "CD_gotLead") as! Int == 1 ? true : false
                        newTransaction.isAppleCareStandalone = queriedRecord.object(forKey: "CD_isAppleCareStandalone") as! Int == 1 ? true : false
                        
                        newTransactionSet.append(newTransaction)
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        fetchStatus = .failure
                    }
                }
                
                queryOperation.queryResultBlock = { (_ operationResult: Result<CKQueryOperation.Cursor?, Error>) -> Void in
                    // Zone Operation 2: Name Query
                    let nameOperation = CKQueryOperation(query: CKQuery(recordType: "cloudkit.share", predicate: NSPredicate(value: true)))
                    nameOperation.zoneID = fetchedZone.zoneID
                    nameOperation.recordMatchedBlock = { (_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void in
                        switch recordResult {
                        case .success(let result):
                            if let shareRecord = result as? CKShare {
                                let newServices = TransactionServices(newTransactionSet)
                                newServices.owner = {
                                    let ownerFirstName = shareRecord.owner.userIdentity.nameComponents?.givenName
                                    let ownerLastName = shareRecord.owner.userIdentity.nameComponents?.familyName
                                    
                                    if ownerFirstName == nil {
                                        return "Name Not Provided"
                                    } else {
                                        if ownerLastName == nil {
                                            return ownerFirstName!
                                        } else {
                                            return ownerFirstName! + " " + ownerLastName!
                                        }
                                    }
                                }()
                                
                                sharingServices.append(newServices)
                                todaySharingServices.append(TransactionServices(newServices.today()))
                                
                                newTransactionSet = []
                                fetchStatus = .success
                            }
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                            fetchStatus = .failure
                        }
                    }
                    CKContainer(identifier: "iCloud.Metrics").sharedCloudDatabase.add(nameOperation)
                }
                
                CKContainer(identifier: "iCloud.Metrics").sharedCloudDatabase.add(queryOperation)
                
            case .failure(let error):
                print(error.localizedDescription)
                fetchStatus = .failure
            }
        }
        
        zoneFetchOperation.fetchRecordZonesResultBlock = { (_ operationResult: Result<Void, Error>) -> Void in
            switch operationResult {
            case .success():
                print("Zone fetch success!")
                sleep(1)
                fetchStatus = .success
            case .failure(let error):
                print(error.localizedDescription)
                fetchStatus = .failure
            }
        }
        
        CKContainer(identifier: "iCloud.Metrics").sharedCloudDatabase.add(zoneFetchOperation)
    }
}

struct WatchSharingView_Previews: PreviewProvider {
    static var previews: some View {
        WatchSharingView()
    }
}
