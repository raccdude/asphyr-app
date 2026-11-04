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
    private(set) var earnedXP = 0
    private(set) var unlockedCloaks: [CloakReward] = []
    private(set) var earnedAchievements: Set<Achievement> = []
    /// How many Journey stars have been announced, so each shows once.
    var seenLitStarCount = 0
    /// The highest level Reward has shown, so each level is announced once.
    private var announcedLevel = 1
    /// Every attribute starts at 10.
    private var attributeGains: [String: Int] = [:]

    init(quests: [Quest] = [Quest.sampleDaily]) {
        self.quests = quests
    }

    var level: Int {
        RewardRules.progress(totalXP: earnedXP).level
    }

    var xpIntoLevel: Int {
        RewardRules.progress(totalXP: earnedXP).xpIntoLevel
    }

    var xpForLevel: Int {
        RewardRules.progress(totalXP: earnedXP).xpForLevel
    }

    /// Clears everything earned. The account, name and identity stay.
    func resetProgress() {
        quests = []
        earnedXP = 0
        unlockedCloaks = []
        earnedAchievements = []
        seenLitStarCount = 0
        announcedLevel = 1
        attributeGains = [:]
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

    /// When each finished quest was finished, which is what streaks count.
    var completionDates: [Date] {
        completedQuests.compactMap(\.completedAt)
    }

    func attributeValue(named name: String) -> Int {
        10 + attributeGains[name, default: 0]
    }

    /// Gives the user today's daily quest. A daily that's been started stays
    /// until it's finished, and completed ones stay as a record.
    func refreshDailyQuest(aspiration: String?, archetype: Archetype?, on date: Date = .now) {
        let calendar = Calendar.current
        let hasToday = quests.contains { quest in
            quest.type == .dailyQuest && quest.generatedOn.map { calendar.isDate($0, inSameDayAs: date) } ?? false
        }
        let hasActive = quests.contains { $0.type == .dailyQuest && $0.status == .active }
        guard !hasToday, !hasActive else { return }

        quests.removeAll { $0.type == .dailyQuest && $0.status == .available }
        quests.append(DailyQuests.quest(aspiration: aspiration, archetype: archetype, on: date))
    }

    /// Swaps today's daily quest after the aspiration or archetype changes. One
    /// that's been started or finished today stays, so changing them can't earn
    /// a second daily quest.
    func renewDailyQuest(aspiration: String?, archetype: Archetype?, on date: Date = .now) {
        let calendar = Calendar.current
        let isTaken = quests.contains { quest in
            guard quest.type == .dailyQuest else { return false }
            let isToday = quest.generatedOn.map { calendar.isDate($0, inSameDayAs: date) } ?? false
            return quest.status == .active || (quest.status == .completed && isToday)
        }
        guard !isTaken else { return }

        quests.removeAll { $0.type == .dailyQuest && $0.status == .available }
        quests.append(DailyQuests.quest(aspiration: aspiration, archetype: archetype, on: date))
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

    /// A main quest's XP goes with it, so deleting and recreating gains nothing.
    func delete(_ quest: Quest) {
        if quest.type == .mainQuest {
            let stepXP = RewardRules.xpPerStep(difficulty: quest.difficulty ?? .moderate)
            earnedXP = max(0, earnedXP - quest.completedStepCount * stepXP)
        }

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

    /// Unticking is always allowed. Ticking stops at the daily limit.
    func canToggle(_ step: QuestStep) -> Bool {
        step.isDone || stepsTickedToday < RewardRules.maxStepsPerDay
    }

    private var stepsTickedToday: Int {
        quests.flatMap(\.steps).filter { step in
            step.doneAt.map(Calendar.current.isDateInToday) ?? false
        }.count
    }

    /// Each step's XP is earned when it's ticked, and lost if it's unticked.
    func toggleStep(_ step: QuestStep, in quest: Quest) {
        guard canToggle(step) else { return }

        update(quest) { quest in
            guard let index = quest.steps.firstIndex(where: { $0.id == step.id }) else { return }

            quest.steps[index].isDone.toggle()
            quest.steps[index].doneAt = quest.steps[index].isDone ? .now : nil
            let stepXP = RewardRules.xpPerStep(difficulty: quest.difficulty ?? .moderate)
            earnedXP += quest.steps[index].isDone ? stepXP : -stepXP
        }
    }

    /// Personal quests past the daily limit earn the flat bonus instead.
    func canEarnFullReward(_ quest: Quest) -> Bool {
        quest.type != .personalQuest || hasFullPersonalRewardsLeft
    }

    var hasFullPersonalRewardsLeft: Bool {
        let fullRewardsToday = quests.filter { other in
            other.type == .personalQuest
                && !other.isBonusReward
                && other.completedAt.map(Calendar.current.isDateInToday) ?? false
        }
        return fullRewardsToday.count < RewardRules.maxFullRewardPersonalQuestsPerDay
    }

    /// The quest as it should be shown: an open quest past the daily limit
    /// shows the bonus it would earn now. The stored quest is unchanged.
    func withCurrentRewards(_ quest: Quest) -> Quest {
        quest.status != .completed && !canEarnFullReward(quest) ? quest.withBonusReward() : quest
    }

    func canComplete(_ quest: Quest) -> Bool {
        quest.status == .active
            && quest.completedStepCount == quest.steps.count
            && quest.timeUntilCompletable(at: .now) == 0
    }

    /// Returns what the Reward screen shows.
    func complete(_ quest: Quest) -> QuestCompletion? {
        guard canComplete(quest) else { return nil }

        let earnsFullReward = canEarnFullReward(quest)

        update(quest) { quest in
            quest.status = .completed
            quest.completedAt = .now

            if !earnsFullReward {
                quest = quest.withBonusReward()
            }

            quest.pausedAt = quest.pausedAt ?? .now
            // Quests with steps have already earned their XP
            if quest.steps.isEmpty {
                earnedXP += quest.xpReward
            }
            for reward in quest.attributeRewards {
                attributeGains[reward.name, default: 0] += reward.value
            }
        }

        guard let completed = quests.first(where: { $0.id == quest.id }) else { return nil }

        // Every cloak the level has reached, so one reached by ticking steps
        // isn't lost if that main quest is later deleted
        let newCloaks = RewardRules.cloaks.filter { $0.level <= level && !unlockedCloaks.contains($0) }
        unlockedCloaks += newCloaks

        earnedAchievements.formUnion(Achievement.earned(
            completionDates: completionDates,
            level: level,
            knowledge: attributeValue(named: "KNOWLEDGE"),
            problemSolving: attributeValue(named: "PROBLEM SOLVING")
        ))

        let levelBefore = announcedLevel
        announcedLevel = max(announcedLevel, level)

        return QuestCompletion(
            quest: completed,
            elapsed: completed.elapsed(at: .now),
            levelBefore: levelBefore,
            levelAfter: level,
            xpIntoLevel: xpIntoLevel,
            xpForLevel: xpForLevel,
            newCloaks: newCloaks
        )
    }

    private func update(_ quest: Quest, _ change: (inout Quest) -> Void) {
        guard let index = quests.firstIndex(where: { $0.id == quest.id }) else { return }
        change(&quests[index])
    }
}

struct QuestCompletion: Identifiable {
    let id = UUID()
    let quest: Quest
    let elapsed: TimeInterval
    let levelBefore: Int
    let levelAfter: Int
    let xpIntoLevel: Int
    let xpForLevel: Int
    let newCloaks: [CloakReward]

    var didLevelUp: Bool {
        levelAfter > levelBefore
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
        difficulty: .moderate,
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
            difficulty: .moderate,
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
            difficulty: .moderate,
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
