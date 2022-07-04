//
//  SharedWithYouView.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/3/22.
//

import SwiftUI
import CloudKit

struct SharedWithYouView: View {
    
    @State var sharedWithYouList: [String] = []
    @State var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.top)
                
                Spacer()
            } else {
                if sharedWithYouList.isEmpty {
                    Text("No People Found")
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                        .font(.title2)
                } else {
                    Form {
                        Section(header: Text("People Sharing With You")) {
                            ForEach(sharedWithYouList, id: \.self) { name in
                                Text(name)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Shared With You")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            var nameList: [String] = []
            let zoneFetchOperation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
            zoneFetchOperation.perRecordZoneResultBlock = { (recordZoneID: CKRecordZone.ID, recordZoneResult: Result<CKRecordZone, Error>) -> Void in
                switch recordZoneResult {
                case .success(let result):
                    nameList.append(result.zoneID.ownerName)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            zoneFetchOperation.fetchRecordZonesResultBlock = { (_ operationResult: Result<Void, Error>) -> Void in
                switch operationResult {
                case .success():
                    sharedWithYouList = nameList
                    isLoading = false
                case .failure(let error):
                    print(error.localizedDescription)
                    isLoading = false
                }
            }
            CKContainer(identifier: "iCloud.Metrics").sharedCloudDatabase.add(zoneFetchOperation)
        }
    }
}

struct SharedWithYouView_Previews: PreviewProvider {
    static var previews: some View {
        SharedWithYouView()
    }
}
