//
//  CardBackground.swift
//  Metrics
//
//  Created by Ethan Marshall on 9/22/26.
//

import SwiftUI

/// The rounded, subtly filled card the app groups related content in.
struct CardBackground: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(.fill.tertiary, in: .rect(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension View {
    /// Places the view on the app's standard card.
    func cardBackground(cornerRadius: CGFloat = 20) -> some View {
        modifier(CardBackground(cornerRadius: cornerRadius))
    }
}
