//
//  SettingsView.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/6/21.
//

import CloudKit
import MessageUI
import SwiftUI
import UIKit

/// App preferences, Sharing controls, data management and support links.
struct SettingsView: View {
    @Environment(\.openURL) private var openURL

    @AppStorage("showGoalsInTodayView") private var showsGoals = true
    @AppStorage("showSharingInTodayView") private var showsSharing = true
    @AppStorage("appleCareGoal") private var appleCareGoal = Metric.appleCare.defaultGoal
    @AppStorage("businessLeadsGoal") private var businessLeadsGoal = Metric.businessLeads.defaultGoal
    @AppStorage("connectivityGoal") private var connectivityGoal = Metric.connectivity.defaultGoal
    @AppStorage("tradeInGoal") private var tradeInGoal = Metric.tradeIn.defaultGoal
    @AppStorage("accessoryGoal") private var accessoryGoal = Metric.accessory.defaultGoal

    @State private var isPreparingShare = false
    @State private var presentedShare: PresentedShare?
    @State private var sharingErrorMessage = ""
    @State private var isShowingSharingError = false
    @State private var isShowingMailSender = false
    @State private var hasCopiedFeedbackEmail = false

    private static let feedbackEmail = "fillips.stamens0i@icloud.com"
    private static let reviewURL = URL(string: "https://apps.apple.com/us/app/metrics-for-product-zone/id1581284514?action=write-review")!
    private static let privacyPolicyURL = URL(string: "https://github.com/BaBingoBango/Metrics-for-Product-Zone/wiki/Privacy-Policy")!
    private static let supportURL = URL(string: "https://github.com/BaBingoBango/Metrics-for-Product-Zone/wiki/Support-Center")!
    private static let repositoryURL = URL(string: "https://github.com/BaBingoBango/Metrics-for-Product-Zone")!

    var body: some View {
        Form {
            Section("Daily Goals") {
                Toggle("Show Goals in Today", isOn: $showsGoals)

                ForEach(Metric.allCases) { metric in
                    NavigationLink {
                        GoalEditorView(metric: metric, goal: goalBinding(for: metric))
                    } label: {
                        LabeledContent("\(metric.title) Goal", value: metric.formattedGoal(goalBinding(for: metric).wrappedValue))
                    }
                }
            }

            Section {
                Toggle("Show Sharing in Today", isOn: $showsSharing)

                if isPreparingShare {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Preparing to Share…")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Button("Share My Metrics…") {
                        Task { await prepareShare() }
                    }
                }

                NavigationLink("Shared With You") {
                    SharedWithYouView()
                }
            } header: {
                Text("Sharing")
            } footer: {
                Text("Metrics never lets other people edit or delete your transactions, even if that permission is enabled on the invitation screen.")
            }

            Section {
                NavigationLink("View Transaction Data") {
                    DataViewer()
                }
            } header: {
                Text("Data Management")
            } footer: {
                Text("Metrics stores your transactions on this device and syncs them across your devices with iCloud. Deleting a transaction removes it from every device and from iCloud.")
            }

            Section {
                Button("Configure Metrics in Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
            } header: {
                Text("Permissions")
            } footer: {
                Text("To grant or revoke permissions for Metrics, open the Settings app.")
            }

            Section("Feedback") {
                if MFMailComposeViewController.canSendMail() {
                    Button("Send Feedback Mail", systemImage: "exclamationmark.bubble.fill") {
                        isShowingMailSender = true
                    }
                } else {
                    Button(hasCopiedFeedbackEmail ? "Feedback Email Copied!" : "Copy Feedback Email", systemImage: "exclamationmark.bubble.fill") {
                        UIPasteboard.general.string = Self.feedbackEmail
                        hasCopiedFeedbackEmail = true
                    }
                }

                Link(destination: Self.reviewURL) {
                    Label("Review on the App Store", systemImage: "star.bubble.fill")
                }
            }

            Section("Resources") {
                NavigationLink {
                    UserGuideView()
                } label: {
                    Label("User Guide", systemImage: "book.fill")
                }

                Link(destination: Self.privacyPolicyURL) {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                }

                Link(destination: Self.supportURL) {
                    Label("Support Center", systemImage: "questionmark.circle.fill")
                }

                Link(destination: Self.repositoryURL) {
                    Label("Metrics on GitHub", systemImage: "curlybraces")
                }
            }

            Section("About") {
                LabeledContent("App Version", value: Bundle.main.shortVersion)
                LabeledContent("Build Number", value: Bundle.main.buildNumber)
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $isShowingMailSender) {
            MailSenderView(
                recipients: [Self.feedbackEmail],
                subject: "Metrics Feedback",
                body: "Please provide your feedback below. Feature suggestions, bug reports, and more are all appreciated! :)\n\n(If applicable, you may be contacted for more information or for follow-up questions.)\n\n\n"
            )
        }
        .sheet(item: $presentedShare) { presented in
            CloudKitSharingView(share: presented.share, container: SharingStore.container)
        }
        .alert("Sharing Failed", isPresented: $isShowingSharingError) {
            Button("Close", role: .cancel) {}
        } message: {
            Text(sharingErrorMessage)
        }
    }

    private func goalBinding(for metric: Metric) -> Binding<Int> {
        switch metric {
        case .appleCare: $appleCareGoal
        case .businessLeads: $businessLeadsGoal
        case .connectivity: $connectivityGoal
        case .tradeIn: $tradeInGoal
        case .accessory: $accessoryGoal
        }
    }

    /// Fetches or creates the user's share, giving up after ten seconds, then presents the sharing UI.
    private func prepareShare() async {
        isPreparingShare = true
        defer { isPreparingShare = false }

        let thumbnail = NSDataAsset(name: "sharing thumbnail")?.data
        let fetch = Task { try await SharingStore.ownShare(thumbnail: thumbnail) }
        let timeout = Task {
            try await Task.sleep(for: .seconds(10))
            fetch.cancel()
        }
        defer { timeout.cancel() }

        do {
            presentedShare = PresentedShare(share: try await fetch.value)
        } catch {
            sharingErrorMessage = fetch.isCancelled
                ? "The request timed out. Check that you are signed in to iCloud and connected to the Internet."
                : error.localizedDescription
            isShowingSharingError = true
        }
    }
}

/// Wraps a share so it can drive a sheet.
struct PresentedShare: Identifiable {
    let id = UUID()
    let share: CKShare
}

extension Bundle {
    /// The marketing version, such as "2.0".
    var shortVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    /// The build number.
    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .previewEnvironment()
}
