//
//  ProgressRing.swift
//  Metrics
//
//  Created by Ethan Marshall on 8/3/21.
//

import SwiftUI

/// A circular progress indicator drawn in a metric's color, with optional content in the center.
struct ProgressRing<Content: View>: View {
    /// The progress to show, from 0 to 1. Values outside that range are clamped.
    var progress: Double
    /// The ring's color.
    var color: Color
    /// The thickness of the ring.
    var lineWidth: Double = 8.5
    /// The view drawn in the center of the ring.
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .rotationEffect(.degrees(-90))
                .animateUnlessReduced(progress)

            content()
        }
        .padding(lineWidth / 2)
        .aspectRatio(1, contentMode: .fit)
    }
}

extension ProgressRing where Content == EmptyView {
    /// A ring with nothing in the center.
    init(progress: Double, color: Color, lineWidth: Double = 8.5) {
        self.init(progress: progress, color: color, lineWidth: lineWidth) { EmptyView() }
    }
}

extension ProgressRing where Content == RingSymbol {
    /// A ring with an SF Symbol in the center, sized relative to the ring.
    init(progress: Double, color: Color, lineWidth: Double = 8.5, symbolName: String) {
        self.init(progress: progress, color: color, lineWidth: lineWidth) {
            RingSymbol(name: symbolName, color: color)
        }
    }
}

/// An SF Symbol scaled to sit comfortably inside a `ProgressRing`.
struct RingSymbol: View {
    var name: String
    var color: Color

    var body: some View {
        Image(systemName: name)
            .resizable()
            .scaledToFit()
            .foregroundStyle(color)
            .scaleEffect(0.38)
    }
}

#Preview {
    HStack {
        ProgressRing(progress: 0.6, color: .red, symbolName: "iphone")
        ProgressRing(progress: 0.35, color: .orange, symbolName: "arrow.triangle.2.circlepath")
        ProgressRing(progress: 0, color: .leadBrown) {
            Text("3").font(.title.bold()).foregroundStyle(.leadBrown)
        }
    }
    .padding()
}
