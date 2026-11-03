//
//  JourneySkyLayout.swift
//  Asphyr
//

import CoreGraphics
import Foundation

/// Where each chapter sits on the sky map, as fractions of the map. Chapter 1 is
/// always at the center, and each aspiration's path winds out from it its own way.
enum JourneySkyLayout {
    private static let center = CGPoint(x: 0.5, y: 0.5)

    private static let layouts: [String: [CGPoint]] = [
        "game developer": spots((0.76, 0.3), (0.24, 0.14), (0.24, 0.7), (0.76, 0.87)),
        "mechanical engineer": spots((0.24, 0.7), (0.76, 0.86), (0.76, 0.3), (0.24, 0.13)),
        "psychologist": spots((0.5, 0.2), (0.22, 0.42), (0.3, 0.84), (0.78, 0.66)),
        "doctor": spots((0.5, 0.76), (0.78, 0.52), (0.7, 0.16), (0.22, 0.26)),
        "writer": spots((0.78, 0.5), (0.5, 0.82), (0.22, 0.6), (0.4, 0.16)),
        "artist": spots((0.22, 0.5), (0.5, 0.18), (0.78, 0.4), (0.6, 0.84)),
        "entrepreneur": spots((0.24, 0.3), (0.76, 0.14), (0.76, 0.7), (0.24, 0.87)),
        "musician": spots((0.5, 0.2), (0.78, 0.42), (0.7, 0.84), (0.22, 0.66)),
        "athlete": spots((0.5, 0.76), (0.22, 0.52), (0.3, 0.16), (0.78, 0.26)),
        "teacher": spots((0.22, 0.5), (0.5, 0.82), (0.78, 0.6), (0.6, 0.16)),
        "designer": spots((0.78, 0.5), (0.5, 0.18), (0.22, 0.4), (0.4, 0.84)),
        "engineer": spots((0.24, 0.24), (0.76, 0.16), (0.76, 0.66), (0.3, 0.84))
    ]

    private static let general = spots((0.76, 0.7), (0.24, 0.86), (0.24, 0.3), (0.76, 0.13))

    static func spots(for aspiration: String?) -> [CGPoint] {
        let name = aspiration?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        return layouts[name] ?? general
    }

    private static func spots(_ others: (CGFloat, CGFloat)...) -> [CGPoint] {
        [center] + others.map { CGPoint(x: $0.0, y: $0.1) }
    }
}
