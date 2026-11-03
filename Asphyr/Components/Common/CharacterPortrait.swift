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

    let imageName: String
    let color: CharacterColor
    var mood: Mood = .idle
    var size: CGFloat = 126

    var body: some View {
        ZStack {
            layer(imageName)

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
            CharacterPortrait(imageName: "characterNoviceGreen", color: .green, mood: mood)
        }
    }
    .background(Color.asphyrBackground)
}
