//
//  AdderView.swift
//  Metrics
//
//  Created by Ethan Marshall on 7/30/21.
//

import CoreData
import SwiftUI
import os

/// The sheet for logging a new transaction.
struct AdderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var draft = TransactionDraft()

    private static let logger = Logger(subsystem: "Ethan.Metrics", category: "Transactions")

    private let deviceColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    /// Additions sit in a flowing grid, or one per row at accessibility text sizes so their names stay legible.
    private var additionColumns: [GridItem] {
        dynamicTypeSize.isAccessibilitySize ? [GridItem(.flexible())] : [GridItem(.adaptive(minimum: 104), spacing: 12)]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Device Type")
                            .font(.title3.bold())

                        LazyVGrid(columns: deviceColumns, spacing: 12) {
                            ForEach(DeviceType.sellable) { device in
                                OptionButton(symbolName: device.symbolName, tint: .green, isSelected: draft.record.deviceType == device, height: 96) {
                                    draft.select(device)
                                }
                                .accessibilityLabel(device.name)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Additions")
                            .font(.title3.bold())

                        LazyVGrid(columns: additionColumns, spacing: 12) {
                            ForEach(draft.availableAdditions) { metric in
                                OptionButton(title: title(for: metric), symbolName: metric.symbolName, tint: tint(for: metric), isSelected: draft.includes(metric), height: 120) {
                                    draft.toggle(metric)
                                }
                            }
                        }
                        .animateUnlessReduced(draft.availableAdditions)

                        Text("Tap AppleCare+ twice to record standalone AppleCare+, which means no new device was purchased.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Log Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", role: .confirm) { save() }
                }
            }
            .sensoryFeedback(.selection, trigger: draft)
        }
    }

    private func tint(for metric: Metric) -> Color {
        metric == .appleCare && draft.record.isAppleCareStandalone ? .standaloneGold : metric.color
    }

    /// Names the standalone AppleCare+ state in words so it is not conveyed by the gold color alone.
    private func title(for metric: Metric) -> String {
        metric == .appleCare && draft.record.isAppleCareStandalone ? "Standalone AppleCare+" : metric.additionTitle
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

/// A large tappable tile for a device or an addition, filled with its color when selected.
///
/// At accessibility text sizes a titled tile lays its icon and title out side by side so the title has room.
struct OptionButton: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    var title: String? = nil
    var symbolName: String
    var tint: Color
    var isSelected: Bool
    var height: CGFloat
    var action: () -> Void

    private var usesRowLayout: Bool { title != nil && dynamicTypeSize.isAccessibilitySize }

    var body: some View {
        Button(action: action) {
            let layout = usesRowLayout ? AnyLayout(HStackLayout(spacing: 12)) : AnyLayout(VStackLayout(spacing: 8))
            layout {
                Image(systemName: symbolName)
                    .font(.system(size: 36, weight: .medium))
                    .frame(width: usesRowLayout ? 44 : nil, height: 44)

                if let title {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .multilineTextAlignment(usesRowLayout ? .leading : .center)
                        .lineLimit(usesRowLayout ? nil : 2)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: usesRowLayout ? .infinity : nil, alignment: .leading)
                }
            }
            .padding(.horizontal, usesRowLayout ? 16 : 6)
            .padding(.vertical, usesRowLayout ? 16 : 0)
            .frame(maxWidth: .infinity, minHeight: usesRowLayout ? 64 : height)
            .foregroundStyle(isSelected ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
            .background(isSelected ? AnyShapeStyle(tint) : AnyShapeStyle(.fill.tertiary), in: .rect(cornerRadius: 12, style: .continuous))
            .overlay(alignment: .topTrailing) {
                // A check mark marks selection so it is not conveyed by color alone.
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(8)
                        .accessibilityHidden(true)
                }
            }
            .contentShape(.rect(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animateUnlessReduced(isSelected)
    }
}

#Preview {
    AdderView()
        .previewEnvironment()
}
