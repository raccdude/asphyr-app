//
//  CharacterArt.swift
//  Asphyr
//

import SwiftUI

/// The character, built from layers so any cloak can be tinted over any color
/// and item without its own image. The cloak sits behind and in front of the
/// tunic, and the hands stay in front of the item.
struct CharacterArt: View {
    let color: CharacterColor
    var archetype: Archetype?
    var cloak: CharacterCloak?

    private var palette: CloakPalette {
        cloak?.palette ?? .starter
    }

    var body: some View {
        ZStack {
            layer("characterLayerBase")
            cloakLayer("characterLayerCloakBack")
            layer("characterTunic\(color.rawValue)")
            cloakLayer("characterLayerCloakFront")
            layer("characterDetails\(color.rawValue)\(archetype?.rawValue ?? "")")

            palette.hand
                .mask { layer("characterLayerHands") }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func layer(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
    }

    /// The gradient runs from y 10.08 to 118.44 of the art's 126.
    private func cloakLayer(_ name: String) -> some View {
        LinearGradient(
            colors: [palette.top, palette.bottom],
            startPoint: UnitPoint(x: 0.5, y: 0.08),
            endPoint: UnitPoint(x: 0.5, y: 0.94)
        )
        .mask { layer(name) }
    }
}

#Preview {
    VStack {
        HStack {
            CharacterArt(color: .green, archetype: .strategist)
            CharacterArt(color: .snow, archetype: .scholar)
            CharacterArt(color: .yellow, archetype: .creator)
        }

        ForEach(Array(CharacterCloak.allCases.enumerated()).chunked, id: \.first?.offset) { row in
            HStack {
                ForEach(row, id: \.offset) { _, cloak in
                    CharacterArt(color: .green, archetype: .explorer, cloak: cloak)
                }
            }
        }
    }
    .background(Color.asphyrBackground)
}

private extension Array {
    var chunked: [[Element]] {
        stride(from: 0, to: count, by: 3).map { Array(self[$0..<Swift.min($0 + 3, count)]) }
    }
}
