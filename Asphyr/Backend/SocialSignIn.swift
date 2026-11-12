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
}
