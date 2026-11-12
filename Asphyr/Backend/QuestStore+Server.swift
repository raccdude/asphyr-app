//
//  QuestStore+Server.swift
//  Asphyr
//

import Foundation

/// The app's quest actions. Each asks the server, which checks the rules with its own
/// clock, and the store updates from the reply. Every failure is thrown as a
/// `QuestError`, and one tap at a time is sent.
extension QuestStore {
    func loadFromServer() async throws {
        load(try await QuestService.playerState())
    }

    func createQuest(
        type: QuestType,
        title: String,
        description: String?,
        category: String,
        durationMinutes: Int?,
        steps: [String]
    ) async throws {
        try await send {
            try await QuestService.create(
                type: type,
                title: title,
                description: description,
                category: category,
                durationMinutes: durationMinutes,
                steps: steps
            )
        }
    }

    func startQuest(_ quest: Quest) async throws {
        try await send { try await QuestService.start(quest.id) }
    }

    func togglePauseQuest(_ quest: Quest) async throws {
        try await send { try await QuestService.pause(quest.id, paused: !quest.isPaused) }
    }

    func abandonQuest(_ quest: Quest) async throws {
        try await send { try await QuestService.abandon(quest.id) }
    }

    func toggleStepOnServer(_ step: QuestStep) async throws {
        try await send { try await QuestService.setStep(step.id, done: !step.isDone) }
    }

    /// Returns what the Reward screen shows.
    func completeQuest(_ quest: Quest) async throws -> QuestCompletion? {
        let reply = try await send { try await QuestService.complete(quest.id) }
        guard let reward = reply.reward, let record = reply.quest else { return nil }
        return completion(from: reward, quest: Quest(record: record))
    }

    func deleteQuest(_ quest: Quest) async throws {
        try await send { try await QuestService.delete(quest.id) }
        remove(questID: quest.id)
    }

    func resetProgressOnServer() async throws {
        try await send { try await QuestService.resetProgress() }
        quests = []
    }

    /// Asks for today's daily quest. Skipped when one is already here, so coming back
    /// to the app doesn't wait on the network.
    func refreshDailyQuestOnServer(aspiration: String?, archetype: Archetype?) async throws {
        let calendar = Calendar.current
        let hasToday = quests.contains { quest in
            quest.type == .dailyQuest && quest.generatedOn.map { calendar.isDateInToday($0) } ?? false
        }
        let hasActive = quests.contains { $0.type == .dailyQuest && $0.status == .active }
        guard isLoaded, !hasToday, !hasActive else { return }

        let daily = DailyQuests.quest(aspiration: aspiration, archetype: archetype, on: .now)
        try await send { try await QuestService.giveDailyQuest(daily, replace: false) }
    }

    /// Swaps today's daily quest after the aspiration or archetype changes. The
    /// profile must be saved first, as the server reads the archetype from it.
    func renewDailyQuestOnServer(aspiration: String?, archetype: Archetype?) async throws {
        let daily = DailyQuests.quest(aspiration: aspiration, archetype: archetype, on: .now)
        try await send { try await QuestService.giveDailyQuest(daily, replace: true) }
    }

    /// Spends Embers on a cloak from the store. The server checks the price and balance.
    func buyCloak(_ name: String) async throws {
        try await send { try await QuestService.buyCloak(name) }
    }

    /// Display only, so it's sent without waiting and a failure is ignored.
    func markJourneySeen(litStarCount: Int) {
        seenLitStarCount = litStarCount
        Task {
            if let reply = try? await QuestService.markJourneySeen(litStarCount: litStarCount) {
                apply(reply.player)
            }
        }
    }

    @discardableResult
    private func send(_ action: () async throws -> QuestReply) async throws -> QuestReply {
        guard !isBusy else { throw QuestError.busy }
        isBusy = true
        defer { isBusy = false }

        do {
            let reply = try await action()
            if let quest = reply.quest {
                apply(quest)
            }
            apply(reply.player)
            return reply
        } catch {
            let error = QuestError(error)
            // The device was out of step with the server, so catch up
            let outOfStep: [QuestError] = [.notFound, .notAllowed, .limitReached, .tooSoon, .notEnoughEmbers]
            if outOfStep.contains(error) {
                try? await loadFromServer()
            }
            throw error
        }
    }
}
