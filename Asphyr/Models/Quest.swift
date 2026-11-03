//
//  Quest.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import Foundation

struct Quest: Identifiable {
    let id = UUID()
    let type: QuestType
    let title: String
    var description: String?
    var objective: String?
    let iconName: String
    var category: String?
    var difficulty: String?
    var durationMinutes: Int?
    let xpReward: Int
    var attributeRewards: [AttributeReward] = []
    var status: QuestStatusType
    var steps: [QuestStep] = []
    var startedAt: Date?
    var pausedAt: Date?
    var pausedDuration: TimeInterval = 0

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

    /// From 0 to 1.
    func timerProgress(at date: Date) -> Double {
        guard let durationMinutes else { return 0 }
        return min(1, elapsed(at: date) / Double(durationMinutes * 60))
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
}

extension TimeInterval {
    /// E.g. "12:48". Minutes keep counting past an hour.
    var timerText: String {
        let totalSeconds = Int(self)
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}

struct QuestStep: Identifiable {
    let id = UUID()
    let title: String
    var isDone = false
}

/// The order here is the section order in the quest log.
enum QuestType: CaseIterable {
    case mainQuest
    case dailyQuest
    case personalQuest

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

/// A placeholder until rewards are inferred from the duration and difficulty.
enum QuestReward {
    static let xpPerStep = 100

    static func xp(forMinutes minutes: Int) -> Int {
        minutes * 5 / 3
    }

    /// Main quests have no duration, so their steps make up the total.
    static func xp(forStepCount stepCount: Int) -> Int {
        stepCount * xpPerStep
    }
}

enum QuestStatusType: String {
    case available = "AVAILABLE"
    case active = "ACTIVE"
    case completed = "COMPLETED"
}
