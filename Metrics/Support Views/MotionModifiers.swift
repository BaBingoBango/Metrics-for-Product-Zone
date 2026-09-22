//
//  MotionModifiers.swift
//  Metrics
//
//  Created by Ethan Marshall on 9/22/26.
//

import SwiftUI

/// Animates changes to `value` unless the person has asked for reduced motion.
struct ReducedMotionAnimation<Value: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let value: Value

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : .snappy, value: value)
    }
}

/// Rolls changing digits unless the person has asked for reduced motion, in which case they cross-fade.
struct NumericContentTransition: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.contentTransition(reduceMotion ? .opacity : .numericText())
    }
}

extension View {
    /// Animates changes to `value` with the app's standard animation, respecting Reduce Motion.
    func animateUnlessReduced<Value: Equatable>(_ value: Value) -> some View {
        modifier(ReducedMotionAnimation(value: value))
    }

    /// Transitions changing numbers, respecting Reduce Motion.
    func numericContentTransition() -> some View {
        modifier(NumericContentTransition())
    }
}
