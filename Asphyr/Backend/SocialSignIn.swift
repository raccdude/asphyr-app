//
//  SocialSignIn.swift
//  Asphyr
//

import AuthenticationServices
import Foundation
import Supabase
import UIKit

enum SocialProvider {
    case apple
    case google
}

/// Sign in with Apple and Google. Both create the account the first time, then the
/// usual profile load decides between onboarding and the tabs.
///
/// Neither works until it's set up: Apple needs the paid Apple Developer account and
/// the Sign in with Apple capability, and Google needs a Google Cloud project. Both then
/// need their provider turned on in Supabase. See docs/BACKEND-SPEC.md, Step 6 notes.
enum SocialSignIn {
    /// Where Google's sign-in page returns to. Must be in Supabase's redirect URLs.
    static let callbackURL = URL(string: "asphyr://login-callback")!

    /// Returns false if the user cancelled, so nothing needs saying. Every other
    /// failure is thrown as an `AccountError`.
    static func signIn(with provider: SocialProvider) async throws -> Bool {
        do {
            switch provider {
            case .apple:
                try await signInWithApple()
            case .google:
                _ = try await Backend.client.auth.signInWithOAuth(provider: .google, redirectTo: callbackURL)
            }
            return true
        } catch {
            if isCancellation(error) {
                return false
            }
            throw accountError(error)
        }
    }

    private static func signInWithApple() async throws {
        let credential = try await AppleSignInRequest().run()

        guard let idToken = credential.identityToken.flatMap({ String(data: $0, encoding: .utf8) }) else {
            throw AccountError.unknown
        }

        _ = try await Backend.client.auth.signInWithIdToken(
            credentials: OpenIDConnectCredentials(provider: .apple, idToken: idToken)
        )
    }

    private static func isCancellation(_ error: Error) -> Bool {
        if let error = error as? ASAuthorizationError {
            return error.code == .canceled
        }
        if let error = error as? ASWebAuthenticationSessionError {
            return error.code == .canceledLogin
        }
        return false
    }

    private static func accountError(_ error: Error) -> AccountError {
        // Apple's sheet fails this way when the app lacks the capability
        if error is ASAuthorizationError {
            return .signInUnavailable
        }
        if let error = error as? AuthError, error.errorCode.rawValue == "provider_disabled" {
            return .signInUnavailable
        }
        return AccountError(error)
    }
}

/// Shows Apple's sign-in sheet and waits for the answer.
private final class AppleSignInRequest: NSObject, ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding {
    private var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?

    func run() async throws -> ASAuthorizationAppleIDCredential {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            continuation?.resume(returning: credential)
        } else {
            continuation?.resume(throwing: ASAuthorizationError(.unknown))
        }
        continuation = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow) ?? ASPresentationAnchor()
    }
}
