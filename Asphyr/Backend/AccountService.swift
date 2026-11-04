//
//  AccountService.swift
//  Asphyr
//

import Foundation
import Supabase

/// The connection to Supabase. The publishable key is designed to ship in apps, and
/// security rules protect the data. Secret keys must never go in the app or the repo.
enum Backend {
    static let passwordResetURL = URL(string: "asphyr://reset-password")!

    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://qnotkiivqelufrqcnquu.supabase.co")!,
        supabaseKey: "sb_publishable_UFvvONfMYxfmu-GWjQj6yg_hYfNEwcJ",
        options: SupabaseClientOptions(
            auth: .init(redirectToURL: passwordResetURL, emitLocalSessionAsInitialSession: true)
        )
    )
}

/// What can go wrong with an account action, in words for the screen.
enum AccountError: Error, Equatable {
    case invalidCredentials
    case emailTaken
    case weakPassword
    case samePassword
    case tooManyAttempts
    case noConnection
    case unknown

    init(_ error: Error) {
        if let error = error as? AccountError {
            self = error
            return
        }

        if error is URLError {
            self = .noConnection
            return
        }

        guard let error = error as? AuthError else {
            self = .unknown
            return
        }

        switch error.errorCode {
        case .invalidCredentials: self = .invalidCredentials
        case .emailExists, .userAlreadyExists: self = .emailTaken
        case .weakPassword: self = .weakPassword
        case .samePassword: self = .samePassword
        case .overRequestRateLimit, .overEmailSendRateLimit: self = .tooManyAttempts
        default: self = .unknown
        }
    }

    var message: String {
        switch self {
        case .invalidCredentials: "Incorrect email or password. Try again."
        case .emailTaken: "This email already has an account. Try logging in."
        case .weakPassword: "Choose a stronger password."
        case .samePassword: "Choose a different password from your current one."
        case .tooManyAttempts: "Too many attempts. Wait a moment and try again."
        case .noConnection: "No connection. Check your internet and try again."
        case .unknown: "Something went wrong. Try again."
        }
    }
}

/// Sign-up, login, logout and password reset. Every failure is thrown as an `AccountError`.
enum AccountService {
    /// Read from the device, so it's ready before the first screen. The session
    /// refreshes itself, and an event signs the user out if that fails.
    static var currentEmail: String? {
        Backend.client.auth.currentSession?.user.email
    }

    static var isSignedIn: Bool {
        Backend.client.auth.currentSession != nil
    }

    /// Runs for as long as the app is open.
    static func followSignOuts(_ onSignedOut: () -> Void) async {
        for await (event, _) in Backend.client.auth.authStateChanges where event == .signedOut {
            onSignedOut()
        }
    }

    static func signUp(email: String, password: String) async throws {
        try await perform {
            try await Backend.client.auth.signUp(email: email, password: password)
        }
    }

    static func logIn(email: String, password: String) async throws {
        try await perform {
            try await Backend.client.auth.signIn(email: email, password: password)
        }
    }

    /// Clears the session on this device, so it works without a connection.
    static func logOut() async {
        try? await Backend.client.auth.signOut(scope: .local)
    }

    static func sendPasswordReset(email: String) async throws {
        try await perform {
            try await Backend.client.auth.resetPasswordForEmail(email, redirectTo: Backend.passwordResetURL)
        }
    }

    static func updatePassword(_ password: String) async throws {
        try await perform {
            try await Backend.client.auth.update(user: UserAttributes(password: password))
        }
    }

    static func isPasswordResetLink(_ url: URL) -> Bool {
        url.scheme == Backend.passwordResetURL.scheme && url.host == Backend.passwordResetURL.host
    }

    /// Signs in from a reset link. This kind of link doesn't send a password recovery
    /// event, so the caller opens the new password screen when this succeeds.
    static func openPasswordResetLink(_ url: URL) async throws {
        try await perform {
            try await Backend.client.auth.session(from: url)
        }
    }

    private static func perform<T>(_ action: () async throws -> T) async throws {
        do {
            _ = try await action()
        } catch {
            throw AccountError(error)
        }
    }
}
