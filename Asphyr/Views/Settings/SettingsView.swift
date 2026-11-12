//
//  SettingsView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/17/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(AppRouter.self) private var router
    @Environment(OnboardingProfile.self) private var profile
    @Environment(QuestStore.self) private var questStore

    @State private var isShowingAppearance = false
    @State private var isShowingReset = false
    @State private var isShowingLogOut = false
    @State private var isShowingDeleteAccount = false
    @State private var toast: String?

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var identityLine: String? {
        let parts = [profile.archetype.map { "The \($0.title)" }, profile.aspiration].compactMap(\.self)
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    var body: some View {
        @Bindable var settings = settings

        ZStack {
            Color.asphyrBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    profileCard

                    SectionDivider(sectionTitle: "GENERAL")
                        .padding(.top, 26)

                    VStack(spacing: 0) {
                        NavigationLink {
                            NotificationsView()
                        } label: {
                            SettingsRow(icon: "iconSettingsBell", title: "Notifications") {
                                SettingsDisclosure(value: settings.pushNotifications ? "On" : "Off")
                            }
                        }
                        .buttonStyle(.plain)

                        SettingsRowDivider()

                        Button {
                            isShowingAppearance = true
                        } label: {
                            SettingsRow(icon: "iconSettingsMoon", title: "Appearance") {
                                SettingsDisclosure(value: settings.appearance.rawValue)
                            }
                        }
                        .buttonStyle(.plain)

                        SettingsRowDivider()

                        SettingsRow(
                            icon: "iconSettingsFlame",
                            title: "Streaks",
                            subtitle: "Optional. Never affects XP or levels."
                        ) {
                            SettingsToggle(title: "Streaks", isOn: $settings.showsStreaks)
                        }

                        SettingsRowDivider()

                        SettingsRow(icon: "iconSettingsPhone", title: "Sounds & haptics") {
                            SettingsToggle(title: "Sounds & haptics", isOn: $settings.soundsAndHaptics)
                        }
                    }
                    .settingsCard()
                    .padding(.top, 12)

                    SectionDivider(sectionTitle: "PROGRESS & ACCOUNT")
                        .padding(.top, 26)

                    VStack(spacing: 0) {
                        Button {
                            isShowingLogOut = true
                        } label: {
                            SettingsRow(icon: "iconSettingsLogOut", title: "Log out")
                        }
                        .buttonStyle(.plain)

                        SettingsRowDivider()

                        Button {
                            isShowingReset = true
                        } label: {
                            SettingsRow(
                                icon: "iconSettingsReset",
                                title: "Reset progress",
                                tint: .asphyrError,
                                titleColor: .asphyrError,
                                tileColor: Color.asphyrError.opacity(0.15)
                            ) {
                                SettingsDisclosure()
                            }
                        }
                        .buttonStyle(.plain)

                        SettingsRowDivider()

                        Button {
                            isShowingDeleteAccount = true
                        } label: {
                            SettingsRow(
                                icon: "iconSettingsTrash",
                                title: "Delete account",
                                tint: .asphyrError,
                                titleColor: .asphyrError,
                                tileColor: Color.asphyrError.opacity(0.15)
                            ) {
                                SettingsDisclosure()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .settingsCard()
                    .padding(.top, 12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                // Leaves room to scroll clear of the version line
                .padding(.bottom, 64)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
        }
        // Measured from the screen's edge, to sit just above the home indicator
        .overlay(alignment: .bottom) {
            versionLine
                .padding(.bottom, 30)
                .ignoresSafeArea(.container, edges: .bottom)
                .allowsHitTesting(false)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            SettingsNavigationTitle(title: "SETTINGS")
        }
        .sheet(isPresented: $isShowingAppearance) {
            AppearanceSheet()
        }
        .sheet(isPresented: $isShowingReset) {
            ResetProgressSheet(onReset: resetProgress)
        }
        .sheet(isPresented: $isShowingLogOut) {
            LogOutSheet {
                profile.clear()
                questStore.clear()
                router.logOut()
                Task {
                    await AccountService.logOut()
                }
            }
        }
        .sheet(isPresented: $isShowingDeleteAccount) {
            DeleteAccountSheet(onDelete: deleteAccount)
        }
        .settingsToast($toast, icon: "iconCheck")
    }

    private var versionLine: some View {
        HStack(spacing: 8) {
            Image("asphyrPrismMark")
                .resizable()
                .scaledToFit()
                .frame(width: 13, height: 16)
                .accessibilityHidden(true)

            Text("ASPHYR · Version \(version)")
                .font(AppTypography.captionMedium)
                .foregroundStyle(Color.asphyrTextSecondary)
        }
    }

    private var profileCard: some View {
        NavigationLink {
            ProfileIdentityView()
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    ProfileAvatar(
                        size: 64,
                        cornerRadius: 20,
                        characterSize: 86,
                        characterOffsetY: 9
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text(profile.name.isEmpty ? "Traveler" : profile.name)
                            .font(AppTypography.sectionTitle)
                            .foregroundStyle(Color.asphyrTextPrimary)

                        if let identityLine {
                            Text(identityLine)
                                .font(AppTypography.bodySecondary)
                                .foregroundStyle(Color.asphyrTextSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image("iconChevronRight")
                        .foregroundStyle(Color.asphyrTextSecondary)
                        .accessibilityHidden(true)
                }

                HStack {
                    Text("LEVEL \(questStore.level)")
                        .foregroundStyle(Color.asphyrAccentPrimary)

                    Spacer(minLength: 8)

                    Text("\(questStore.xpIntoLevel) / \(questStore.xpForLevel) XP")
                        .foregroundStyle(Color.asphyrTextSecondary)
                }
                .font(AppTypography.captionMedium)
                .padding(.top, 16)

                XPBar(
                    progress: CGFloat(questStore.xpIntoLevel) / CGFloat(questStore.xpForLevel),
                    height: 6
                )
                .padding(.top, 8)
            }
            .padding(18)
            .settingsCard(cornerRadius: 22)
            .contentShape(RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
    }

    /// Deletes the login and its data on the server. If that fails, the user stays
    /// signed in and can try again.
    private func deleteAccount() {
        Task {
            do {
                try await AccountService.deleteAccount()
                ReminderNotifications.cancelAll()
                questStore.clear()
                profile.clear()
                router.logOut()
            } catch {
                toast = (error as? AccountError ?? .unknown).message
            }
        }
    }

    private func resetProgress() {
        Task {
            do {
                try await questStore.resetProgressOnServer()
                // Cloaks are earned again from level 3
                profile.cloak = nil
                toast = "Your progress has been reset."
                try? await questStore.refreshDailyQuestOnServer(
                    aspiration: profile.aspiration,
                    archetype: profile.archetype
                )
            } catch {
                toast = (error as? QuestError)?.message ?? AccountError.unknown.message
            }
        }
    }
}

#Preview(traits: .dark) {
    let profile = OnboardingProfile()
    profile.name = "Lou"
    profile.archetype = .strategist
    profile.aspiration = "Game Developer"

    return NavigationStack {
        SettingsView()
    }
    .environment(AppSettings())
    .environment(AppRouter())
    .environment(profile)
    .environment(QuestStore())
}
