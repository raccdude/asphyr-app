//
//  QuestStore.swift
//  Asphyr
//

import Foundation

/// The quests shared by Home and the quest log. Kept in memory until a backend
/// exists, so they reset when the app relaunches. Everyone starts with only the
/// daily quest, because main and personal quests are created by the user.
@Observable
final class QuestStore {
    static let maxOpenPersonalQuests = 5

    var quests: [Quest]

    init(quests: [Quest] = [Quest.sampleDaily]) {
        self.quests = quests
    }

    var todaysQuest: Quest? {
        quests.first { $0.type == .dailyQuest }
    }

    /// Whether another quest of this type can be created. One main quest and
    /// a limited number of personal quests can be open at a time.
    func canCreate(_ type: QuestType) -> Bool {
        let openCount = quests.filter { $0.type == type && $0.status != .completed }.count

        switch type {
        case .mainQuest: return openCount < 1
        case .personalQuest: return openCount < Self.maxOpenPersonalQuests
        case .dailyQuest: return false
        }
    }

    /// Daily quests renew on their own, and completed quests stay as a record.
    func canDelete(_ quest: Quest) -> Bool {
        quest.type != .dailyQuest && quest.status != .completed
    }

    func delete(_ quest: Quest) {
        quests.removeAll { $0.id == quest.id }
    }
}

extension Quest {
    /// Fixed until daily quests are generated from the aspiration and archetype.
    static let sampleDaily = Quest(
        type: .dailyQuest,
        title: "BUILD A SMALL MECHANIC",
        description: "Turn a simple idea into a working feature.",
        iconName: "iconQuestGamepad",
        category: "DEVELOPMENT",
        durationMinutes: 30,
        xpReward: 100,
        attributeReward: "+5 CREATIVITY",
        status: .available
    )

    /// Figma's full quest log, for previews.
    static let samples = [
        Quest(
            type: .mainQuest,
            title: "STUDY MIDTERM",
            iconName: "iconQuestBook",
            xpReward: 500,
            status: .active,
            steps: [
                QuestStep(title: "Study Figma", isDone: true),
                QuestStep(title: "Review Input Components", isDone: true),
                QuestStep(title: "Practice Coding"),
                QuestStep(title: "Learn MVVM"),
                QuestStep(title: "Implement New Features")
            ]
        ),
        Quest(
            type: .dailyQuest,
            title: "BUILD A SMALL MECHANIC",
            description: "Turn a simple idea into a working feature.",
            iconName: "iconQuestGamepad",
            category: "DEVELOPMENT",
            durationMinutes: 30,
            xpReward: 100,
            attributeReward: "+5 CREATIVITY",
            status: .active
        ),
        Quest(
            type: .personalQuest,
            title: "BUILD PORTFOLIO",
            description: "Develop using SwiftUI",
            iconName: "iconQuestHammer",
            xpReward: 75,
            status: .available
        ),
        Quest(
            type: .personalQuest,
            title: "STUDY PHYSICS",
            description: "Learn fundamentals",
            iconName: "iconQuestAtom",
            xpReward: 50,
            status: .available
        )
    ]
}
