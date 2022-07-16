//
//  MainTabView.swift
//  WatchMetrics Extension
//
//  Created by Ethan Marshall on 8/14/21.
//

import SwiftUI

/// The entry point for the watchOS app. It is the main view for the watch app, holding the Log button and the day's stats.
struct WatchTodayView: View {
    
    // View context & transaction fetch request
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Transaction.entity(), sortDescriptors: [])
    var transactions: FetchedResults<Transaction>
    
    // TransactionServices objects
    var data: TransactionServices {
        return TransactionServices(transactions.reversed().reversed())
    }
    var todayData: TransactionServices {
        return TransactionServices(data.today())
    }
    
    // State variables
    @State var showingAdderView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Log Transaction button
                    Button(action: {
                        showingAdderView.toggle()
                    }) {
                        ZStack {
                            
                            Rectangle()
                                .frame(height: 40)
                                .cornerRadius(10)
                                .foregroundColor(.green)
                            
                            HStack {
                                Image(systemName: "plus")
                                    .font(Font.body.weight(.bold))
                                Text("Log Transaction")
                            }
                            
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingAdderView) {
                        AdderView()
                            .toolbar(content: {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button(action: {
                                        showingAdderView = false
                                    }) {
                                        Text("Cancel")
                                    }
                                }
                            })
                    }
                    
                    // AppleCare+ indicator
                    ZStack {
                        ProgressBar(progress: Double(todayData.appleCarePercent()) / 100, color: .red, lineWidth: 10.0, imageName: "")
                            .frame(width: 75, height: 75)
                        Image(systemName: "applelogo")
                            .foregroundColor(.red)
                            .imageScale(.large)
                    }
                    
                    HStack {
                        // Leads indicator
                        ZStack {
                            ProgressBar(progress: 0.0, color: Color("brown"), lineWidth: 10.0, imageName: "")
                                .frame(width: 75, height: 75)
                            HStack(spacing: 4) {
                                Text("\(todayData.numBusinessLeads())")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("brown"))
                            }
                        }
                        // Connectivity indicator
                        ZStack {
                            ProgressBar(progress: Double(todayData.connectivityPercent()) / 100, color: .blue, lineWidth: 10.0, imageName: "")
                                .frame(width: 75, height: 75)
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(Font.body.weight(.bold))
                                .imageScale(.large)
                                .foregroundColor(.blue)
                        }
                    }
                    .offset(y: -5)
                    
                }
            }
            
            // MARK: Nav Bar Settings
            .navigationBarTitle(Text("Today"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WatchTodayView_Previews: PreviewProvider {
    static var previews: some View {
        WatchTodayView()
    }
}
