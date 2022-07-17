//
//  DataViewer.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/13/21.
//

import SwiftUI

/// A view listing all of the user's logged transactions.
struct DataViewer: View {
    
    // MARK: - View Variables
    // Modal variable
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    // View context & transaction fetch request
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Transaction.entity(), sortDescriptors: [])
    var transactions: FetchedResults<Transaction>
    
    /// The navigation title text for this view.
    var titleText = "Transaction Data"
    /// A transaction list for this view that will override the one from Core Data.
    var customTransactions: [Transaction]?
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    Image(systemName: "doc.on.doc.fill")
                        .resizable()
                        .foregroundColor(.green)
                        .frame(width: 63, height: 75)
                        .padding(.top, 30)

                    Text(titleText)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .padding([.top, .horizontal])
                    
                    if customTransactions != nil ? customTransactions!.isEmpty : transactions.isEmpty {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.gray)
                                .opacity(0.15)
                                .cornerRadius(20)
                            
                            VStack(spacing: 4) {
                                Image(systemName: "figure.wave")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.secondary)
                                    .frame(height: 100)
                                
                                Text("No Data Yet")
                                    .foregroundColor(.secondary)
                                    .fontWeight(.bold)
                                    .font(.title2)
                                
                                Text("Nice to see you here though!")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.all)
                        }
                        .padding(.horizontal)
                    }
                    
                    if customTransactions != nil {
                        ForEach(customTransactions!.reversed()) { transaction in
                            TransactionDataOption(transaction: transaction, allowDelete: customTransactions == nil)
                        }
                    } else {
                        ForEach(transactions.reversed()) { transaction in
                            TransactionDataOption(transaction: transaction)
                        }
                    }
                    
                }
                .padding(.bottom)
            }
            
            // MARK: Nav Bar Settings
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Done").fontWeight(.bold) })
            
        }
    }
}

struct DataViewer_Previews: PreviewProvider {
    static var previews: some View {
        DataViewer()
    }
}

struct TransactionDataOption: View {
    
    // View context variable
    @Environment(\.managedObjectContext) private var viewContext
    
    // Variables
    var transaction: Transaction
    var dateFormatter: DateFormatter {
        let answer = DateFormatter()
        answer.dateStyle = .short
        answer.timeStyle = .short
        return answer
    }
    @State var showingDetail = false
    var allowDelete = true
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            ZStack {
                HStack {
                    Image(systemName: imageDelegator())
                        .imageScale(.small)
                        .font(Font.title.weight(.medium))
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading) {
                        Text(transaction.deviceType ?? "Unknown Device")
                            .fontWeight(.bold)
                            .font(.title3)
                            .foregroundColor(.primary)
                        
                        Text(dateFormatter.string(from: transaction.date!))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 30)
                
                Rectangle()
                    .foregroundColor(.gray)
                    .opacity(0.15)
                    .cornerRadius(20)
                    .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingDetail) {
            TransactionDetailView(transaction: transaction, allowDelete: allowDelete)
        }
    }
    
    // Functions
    func imageDelegator() -> String {
        switch transaction.deviceType! {
        case "iPhone": return "iphone"
        case "iPad": return "ipad.landscape"
        case "Mac": return "desktopcomputer"
        case "Apple Watch": return "applewatch"
        case "Apple TV": return "appletv"
        case "Headphones": return "headphones"
        case "No Device": return "briefcase.fill"
        default: return ""
        }
    }
    
}
