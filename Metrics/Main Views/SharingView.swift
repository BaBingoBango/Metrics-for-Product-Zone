//
//  SharingView.swift
//  Metrics
//
//  Created by Ethan Marshall on 6/27/22.
//

import SwiftUI
import CloudKit

struct SharingView: View {
    
    /// One of the view modes for the Sharing view.
    enum SharingViewMode { case fromMe; case toMe }
    /// The current view mode for the Sharing view.
    @State var selectedMode: SharingViewMode = .fromMe
    
    var body: some View {
        ScrollView {
            VStack {
                Picker("", selection: $selectedMode) {
                    Text("From Me").tag(SharingViewMode.fromMe)
                    Text("To Me").tag(SharingViewMode.toMe)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray)
                        .opacity(0.15)
                        .cornerRadius(20)
                    
                    VStack {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 50))
                        
                        Text("Share Your Progress")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.top, 5)
                        
                        Text("Use iCloud to share your daily metrics with selected users!")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.all)
                }
                .padding([.top, .leading, .trailing])
                
                Button(action: {
                    let share = CKShare(recordZoneID: CKRecordZone.ID(zoneName: "com.apple.coredata.cloudkit.zone", ownerName: CKCurrentUserDefaultName))
                    share[CKShare.SystemFieldKey.title] = "Title!"
                    share[CKShare.SystemFieldKey.shareType] = "com.metrics.sharing"
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.gray)
                            .opacity(0.15)
                            .cornerRadius(20)
                        
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(Font.system(size: 25).weight(.bold))
                                .foregroundColor(.accentColor)
                            
                            Text("Share Daily Metrics...")
                                .font(.system(size: 17))
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.all)
                    }
                }
                .padding([.top, .leading, .trailing])
            }
        }
    }
}

struct SharingView_Previews: PreviewProvider {
    static var previews: some View {
        SharingView()
    }
}
