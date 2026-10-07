//
//  WatchAdderView.swift
//  WatchMetrics
//
//  Created by Ethan Marshall on 8/14/21.
//

import CoreData
import SwiftUI
import os

/// The two-page sheet for logging a transaction on the watch: pick a device, then additions.
struct WatchAdderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var page = 1
    @State private var draft = TransactionDraft()

    private static let logger = Logger(subsystem: "Ethan.Metrics", category: "Transactions")

    var body: some View {
        NavigationStack {
            TabView(selection: $page) {
                devicePage
                    .tag(1)

                additionsPage
                    .tag(2)
            }
            .tabViewStyle(.page)
            .navigationTitle("Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
        }
    }

    private var devicePage: some View {
        VStack(spacing: 6) {
            ForEach([DeviceType.sellable.prefix(3), DeviceType.sellable.suffix(3)], id: \.first) { row in
                HStack(spacing: 6) {
                    ForEach(row) { device in
                        WatchOptionButton(symbolName: device.symbolName, tint: .green, isSelected: draft.record.deviceType == device) {
                            draft.select(device)
                            page = 2
                        }
                        .accessibilityLabel(device.name)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }

    private var additionsPage: some View {
        ScrollView {
            VStack(spacing: 6) {
                ForEach(draft.availableAdditions) { metric in
                    WatchOptionButton(title: title(for: metric), symbolName: metric.symbolName, tint: tint(for: metric), isSelected: draft.includes(metric)) {
                        draft.toggle(metric)
                    }
                }

                Button("Save", role: .confirm) { save() }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 4)
        }
    }

    private func tint(for metric: Metric) -> Color {
        metric == .appleCare && draft.record.isAppleCareStandalone ? .standaloneGold : metric.color
    }

    /// Names the standalone AppleCare+ state in words so it is not conveyed by the gold color alone.
    private func title(for metric: Metric) -> String {
        metric == .appleCare && draft.record.isAppleCareStandalone ? "Standalone AC+" : metric.additionTitle
    }

    private func save() {
        Transaction(context: viewContext).apply(draft.finalized())
        do {
            try viewContext.save()
        } catch {
            Self.logger.error("Failed to save transaction: \(error.localizedDescription)")
        }
        dismiss()
    }
}

/// A compact tappable tile for a device or an addition, filled with its color when selected.
///
/// Unselected tiles use an opaque gray because the sheet behind them is translucent on watchOS, and a
/// tinted material could be mistaken for a selection.
struct WatchOptionButton: View {
    var title: String? = nil
    var symbolName: String
    var tint: Color
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let title {
                    // One line at normal sizes, stepping down a text style or two when that keeps one
                    // line on 40mm watches. At the largest text sizes, multi-word titles wrap and single
                    // words shrink instead of breaking mid-word.
                    ViewThatFits(in: .horizontal) {
                        titleRow(title, font: .body, lineLimit: 1)
                        titleRow(title, font: .subheadline, lineLimit: 1)
                        titleRow(title, font: .footnote, lineLimit: 1)
                        if title.contains(" ") {
                            // Breaking at the space keeps "Standalone" whole; the scale factor then
                            // shrinks the whole title if a word is still too wide for one line.
                            titleRow(title.replacingOccurrences(of: " ", with: "\n"), font: .body, lineLimit: 2)
                        }
                    }
                } else {
                    Image(systemName: symbolName)
                        .font(.body.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .foregroundStyle(isSelected ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
            .background(isSelected ? tint : Color(white: 0.24), in: .rect(cornerRadius: 10, style: .continuous))
            .overlay(alignment: .topTrailing) {
                // A check mark marks selection so it is not conveyed by color alone.
                // The badge keeps a fixed size so it stays in the corner at every text size.
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(3)
                        .accessibilityHidden(true)
                }
            }
            .contentShape(.rect(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func titleRow(_ title: String, font: Font, lineLimit: Int) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbolName)
            Text(title)
                .lineLimit(lineLimit)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.leading)
        }
        .font(font.weight(.semibold))
        // Keeps the title clear of the check mark in the corner; wrapped titles sit higher, so they need more.
        .padding(.horizontal, lineLimit > 1 ? 16 : 14)
        .padding(.vertical, lineLimit > 1 ? 6 : 0)
    }
}

#Preview {
    WatchAdderView()
        .previewEnvironment()
}
