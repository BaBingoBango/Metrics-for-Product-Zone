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
                    WatchOptionButton(title: metric.additionTitle, symbolName: metric.symbolName, tint: tint(for: metric), isSelected: draft.includes(metric)) {
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
            HStack(spacing: 6) {
                Image(systemName: symbolName)

                if let title {
                    Text(title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 44)
            .foregroundStyle(isSelected ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
            .background(isSelected ? tint : Color(white: 0.24), in: .rect(cornerRadius: 10, style: .continuous))
            .contentShape(.rect(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    WatchAdderView()
        .previewEnvironment()
}
