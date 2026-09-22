//
//  SharedWithYouView.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/3/22.
//

import CloudKit
import SwiftUI
import os

/// The people sharing their data with the current user. Selecting one opens the system sharing UI, where the
/// user can see other participants or leave the share.
struct SharedWithYouView: View {
    @State private var users: [SharingUser] = []
    @State private var isLoading = true
    @State private var selectedUser: SharingUser?

    private static let logger = Logger(subsystem: "Ethan.Metrics", category: "Sharing")

    var body: some View {
        Group {
            if isLoading, users.isEmpty {
                ProgressView()
                    .controlSize(.large)
            } else if users.isEmpty {
                ContentUnavailableView(
                    "No People Found",
                    systemImage: "person.2",
                    description: Text("No one is sharing their metrics with you right now.")
                )
            } else {
                List {
                    Section("People Sharing With You") {
                        ForEach(users) { user in
                            Button {
                                selectedUser = user
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(user.displayName)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)

                                    if let email = user.email {
                                        Text(email)
                                            .foregroundStyle(.secondary)
                                    }

                                    if let phoneNumber = user.phoneNumber {
                                        Text(phoneNumber)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Shared With You")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
        .refreshable { await load() }
        .sheet(item: $selectedUser, onDismiss: { Task { await load() } }) { user in
            CloudKitSharingView(share: user.share, container: SharingStore.container)
        }
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            users = try await SharingStore.sharingUsers()
        } catch {
            Self.logger.error("Failed to load people sharing with you: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NavigationStack {
        SharedWithYouView()
    }
}
