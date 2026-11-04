//
//  CharacterTapCounter.swift
//  Asphyr
//

import Foundation

/// Tapping the character too many times, too quickly, makes it angry.
struct CharacterTapCounter {
    private static let tapsToAnger = 5
    private static let window: TimeInterval = 2

    private var taps: [Date] = []

    /// Returns true on the tap that crosses the line, then starts counting again.
    mutating func register(at date: Date) -> Bool {
        taps = taps.filter { date.timeIntervalSince($0) <= Self.window } + [date]
        guard taps.count >= Self.tapsToAnger else { return false }

        taps = []
        return true
    }
}
