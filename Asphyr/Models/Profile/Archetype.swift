//
//  Archetype.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/8/26.
//

import Foundation

enum Archetype: String, CaseIterable, Identifiable {
    case strategist = "Strategist"
    case scholar = "Scholar"
    case creator = "Creator"
    case explorer = "Explorer"

    var id: Self { self }

    var title: String { rawValue }

    var iconName: String { "icon\(rawValue)" }

    var description: String {
        switch self {
        case .strategist: "Analytical, deliberate, focused on planning."
        case .scholar: "Curious, disciplined, driven by knowledge."
        case .creator: "Imaginative, expressive, driven to build."
        case .explorer: "Curious, adaptable, willing to discover."
        }
    }
}
