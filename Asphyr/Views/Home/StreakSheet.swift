//
//  StreakSheet.swift
//  Asphyr
//

import SwiftUI

/// Opened from the streak chip on Home.
struct StreakSheet: View {
    let status: StreakStatus

    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openQuests) private var openQuests

    @State private var spiritMood: SpiritView.Mood = .happy

    private var isResting: Bool {
        status.state == .resting
    }

    var body: some View {
        @Bindable var settings = settings

        VStack(spacing: 0) {
            SettingsSheetHeader(title: "STREAK", closeTitle: "Close") {
                dismiss()
            }

            Button {
                spiritMood = spiritMood.next
            } label: {
                SpiritView(mood: spiritMood, size: 110)
            }
            .buttonStyle(PressableButtonStyle())
            .hapticFeedback(.selection, trigger: spiritMood)
            .accessibilityLabel("Flame spirit")
            .accessibilityHint("Changes the spirit’s expression")
            .padding(.top, 14)

            Text(status.title)
                .font(AppTypography.screenTitle)
                .foregroundStyle(Color.asphyrTextPrimary)
                .padding(.top, 10)

            Text(status.message)
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)

            Text("THIS WEEK")
                .font(AppTypography.captionMedium)
                .foregroundStyle(Color.asphyrTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 22)

            week
                .padding(.top, 12)

            HStack(spacing: 12) {
                Image("iconStreakShield")
                    .foregroundStyle(Color.asphyrAccentPrimary)
                    .frame(width: 32, height: 32)
                    .background(Color.asphyrAccentPrimary.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))
                    .accessibilityHidden(true)

                Text("Streaks are optional. Missing a day never removes XP, levels or attributes.")
                    .font(AppTypography.bodySecondary)
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .settingsCard(cornerRadius: 16)
            .padding(.top, 18)

            SettingsRow(icon: "iconSettingsFlame", title: "Show streak on Home") {
                SettingsToggle(title: "Show streak on Home", isOn: $settings.showsStreaks)
            }
            .settingsCard()
            .padding(.top, 10)

            Spacer(minLength: 16)

            PrimaryButton(title: isResting ? "FIND A QUEST" : "GOT IT") {
                dismiss()
                if isResting {
                    openQuests()
                }
            }
        }
        .padding(.horizontal, 19)
        .padding(.top, 24)
        .padding(.bottom, 24)
        .onAppear {
            spiritMood = isResting ? .sleepy : .happy
        }
        .settingsSheet(height: isResting ? 740 : 720)
    }

    private var week: some View {
        HStack(spacing: 0) {
            ForEach(status.week.indices, id: \.self) { index in
                VStack(spacing: 6) {
                    dayCircle(status.week[index])

                    Text(ReminderSchedule.dayLetters[index])
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(index == status.todayIndex ? Color.asphyrTextPrimary : Color.asphyrTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Calendar.current.weekdaySymbols[ReminderSchedule.calendarWeekday(forDay: index) - 1])
                .accessibilityValue(status.week[index] == .lit ? "Quest finished" : "No quest")
            }
        }
    }

    @ViewBuilder
    private func dayCircle(_ day: StreakStatus.Day) -> some View {
        switch day {
        case .lit:
            Image("iconStreakFlame")
                .foregroundStyle(Color.asphyrAccentPrimary)
                .frame(width: 36, height: 36)
                .background(Color.asphyrAccentPrimary.opacity(0.12), in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(Color.asphyrAccentPrimary, lineWidth: 1)
                }
        case .today:
            Circle()
                .strokeBorder(Color.asphyrAccentPrimary, lineWidth: 1)
                .frame(width: 36, height: 36)
        case .empty:
            Circle()
                .fill(Color.asphyrSurfaceElevated)
                .frame(width: 36, height: 36)
        }
    }
}

#Preview("Active", traits: .dark) {
    Color.asphyrBackground
        .sheet(isPresented: .constant(true)) {
            StreakSheet(status: StreakRules.status(completions: [.now, .now.addingTimeInterval(-86_400)]))
                .environment(AppSettings())
        }
}

#Preview("Resting", traits: .dark) {
    Color.asphyrBackground
        .sheet(isPresented: .constant(true)) {
            StreakSheet(status: StreakRules.status(completions: [.now.addingTimeInterval(-172_800)]))
                .environment(AppSettings())
        }
}
