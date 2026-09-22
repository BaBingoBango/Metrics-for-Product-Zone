//
//  GoalEditorView.swift
//  Metrics
//
//  Created by Ethan Marshall on 6/25/22.
//

import SwiftUI

/// Controls for editing one of the user's daily goals.
struct GoalEditorView: View {
    let metric: Metric
    @Binding var goal: Int

    private var range: ClosedRange<Int> { metric.isRate ? 0...100 : 0...999 }

    private var description: String {
        metric.isRate ? metric.rateDescription : metric.unitName(for: goal)
    }

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 32) {
                Button("Decrease", systemImage: "minus.circle.fill") {
                    goal = max(range.lowerBound, goal - 1)
                }
                .disabled(goal <= range.lowerBound)

                Text(metric.isRate ? "\(goal)%" : "\(goal)")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(minWidth: 150)
                    .contentTransition(.numericText(value: Double(goal)))

                Button("Increase", systemImage: "plus.circle.fill") {
                    goal = min(range.upperBound, goal + 1)
                }
                .disabled(goal >= range.upperBound)
            }
            .labelStyle(.iconOnly)
            .font(.system(size: 34))
            .tint(metric.color)

            Text(description)
                .font(.headline)
                .foregroundStyle(metric.color)

            if metric.isRate {
                Slider(
                    value: Binding(get: { Double(goal) }, set: { goal = Int($0.rounded()) }),
                    in: Double(range.lowerBound)...Double(range.upperBound),
                    step: 1
                ) {
                    Text("\(metric.title) goal")
                }
                .tint(metric.color)
                .frame(maxWidth: 520)
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top, 32)
        .padding()
        .navigationTitle("Daily \(metric.title) Goal")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.snappy, value: goal)
        .sensoryFeedback(.increase, trigger: goal) { old, new in new > old }
        .sensoryFeedback(.decrease, trigger: goal) { old, new in new < old }
    }
}

#Preview {
    @Previewable @State var goal = 60
    NavigationStack {
        GoalEditorView(metric: .appleCare, goal: $goal)
    }
}
