//
//  TodayTabView.swift
//  Metrics
//
//  Created by Ethan Marshall on 6/20/22.
//

import SwiftUI

struct TodayTabView: View {
    
    // MARK: View Variables
    /// The environment managed object context for this view.
    @Environment(\.managedObjectContext) private var viewContext
    /// The complete list of the user's transactions, fetched from Core Data.
    @FetchRequest(entity: Transaction.entity(), sortDescriptors: [])
    var transactions: FetchedResults<Transaction>
    /// A date formatter which provides date strings suitable for the Today view UI's heading.
    var todayViewDateFormatter: DateFormatter {
        let answer = DateFormatter()
        answer.dateStyle = .full
        answer.timeStyle = .none
        return answer
    }
    /// A `TransactionServices` object used to access Core Data in this view.
    var data: TransactionServices {
        return TransactionServices(transactions.reversed().reversed())
    }
    ///
    var todayData: TransactionServices {
        return TransactionServices(data.today())
    }
    
    // MARK: View Body
    var body: some View {
//        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text(todayViewDateFormatter.string(from: Date()).uppercased())
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                        Spacer()
                    }
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(.gray)
                            .opacity(0.2)
                            .cornerRadius(20)
                        
                        VStack {
                            HStack {
                                Image(systemName: "applelogo")
                                    .imageScale(.large)
                                    .foregroundColor(.red)
                                
                                Text("AppleCare+")
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                Spacer()
                                
                                Text("\(todayData.appleCarePercent())%")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                            .padding([.top, .leading, .trailing])
                            
                            HStack(spacing: 0) {
                                
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("iPhone")) / 100, color: .red, lineWidth: 8.5, imageName: "iphone")
                                    .aspectRatio(1, contentMode: .fit)
                                
                                Spacer()
                                
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("iPad")) / 100, color: .red, lineWidth: 8.5, imageName: "ipad.landscape")
                                    .aspectRatio(1, contentMode: .fit)
                                
                                Spacer()
                                
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("Mac")) / 100, color: .red, lineWidth: 8.5, imageName: "desktopcomputer")
                                    .aspectRatio(1, contentMode: .fit)
                            }
                            .padding(.horizontal)
                            
                            HStack(spacing: 0) {
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("Apple Watch")) / 100, color: .red, lineWidth: 8.5, imageName: "applewatch")
                                    .aspectRatio(1, contentMode: .fit)
                                
                                Spacer()
                                
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("Apple TV")) / 100, color: .red, lineWidth: 8.5, imageName: "appletv")
                                    .aspectRatio(1, contentMode: .fit)
                                
                                Spacer()
                                
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("Headphones")) / 100, color: .red, lineWidth: 8.5, imageName: "headphones")
                                    .aspectRatio(1, contentMode: .fit)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom)
                    }
                    .padding(.horizontal)
                }
            }
            
            // MARK: Navigation View Settings
            .navigationTitle(Text("Today"))
//        }
    }
}

// MARK: View Preview
struct TodayTabView_Previews: PreviewProvider {
    static var previews: some View {
        TodayTabView()
    }
}
