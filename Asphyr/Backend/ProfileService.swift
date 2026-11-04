//
//  ProfileService.swift
//  Asphyr
//

import Foundation
import Supabase

/// Saves the profile to the account. The worn cloak and photo aren't saved yet: cloaks are
/// unlocked on the device until backend step 4, and photos come in step 5.
enum ProfileService {
    private struct Row: Codable {
        var name: String
        var color: String
        var aspiration: String?
        var archetype: String?
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
                .select("name, color, aspiration, archetype")
                .eq("id", value: try userID())
                .single()
                .execute()
                .value

            profile.name = row.name
            profile.color = CharacterColor(rawValue: row.color) ?? .green
            profile.aspiration = row.aspiration
            profile.archetype = row.archetype.flatMap(Archetype.init(rawValue:))
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
            archetype: profile.archetype?.rawValue
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
