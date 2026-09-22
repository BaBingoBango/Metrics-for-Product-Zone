//
//  WatchSharingView.swift
//  WatchMetrics
//
//  Created by Ethan Marshall on 7/16/22.
//

import SwiftUI

/// Today's numbers for everyone sharing their metrics with the user.
struct WatchSharingView: View {
    @Environment(SharingStore.self) private var sharingStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    if sharingStore.status != .inProgress {
                        Button {
                            Task { await sharingStore.refresh() }
                        } label: {
                            Label("Refresh", systemImage: "arrow.clockwise")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }

                    switch sharingStore.status {
                    case .notStarted, .inProgress:
                        VStack(spacing: 6) {
                            ProgressView()
                            Text("Connecting…")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top)

                    case .failure:
                        WatchSharingMessage(systemImage: "exclamationmark.icloud.fill", title: "Sharing Unavailable", message: "Check iCloud and your connection, then refresh.")

                    case .success where sharingStore.people.isEmpty:
                        WatchSharingMessage(systemImage: "person.3.fill", title: "No People Found", message: "No one is sharing their metrics with you right now.")

                    case .success:
                        ForEach(sharingStore.people) { person in
                            WatchSharingRectangleView(person: person.today)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .navigationTitle("Sharing")
        }
        .task {
            if !sharingStore.hasLoaded {
                await sharingStore.refresh()
            }
        }
    }
}

/// A status message shown in place of Sharing data.
struct WatchSharingMessage: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }
}

#Preview {
    WatchSharingView()
        .previewEnvironment()
}
