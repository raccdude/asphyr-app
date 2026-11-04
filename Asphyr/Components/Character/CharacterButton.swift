//
//  CharacterButton.swift
//  Asphyr
//

import SwiftUI

/// The tappable character on Home and Character. Each tap changes its mood, and
/// too many quick taps make it angry for a few seconds.
struct CharacterButton: View {
    let color: CharacterColor
    var archetype: Archetype?
    var cloak: CharacterCloak?
    @Binding var mood: CharacterPortrait.Mood
    var size: CGFloat = 126
    /// What it calms down to.
    var restingMood: CharacterPortrait.Mood = .idle

    @State private var tapCount = 0
    @State private var tapCounter = CharacterTapCounter()
    @State private var angerCount = 0

    var body: some View {
        Button(action: tap) {
            CharacterPortrait(color: color, archetype: archetype, cloak: cloak, mood: mood, size: size, tapCount: tapCount)
                .modifier(ShakeEffect(shakes: CGFloat(angerCount)))
        }
        .buttonStyle(PressableButtonStyle())
        .hapticFeedback(.selection, trigger: tapCount)
        .hapticFeedback(.impact(weight: .heavy), trigger: angerCount)
        .accessibilityLabel("Character")
        .accessibilityHint("Changes the character’s expression")
    }

    private func tap() {
        tapCount += 1
        guard mood != .angry else { return }

        guard tapCounter.register(at: .now) else {
            mood = mood.next
            return
        }

        mood = .angry
        withAnimation(.linear(duration: 0.4)) {
            angerCount += 1
        }

        Task {
            try? await Task.sleep(for: .seconds(3))
            if mood == .angry {
                mood = restingMood
            }
        }
    }
}
