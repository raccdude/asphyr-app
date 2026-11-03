//
//  ReminderNotifications.swift
//  Asphyr
//

import UserNotifications

/// Schedules the daily quest reminder on the device, so it needs no backend.
enum ReminderNotifications {
    private static let idPrefix = "dailyQuestReminder"

    static func requestPermission() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false
    }

    /// Replaces any scheduled reminders with what the settings now say.
    static func update(from settings: AppSettings) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(
            withIdentifiers: (0..<7).map { "\(idPrefix)\($0)" }
        )

        guard settings.pushNotifications, settings.dailyReminder else { return }

        for day in settings.reminderDays {
            let content = UNMutableNotificationContent()
            content.title = "ASPHYR"
            content.body = "Your daily quest is waiting."
            content.sound = settings.soundsAndHaptics ? .default : nil

            var time = DateComponents()
            time.weekday = ReminderSchedule.calendarWeekday(forDay: day)
            time.hour = settings.reminderHour
            time.minute = settings.reminderMinute

            center.add(UNNotificationRequest(
                identifier: "\(idPrefix)\(day)",
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
            ))
        }
    }
}
