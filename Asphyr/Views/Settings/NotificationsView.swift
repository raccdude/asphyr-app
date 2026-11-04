//
//  NotificationsView.swift
//  Asphyr
//

import SwiftUI

struct NotificationsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(OnboardingProfile.self) private var profile

    @State private var isShowingReminderTime = false
    @State private var toast: String?

    private var pushBinding: Binding<Bool> {
        Binding {
            settings.pushNotifications
        } set: { isOn in
            guard isOn else {
                settings.pushNotifications = false
                ReminderNotifications.update(from: settings)
                return
            }

            Task {
                let isAllowed = await ReminderNotifications.requestPermission()
                settings.pushNotifications = isAllowed
                ReminderNotifications.update(from: settings)

                if !isAllowed {
                    toast = "Allow notifications for ASPHYR in the iOS Settings app."
                }
            }
        }
    }

    var body: some View {
        @Bindable var settings = settings

        ZStack {
            Color.asphyrBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    pushCard

                    SectionDivider(sectionTitle: "REMINDERS")
                        .padding(.top, 26)

                    VStack(spacing: 0) {
                        SettingsRow(
                            icon: "iconSettingsFlag",
                            title: "Daily quest reminder",
                            subtitle: "A gentle nudge to take action."
                        ) {
                            SettingsToggle(title: "Daily quest reminder", isOn: $settings.dailyReminder)
                        }

                        SettingsRowDivider()

                        Button {
                            isShowingReminderTime = true
                        } label: {
                            SettingsRow(icon: "iconSettingsClock", title: "Reminder time") {
                                SettingsDisclosure(value: settings.reminderTimeText)
                            }
                        }
                        .buttonStyle(.plain)

                        SettingsRowDivider()

                        SettingsRow(
                            icon: "iconSettingsFlame",
                            title: "Streak alerts",
                            subtitle: "Before a streak resets."
                        ) {
                            SettingsToggle(title: "Streak alerts", isOn: $settings.streakAlerts)
                        }
                    }
                    .settingsCard()
                    .padding(.top, 12)

                    SectionDivider(sectionTitle: "EMAIL")
                        .padding(.top, 26)

                    SettingsRow(
                        icon: "iconSettingsMail",
                        title: "Weekly progress summary",
                        subtitle: profile.email.isEmpty ? nil : "Sent to \(profile.email)"
                    ) {
                        SettingsToggle(title: "Weekly progress summary", isOn: $settings.weeklySummary)
                    }
                    .settingsCard()
                    .padding(.top, 12)

                    Text("Changes save automatically.")
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(Color.asphyrTextSecondary)
                        .padding(.top, 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            SettingsNavigationTitle(title: "NOTIFICATIONS")
        }
        .onChange(of: settings.dailyReminder) {
            ReminderNotifications.update(from: settings)
        }
        .sheet(isPresented: $isShowingReminderTime) {
            ReminderTimeSheet()
        }
        .settingsToast($toast)
    }

    private var pushCard: some View {
        HStack(spacing: 14) {
            Image("iconSettingsBellLarge")
                .foregroundStyle(Color.asphyrAccentPrimary)
                .frame(width: 44, height: 44)
                .background(Color.asphyrAccentPrimary.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("Push notifications")
                    .font(AppTypography.bodySemiBold)
                    .foregroundStyle(Color.asphyrTextPrimary)

                Text("Allow ASPHYR to send you alerts.")
                    .font(AppTypography.bodySecondary)
                    .foregroundStyle(Color.asphyrTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            SettingsToggle(title: "Push notifications", isOn: pushBinding)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .settingsCard()
    }
}

#Preview(traits: .dark) {
    NavigationStack {
        NotificationsView()
    }
    .environment(AppSettings())
    .environment(OnboardingProfile())
}
