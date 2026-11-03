//
//  CharacterColor.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import SwiftUI

/// The six character colors. Deliberately not tokenised
/// (see docs/DESIGN-DECISIONS.md).
enum CharacterColor: String, CaseIterable, Identifiable {
    case green = "Green"
    case oxblood = "Oxblood"
    case yellow = "Yellow"
    case snow = "Snow"
    case midnight = "Midnight"
    case plum = "Plum"

    var id: Self { self }   

    var swatch: Color {
        switch self {
        case .green: Color(red: 0 / 255, green: 255 / 255, blue: 65 / 255)      // #00FF41
        case .oxblood: Color(red: 74 / 255, green: 15 / 255, blue: 28 / 255)    // #4A0F1C
        case .yellow: Color(red: 255 / 255, green: 216 / 255, blue: 77 / 255)   // #FFD84D
        case .snow: Color(red: 245 / 255, green: 247 / 255, blue: 255 / 255)    // #F5F7FF
        case .midnight: Color(red: 22 / 255, green: 38 / 255, blue: 79 / 255)   // #16264F
        case .plum: Color(red: 47 / 255, green: 22 / 255, blue: 80 / 255)       // #2F1650
        }
    }

    /// The eyes and mouth, matching the character art.
    var faceColor: Color {
        switch self {
        case .green: Color(red: 128 / 255, green: 255 / 255, blue: 160 / 255)     // #80FFA0
        case .oxblood: Color(red: 255 / 255, green: 122 / 255, blue: 138 / 255)   // #FF7A8A
        case .yellow: Color(red: 255 / 255, green: 236 / 255, blue: 166 / 255)    // #FFECA6
        case .snow: Color(red: 250 / 255, green: 251 / 255, blue: 255 / 255)      // #FAFBFF
        case .midnight: Color(red: 127 / 255, green: 166 / 255, blue: 255 / 255)  // #7FA6FF
        case .plum: Color(red: 181 / 255, green: 140 / 255, blue: 255 / 255)      // #B58CFF
        }
    }

    var noviceImageName: String { "characterNovice\(rawValue)" }

    /// The novice holding the archetype's item, or empty-handed without one.
    func noviceImageName(holdingItemOf archetype: Archetype?) -> String {
        noviceImageName + (archetype?.rawValue ?? "")
    }
}
