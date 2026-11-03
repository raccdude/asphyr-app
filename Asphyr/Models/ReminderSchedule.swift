//
//  ReminderSchedule.swift
//  Asphyr
//

import Foundation

/// The rules for the daily quest reminder. Days count from Monday = 0.
enum ReminderSchedule {
    static let dayLetters = ["M", "T", "W", "T", "F", "S", "S"]
    private static let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    static func summary(time: String, days: Set<Int>) -> String {
        guard !days.isEmpty else { return "Pick at least one day." }

        let when: String
        if days.count == 7 {
            when = "every day"
        } else if days == [0, 1, 2, 3, 4] {
            when = "on weekdays"
        } else if days == [5, 6] {
            when = "on weekends"
        } else {
            when = "on " + days.sorted().map { dayNames[$0] }.joined(separator: ", ")
        }
        return "You’ll get a reminder at \(time) \(when)."
    }

    /// `Calendar` counts weekdays from Sunday = 1.
    static func calendarWeekday(forDay day: Int) -> Int {
        (day + 1) % 7 + 1
    }
}
