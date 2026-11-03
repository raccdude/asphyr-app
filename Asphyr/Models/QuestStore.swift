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
    /// A placeholder until the real progression system exists.
    private(set) var earnedXP = 0
    /// Everything starts at 10 until the real progression system exists.
    private var attributeGains: [String: Int] = [:]

    init(quests: [Quest] = [Quest.sampleDaily]) {
        self.quests = quests
    }

    /// The level and bar on Home use a flat 500 XP per level for now.
    static let xpPerLevel = 500

    var level: Int {
        earnedXP / Self.xpPerLevel + 1
    }

    var xpIntoLevel: Int {
        earnedXP % Self.xpPerLevel
    }

    /// The quest on Home: what the user is working on, then today's daily quest,
    /// then the active main quest, then anything available. Nil once everything
    /// is finished, when Home shows its completion card.
    var homeQuest: Quest? {
        quests.first { $0.status == .active && $0.type != .mainQuest }
            ?? quests.first { $0.type == .dailyQuest && $0.status != .completed }
            ?? quests.first { $0.status == .active }
            ?? quests.first { $0.status == .available }
    }

    var completedQuests: [Quest] {
        quests.filter { $0.status == .completed }
    }

    func attributeValue(named name: String) -> Int {
        10 + attributeGains[name, default: 0]
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

    /// At most two quests can be active: the main quest plus one other.
    func canStart(_ quest: Quest) -> Bool {
        quest.type == .mainQuest || !quests.contains { $0.status == .active && $0.type != .mainQuest }
    }

    func start(_ quest: Quest) {
        guard canStart(quest) else { return }

        update(quest) { quest in
            quest.status = .active
            // Main quests go at the user's own pace, so they have no timer
            quest.startedAt = quest.durationMinutes == nil ? nil : .now
        }
    }

    func togglePause(_ quest: Quest) {
        update(quest) { quest in
            if let pausedAt = quest.pausedAt {
                quest.pausedDuration += Date.now.timeIntervalSince(pausedAt)
                quest.pausedAt = nil
            } else {
                quest.pausedAt = .now
            }
        }
    }

    /// Back to available. A main quest keeps its ticked steps and their XP.
    func abandon(_ quest: Quest) {
        update(quest) { quest in
            quest.status = .available
            quest.startedAt = nil
            quest.pausedAt = nil
            quest.pausedDuration = 0
        }
    }

    /// Each step's XP is earned when it's ticked, and lost if it's unticked.
    func toggleStep(_ step: QuestStep, in quest: Quest) {
        update(quest) { quest in
            guard let index = quest.steps.firstIndex(where: { $0.id == step.id }) else { return }

            quest.steps[index].isDone.toggle()
            earnedXP += quest.steps[index].isDone ? QuestReward.xpPerStep : -QuestReward.xpPerStep
        }
    }

    func canComplete(_ quest: Quest) -> Bool {
        quest.status == .active && quest.completedStepCount == quest.steps.count
    }

    func complete(_ quest: Quest) {
        guard canComplete(quest) else { return }

        update(quest) { quest in
            quest.status = .completed
            quest.pausedAt = quest.pausedAt ?? .now
            // Quests with steps have already earned their XP
            if quest.steps.isEmpty {
                earnedXP += quest.xpReward
            }
            for reward in quest.attributeRewards {
                attributeGains[reward.name, default: 0] += reward.value
            }
        }
    }

    private func update(_ quest: Quest, _ change: (inout Quest) -> Void) {
        guard let index = quests.firstIndex(where: { $0.id == quest.id }) else { return }
        change(&quests[index])
    }
}

extension Quest {
    /// Fixed until daily quests are generated from the aspiration and archetype.
    static let sampleDaily = Quest(
        type: .dailyQuest,
        title: "BUILD A SMALL MECHANIC",
        description: "Turn a simple idea into a working feature.",
        objective: "Implement one small gameplay mechanic in your current project.",
        iconName: "iconQuestGamepad",
        category: "DEVELOPMENT",
        difficulty: "MODERATE",
        durationMinutes: 30,
        xpReward: 100,
        attributeRewards: [
            AttributeReward(name: "CREATIVITY", value: 5),
            AttributeReward(name: "DISCIPLINE", value: 2)
        ],
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
            objective: "Implement one small gameplay mechanic in your current project.",
            iconName: "iconQuestGamepad",
            category: "DEVELOPMENT",
            difficulty: "MODERATE",
            durationMinutes: 30,
            xpReward: 100,
            attributeRewards: [
                AttributeReward(name: "CREATIVITY", value: 5),
                AttributeReward(name: "DISCIPLINE", value: 2)
            ],
            status: .active,
            startedAt: .now.addingTimeInterval(-768)
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
