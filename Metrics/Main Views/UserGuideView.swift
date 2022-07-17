//
//  UserGuideView.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/16/22.
//

import SwiftUI

struct UserGuideView: View {
    
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recording Data")) {
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                Data in Metrics is represented by transactions. In order to keep track of your Product Zone stats, Metrics uses your list of transactions to calculate the relevant information. Thus, in order to report your stats, you need to log each of your transactions in the Metrics app.

                                To access the Log Transaction screen, tap the green plus symbol in the top-right corner of the Today screen on iOS, iPadOS, and macOS. On watchOS, select Log Transaction from the initial Today tab.

                                From there, select the type of device you transacted; if there was no physical device involved (e.g. an unaccompanied business lead), don’t select a device type (on watchOS, swipe left to access the additions selection page).

                                From there, select any additions to your transaction, whether that be AppleCare+, a Business Lead, or a successful cellular connection for an iPhone. To indicate standalone AppleCare+, tap the AppleCare+ button twice (this also indicates that no new device was purchased).

                                The only addition available for a no-device transaction is a Business Lead, so to indicate a standalone lead, leave the device type unselected and toggle on the Business Lead option.

                                To save your transaction, select the Save button.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Adding Transactions")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "plus").imageScale(.large); Text("Adding Transactions") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                To view and delete all of your transactions on iOS, iPadOS, and watchOS, navigate to the Settings screen and select View Transaction Data. From there, you can view each of your transaction’s device type and log date.

                                Tap on a transaction to reveal the complete list of information about it. On this detail screen, you can view all pieces of data that encompass the transaction. From here, you can select Done to return to the list of transactions, or Delete to erase the transaction.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Managing Transactions")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "doc.on.doc.fill").imageScale(.medium); Text("Managing Transactions") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                Daily Goals help you keep track of standards you’d like to maintain in a day-to-day context. Each of the goals you set from the Settings screen will be reflected in the three circles at the top of the Today view.

                                As your day’s transactions are logged, the Daily Goals circles will fill or lower in accordance with progress towards the values you set. When you have completed a goal, you’ll see a green checkmark instead of a progress circle.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Setting Daily Goals")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "star.fill").imageScale(.medium); Text("Setting Daily Goals") }
                    }
                }
                
                Section(header: Text("Viewing Data")) {
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                The Today view is accessible from the left-most tab on iOS, the first sidebar option on iPadOS and macOS, and the first page on watchOS. If enabled, it displays progress towards Daily Goals at the top and summarizes information about the day’s transactions below.

                                Below your daily summary, the Today view displays the Sharing section, which lists a short summary of the daily transactions of anyone who is sharing their data with you. From there, you can tap on an individual’s display to view that person’s This Week, Lifetime, and Transaction Data views.

                                You can also select the green plus icon located on the Today view to log a new transaction.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Today View")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "sun.max.fill").imageScale(.large); Text("Today View") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                The This Week screen is available on iOS, iPadOS, and macOS, and is your one-stop shop to view your weekly transaction history! The bar graphs display your daily metrics for AppleCare+, Business Leads, and iPhone connectivity for each day of the current week, Sunday through Saturday.

                                It also displays your averages for the three metrics and provides access to the graph views for each - tap on any of the graphs to open the full information for each statistic.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("This Week View")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "calendar").imageScale(.large); Text("This Week View") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                The graph view provides a visual display of your complete transaction history! You can access it by tapping on any one of the smaller bar graphs on the This Week view.

                                The graph view displays information about your complete transaction history for a certain metric. At the top of the view, you can choose from Weekly, Monthly, or Yearly displays, which change the scale of the main bar graph displayed.

                                Once you have selected a scale, you can use the arrow buttons near the top of the view to adjust the period of time you are currently examining.

                                Below the bar graph, the Highlights section summarizes the data contained in the current time selection for easy viewing.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Graph View")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "chart.bar.fill").imageScale(.medium); Text("Graph View") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                The Lifetime view provides a summary of your entire transaction history! The statistics displayed here are based off of all your logged transactions and is a great place to review your entire transactional journey!

                                The Lifetime view is also accessible when viewing the metrics of someone who is sharing their data with you.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Lifetime View")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "crown.fill").imageScale(.medium); Text("Lifetime View") }
                    }
                }
                
                Section(header: Text("Sharing Data")) {
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                The Product Zone of Apple Retail environments is a very social place; employees of all different levels are constantly conversing and sharing information. To that end, Metrics provides the Sharing feature!

                                Sharing allows you to keep others updated on your transactions and check up on the transactions of others! Anyone with Sharing access to another person’s data can view (but not edit) their entire transaction history and any new transactions via the Sharing section of the Today view on iOS, iPadOS, and macOS, and the Sharing page of watchOS.

                                In order to participate in Sharing, you’ll need to be connected to the Internet and your device will need to be signed in to iCloud. After confirming these, you can share your data with another by navigating to the Settings screen and selecting Share My Metrics. From there, you can add people to your data, any of whom can view your latest transactions.

                                At any time, if you would like to revoke access, return to the Share My Metrics screen and select the name of the person you would like to remove.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Sharing Your Data")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "square.and.arrow.up").imageScale(.large); Text("Sharing Your Data") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                The first step in viewing someone’s transaction data is to accept their invitation by tapping on an invitation link. From there, the Metrics app will open and automatically accept the invitation.

                                Once you have accepted an invitation, you can view that person’s information in the Sharing section of the Today view.

                                If you no longer want to view someone else’s data, or to view the list of people sharing with you, navigate to Settings and select Shared With You. From there, you can select someone’s name to view other participants and revoke your access.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Viewing Shared Data")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "person.2.fill").imageScale(.medium); Text("Viewing Shared Data") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                In order to facilitate the Sharing feature, your data must be uploaded to a place on the Internet so that people you share with can access it. In order to protect your privacy as much as possible during this process, Metrics utilizes iCloud private databases through Apple’s CloudKit technology.

                                Using this model, any and all data sent off your device to the Internet is stored in your personal private database, which is managed by Apple and locked behind your Apple ID. This means that only you and those you invite with Sharing, not even Apple or the developer of Metrics, can view your data.

                                When you share your data with Sharing, those you invite receive a “window” into your private database. In this way, specific individuals can access your data without comprising it for the whole world to see.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Sharing and Privacy")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "hand.raised.fill").imageScale(.large); Text("Sharing and Privacy") }
                    }
                }
            }
            
            // MARK: - Navigation View Settings
            .navigationTitle("User Guide")
            .navigationBarItems(trailing: Button(action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Done").fontWeight(.bold) })
        }
    }
}

struct UserGuideView_Previews: PreviewProvider {
    static var previews: some View {
        UserGuideView()
    }
}
