//
//  TodayView.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/3/21.
//

import SwiftUI

struct TodayView: View {
    
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
    
    // Variables
    var dateFormatter: DateFormatter {
        let answer = DateFormatter()
        answer.dateStyle = .long
        answer.timeStyle = .none
        return answer
    }
    
    var body: some View {
//        NavigationView {
            ScrollView {
                VStack {
                    
                    HStack {
                        Text(dateFormatter.string(from: Date()).uppercased())
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
                            .padding(.horizontal)
                        
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
                                    .padding(.trailing, 30)
                            }
                            .padding(.top, 15)
                            .padding(.leading, 35)
                            
                            HStack(spacing: 0) {
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("iPhone")) / 100, color: .red, lineWidth: 5.0, imageName: "iphone")
                                    .frame(width: 100, height: 100)
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("iPad")) / 100, color: .red, lineWidth: 5.0, imageName: "ipad.landscape")
                                    .frame(width: 100, height: 100)
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("Mac")) / 100, color: .red, lineWidth: 5.0, imageName: "desktopcomputer")
                                    .frame(width: 100, height: 100)
                            }
                            HStack(spacing: 0) {
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("Apple Watch")) / 100, color: .red, lineWidth: 5.0, imageName: "applewatch")
                                    .frame(width: 100, height: 100)
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("Apple TV")) / 100, color: .red, lineWidth: 5.0, imageName: "appletv")
                                    .frame(width: 100, height: 100)
                                ProgressBar(progress: Double(todayData.customAppleCarePercent("Headphones")) / 100, color: .red, lineWidth: 5.0, imageName: "headphones")
                                    .frame(width: 100, height: 100)
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                            
                        }
                        
                    }
                    .frame(height: 280)
                    
                    HStack(spacing: 10) {
                        
                        ZStack {
                            
                            Rectangle()
                                .foregroundColor(.gray)
                                .opacity(0.2)
                                .cornerRadius(20)
                            
                            VStack {
                                
                                Image(systemName: "briefcase.fill")
                                    .imageScale(.large)
                                    .foregroundColor(Color("brown"))
                                    .padding(.top)
                                Text("Business Leads")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("brown"))
                                    .padding(.top, 1)
                                
                                ZStack {
                                    
                                    ProgressBar(progress: 0.0, color: Color("brown"), lineWidth: 5.0, imageName: "")
                                        .frame(width: 100, height: 100)
                                    
                                    HStack(spacing: 4) {
                                        Text("\(todayData.numBusinessLeads())")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color("brown"))
                                    }
                                    
                                }
                                
                                Spacer()
                                
                            }
                            
                        }
                        .frame(height: 150)
                        
                        ZStack {
                            
                            Rectangle()
                                .foregroundColor(.gray)
                                .opacity(0.2)
                                .cornerRadius(20)
                            
                            VStack {
                                
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .imageScale(.large)
                                    .foregroundColor(.blue)
                                    .padding(.top)
                                Text("Connectivity")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                    .padding(.top, 1)
                                
                                ZStack {
                                    
                                    ProgressBar(progress: Double(todayData.connectivityPercent()) / 100, color: .blue, lineWidth: 5.0, imageName: "")
                                        .frame(width: 100, height: 100)
                                    
                                    Text("\(todayData.connectivityPercent())%")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                    
                                }
                                
                                Spacer()
                                
                            }
                            
                        }
                        .frame(height: 150)
                        
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                }
                
                // MARK: Nav Bar Settings
                    .navigationBarTitle(Text("Today"))
                .navigationBarItems(trailing: Button(action: { showingAdderView.toggle() }) { Image(systemName: "plus.circle.fill").font(Font.title.weight(.bold)) }).sheet(isPresented: $showingAdderView) {
                    AdderView()
            }
            }
        
            
//        }
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}
