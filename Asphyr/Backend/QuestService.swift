//
//  QuestService.swift
//  Asphyr
//

import Foundation
import Supabase

/// What can go wrong with a quest action, in words for the screen. The server
/// raises these as short codes. See `supabase/migrations`.
enum QuestError: Error, Equatable {
    case notSignedIn
    case notFound
    case invalidInput
    case notAllowed
    case limitReached
    case tooSoon
    case busy
    case noConnection
    case unknown

    init(_ error: Error) {
        if let error = error as? QuestError {
            self = error
            return
        }

        if error is URLError {
            self = .noConnection
            return
        }

        guard let error = error as? PostgrestError else {
            self = .unknown
            return
        }

        switch error.message {
        case "not_signed_in": self = .notSignedIn
        case "not_found": self = .notFound
        case "invalid_input": self = .invalidInput
        case "not_allowed": self = .notAllowed
        case "limit_reached": self = .limitReached
        case "too_soon": self = .tooSoon
        default: self = .unknown
        }
    }

    /// Nil when there's nothing to tell the user.
    var message: String? {
        switch self {
        case .notSignedIn: "You were signed out. Log in again."
        case .notFound: "This quest no longer exists."
        case .invalidInput: "Check the quest’s details and try again."
        case .notAllowed: "This quest has changed. Check it and try again."
        case .limitReached: "That’s today’s limit. More tomorrow."
        case .tooSoon: "Keep going a little longer first."
        case .busy: nil
        case .noConnection: AccountError.noConnection.message
        case .unknown: AccountError.unknown.message
        }
    }
}

/// Calls the server functions, which check every quest and reward rule with the
/// server's clock. Every failure is thrown as a `QuestError`.
enum QuestService {
    /// Also saves the phone's time zone, which the daily limits count from.
    static func playerState() async throws -> PlayerStateRecord {
        try await call("get_player_state", ["p_time_zone": .string(TimeZone.current.identifier)])
    }

    static func create(
        type: QuestType,
        title: String,
        description: String?,
        category: String,
        durationMinutes: Int?,
        steps: [String]
    ) async throws -> QuestReply {
        try await call("create_quest", [
            "p_type": .string(type.serverName),
            "p_title": .string(title),
            "p_description": description.map(AnyJSON.string) ?? .null,
            "p_category": .string(category),
            "p_duration_minutes": durationMinutes.map(AnyJSON.integer) ?? .null,
            "p_steps": type == .mainQuest ? .array(steps.map(AnyJSON.string)) : .null
        ])
    }

    static func start(_ questID: UUID) async throws -> QuestReply {
        try await call("start_quest", ["p_quest": .string(questID.uuidString)])
    }

    static func pause(_ questID: UUID, paused: Bool) async throws -> QuestReply {
        try await call("pause_quest", ["p_quest": .string(questID.uuidString), "p_paused": .bool(paused)])
    }

    static func abandon(_ questID: UUID) async throws -> QuestReply {
        try await call("abandon_quest", ["p_quest": .string(questID.uuidString)])
    }

    static func setStep(_ stepID: UUID, done: Bool) async throws -> QuestReply {
        try await call("set_step_done", ["p_step": .string(stepID.uuidString), "p_done": .bool(done)])
    }

    static func complete(_ questID: UUID) async throws -> QuestReply {
        try await call("complete_quest", ["p_quest": .string(questID.uuidString)])
    }

    static func delete(_ questID: UUID) async throws -> QuestReply {
        try await call("delete_quest", ["p_quest": .string(questID.uuidString)])
    }

    /// The app writes the daily quest's words, and the server sets its rewards.
    /// `replace` swaps an untouched one after the aspiration or archetype changes.
    static func giveDailyQuest(_ quest: Quest, replace: Bool) async throws -> QuestReply {
        try await call(replace ? "renew_daily_quest" : "refresh_daily_quest", [
            "p_title": .string(quest.title),
            "p_description": quest.description.map(AnyJSON.string) ?? .null,
            "p_objective": quest.objective.map(AnyJSON.string) ?? .null,
            "p_icon_name": .string(quest.iconName),
            "p_category": .string(quest.category ?? "Other")
        ])
    }

    static func markJourneySeen(litStarCount: Int) async throws -> QuestReply {
        try await call("mark_journey_seen", ["p_lit_star_count": .integer(litStarCount)])
    }

    static func resetProgress() async throws -> QuestReply {
        try await call("reset_progress", [:])
    }

    private static func call<Reply: Decodable>(_ function: String, _ params: [String: AnyJSON]) async throws -> Reply {
        do {
            let response = try await Backend.client.rpc(function, params: params).execute()
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(Reply.self, from: response.data)
        } catch {
            throw QuestError(error)
        }
    }
}
