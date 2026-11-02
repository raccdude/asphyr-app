//
//  RootView.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import SwiftUI

/// The app's one root `NavigationStack`. Pushed screens should not create
/// their own stack.
struct RootView: View {
    @State private var router = AppRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            SplashView()
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .welcome:
                        WelcomeView()
                    case .createAccount:
                        CreateAccountView()
                    case .login:
                        LoginView()
                    case .recover:
                        RecoverAccountView()
                    case .recoverySuccess(let email):
                        RecoverySuccessView(email: email)
                    case .identity:
                        IdentityCreationView()
                    case .archetype:
                        ArchetypeSelectionView()
                    case .home:
                        HomeView()
                    }
                }
        }
        .environment(router)
    }
}

#Preview {
    RootView()
}
