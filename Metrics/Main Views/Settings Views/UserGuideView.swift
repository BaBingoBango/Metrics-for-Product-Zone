//
//  UserGuideView.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/16/22.
//

import SwiftUI

/// Short articles about using the app.
struct UserGuideView: View {
    var body: some View {
        List {
            Section("Recording Data") {
                GuideArticleLink(title: "Adding Transactions", systemImage: "plus", text: """
                Data in Metrics is represented by transactions. In order to keep track of your Product Zone stats, Metrics uses your list of transactions to calculate the relevant information. Thus, in order to report your stats, you need to log each of your transactions in the Metrics app.

                To access the Log Transaction screen, tap the plus button in the top-right corner of the Today screen on iOS and iPadOS. On watchOS, select Log Transaction on the Today page.

                From there, select the type of device you transacted; if there was no physical device involved (e.g. an unaccompanied business lead), don’t select a device type (on watchOS, swipe left to reach the additions page).

                Next, select any additions to your transaction: AppleCare+, a Business Lead, a successful cellular connection for an iPhone, a Trade-In, or an Accessory. To indicate standalone AppleCare+, tap the AppleCare+ button twice. This also indicates that no new device was purchased, so Trade-In and Accessory are not available for standalone AppleCare+.

                The only addition available for a no-device transaction is a Business Lead, so to indicate a standalone lead, leave the device type unselected and toggle on the Business Lead option.

                To save your transaction, select Save.
                """)

                GuideArticleLink(title: "Managing Transactions", systemImage: "doc.on.doc.fill", text: """
                To view and delete your transactions, open Settings and select View Transaction Data. Each transaction is listed with its device type, log date and additions.

                Tap a transaction to reveal everything recorded about it. From the detail screen, select Delete Transaction to erase it from all of your devices and from iCloud.
                """)

                GuideArticleLink(title: "Setting Daily Goals", systemImage: "star.fill", text: """
                Daily Goals help you keep track of standards you’d like to maintain in a day-to-day context. Each of the goals you set from the Settings screen is reflected in the five circles at the top of the Today view: AppleCare+, Business Leads, Connectivity, Trade-In and Accessories.

                As your day’s transactions are logged, the Daily Goals circles fill in accordance with your progress towards the values you set. When you have completed a goal, you’ll see a green checkmark instead of a progress circle.
                """)
            }

            Section("Viewing Data") {
                GuideArticleLink(title: "Today View", systemImage: "sun.max.fill", text: """
                The Today view is the first tab on iOS and iPadOS and the first page on watchOS. If enabled, it displays progress towards your Daily Goals at the top and summarizes the day’s transactions below.

                Beneath your daily summary, the Today view displays the Sharing section, which lists a short summary of the daily transactions of anyone who is sharing their data with you. Tap a person to view their This Week, Lifetime and Transaction Data screens. Pull down to refresh the Sharing section.

                You can also select the plus button on the Today view to log a new transaction.
                """)

                GuideArticleLink(title: "This Week View", systemImage: "calendar", text: """
                The This Week screen is your one-stop shop to view your weekly transaction history! The bar graphs display your daily metrics for AppleCare+, Business Leads, iPhone Connectivity, Trade-In and Accessories for each day of the current week.

                It also displays your totals and averages for each metric and provides access to the graph views: tap any graph to open the full information for that statistic.
                """)

                GuideArticleLink(title: "Graph View", systemImage: "chart.bar.fill", text: """
                The graph view provides a visual display of your complete transaction history! You can access it by tapping any of the smaller bar graphs on the This Week view.

                At the top of the view, choose from Weekly, Monthly or Yearly displays, which change the scale of the bar graph. Once you have selected a scale, use the arrow buttons to move through earlier and later periods.

                Below the bar graph, the Highlights section summarizes the data contained in the current time selection.
                """)

                GuideArticleLink(title: "Lifetime View", systemImage: "crown.fill", text: """
                The Lifetime view provides a summary of your entire transaction history! The statistics displayed here are based on all of your logged transactions and are a great place to review your entire transactional journey.

                The Lifetime view is also available when viewing the metrics of someone who is sharing their data with you.
                """)
            }

            Section("Sharing Data") {
                GuideArticleLink(title: "Sharing Your Data", systemImage: "square.and.arrow.up", text: """
                The Product Zone of Apple Retail environments is a very social place; employees of all different levels are constantly conversing and sharing information. To that end, Metrics provides the Sharing feature!

                Sharing allows you to keep others updated on your transactions and check up on the transactions of others! Anyone with Sharing access to another person’s data can view (but not edit) their entire transaction history and any new transactions via the Sharing section of the Today view on iOS and iPadOS, and the Sharing page on watchOS.

                In order to participate in Sharing, you’ll need to be connected to the Internet and your device will need to be signed in to iCloud. After confirming these, you can share your data with someone by opening Settings and selecting Share My Metrics. From there, you can add people to your data, any of whom can view your latest transactions.

                At any time, if you would like to revoke access, return to Share My Metrics and select the name of the person you would like to remove.
                """)

                GuideArticleLink(title: "Viewing Shared Data", systemImage: "person.2.fill", text: """
                The first step in viewing someone’s transaction data is to accept their invitation by tapping on an invitation link. The Metrics app opens and automatically accepts the invitation.

                Once you have accepted an invitation, you can view that person’s information in the Sharing section of the Today view.

                If you no longer want to view someone else’s data, or want to see the list of people sharing with you, open Settings and select Shared With You. From there, select a person’s name to view other participants and leave the share.
                """)

                GuideArticleLink(title: "Sharing and Privacy", systemImage: "hand.raised.fill", text: """
                In order to facilitate the Sharing feature, your data must be uploaded to a place on the Internet so that the people you share with can access it. To protect your privacy as much as possible during this process, Metrics uses iCloud private databases through Apple’s CloudKit technology.

                Using this model, any and all data sent off your device is stored in your personal private database, which is managed by Apple and locked behind your Apple Account. This means that only you and those you invite with Sharing, not even Apple or the developer of Metrics, can view your data.

                When you share your data, the people you invite receive a “window” into your private database. In this way, specific individuals can access your data without exposing it to the whole world.
                """)
            }
        }
        .navigationTitle("User Guide")
    }
}

/// A row that opens one guide article.
struct GuideArticleLink: View {
    let title: String
    let systemImage: String
    let text: String

    var body: some View {
        NavigationLink {
            ScrollView {
                Text(text)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            Label(title, systemImage: systemImage)
        }
    }
}

#Preview {
    NavigationStack {
        UserGuideView()
    }
}
