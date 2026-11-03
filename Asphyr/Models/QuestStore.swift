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
    var quests: [Quest]

    init(quests: [Quest] = [Quest.sampleDaily]) {
        self.quests = quests
    }

    var todaysQuest: Quest? {
        quests.first { $0.type == .dailyQuest }
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
