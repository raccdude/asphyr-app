//
//  AppRouter.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import Observation

/// Screens pushed onto the root stack.
enum AuthRoute: Hashable {
    case welcome
    case createAccount
    case login
    case recover
    case recoverySuccess(email: String)
    case identity
    case archetype
}

/// Owns the root stack's path, so every screen shares one source of truth.
@Observable
final class AppRouter {
    var path: [AuthRoute] = []
    /// True once sign-up or login finishes, which swaps the root to the tabs.
    private(set) var isInApp = false

    /// Ignored when `route` is already on top, so a double tap pushes once.
    func push(_ route: AuthRoute) {
        guard path.last != route else { return }
        path.append(route)
    }

    /// Replaces the top screen, so Login and Create Account swap in place
    /// instead of stacking on each other.
    func switchTo(_ route: AuthRoute) {
        _ = path.popLast()
        path.append(route)
    }

    /// Replaces the auth stack with the tabs, so there's no way back to it.
    func enterApp() {
        isInApp = true
        path = []
    }

    /// Returns to the Login screen already on the stack.
    func popToLogin() {
        guard let index = path.lastIndex(of: .login) else { return }
        path.removeSubrange((index + 1)...)
    }
}
