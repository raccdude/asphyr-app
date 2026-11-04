//
//  HapticFeedback.swift
//  Asphyr
//

import SwiftUI

extension EnvironmentValues {
    /// Follows Sounds & haptics in Settings.
    @Entry var hapticsEnabled = true
}

extension View {
    /// `sensoryFeedback` that respects Sounds & haptics.
    func hapticFeedback<T: Equatable>(_ feedback: SensoryFeedback, trigger: T) -> some View {
        modifier(HapticFeedbackModifier(feedback: feedback, trigger: trigger))
    }
}

private struct HapticFeedbackModifier<T: Equatable>: ViewModifier {
    let feedback: SensoryFeedback
    let trigger: T

    @Environment(\.hapticsEnabled) private var hapticsEnabled

    func body(content: Content) -> some View {
        content.sensoryFeedback(feedback, trigger: trigger) { _, _ in
            hapticsEnabled
        }
    }
}
