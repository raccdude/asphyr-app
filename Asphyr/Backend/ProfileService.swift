//
//  ProfileService.swift
//  Asphyr
//

import Foundation
import Supabase

/// Saves the profile to the account, including the worn cloak and photo. The server
/// refuses a cloak that isn't unlocked.
enum ProfileService {
    private struct Row: Codable {
        var name: String
        var color: String
        var aspiration: String?
        var archetype: String?
        var cloak: String?
        /// Only read here. `savePhoto` sets it, once the photo is uploaded.
        var photoPath: String?

        enum CodingKeys: String, CodingKey {
            case name, color, aspiration, archetype, cloak
            case photoPath = "photo_path"
        }

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
                .select("name, color, aspiration, archetype, cloak, photo_path")
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
            // The photo isn't worth failing the launch over
            profile.photoData = nil
            if let path = row.photoPath {
                profile.photoData = try? await photos.download(path: path)
            }
        } catch {
            throw AccountError(error)
        }
    }

    private static var photos: StorageFileApi {
        Backend.client.storage.from("avatars")
    }

    /// Uploads the photo, or removes it when nil, then points the profile at it. Each
    /// person has one photo, at `<their id>/avatar.jpg`, as the server requires.
    static func savePhoto(_ data: Data?) async throws {
        struct PhotoRow: Encodable {
            let path: String?

            nonisolated func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(path, forKey: .path)
            }

            enum CodingKeys: String, CodingKey {
                case path = "photo_path"
            }
        }

        do {
            let id = try userID()
            // Matches the server's lowercase ids
            let path = "\(id.uuidString.lowercased())/avatar.jpg"

            if let data {
                _ = try await photos.upload(
                    path: path,
                    file: data,
                    options: FileOptions(contentType: "image/jpeg", upsert: true)
                )
            } else {
                _ = try await photos.remove(paths: [path])
            }

            try await Backend.client
                .from("profiles")
                .update(PhotoRow(path: data == nil ? nil : path))
                .eq("id", value: id)
                .execute()
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
