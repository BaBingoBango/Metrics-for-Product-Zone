//
//  TransactionDetailView.swift
//  Metrics
//
//  Created by Ethan Marshall on 6/21/22.
//

import SwiftUI

struct TransactionDetailView: View {
    
    // MARK: - View Variables
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext
    @State var isShowingDeleteWarning = false
    @State var isDeletingTransaction = false
    var transaction: Transaction
    var dateFormatter: DateFormatter {
        let answer = DateFormatter()
        answer.dateStyle = .short
        answer.timeStyle = .short
        return answer
    }
    var allowDelete = true
    
    // MARK: - View Body
    var body: some View {
        if !isDeletingTransaction {
            NavigationView {
                ScrollView {
                    VStack {
                        ZStack {
                            Circle()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.gray)
                                .opacity(0.15)
                            
                            Image(systemName: imageDelegator())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.blue)
                                .shadow(radius: 10)
                                .frame(width: 90, height: 90)
                        }
                        .padding(.top)
                        
                        Text("\(transaction.deviceType ?? "") Transaction")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                            .padding([.top, .leading, .trailing])
                        
                        Text(dateFormatter.string(from: transaction.date!))
                            .fontWeight(.semibold)
                            .font(.title2)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Details")
                                .font(.title)
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                            
                            Spacer()
                        }
                        .padding([.top, .leading, .trailing])
                        
                        HStack {
                            ZStack {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(transaction.boughtAppleCare ? .green : .red)
                                
                                Image(systemName: "applelogo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            
                            Text("\(transaction.boughtAppleCare ? "Purchased" : "Did Not Purchase") AppleCare+")
                                .fontWeight(.semibold)
                                .font(.title3)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            ZStack {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(transaction.isAppleCareStandalone ? .green : .red)
                                
                                Image(systemName: "sparkle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            
                            Text("AppleCare+ Is \(transaction.isAppleCareStandalone ? "" : "Not ")Standalone")
                                .fontWeight(.semibold)
                                .font(.title3)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            ZStack {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(transaction.connected ? .green : .red)
                                
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            
                            Text(transaction.connected ? "Connected" : "Did Not Connect")
                                .fontWeight(.semibold)
                                .font(.title3)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            ZStack {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(transaction.gotLead ? .green : .red)
                                
                                Image(systemName: "briefcase.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            
                            Text("\(transaction.gotLead ? "Recorded" : "Did Not Record") Business Lead")
                                .fontWeight(.semibold)
                                .font(.title3)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            ZStack {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(.gray)
                                
                                Image(systemName: "barcode")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("ID")
                                    .fontWeight(.semibold)
                                    .font(.title3)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                
                                Text(transaction.id!.uuidString)
                                    .font(.custom("Roboto Mono", size: 20))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
                
                // MARK: - Navigation View Settings
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Done")
                                .fontWeight(.bold)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            isShowingDeleteWarning = true
                        }) {
                            Text("Delete")
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                        .isHidden(!allowDelete, remove: !allowDelete)
                        .alert("Delete this transaction?", isPresented: $isShowingDeleteWarning) {
                            Button(role: .cancel, action: {
                                isShowingDeleteWarning = false
                            }) {
                                Text("Cancel")
                            }
                            
                            Button(role: .destructive, action: {
                                isDeletingTransaction = true
                                viewContext.delete(transaction)
                                do {
                                    try viewContext.save()
                                } catch {
                                    print(error.localizedDescription)
                                }
                                self.presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Delete")
                            }
                        }
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    // MARK: - View Functions
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

// MARK: - View Preview
//struct TransactionDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        TransactionDetailView()
//    }
//}
