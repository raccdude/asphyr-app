//
//  CharacterPortrait.swift
//  Asphyr
//

import SwiftUI

/// The character with a mood drawn over its face. The face sits on its own
/// layer so one set of moods works for every color and archetype image.
struct CharacterPortrait: View {
    enum Mood: CaseIterable {
        case idle
        case happy
        case sleepy
        case focused
        /// Only from too many quick taps, so it's not part of the cycle.
        case angry

        var next: Mood {
            let moods: [Mood] = [.idle, .happy, .sleepy, .focused]
            let index = moods.firstIndex(of: self) ?? 0
            return moods[(index + 1) % moods.count]
        }

        var faceImageName: String? {
            switch self {
            case .idle: nil
            case .happy: "characterFaceHappy"
            case .sleepy: "characterFaceSleepy"
            case .focused: "characterFaceFocused"
            case .angry: "characterFaceAngry"
            }
        }
    }

    let color: CharacterColor
    var archetype: Archetype?
    var cloak: CharacterCloak?
    var mood: Mood = .idle
    var size: CGFloat = 126
    /// Goes up with each tap, for the bounce and ripple.
    var tapCount = 0

    var body: some View {
        ZStack {
            if mood == .angry {
                AngryFlames(color: color)
                    .transition(.opacity)
            }

            CharacterArt(color: color, archetype: archetype, cloak: cloak)

            if let faceImageName = mood.faceImageName {
                layer("characterFaceVisor")

                layer(faceImageName)
                    .foregroundStyle(color.faceColor)
                    .id(mood)
                    .transition(.opacity)
            }

            if mood == .sleepy {
                layer("characterSleepyZs")
                    .transition(.opacity)
            }
        }
        .frame(width: size, height: size)
        .animation(.easeInOut(duration: 0.2), value: mood)
        // A little bounce and a ripple in the user's color, only when tapped
        .keyframeAnimator(initialValue: TapEffect(), trigger: tapCount) { content, effect in
            content
                .scaleEffect(effect.scale)
                .background {
                    Circle()
                        .stroke(color.faceColor, lineWidth: 2)
                        .scaleEffect(effect.rippleScale)
                        .opacity(effect.rippleOpacity)
                }
        } keyframes: { _ in
            KeyframeTrack(\.scale) {
                SpringKeyframe(1.08, duration: 0.14)
                SpringKeyframe(1, duration: 0.3)
            }
            KeyframeTrack(\.rippleScale) {
                CubicKeyframe(0.55, duration: 0.01)
                CubicKeyframe(1.1, duration: 0.45)
            }
            KeyframeTrack(\.rippleOpacity) {
                CubicKeyframe(0.45, duration: 0.01)
                CubicKeyframe(0, duration: 0.45)
            }
        }
    }

    private struct TapEffect {
        var scale: CGFloat = 1
        var rippleScale: CGFloat = 0.55
        var rippleOpacity: Double = 0
    }

    private func layer(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
    }
}

/// Flames flickering around an angry character.
private struct AngryFlames: View {
    let color: CharacterColor

    /// Position as fractions of the portrait, and size as a fraction of it.
    private static let flames: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
        (0.16, 0.74, 0.3), (0.84, 0.74, 0.3), (0.08, 0.46, 0.22), (0.92, 0.46, 0.22),
        (0.3, 0.1, 0.2), (0.7, 0.1, 0.2), (0.5, 0.02, 0.26)
    ]

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: 1 / 20)) { context in
                let time = context.date.timeIntervalSinceReferenceDate

                ForEach(Self.flames.indices, id: \.self) { index in
                    let flame = Self.flames[index]
                    let flicker = sin(time * 9 + Double(index) * 1.7)

                    Image(systemName: "flame.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(
                            // Bright at the tip, so dark colors still show against the background
                            LinearGradient(colors: [color.faceColor, color.swatch], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: proxy.size.width * flame.size)
                        .scaleEffect(1 + flicker * 0.14, anchor: .bottom)
                        .opacity(0.8 + flicker * 0.2)
                        .position(x: proxy.size.width * flame.x, y: proxy.size.height * flame.y)
                }
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview("Angry") {
    CharacterPortrait(color: .green, archetype: .strategist, mood: .angry)
        .padding(40)
        .background(Color.asphyrBackground)
}

#Preview {
    HStack {
        ForEach(CharacterPortrait.Mood.allCases, id: \.self) { mood in
            CharacterPortrait(color: .green, mood: mood)
        }
    }
    .background(Color.asphyrBackground)
}
