//
//  TodayTabView.swift
//  Metrics
//
//  Created by Ethan Marshall on 6/20/22.
//

import SwiftUI

struct TodayTabView: View {
    
    // MARK: View Variables
    /// The complete list of the user's transactions, fetched from Core Data.
    @FetchRequest(entity: Transaction.entity(), sortDescriptors: []) var transactions: FetchedResults<Transaction>
    /// A `TransactionServices` object used to interact with all of the user's transactions.
    var data: TransactionServices {
        return TransactionServices(transactions.reversed().reversed())
    }
    /// A `TransactionServices` object used to interact with all of the user's transactions from the current day.
    var todayData: TransactionServices {
        return TransactionServices(data.today())
    }
    /// A date formatter which provides date strings suitable for the Today view UI's heading.
    var todayViewDateFormatter: DateFormatter {
        let answer = DateFormatter()
        answer.dateStyle = .full
        answer.timeStyle = .none
        return answer
    }
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text(todayViewDateFormatter.string(from: Date()).uppercased())
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                        Spacer()
                    }
                    
                    Text("Good morning, Name!")
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                        .truncationMode(.middle)
                        .padding(.horizontal)
                        .padding(.top, 10)

                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .hidden()

                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .hidden()

                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .foregroundColor(.green)

                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .foregroundColor(.green)

                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .foregroundColor(.green)

                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .hidden()

                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .hidden()
                    }
                    .padding(.bottom, 10)

                    Text("Woohoo, Monday! All your goals are green right now! Great job, and keep it up!")
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding([.leading, .bottom, .trailing])
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(.gray)
                            .opacity(0.15)
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
                    
                    HStack {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.gray)
                                .opacity(0.15)
                                .cornerRadius(20)
                            
                            HStack {
                                VStack {
                                    HStack(alignment: .center) {
                                        Image(systemName: "briefcase.fill")
                                            .imageScale(.large)
                                            .foregroundColor(.brown)
                                        
                                        Text("Leads")
                                            .fontWeight(.bold)
                                            .foregroundColor(.brown)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                    }
                                    .padding(.top)
                                    .padding(.horizontal, 5)
                                    
                                    ZStack {
                                        ProgressBar(progress: 0.0, color: .brown, lineWidth: 8.5, imageName: "")
                                            .aspectRatio(1, contentMode: .fit)
                                        
                                        Text("\(todayData.numBusinessLeads())")
                                            .font(.system(size: 30))
                                            .fontWeight(.bold)
                                            .foregroundColor(.brown)
                                    }
                                    .padding(.bottom)
                                }
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                        
                        
                        ZStack {
                            Rectangle()
                                .foregroundColor(.gray)
                                .opacity(0.15)
                                .cornerRadius(20)
                            
                            HStack {
                                VStack {
                                    HStack(alignment: .center) {
                                        Image(systemName: "antenna.radiowaves.left.and.right")
                                            .imageScale(.large)
                                            .foregroundColor(.blue)
                                        
                                        Text("Connected")
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                    }
                                    .padding(.top)
                                    .padding(.horizontal, 5)
                                    
                                    ZStack {
                                        ProgressBar(progress: Double(todayData.connectivityPercent()) / 100, color: .blue, lineWidth: 8.5, imageName: "")
                                            .aspectRatio(1, contentMode: .fit)
                                        
                                        Text("\(todayData.connectivityPercent())%")
                                            .font(.body)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.bottom)
                                }
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Sharing")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding([.top, .leading])
                    
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
                                
                                Text("Elizabeth Lemon")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Spacer()
                            }
                            .padding([.top, .leading])
                            
                            HStack {
                                ProgressBar(progress: 0, color: .red, lineWidth: 8.5, imageName: "applelogo")
                                    .aspectRatio(1, contentMode: .fit)
                                
                                Spacer()
                                
                                ProgressBar(progress: 0, color: .brown, lineWidth: 8.5, imageName: "briefcase.fill")
                                    .aspectRatio(1, contentMode: .fit)
                                
                                Spacer()
                                
                                ProgressBar(progress: 0, color: .blue, lineWidth: 8.5, imageName: "antenna.radiowaves.left.and.right")
                                    .aspectRatio(1, contentMode: .fit)
                            }
                            .padding([.leading, .bottom, .trailing])
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            
            // MARK: Navigation View Settings
            .navigationTitle(Text("Today"))
        }
    }
}

// MARK: View Preview
struct TodayTabView_Previews: PreviewProvider {
    static var previews: some View {
        TodayTabView()
    }
}
