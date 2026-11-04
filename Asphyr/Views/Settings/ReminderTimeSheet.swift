//
//  ReminderTimeSheet.swift
//  Asphyr
//

import SwiftUI

struct ReminderTimeSheet: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var time = Date.now
    @State private var days: Set<Int> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SettingsSheetHeader(title: "REMINDER TIME", closeTitle: "Cancel") {
                dismiss()
            }

            DatePicker("Reminder time", selection: $time, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipped()
                .padding(.top, 8)

            Text("REPEAT ON")
                .font(AppTypography.captionMedium)
                .foregroundStyle(Color.asphyrTextSecondary)
                .padding(.top, 16)

            HStack(spacing: 0) {
                ForEach(ReminderSchedule.dayLetters.indices, id: \.self) { day in
                    dayButton(day)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 12)

            Text(ReminderSchedule.summary(time: time.formatted(date: .omitted, time: .shortened), days: days))
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 16)

            Spacer(minLength: 16)

            PrimaryButton(title: "SAVE") {
                settings.reminderTime = time
                settings.reminderDays = days
                ReminderNotifications.update(from: settings)
                dismiss()
            }
            .disabled(days.isEmpty)
            .opacity(days.isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal, 19)
        .padding(.top, 24)
        .padding(.bottom, 24)
        .onAppear {
            time = settings.reminderTime
            days = settings.reminderDays
        }
        .settingsSheet(height: 580)
    }

    private func dayButton(_ day: Int) -> some View {
        let isSelected = days.contains(day)

        return Button {
            if isSelected {
                days.remove(day)
            } else {
                days.insert(day)
            }
        } label: {
            Text(ReminderSchedule.dayLetters[day])
                .font(AppTypography.captionMedium)
                .foregroundStyle(isSelected ? Color.asphyrAccentPrimary : Color.asphyrTextSecondary)
                .frame(width: 40, height: 40)
                .background(
                    isSelected ? Color.asphyrAccentPrimary.opacity(0.12) : Color.asphyrSurfaceElevated,
                    in: Circle()
                )
                .overlay {
                    if isSelected {
                        Circle()
                            .strokeBorder(Color.asphyrAccentPrimary, lineWidth: 1.5)
                    }
                }
                .frame(minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Calendar.current.weekdaySymbols[ReminderSchedule.calendarWeekday(forDay: day) - 1])
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
