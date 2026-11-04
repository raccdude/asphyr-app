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
        // Only the title can make a quest Hard, so a word added to the description
        // can't raise its reward. Hard wins, so "Tidy my calculus notes" isn't easy.
        if !words(in: title).isDisjoint(with: hardWords) { return .hard }
        if !words(in: "\(title) \(description)").isDisjoint(with: easyWords) { return .easy }
        return .moderate
    }

    private static func words(in text: String) -> Set<String> {
        Set(text.lowercased().components(separatedBy: CharacterSet.letters.inverted))
    }
}
