//
//  QuestRecords.swift
//  Asphyr
//

import Foundation

/// What the server's quest functions send back. The shapes are built in
/// `supabase/migrations`, and decoded with snake_case keys converted to camelCase.
/// Times are seconds since 1970.
struct QuestRecord: Decodable {
    struct Step: Decodable {
        let id: UUID
        let position: Int
        let title: String
        let doneAt: Double?
    }

    struct Attribute: Decodable {
        let name: String
        let value: Int
    }

    let id: UUID
    let type: String
    let title: String
    let description: String?
    let objective: String?
    let iconName: String
    let category: String?
    let difficulty: String?
    let durationMinutes: Int?
    let xpReward: Int
    let attributeRewards: [Attribute]
    let status: String
    /// The user's own day, e.g. "2026-11-12".
    let generatedOn: String?
    let startedAt: Double?
    let pausedAt: Double?
    let pausedDuration: Double
    let completedAt: Double?
    let isBonusReward: Bool
    let steps: [Step]
}

struct PlayerRecord: Decodable {
    let earnedXp: Int
    let attributeGains: [String: Int]
    let announcedLevel: Int
    let seenLitStarCount: Int
    /// E.g. "Midnight".
    let unlockedCloaks: [String]
    /// The `Achievement` case names, e.g. "firstQuest".
    let earnedAchievements: [String]
    /// Optional, so a reply from before the Store still decodes.
    let embers: Int?
    /// Every cloak owned, level and bought, e.g. "Green".
    let ownedCloaks: [String]?
}

/// A cloak for sale, e.g. Green at 200 Embers.
struct StoreItemRecord: Decodable, Equatable {
    let item: String
    let price: Int
}

struct RewardRecord: Decodable {
    let elapsedSeconds: Double
    let levelBefore: Int
    let levelAfter: Int
    let xpIntoLevel: Int
    let xpForLevel: Int
    let newCloaks: [String]
    let embersEarned: Int?
}

/// The reply to every quest action. `quest` is nil when nothing was added or the
/// quest was deleted, and `reward` is only sent when a quest is completed.
struct QuestReply: Decodable {
    let quest: QuestRecord?
    let player: PlayerRecord
    let reward: RewardRecord?
}

struct PlayerStateRecord: Decodable {
    let quests: [QuestRecord]
    let player: PlayerRecord
    let store: [StoreItemRecord]?
}

extension Quest {
    init(record: QuestRecord) {
        self.init(
            id: record.id,
            type: QuestType(serverName: record.type) ?? .personalQuest,
            title: record.title,
            description: record.description,
            objective: record.objective,
            iconName: record.iconName,
            category: record.category,
            difficulty: record.difficulty.flatMap(QuestDifficulty.init(rawValue:)),
            durationMinutes: record.durationMinutes,
            xpReward: record.xpReward,
            attributeRewards: record.attributeRewards.map { AttributeReward(name: $0.name, value: $0.value) },
            status: QuestStatusType(rawValue: record.status) ?? .available,
            steps: record.steps.sorted { $0.position < $1.position }.map { step in
                QuestStep(
                    id: step.id,
                    title: step.title,
                    isDone: step.doneAt != nil,
                    doneAt: step.doneAt.map(Date.init(timeIntervalSince1970:))
                )
            },
            generatedOn: record.generatedOn.flatMap(Self.serverDay),
            startedAt: record.startedAt.map(Date.init(timeIntervalSince1970:)),
            pausedAt: record.pausedAt.map(Date.init(timeIntervalSince1970:)),
            pausedDuration: record.pausedDuration,
            completedAt: record.completedAt.map(Date.init(timeIntervalSince1970:)),
            isBonusReward: record.isBonusReward
        )
    }

    /// The server counts days in the phone's time zone, so its date is the start of
    /// that day here.
    private static func serverDay(_ text: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: text)
    }
}

extension Achievement {
    init?(serverName: String) {
        guard let achievement = Self.allCases.first(where: { "\($0)" == serverName }) else { return nil }
        self = achievement
    }
}

extension CloakReward {
    /// The server names cloaks by color, e.g. "Midnight" for the Midnight cloak.
    init?(serverName: String) {
        guard let cloak = RewardRules.cloaks.first(where: { $0.name == "\(serverName) cloak" }) else { return nil }
        self = cloak
    }
}
