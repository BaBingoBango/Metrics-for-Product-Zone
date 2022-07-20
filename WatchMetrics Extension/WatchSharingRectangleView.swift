//
//  WatchSharingRectangleView.swift
//  WatchMetrics Extension
//
//  Created by Ethan Marshall on 7/16/22.
//

import SwiftUI

struct WatchSharingRectangleView: View {
    // MARK: - View Variables
    /// The Sharing user's transactions for the current day.
    var eachTodayData: TransactionServices?
    /// A safe version of `eachTodayData` that will always be non-nil.
    var safeTodayData: TransactionServices {
        if eachTodayData == nil {
            let placeholderTransactions = TransactionServices([])
            placeholderTransactions.owner = "Placeholder Name"
            return placeholderTransactions
        } else {
            return eachTodayData!
        }
    }
    /// Whether or not this view should act as a placeholder instead of displaying data.
    var isPlaceholder = false
    /// Whether or not this view should act as a progress indicator instead of displaying data.
    var isLoading = false
    
    // MARK: - View Body
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.gray)
                .opacity(0.15)
                .cornerRadius(20)
                .isHidden(isPlaceholder || isLoading)
            
            VStack {
                HStack {
                    Image(systemName: "person.crop.circle")
                        .font(.title3)
                        .foregroundColor(.primary)
                    
                    Text(safeTodayData.owner!)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding([.top, .leading])
                
                HStack {
                    ProgressBar(progress: Double(safeTodayData.appleCarePercent()) / 100.0, color: .red, lineWidth: 8.5, imageName: "applelogo")
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    ZStack {
                        ProgressBar(progress: 0.0, color: Color("brown"), lineWidth: 8.5, imageName: "")
                            .aspectRatio(1, contentMode: .fit)
                        
                        Text("\(safeTodayData.numBusinessLeads())")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(Color("brown"))
                    }
                    
                    Spacer()
                    
                    ProgressBar(progress: Double(safeTodayData.connectivityPercent()) / 100.0, color: .blue, lineWidth: 8.5, imageName: "antenna.radiowaves.left.and.right")
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundColor(.blue)
                }
                .padding(.bottom)
                .padding(.horizontal, 10)
            }
            .isHidden(eachTodayData == nil)
            
            if eachTodayData == nil {
                if isPlaceholder {
                    VStack(spacing: 0) {
                        Image(systemName: "person.3.fill")
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.secondary)
                            .font(.system(size: 20))
                        
                        Text("No People Found")
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                            .font(.system(size: 15))
                            .multilineTextAlignment(.center)
                            .padding(.top)
                        
                        Text("No one is sharing their metrics with you right now.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                    }
                    .padding(.horizontal)
                } else if isLoading {
                    VStack(spacing: 0) {
                        ProgressView()
                        
                        Text("Connecting...")
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                            .font(.system(size: 20))
                    }
                }
            }
        }
    }
}

struct WatchSharingRectangleView_Previews: PreviewProvider {
    static var previews: some View {
        WatchSharingRectangleView()
    }
}
