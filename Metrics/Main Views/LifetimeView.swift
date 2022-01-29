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
            VStack {
                
                HStack {
                    Spacer()
                    VStack {
                        ColorTextWithCaption(color: .red, number: String(Int(data.appleCareNumerator())), caption: "AppleCare+\nUnits Sold")
                        ColorTextWithCaption(color: .red, number: String(Double(data.appleCarePercent())) + "%", caption: "AppleCare+\nAttach Rate")
                            .padding(.top, 30)
                    }
                    Spacer()
                    VStack {
                        ColorTextWithCaption(color: .brown, number: String(Int(data.numBusinessLeads())), caption: "Business\nLeads")
                        ColorTextWithCaption(color: .brown, number: String((Double(data.numBusinessLeads()) / Double(data.numUniqueDays())).truncate(places: 3)), caption: "Average\nPer Day")
                            .padding(.top, 30)
                    }
                    Spacer()
                    VStack {
                        ColorTextWithCaption(color: .blue, number: String(Int(data.connectedUnits())), caption: "Connected\nDevices")
                        ColorTextWithCaption(color: .blue, number: String(Double(data.connectivityPercent()).truncate(places: 3)) + "%", caption: "Connectivity\nRate")
                            .padding(.top, 30)
                    }
                    Spacer()
                }
                .padding(.top)
                
                ColorTextWithCaption(color: .gray, number: String(Int(data.withDevice().count)), caption: "Total Devices Transacted")
                    .padding(.top, 30)
                
                Spacer()
                
            }
            
            // MARK: Nav Bar Settings
            .navigationBarTitle(Text("Lifetime"))
            
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
