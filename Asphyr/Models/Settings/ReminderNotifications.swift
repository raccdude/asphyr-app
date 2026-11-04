//
//  ReminderNotifications.swift
//  Asphyr
//

import UserNotifications

/// Schedules the daily quest reminder on the device, so it needs no backend.
enum ReminderNotifications {
    private static let idPrefix = "dailyQuestReminder"
    private static let streakAlertID = "streakAlert"

    /// Stops every reminder, for when the account is deleted.
    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    static func requestPermission() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false
    }

    /// Replaces the streak alert. Finishing a quest moves it to the next day.
    static func updateStreakAlert(from settings: AppSettings, completions: [Date]) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [streakAlertID])

        guard settings.pushNotifications, settings.streakAlerts, settings.showsStreaks,
              let date = StreakRules.alertDate(completions: completions)
        else { return }

        let content = UNMutableNotificationContent()
        content.title = "ASPHYR"
        content.body = "Your flame is still burning. Finish any quest today to keep your streak."
        content.sound = settings.soundsAndHaptics ? .default : nil

        let time = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        center.add(UNNotificationRequest(
            identifier: streakAlertID,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: time, repeats: false)
        ))
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
