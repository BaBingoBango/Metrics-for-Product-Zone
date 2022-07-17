//
//  SharingTabView.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/15/22.
//

import SwiftUI

/// A version of the main tab view that is presented when a user taps on a user in the Sharing section of the Today view.
struct SharingTabView: View {
    // MARK: - View Variables
    /// The system `PresentationMode` variable for this view.
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    /// The transactions for the Sharing user this view represents,
    var transactions: TransactionServices
    /// The currently selected sidebar tab.
    @State var selection: Int? = 1
    
    // MARK: - View Body
    var body: some View {
        TabView {
            NavigationView {
                ThisWeekView(navigationTitleText: transactions.owner != nil ? "\(transactions.owner!)'s Week" : "This Week", customTransactions: transactions)
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                self.presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Done")
                                    .fontWeight(.bold)
                                    .foregroundColor(.accentColor)
                            }
                        }
                    })
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "calendar"); Text("This Week")
            }
            
            NavigationView {
                LifetimeView(navigationTitleText: transactions.owner != nil ? "\(transactions.owner!)'s Lifetime" : "Lifetime", customTransactions: transactions)
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                self.presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Done")
                                    .fontWeight(.bold)
                                    .foregroundColor(.accentColor)
                            }
                        }
                    })
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "crown.fill"); Text("Lifetime")
            }
            
            DataViewer(titleText: transactions.owner != nil ? "\(transactions.owner!)'s Transactions" : "Transaction Data", customTransactions: transactions.transactions)
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Done")
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                        }
                    }
                })
                .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "doc.on.doc.fill"); Text("Transactions")
            }
        }
    }
}

struct SharingTabView_Previews: PreviewProvider {
    static var previews: some View {
        SharingTabView(transactions: TransactionServices([]))
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
