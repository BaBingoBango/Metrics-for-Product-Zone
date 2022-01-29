//
//  DataViewer.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/13/21.
//

import SwiftUI

struct DataViewer: View {
    
    // Modal variable
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    // View context & transaction fetch request
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Transaction.entity(), sortDescriptors: [])
    var transactions: FetchedResults<Transaction>
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    Image(systemName: "doc.on.doc.fill")
                        .resizable()
                        .foregroundColor(.green)
                        .frame(width: 63, height: 75)
                        .padding(.top, 30)

                    Text("Transaction Save Data")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    ForEach(transactions.reversed()) { transaction in
                        TransactionDataOption(transaction: transaction)
                    }
                    
                }
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
    
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: imageDelegator())
                    .imageScale(.small)
                    .font(Font.title.weight(.medium))
                Text(dateFormatter.string(from: transaction.date!))
                Spacer()
                Button(action: {
                    viewContext.delete(transaction)
                    do {
                        try viewContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }) {
                    Image(systemName: "minus.circle.fill").foregroundColor(.red)
                }
            }
            .padding(.horizontal, 30)
            
            Rectangle()
                .foregroundColor(.gray)
                .opacity(0.3)
                .frame(height: 50)
                .cornerRadius(10)
                .padding(.horizontal)
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
