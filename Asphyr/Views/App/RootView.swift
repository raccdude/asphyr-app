//
//  RootView.swift
//  Asphyr
//
//  Created by Angelo Buedo on 11/2/26.
//

import SwiftUI

/// The root `NavigationStack` for auth and onboarding, swapped for the tabs
/// once they finish. Pushed screens should not create their own stack.
struct RootView: View {
    @State private var router = AppRouter(isSignedIn: AccountService.isSignedIn)
    @State private var profile = OnboardingProfile()
    @State private var settings = AppSettings()

    var body: some View {
        Group {
            if router.isInApp {
                MainTabView()
                    .transition(.opacity)
            } else {
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
                            case .newPassword:
                                SetNewPasswordView()
                            }
                        }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: router.isInApp)
        .environment(router)
        .environment(profile)
        .environment(settings)
        .environment(\.hapticsEnabled, settings.soundsAndHaptics)
        .preferredColorScheme(settings.appearance.colorScheme)
        .onOpenURL { url in
            AccountService.handle(url)
        }
        .task {
            if let email = AccountService.currentEmail {
                profile.email = email
            }
            await AccountService.followEvents {
                router.showNewPassword()
            } onSignedOut: {
                // Also covers a session that can no longer be refreshed
                profile.clear()
                router.logOut()
            }
        }
    }
}

#Preview(traits: .dark) {
    RootView()
}
