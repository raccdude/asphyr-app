//
//  SocialSignIn.swift
//  Asphyr
//

import AuthenticationServices
import Foundation
import Supabase

enum SocialProvider {
    case google
}

/// Google sign-in. It creates the account the first time, then the usual profile load
/// decides between onboarding and the tabs. Apple sign-in was removed on 12 Nov 2026
/// at the developer's request.
///
/// It doesn't work until it's set up: a Google Cloud project, then the Google provider
/// turned on in Supabase. See docs/BACKEND-SPEC.md, Step 6 notes.
enum SocialSignIn {
    /// Where Google's sign-in page returns to. Must be in Supabase's redirect URLs.
    static let callbackURL = URL(string: "asphyr://login-callback")!

    /// Returns false if the user cancelled, so nothing needs saying. Every other
    /// failure is thrown as an `AccountError`.
    static func signIn(with provider: SocialProvider) async throws -> Bool {
        // Supabase answers a turned-off provider with an error page the sign-in sheet
        // can't show, which looked like the button did nothing. Ask first instead.
        guard await isEnabled(provider) else {
            throw AccountError.signInUnavailable
        }

        do {
            switch provider {
            case .google:
                _ = try await Backend.client.auth.signInWithOAuth(provider: .google, redirectTo: callbackURL)
            }
            return true
        } catch {
            if let error = error as? ASWebAuthenticationSessionError, error.code == .canceledLogin {
                return false
            }
            if let error = error as? AuthError, error.errorCode.rawValue == "provider_disabled" {
                throw AccountError.signInUnavailable
            }
            throw AccountError(error)
        }
    }

    /// Part of Supabase Auth's public settings: which sign-in providers are turned on.
    private struct AuthSettings: Decodable {
        struct Providers: Decodable {
            let google: Bool?
        }

        let external: Providers
    }

    /// If the settings can't be read, this says yes and lets the sign-in itself report
    /// what's wrong.
    private static func isEnabled(_ provider: SocialProvider) async -> Bool {
        var request = URLRequest(url: Backend.projectURL.appendingPathComponent("auth/v1/settings"))
        request.setValue(Backend.publishableKey, forHTTPHeaderField: "apikey")
        request.timeoutInterval = 10

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let settings = try? JSONDecoder().decode(AuthSettings.self, from: data) else {
            return true
        }

        switch provider {
        case .google: return settings.external.google ?? false
        }
    }
}
