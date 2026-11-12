//
//  ProfileService.swift
//  Asphyr
//

import Foundation
import Supabase

/// Saves the profile to the account, including the worn cloak. The server refuses a
/// cloak that isn't unlocked. Photos come in step 5.
enum ProfileService {
    private struct Row: Codable {
        var name: String
        var color: String
        var aspiration: String?
        var archetype: String?
        var cloak: String?

        /// Writes empty answers as null, so clearing one clears it on the server.
        nonisolated func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(color, forKey: .color)
            try container.encode(aspiration, forKey: .aspiration)
            try container.encode(archetype, forKey: .archetype)
            try container.encode(cloak, forKey: .cloak)
        }
    }

    private static func userID() throws -> UUID {
        guard let id = Backend.client.auth.currentSession?.user.id else {
            throw AccountError.unknown
        }
        return id
    }

    /// Fills in the profile from the account.
    static func load(into profile: OnboardingProfile) async throws {
        do {
            let row: Row = try await Backend.client
                .from("profiles")
                .select("name, color, aspiration, archetype, cloak")
                .eq("id", value: try userID())
                .single()
                .execute()
                .value

            profile.name = row.name
            profile.color = CharacterColor(rawValue: row.color) ?? .green
            profile.aspiration = row.aspiration
            profile.archetype = row.archetype.flatMap(Archetype.init(rawValue:))
            profile.cloak = row.cloak.flatMap(CharacterCloak.init(rawValue:))
            profile.email = AccountService.currentEmail ?? ""
        } catch {
            throw AccountError(error)
        }
    }

    static func save(_ profile: OnboardingProfile) async throws {
        let row = Row(
            name: profile.name,
            color: profile.color.rawValue,
            aspiration: profile.aspiration,
            archetype: profile.archetype?.rawValue,
            cloak: profile.cloak?.rawValue
        )

        do {
            try await Backend.client
                .from("profiles")
                .update(row)
                .eq("id", value: try userID())
                .execute()
        } catch {
            throw AccountError(error)
        }
    }
}
