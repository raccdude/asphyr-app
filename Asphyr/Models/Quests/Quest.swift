//
//  Quest.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import Foundation

struct Quest: Identifiable {
    /// The server's id once saved. Samples and previews make their own.
    var id = UUID()
    let type: QuestType
    let title: String
    var description: String?
    var objective: String?
    let iconName: String
    var category: String?
    var difficulty: QuestDifficulty?
    var durationMinutes: Int?
    var xpReward: Int
    var attributeRewards: [AttributeReward] = []
    var status: QuestStatusType
    var steps: [QuestStep] = []
    /// The day the system made this daily quest.
    var generatedOn: Date?
    var startedAt: Date?
    var pausedAt: Date?
    var pausedDuration: TimeInterval = 0
    var completedAt: Date?
    /// True when a personal quest was completed past the daily limit, so its
    /// rewards were swapped for the flat bonus.
    var isBonusReward = false

    /// The same quest with its rewards swapped for the flat bonus.
    func withBonusReward() -> Quest {
        var quest = self
        quest.isBonusReward = true
        quest.xpReward = RewardRules.bonusXP
        quest.attributeRewards = RewardRules.bonusAttributes(from: attributeRewards)
        return quest
    }

    var completedStepCount: Int {
        steps.filter(\.isDone).count
    }

    var isPaused: Bool {
        pausedAt != nil
    }

    var hasTimer: Bool {
        status == .active && startedAt != nil && durationMinutes != nil
    }

    func elapsed(at date: Date) -> TimeInterval {
        guard let startedAt else { return 0 }
        return max(0, (pausedAt ?? date).timeIntervalSince(startedAt) - pausedDuration)
    }

    /// How long is left before a timed quest can be completed. Paused time
    /// doesn't count.
    func timeUntilCompletable(at date: Date) -> TimeInterval {
        guard hasTimer, let durationMinutes else { return 0 }
        return max(0, Double(durationMinutes * 60) * QuestReward.minimumTimeFraction - elapsed(at: date))
    }

    /// From 0 to 1.
    func timerProgress(at date: Date) -> Double {
        guard let durationMinutes else { return 0 }
        return min(1, elapsed(at: date) / Double(durationMinutes * 60))
    }

    /// The countdown, e.g. "17:12". Rounds up, so it only shows 0:00 once time's up.
    func timeLeftClock(at date: Date) -> String {
        guard let durationMinutes else { return "" }
        return max(0, Double(durationMinutes * 60) - elapsed(at: date)).rounded(.up).timerText
    }

    /// Only said when the countdown alone wouldn't explain it. Time's up takes
    /// nothing away, and the quest can still be completed.
    func timerStateText(at date: Date) -> String? {
        if isPaused { return "Paused" }
        guard let durationMinutes else { return nil }
        return elapsed(at: date) >= Double(durationMinutes * 60) ? "Time’s up" : nil
    }

    /// E.g. "17 min left", for a quest with a timer.
    func timeLeftText(at date: Date) -> String {
        guard let durationMinutes else { return "" }

        let secondsLeft = Double(durationMinutes * 60) - elapsed(at: date)
        if secondsLeft <= 0 { return "Time’s up" }
        if secondsLeft < 60 { return "Under 1 min left" }
        return "\(Int(secondsLeft / 60)) min left"
    }
}

struct AttributeReward {
    let name: String
    let value: Int

    var iconName: String {
        UserAttribute.iconNames.first { $0.name == name }?.iconName ?? "iconSparklesSmall"
    }
}

extension TimeInterval {
    /// E.g. "12:48". Minutes keep counting past an hour.
    var timerText: String {
        let totalSeconds = Int(self)
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}

struct QuestStep: Identifiable {
    var id = UUID()
    let title: String
    var isDone = false
    var doneAt: Date?
}

/// The order here is the section order in the quest log.
enum QuestType: CaseIterable {
    case mainQuest
    case dailyQuest
    case personalQuest

    /// The name the server uses.
    var serverName: String {
        switch self {
        case .mainQuest: "main"
        case .dailyQuest: "daily"
        case .personalQuest: "personal"
        }
    }

    init?(serverName: String) {
        guard let type = Self.allCases.first(where: { $0.serverName == serverName }) else { return nil }
        self = type
    }

    var title: String {
        switch self {
        case .mainQuest: "MAIN QUEST"
        case .dailyQuest: "DAILY QUEST"
        case .personalQuest: "PERSONAL QUEST"
        }
    }

    var sectionTitle: String {
        "\(title)S"
    }

    var iconName: String {
        switch self {
        case .mainQuest: "iconQuestBook"
        case .dailyQuest: "iconQuestGamepad"
        case .personalQuest: "iconQuestHammer"
        }
    }
}

enum QuestReward {
    /// The share of a quest's duration that must pass before it can be completed.
    /// Debug builds use a tiny share so the rest of the flow stays quick to test.
    #if DEBUG
    static let minimumTimeFraction = 0.01
    #else
    static let minimumTimeFraction = 0.5
    #endif
}

enum QuestStatusType: String {
    case available = "AVAILABLE"
    case active = "ACTIVE"
    case completed = "COMPLETED"
}
