//
//  TodayTabView.swift
//  Metrics
//
//  Created by Ethan Marshall on 6/20/22.
//

import CoreData
import SwiftUI

/// The Today view: daily goals, a summary of today's transactions and the Sharing section.
struct TodayTabView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(SharingStore.self) private var sharingStore
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)], animation: .default)
    private var transactions: FetchedResults<Transaction>

    @AppStorage("showGoalsInTodayView") private var showsGoals = true
    @AppStorage("showSharingInTodayView") private var showsSharing = true
    @AppStorage("appleCareGoal") private var appleCareGoal = Metric.appleCare.defaultGoal
    @AppStorage("businessLeadsGoal") private var businessLeadsGoal = Metric.businessLeads.defaultGoal
    @AppStorage("connectivityGoal") private var connectivityGoal = Metric.connectivity.defaultGoal
    @AppStorage("tradeInGoal") private var tradeInGoal = Metric.tradeIn.defaultGoal
    @AppStorage("accessoryGoal") private var accessoryGoal = Metric.accessory.defaultGoal

    @State private var isShowingAdder = false
    @State private var selectedPerson: TransactionServices?

    private var isCompact: Bool { horizontalSizeClass == .compact }

    /// Today's transactions.
    private var todayData: TransactionServices {
        TransactionServices(transactions.map(\.record)).today
    }

    private var goals: [Metric: Int] {
        [
            .appleCare: appleCareGoal,
            .businessLeads: businessLeadsGoal,
            .connectivity: connectivityGoal,
            .tradeIn: tradeInGoal,
            .accessory: accessoryGoal,
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(Date.now.formatted(date: .complete, time: .omitted).uppercased())
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.secondary)

                    Text("Good \(TodayGreeting.timeOfDay())!")
                        .font(.title.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }

                if showsGoals {
                    DailyGoalsSection(todayData: todayData, goals: goals)
                }

                AppleCareSummaryCard(todayData: todayData, columns: isCompact ? 3 : 6)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: isCompact ? 2 : 4), spacing: 16) {
                    ForEach(Metric.allCases.filter { $0 != .appleCare }) { metric in
                        MetricSummaryCard(metric: metric, todayData: todayData)
                    }
                }

                if showsSharing {
                    SharingSection(isCompact: isCompact) { selectedPerson = $0 }
                }
            }
            .padding()
        }
        .navigationTitle("Today")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Log Transaction", systemImage: "plus") {
                    isShowingAdder = true
                }
            }
        }
        .sheet(isPresented: $isShowingAdder) {
            AdderView()
        }
        .sheet(item: $selectedPerson) { person in
            SharingTabView(transactions: person)
        }
        .task(id: showsSharing) {
            if showsSharing, !sharingStore.hasLoaded {
                await sharingStore.refresh()
            }
        }
        .refreshable {
            if showsSharing {
                await sharingStore.refresh()
            }
        }
    }
}

// MARK: - Greeting

/// The friendly copy at the top of the Today view.
enum TodayGreeting {
    /// A word for the current part of the day, as in "Good morning".
    static func timeOfDay(at date: Date = .now, calendar: Calendar = .current) -> String {
        switch calendar.component(.hour, from: date) {
        case 22...: "evening"
        case 12..<22: "afternoon"
        case 6..<12: "morning"
        default: "evening"
        }
    }

    /// A short exclamation about the day of the week.
    static func dayOfWeekPhrase(for date: Date = .now, calendar: Calendar = .current) -> String {
        switch calendar.component(.weekday, from: date) {
        case 1: "Happy Sunday!"
        case 2: "It's Monday..."
        case 3: "Happy 2's day!"
        case 4: "Happy hump day!"
        case 5: "Happy Thursday!"
        case 6: "It's Friday!!"
        case 7: "Happy weekend!"
        default: "Hello!"
        }
    }

    /// Encouragement based on how many daily goals are met.
    static func goalProgress(met: Int, of total: Int) -> String {
        let remaining = total - met
        if met == 0 { return "It's a great time to get started on your goals! You can do it!" }
        if remaining == 0 { return "All your goals are green right now! Great job, you did it!" }
        if remaining == 1 { return "You only have one goal to go! You're almost there!" }
        return "\(spelledOut(met).capitalized) down, \(spelledOut(remaining)) to go! Keep going, you got this!"
    }

    private static func spelledOut(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - Daily goals

/// The row of goal rings and the encouragement line beneath it.
struct DailyGoalsSection: View {
    let todayData: TransactionServices
    let goals: [Metric: Int]

    private func goal(for metric: Metric) -> Int {
        goals[metric] ?? metric.defaultGoal
    }

    private func progress(for metric: Metric) -> Double {
        if metric.isRate {
            return Double(todayData.percent(for: metric)) / 100
        }
        let goal = goal(for: metric)
        return goal == 0 ? 1 : Double(todayData.count(for: metric)) / Double(goal)
    }

    private func isMet(_ metric: Metric) -> Bool {
        todayData.value(for: metric) >= goal(for: metric)
    }

    private var metCount: Int {
        Metric.allCases.count(where: isMet)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ForEach(Metric.allCases) { metric in
                    GoalRing(metric: metric, progress: progress(for: metric), isMet: isMet(metric))
                }
            }
            .frame(maxWidth: 520)

            Text("\(TodayGreeting.dayOfWeekPhrase()) \(TodayGreeting.goalProgress(met: metCount, of: Metric.allCases.count))")
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

/// One daily goal: a progress ring, or a green check once the goal is met.
struct GoalRing: View {
    let metric: Metric
    let progress: Double
    let isMet: Bool

    var body: some View {
        Group {
            if isMet {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.green)
                    .padding(2.5)
            } else {
                ProgressRing(progress: progress, color: metric.color, symbolName: metric.symbolName)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isMet ? "\(metric.title) goal met" : "\(metric.title) goal, \(Int((progress * 100).rounded())) percent of the way there")
    }
}

// MARK: - Summary cards

/// AppleCare+ attach for the day, broken down by device type.
struct AppleCareSummaryCard: View {
    let todayData: TransactionServices
    let columns: Int

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label("AppleCare+", systemImage: "applelogo")
                    .font(.headline)
                    .foregroundStyle(.red)

                Spacer()

                Text("\(todayData.appleCarePercent)%")
                    .font(.title3.bold())
                    .foregroundStyle(.red)
                    .contentTransition(.numericText())
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: columns), spacing: 12) {
                ForEach(DeviceType.sellable) { device in
                    ProgressRing(progress: Double(todayData.appleCarePercent(for: device)) / 100, color: .red, symbolName: device.symbolName)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(device.name) AppleCare+ attach rate \(todayData.appleCarePercent(for: device)) percent")
                }
            }
        }
        .padding()
        .cardBackground()
    }
}

/// A square card with a metric's headline number for the day inside its ring.
struct MetricSummaryCard: View {
    let metric: Metric
    let todayData: TransactionServices

    private var value: String { todayData.formattedValue(for: metric) }

    var body: some View {
        VStack(spacing: 8) {
            Label(metric.shortTitle, systemImage: metric.symbolName)
                .font(.headline)
                .foregroundStyle(metric.color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            ProgressRing(progress: metric.isRate ? Double(todayData.percent(for: metric)) / 100 : 0, color: metric.color) {
                Text(value)
                    .font(metric.isRate ? .body.bold() : .largeTitle.bold())
                    .foregroundStyle(metric.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText())
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .cardBackground()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(metric.title) today: \(value)")
    }
}

// MARK: - Sharing

/// The list of people sharing their metrics, with today's numbers for each.
struct SharingSection: View {
    @Environment(SharingStore.self) private var sharingStore
    let isCompact: Bool
    let onSelect: (TransactionServices) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text("Sharing")
                    .font(.title.bold())

                if sharingStore.hasLoaded {
                    Button("Refresh Sharing", systemImage: "arrow.clockwise") {
                        Task { await sharingStore.refresh() }
                    }
                    .labelStyle(.iconOnly)
                    .font(.title3.weight(.semibold))
                }

                Spacer()
            }

            switch sharingStore.status {
            case .notStarted, .inProgress:
                SharingMessageCard {
                    ProgressView()
                        .controlSize(.large)
                    Text("Connecting…")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

            case .failure:
                SharingMessageCard(
                    systemImage: "exclamationmark.icloud.fill",
                    title: "Sharing Unavailable",
                    message: "Check that you're signed in to iCloud and connected to the Internet, then refresh."
                )

            case .success where sharingStore.people.isEmpty:
                SharingMessageCard(
                    systemImage: "person.3.fill",
                    title: "No People Found",
                    message: "No one is sharing their metrics with you right now."
                )

            case .success:
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: isCompact ? 1 : 2), spacing: 16) {
                    ForEach(sharingStore.people) { person in
                        Button {
                            onSelect(person)
                        } label: {
                            SharingRectangleView(person: person.today)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Shows this person's week, lifetime and transactions")
                    }
                }
            }
        }
    }
}

/// A card carrying a status message in place of Sharing data.
struct SharingMessageCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 10) {
            content()
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .cardBackground()
    }
}

extension SharingMessageCard where Content == SharingMessage {
    init(systemImage: String, title: String, message: String) {
        self.init { SharingMessage(systemImage: systemImage, title: title, message: message) }
    }
}

/// An icon, headline and explanation for a `SharingMessageCard`.
struct SharingMessage: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 40))
            .foregroundStyle(.secondary)

        Text(title)
            .font(.title2.bold())
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

        Text(message)
            .font(.callout)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    NavigationStack {
        TodayTabView()
    }
    .previewEnvironment()
}
