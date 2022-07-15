//
//  SharingRectangleVie.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/15/22.
//

import SwiftUI

/// A view displaying basic information about a Sharing user's metrics for the current day.
struct SharingRectangleView: View {
    
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
            
            VStack {
                HStack {
                    Image(systemName: "person.crop.circle")
                        .font(.title)
                        .imageScale(.large)
                        .foregroundColor(.primary)
                    
                    Text(safeTodayData.owner!)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Image(systemName: "chevron.right")
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary)
                        .font(.system(size: 20))
                    
                    Spacer()
                }
                .padding([.top, .leading])
                
                HStack {
                    ProgressBar(progress: Double(safeTodayData.appleCarePercent()) / 100.0, color: .red, lineWidth: 8.5, imageName: "applelogo")
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundColor(.red)
                        .onAppear {
                            print(safeTodayData.appleCarePercent())
                            print(Double(safeTodayData.appleCarePercent()) / 100.0)
                        }
                    
                    Spacer()
                    
                    ZStack {
                        ProgressBar(progress: 0.0, color: Color("brown"), lineWidth: 8.5, imageName: "")
                            .aspectRatio(1, contentMode: .fit)
                        
                        Text("\(safeTodayData.numBusinessLeads())")
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .foregroundColor(Color("brown"))
                    }
                    
                    Spacer()
                    
                    ProgressBar(progress: Double(safeTodayData.connectivityPercent()) / 100.0, color: .blue, lineWidth: 8.5, imageName: "antenna.radiowaves.left.and.right")
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundColor(.blue)
                }
                .padding([.leading, .bottom, .trailing])
            }
            .isHidden(eachTodayData == nil)
            
            if eachTodayData == nil {
                if isPlaceholder {
                    VStack(spacing: 0) {
                        Image(systemName: "person.3.fill")
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.secondary)
                            .font(.system(size: 40))
                        
                        Text("No People Found")
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                            .font(.system(size: 25))
                            .padding(.top)
                        
                        Text("No one is sharing their metrics with you right now. If this is a mistake, confirm you are signed in to iCloud and that you have tapped on any invitation links you received.")
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                    }
                    .padding(.horizontal)
                } else if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.25)
                        
                        Text("Connecting...")
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                            .font(.system(size: 20))
                            .padding(.top)
                    }
                }
            }
        }
    }
}

struct SharingRectangleView_Previews: PreviewProvider {
    static var previews: some View {
        SharingRectangleView(isLoading: true)
    }
}
