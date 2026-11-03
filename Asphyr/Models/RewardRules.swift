//
//  RewardRules.swift
//  Asphyr
//

import Foundation

enum QuestDifficulty: String, CaseIterable {
    case easy = "EASY"
    case moderate = "MODERATE"
    case hard = "HARD"
}

struct CloakReward: Equatable {
    let level: Int
    let name: String
}

/// How much quests are worth and what levels cost. See docs/XP-SYSTEM-SPEC.md.
enum RewardRules {
    /// How many main quest steps can be ticked per day, so XP can't be farmed.
    static let maxStepsPerDay = 3

    /// How many personal quests can earn full rewards per day, so XP can't be
    /// farmed. Later ones earn a small flat bonus, because small progress is
    /// still progress.
    static let maxFullRewardPersonalQuestsPerDay = 3
    static let bonusXP = 10

    /// Fewer would let one main quest be finished in a single tick.
    static let minStepsPerMainQuest = 3

    static let cloaks = [
        CloakReward(level: 3, name: "Midnight cloak"),
        CloakReward(level: 5, name: "Oxblood cloak"),
        CloakReward(level: 8, name: "Plum cloak")
    ]

    static func xp(minutes: Int, difficulty: QuestDifficulty) -> Int {
        let base = minutes * 5 / 3

        switch difficulty {
        case .easy: return base
        case .moderate: return base * 2
        case .hard: return base * 3
        }
    }

    /// +1 of the quest's main attribute, whatever its difficulty.
    static func bonusAttributes(from rewards: [AttributeReward]) -> [AttributeReward] {
        rewards.prefix(1).map { AttributeReward(name: $0.name, value: 1) }
    }

    static func xpPerStep(difficulty: QuestDifficulty) -> Int {
        switch difficulty {
        case .easy: return 50
        case .moderate: return 100
        case .hard: return 150
        }
    }

    static func attributes(category: String, difficulty: QuestDifficulty) -> [AttributeReward] {
        let names: [String]

        switch category.lowercased() {
        case "development": names = ["PROBLEM SOLVING", "KNOWLEDGE"]
        case "learning": names = ["KNOWLEDGE", "DISCIPLINE"]
        case "health": names = ["DISCIPLINE"]
        case "creative", "social": names = ["CREATIVITY"]
        case "career": names = ["DISCIPLINE", "PROBLEM SOLVING"]
        default: names = ["DISCIPLINE"]
        }

        let amounts: [Int]

        switch difficulty {
        case .easy: amounts = [2, 1]
        case .moderate: amounts = [5, 2]
        case .hard: amounts = [8, 3]
        }

        return zip(names, amounts).map { AttributeReward(name: $0, value: $1) }
    }

    /// The XP needed to finish a level. Level 1 needs 500, and each one after
    /// that needs 200 more.
    static func xpNeeded(forLevel level: Int) -> Int {
        500 + 200 * (level - 1)
    }

    static func progress(totalXP: Int) -> (level: Int, xpIntoLevel: Int, xpForLevel: Int) {
        var level = 1
        var remaining = max(0, totalXP)

        while remaining >= xpNeeded(forLevel: level) {
            remaining -= xpNeeded(forLevel: level)
            level += 1
        }

        return (level, remaining, xpNeeded(forLevel: level))
    }
}
