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
}

/// The colors a cloak is drawn with.
struct CloakPalette: Equatable {
    let top: Color
    let bottom: Color
    let hand: Color

    /// The look every character starts with.
    static let starter = CloakPalette(
        top: Color(red: 43 / 255, green: 48 / 255, blue: 61 / 255),      // #2B303D
        bottom: Color(red: 18 / 255, green: 20 / 255, blue: 26 / 255),   // #12141A
        hand: Color(red: 58 / 255, green: 63 / 255, blue: 76 / 255)      // #3A3F4C
    )
}

/// The cloaks, which go over any character color. Adding one only needs its
/// colors here, as the art is tinted in code. Hands are the top color × 1.25.
enum CharacterCloak: String, CaseIterable, Identifiable {
    case midnight = "Midnight"
    case oxblood = "Oxblood"
    case plum = "Plum"
    case green = "Green"
    case yellow = "Yellow"
    case snow = "Snow"
    case teal = "Teal"

    var id: Self { self }

    var palette: CloakPalette {
        switch self {
        case .midnight: palette(top: 0x22386F, bottom: 0x0E1730, hand: 0x2B468B)
        case .oxblood: palette(top: 0x5A1A28, bottom: 0x2A0A12, hand: 0x712132)
        case .plum: palette(top: 0x3F2268, bottom: 0x1D0F33, hand: 0x4F2B82)
        case .green: palette(top: 0x14532B, bottom: 0x07210F, hand: 0x196836)
        case .yellow: palette(top: 0x6B5314, bottom: 0x2B2108, hand: 0x866819)
        case .snow: palette(top: 0x8B90A3, bottom: 0x3A3D4A, hand: 0xAEB4CC)
        case .teal: palette(top: 0x12565E, bottom: 0x06252A, hand: 0x176C76)
        }
    }

    /// The level reward that unlocks it. Cloaks without one come with the store.
    var reward: CloakReward? {
        RewardRules.cloaks.first { $0.name == "\(rawValue) cloak" }
    }

    private func palette(top: Int, bottom: Int, hand: Int) -> CloakPalette {
        CloakPalette(top: color(top), bottom: color(bottom), hand: color(hand))
    }

    private func color(_ hex: Int) -> Color {
        Color(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
