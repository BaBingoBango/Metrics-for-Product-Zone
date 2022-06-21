//
//  LifetimeView.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/6/21.
//

import SwiftUI

struct LifetimeView: View {
    
    // View context & transaction fetch request
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Transaction.entity(), sortDescriptors: [])
    var transactions: FetchedResults<Transaction>
    
    // TransactionServices object
    var data: TransactionServices {
        return TransactionServices(transactions.reversed().reversed())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    /// The lifetime number of transacted devices for the user.
                    let totalDevices = data.withDevice().count
                    /// The lifetime number of business leads for the user.
                    let totalLeads = data.numBusinessLeads()
                    /// The user's average business leads per day.
                    let averageLeads = Double(totalLeads) / Double(data.numUniqueDays())
                    /// The lifetime number of connected devices for the user.
                    let totalConnected = data.connectedUnits()
                    /// The user's lifetime device connection rate.
                    let connectionRate = data.connectivityPercent()
                    
                    LifetimeStatView(description: "\(totalDevices != 1 ? "Devices" : "Device") Transacted", stat: Double(totalDevices), color: .gray, SFsymbol: "iphone")

                    HStack {
                        Text("AppleCare+")
                            .font(.title)
                            .fontWeight(.bold)

                        Spacer()
                    }
                    .padding([.top, .leading])

                    LifetimeStatView(description: "\(totalDevices != 1 ? "Units" : "Unit") Sold", stat: Double(totalDevices), color: .red, SFsymbol: "applelogo", secondDescription: "Attach Rate", secondStat: Double(data.appleCarePercent()), secondIsPercent: true)
                    
                    HStack {
                        Text("Business Leads")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding([.top, .leading])
                    
                    LifetimeStatView(description: "\(totalLeads != 1 ? "Business Leads" : "Lead")", stat: Double(totalLeads), color: .brown, SFsymbol: "briefcase.fill", secondDescription: "Average Per Day", secondStat: averageLeads.isNaN ? 0 : averageLeads, secondIsPercent: true)
                    
                    HStack {
                        Text("Connected")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding([.top, .leading])
                    
                    LifetimeStatView(description: "\(totalConnected != 1 ? "Devices" : "Device") Connected", stat: Double(totalConnected), color: .blue, SFsymbol: "antenna.radiowaves.left.and.right", secondDescription: "Connectivity Rate", secondStat: Double(connectionRate), secondIsPercent: true)
                }
                .padding(.bottom)
                
                // MARK: Nav Bar Settings
                .navigationBarTitle(Text("Lifetime"))
            }
        }
    }
}

struct LifetimeView_Previews: PreviewProvider {
    static var previews: some View {
        LifetimeView()
    }
}

struct ColorTextWithCaption: View {
    
    // Variables
    var color: Color
    var number: String
    var caption: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(number)")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(color)
            Text("\(caption)")
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
    }
}

/// A view with a color, SF symbol, integer stat, and name which is used to display a user's lifetime accomplishments in the Lifetime view.
struct LifetimeStatView: View {
    
    // MARK: - View Variables
    /// The description or name of the first stat.
    var description = "Total Devices Transacted"
    /// The numerical stat to display first.
    var stat: Double = 5_000
    /// Whether or not the first stat is a percent.
    var isPercent = false
    /// The color of the view's background, as well as the SF symbol's color.
    var color = Color.gray
    /// The opacity of the background.
    var backgroundOpacity = 0.15
    /// The opacity of the SF symbol.
    var SFsymbolOpacity = 0.3
    /// The name of the first SF symbol.
    var SFsymbol = "iphone"
    /// The height the view should be.
    var height: CGFloat = 125
    
    /// The description or name of the second stat.
    var secondDescription: String? = nil
    /// The numerical stat to display second.
    var secondStat: Double? = nil
    /// Whether or not the second stat is a percent.
    var secondIsPercent = false
    
    /// A decimal-style number formatter for use on the stat(s).
    var numberFormatter : NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
    
    // MARK: View Body
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(color)
                .opacity(0.15)
            
            HStack {
                Image(systemName: SFsymbol)
                    .resizable()
                    .foregroundColor(color)
                    .aspectRatio(contentMode: .fit)
                    .opacity(SFsymbolOpacity)
                    .padding([.top, .leading, .bottom])
                
                Spacer()
            }
            
            HStack {
                if secondDescription != nil && secondStat != nil {
                    Spacer()
                }
                
                VStack(spacing: 5) {
                    Text(numberFormatter.string(from: NSNumber(value: stat))! + "\(isPercent ? "%" : "")")
                        .font(.system(size: 33))
                        .fontWeight(.heavy)
                    
                    Text(description)
                        .fontWeight(.semibold)
                }
                
                if secondDescription != nil && secondStat != nil {
                    Spacer()
                    
                    VStack(spacing: 5) {
                        Text(numberFormatter.string(from: NSNumber(value: secondStat!))! + "\(secondIsPercent ? "%" : "")")
                            .font(.system(size: 33))
                            .fontWeight(.heavy)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                        
                        Text(secondDescription!)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                    }
                    
                    Spacer()
                }
            }
        }
        .frame(height: height)
    }
}
