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

        var next: Mood {
            let moods = Mood.allCases
            let index = moods.firstIndex(of: self) ?? 0
            return moods[(index + 1) % moods.count]
        }

        var faceImageName: String? {
            switch self {
            case .idle: nil
            case .happy: "characterFaceHappy"
            case .sleepy: "characterFaceSleepy"
            case .focused: "characterFaceFocused"
            }
        }
    }

    let color: CharacterColor
    var archetype: Archetype?
    var cloak: CharacterCloak?
    var mood: Mood = .idle
    var size: CGFloat = 126

    var body: some View {
        ZStack {
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
        // A little bounce and a ring in the user's color when the mood changes
        .keyframeAnimator(initialValue: MoodChange(), trigger: mood) { content, change in
            content
                .scaleEffect(change.scale)
                .background {
                    Circle()
                        .stroke(color.faceColor, lineWidth: 2)
                        .scaleEffect(change.ringScale)
                        .opacity(change.ringOpacity)
                }
        } keyframes: { _ in
            KeyframeTrack(\.scale) {
                SpringKeyframe(1.08, duration: 0.14)
                SpringKeyframe(1, duration: 0.3)
            }
            KeyframeTrack(\.ringScale) {
                CubicKeyframe(0.55, duration: 0.01)
                CubicKeyframe(1.1, duration: 0.45)
            }
            KeyframeTrack(\.ringOpacity) {
                CubicKeyframe(0.45, duration: 0.01)
                CubicKeyframe(0, duration: 0.45)
            }
        }
    }

    private struct MoodChange {
        var scale: CGFloat = 1
        var ringScale: CGFloat = 0.55
        var ringOpacity: Double = 0
    }

    private func layer(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
    }
}

#Preview {
    HStack {
        ForEach(CharacterPortrait.Mood.allCases, id: \.self) { mood in
            CharacterPortrait(color: .green, mood: mood)
        }
    }
    .background(Color.asphyrBackground)
}
