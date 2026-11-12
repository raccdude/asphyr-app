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
    @State private var questStore = QuestStore(quests: [])
    @State private var questError: String?

    /// Hides the tabs until the account's profile has loaded.
    @State private var isLoadingAccount = AccountService.isSignedIn
    @State private var accountError: String?
    @State private var loadAttempt = 0
    @State private var isSplashTapped = false
    @State private var linkError: String?

    /// What's saved to the account, so a change can be saved once.
    private var savedProfile: [String?] {
        [profile.name, profile.color.rawValue, profile.aspiration, profile.archetype?.rawValue, profile.cloak?.rawValue]
    }

    var body: some View {
        Group {
            if isLoadingAccount, let accountError {
                AccountLoadingView(errorMessage: accountError) {
                    self.accountError = nil
                    loadAttempt += 1
                } onLogOut: {
                    logOut()
                }
            } else if isLoadingAccount {
                SplashView(isReturningUser: true) {
                    isSplashTapped = true
                }
            } else if router.isInApp, questStore.isLoaded {
                MainTabView()
                    .transition(.opacity)
            } else if router.isInApp, let questError {
                AccountLoadingView(errorMessage: questError) {
                    self.questError = nil
                    loadAttempt += 1
                } onLogOut: {
                    logOut()
                }
            } else if router.isInApp {
                // After login or onboarding, while the quests load
                SplashView(isReturningUser: true)
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
        .environment(questStore)
        .environment(\.hapticsEnabled, settings.soundsAndHaptics)
        .preferredColorScheme(settings.appearance.colorScheme)
        .overlay(alignment: .top) {
            if let linkError {
                AsphyrToast(icon: "iconAlert", message: linkError)
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: linkError)
        .onOpenURL(perform: openLink)
        .task {
            // Also covers a session that can no longer be refreshed
            await AccountService.followSignOuts {
                isLoadingAccount = false
                accountError = nil
                profile.clear()
                questStore.clear()
                router.logOut()
            }
        }
        .task(id: loadAttempt) {
            await loadAccount()
        }
        // Login, onboarding and a password reset reach the tabs without loadAccount
        .task(id: QuestLoadKey(isInApp: router.isInApp, attempt: loadAttempt)) {
            await loadQuests()
        }
        .task(id: savedProfile) {
            await saveProfileChanges()
        }
        .task(id: linkError) {
            guard linkError != nil else { return }

            try? await Task.sleep(for: .seconds(4))
            if !Task.isCancelled {
                linkError = nil
            }
        }
    }

    private static let minimumSplashTime = 1.2

    private func loadAccount() async {
        guard isLoadingAccount else { return }

        do {
            let start = Date.now
            try await ProfileService.load(into: profile)
            try await questStore.loadFromServer()

            // Lets Splash's animation play, unless the user taps to move on
            while !isSplashTapped, Date.now.timeIntervalSince(start) < Self.minimumSplashTime {
                try? await Task.sleep(for: .seconds(0.05))
            }

            router.showAccount(isOnboarded: profile.isComplete)
            isLoadingAccount = false
        } catch {
            accountError = (error as? AccountError)?.message
                ?? (error as? QuestError)?.message
                ?? AccountError.unknown.message
        }
    }

    private func loadQuests() async {
        guard router.isInApp, !questStore.isLoaded, !isLoadingAccount else { return }

        do {
            try await questStore.loadFromServer()
        } catch {
            questError = (error as? QuestError)?.message ?? AccountError.unknown.message
        }
    }

    /// Onboarding saves when it finishes, so this only covers changes made in the tabs.
    private func saveProfileChanges() async {
        guard router.isInApp, !isLoadingAccount else { return }

        // Waits for a pause, so several quick changes save once
        try? await Task.sleep(for: .seconds(0.5))
        guard !Task.isCancelled else { return }

        try? await ProfileService.save(profile)
    }

    private func openLink(_ url: URL) {
        guard AccountService.isPasswordResetLink(url) else { return }

        Task {
            do {
                try await AccountService.openPasswordResetLink(url)
                accountError = nil
                isLoadingAccount = false
                router.showNewPassword()
            } catch {
                linkError = "This reset link has expired or was already used. Request a new one."
            }
        }
    }

    private func logOut() {
        isLoadingAccount = false
        accountError = nil
        questError = nil
        profile.clear()
        questStore.clear()
        router.logOut()
        Task {
            await AccountService.logOut()
        }
    }
}

/// Reloads the quests when the tabs appear, or when Try Again is tapped.
private struct QuestLoadKey: Equatable {
    let isInApp: Bool
    let attempt: Int
}

#Preview(traits: .dark) {
    RootView()
}
