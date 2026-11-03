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
    let iconName: String
    var category: String?
    var durationMinutes: Int?
    let xpReward: Int
    var attributeReward: String?
    var status: QuestStatusType
    var steps: [QuestStep] = []

    var completedStepCount: Int {
        steps.filter(\.isDone).count
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
