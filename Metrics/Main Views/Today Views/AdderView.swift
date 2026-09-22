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
    @State private var draft = TransactionDraft()

    private static let logger = Logger(subsystem: "Ethan.Metrics", category: "Transactions")

    private let deviceColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    private let additionColumns = [GridItem(.adaptive(minimum: 104), spacing: 12)]

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
                                OptionButton(title: metric.additionTitle, symbolName: metric.symbolName, tint: tint(for: metric), isSelected: draft.includes(metric), height: 120) {
                                    draft.toggle(metric)
                                }
                                .accessibilityValue(metric == .appleCare && draft.record.isAppleCareStandalone ? "Standalone" : "")
                            }
                        }
                        .animation(.snappy, value: draft.availableAdditions)

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
struct OptionButton: View {
    var title: String? = nil
    var symbolName: String
    var tint: Color
    var isSelected: Bool
    var height: CGFloat
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: symbolName)
                    .font(.system(size: 36, weight: .medium))
                    .frame(height: 44)

                if let title {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
            }
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, minHeight: height)
            .foregroundStyle(isSelected ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
            .background(isSelected ? AnyShapeStyle(tint) : AnyShapeStyle(.fill.tertiary), in: .rect(cornerRadius: 12, style: .continuous))
            .contentShape(.rect(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(.snappy, value: isSelected)
    }
}

#Preview {
    AdderView()
        .previewEnvironment()
}
