//
//  ThisWeekView.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/5/21.
//

import SwiftUI

struct ThisWeekView: View {
    
    // View context & transaction fetch request
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Transaction.entity(), sortDescriptors: [])
    var transactions: FetchedResults<Transaction>
    
    // TransactionServices objects
    var data: TransactionServices {
        return TransactionServices(transactions.reversed().reversed())
    }
    
    // Variables
    var dateFormatter: DateFormatter {
        let answer = DateFormatter()
        answer.dateStyle = .medium
        answer.timeStyle = .none
        return answer
    }
    
    // State variables
    @State var showingAC = false
    @State var showingBL = false
    @State var showingC = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text("\(dateFormatter.string(from: Date().previous(.sunday))) - \(dateFormatter.string(from: Date().next(.saturday)))".uppercased())
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                        Spacer()
                    }
                    
                    // MARK: AppleCare+
                    
                    Button(action: {
                        showingAC.toggle()
                    }) {
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
                                    HStack(spacing: 6) {
                                        Text("TOTAL")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                        Text("\(TransactionServices(data.allWeek()).appleCarePercent())%")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                            .padding(.trailing, 30)
                                    }
                                }
                                .padding(.top, 15)
                                .padding(.leading, 35)
                                
                                BarGraphRow(percents: [
                                            Double(TransactionServices(data.thisWeek(.sunday)).appleCarePercent()) / 100.0,
                                            Double(TransactionServices(data.thisWeek(.monday)).appleCarePercent()) / 100.0,
                                            Double(TransactionServices(data.thisWeek(.tuesday)).appleCarePercent()) / 100.0,
                                            Double(TransactionServices(data.thisWeek(.wednesday)).appleCarePercent()) / 100.0,
                                            Double(TransactionServices(data.thisWeek(.thursday)).appleCarePercent()) / 100.0,
                                            Double(TransactionServices(data.thisWeek(.friday)).appleCarePercent()) / 100.0,
                                            Double(TransactionServices(data.thisWeek(.saturday)).appleCarePercent()) / 100.0
                                ], color: .red)
                                
                                Spacer()
                                
                            }
                            
                        }
                        .frame(height: 280)
                    }
                    .sheet(isPresented: $showingAC) {
                        GraphDetailView(data: data, stat: "AppleCare+")
                    }
                    
                    // MARK: Business Leads
                    
                    Button(action: {
                        showingBL.toggle()
                    }) {
                        ZStack {
                            
                            Rectangle()
                                .foregroundColor(.gray)
                                .opacity(0.2)
                                .cornerRadius(20)
                                .padding(.horizontal)
                            
                            VStack {
                                
                                HStack {
                                    Image(systemName: "briefcase.fill")
                                        .imageScale(.large)
                                        .foregroundColor(.brown)
                                    Text("Business Leads")
                                        .fontWeight(.bold)
                                        .foregroundColor(.brown)
                                    Spacer()
                                    HStack(spacing: 6) {
                                        Text("AVG")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                        
                                        let bizServices = TransactionServices(data.allWeek())
                                        let bizAverage = ((Double(bizServices.numBusinessLeads()) / Double(bizServices.numUniqueDays())).truncate(places: 3))
                                        
                                        Text(bizAverage.isNaN ? "0" : String(bizAverage))
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.brown)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                            .padding(.trailing, 30)
                                    }
                                }
                                .padding(.top, 15)
                                .padding(.leading, 35)
                                
                                BarGraphRow(percents: [
                                            Double(TransactionServices(data.thisWeek(.sunday)).numBusinessLeads()) / 5.0,
                                            Double(TransactionServices(data.thisWeek(.monday)).numBusinessLeads()) / 5.0,
                                            Double(TransactionServices(data.thisWeek(.tuesday)).numBusinessLeads()) / 5.0,
                                            Double(TransactionServices(data.thisWeek(.wednesday)).numBusinessLeads()) / 5.0,
                                            Double(TransactionServices(data.thisWeek(.thursday)).numBusinessLeads()) / 5.0,
                                            Double(TransactionServices(data.thisWeek(.friday)).numBusinessLeads()) / 5.0,
                                            Double(TransactionServices(data.thisWeek(.saturday)).numBusinessLeads()) / 5.0
                                ], color: .brown)
                                
                                Spacer()
                                
                            }
                            
                        }
                        .frame(height: 280)
                        .padding(.top)
                    }
                    .sheet(isPresented: $showingBL) {
                        GraphDetailView(data: data, stat: "Business Leads")
                    }
                    
                    // MARK: Connectivity
                    
                    Button(action: {
                        showingC.toggle()
                    }) {
                        ZStack {
                            
                            Rectangle()
                                .foregroundColor(.gray)
                                .opacity(0.2)
                                .cornerRadius(20)
                                .padding(.horizontal)
                            
                            VStack {
                                
                                HStack {
                                    Image(systemName: "antenna.radiowaves.left.and.right")
                                        .imageScale(.large)
                                        .foregroundColor(.blue)
                                    Text("Connectivity")
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                    Spacer()
                                    HStack(spacing: 6) {
                                        Text("TOTAL")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                        Text("\(TransactionServices(data.allWeek()).connectivityPercent())%")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                            .padding(.trailing, 30)
                                    }
                                }
                                .padding(.top, 15)
                                .padding(.leading, 35)
                                
                                BarGraphRow(percents: [
                                            Double(TransactionServices(data.thisWeek(.sunday)).connectivityPercent()) / 100.0,
                                            Double(TransactionServices(data.thisWeek(.monday)).connectivityPercent()) / 100.0,
                                            Double(TransactionServices(data.thisWeek(.tuesday)).connectivityPercent()) / 100.0,
                                            Double(TransactionServices(data.thisWeek(.wednesday)).connectivityPercent()) / 100.0,
                                            Double(TransactionServices(data.thisWeek(.thursday)).connectivityPercent()) / 100.0,
                                            Double(TransactionServices(data.thisWeek(.friday)).connectivityPercent()) / 100.0,
                                            Double(TransactionServices(data.thisWeek(.saturday)).connectivityPercent()) / 100.0
                                ], color: .blue)
                                
                                Spacer()
                                
                            }
                            
                        }
                        .frame(height: 280)
                        .padding([.top, .bottom])
                    }
                    .sheet(isPresented: $showingC) {
                        GraphDetailView(data: data, stat: "Connectivity")
                    }
                    
                    Spacer()
                    
                }
                
                // MARK: Nav Bar Settings
                .navigationBarTitle(Text("This Week"))
            }
            
        }
    }
}

struct ThisWeekView_Previews: PreviewProvider {
    static var previews: some View {
        ThisWeekView()
    }
}

struct BarGraphRow: View {
    
    // Parameter for the labels
    var labels: [String] = ["S", "M", "T", "W", "T", "F", "S"]
    
    // Pass-In Variable
    var percents: [Double]
    var color: Color
    
    // Functions
    func reduce(_ num: Double) -> Double {
        if num > 1.0 {
            return 1.0
        } else {
            return num
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor(color)
                    .cornerRadius(10)
                    .frame(height: 191 * CGFloat(reduce(percents[0])))
                Text(labels[0])
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor(color)
                    .cornerRadius(10)
                    .frame(height: 191 * CGFloat(reduce(percents[1])))
                Text(labels[1])
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor(color)
                    .cornerRadius(10)
                    .frame(height: 191 * CGFloat(reduce(percents[2])))
                Text(labels[2])
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor(color)
                    .cornerRadius(10)
                    .frame(height: 191 * CGFloat(reduce(percents[3])))
                Text(labels[3])
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor(color)
                    .cornerRadius(10)
                    .frame(height: 191 * CGFloat(reduce(percents[4])))
                Text(labels[4])
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor(color)
                    .cornerRadius(10)
                    .frame(height: 191 * CGFloat(reduce(percents[5])))
                Text(labels[5])
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor(color)
                    .cornerRadius(10)
                    .frame(height: 191 * CGFloat(reduce(percents[6])))
                Text(labels[6])
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 30)
    }
}
