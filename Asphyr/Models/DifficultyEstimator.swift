//
//  DifficultyEstimator.swift
//  Asphyr
//

import Foundation

/// Judges a quest from its words, never its duration. The only place that
/// decides difficulty, so AI can replace the keywords later.
enum DifficultyEstimator {
    private static let hardWords: Set<String> = [
        "algebra", "algorithm", "algorithms", "biology", "calculus", "certification", "chemistry",
        "dissertation", "exam", "exams", "finals", "geometry", "interview", "marathon", "midterm",
        "midterms", "orals", "physics", "programming", "research", "statistics", "thesis", "triathlon"
    ]

    private static let easyWords: Set<String> = [
        "dishes", "drink", "errand", "errands", "laundry", "meditate", "nap", "stretch", "tidy",
        "vacuum", "walk", "water"
    ]

    static func estimate(title: String, description: String) -> QuestDifficulty {
        let words = Set(
            "\(title) \(description)"
                .lowercased()
                .components(separatedBy: CharacterSet.letters.inverted)
        )

        // Hard wins, so "Tidy my calculus notes" isn't treated as easy
        if !words.isDisjoint(with: hardWords) { return .hard }
        if !words.isDisjoint(with: easyWords) { return .easy }
        return .moderate
    }
}
