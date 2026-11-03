//
//  StreakRules.swift
//  Asphyr
//

import Foundation

/// Where a streak stands. Streaks are optional, and missing a day never removes
/// XP, levels or attributes.
struct StreakStatus: Equatable {
    enum State: Equatable {
        /// No quest has been finished yet.
        case none
        case active
        /// Nothing was finished yesterday or today.
        case resting
    }

    enum Day: Equatable {
        case lit
        /// Today, before a quest is finished.
        case today
        case empty
    }

    let state: State
    let days: Int
    /// Monday to Sunday.
    let week: [Day]
    let todayIndex: Int
    let didFinishToday: Bool

    var title: String {
        state == .resting ? "Your flame is resting" : "\(days)-day streak"
    }

    var message: String {
        switch state {
        case .none:
            "Finish any quest to light your flame."
        case .resting:
            "No quest yesterday, and that’s okay.\nFinish any quest to rekindle it."
        case .active where days == 1:
            didFinishToday ? "You took a step today." : "You took a step yesterday."
        case .active:
            "You’ve taken a step \(Self.spelledOut(days)) days in a row."
        }
    }

    private static func spelledOut(_ number: Int) -> String {
        let words = ["two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]
        return (2...10).contains(number) ? words[number - 2] : "\(number)"
    }
}

enum StreakRules {
    /// A streak continues through any day with a finished quest, and stays alive
    /// until the end of the next day.
    static func status(completions: [Date], now: Date = .now, calendar: Calendar = .current) -> StreakStatus {
        let today = calendar.startOfDay(for: now)
        let active = Set(completions.map { calendar.startOfDay(for: $0) })
        let todayIndex = (calendar.component(.weekday, from: today) + 5) % 7

        let week = (0..<7).map { index -> StreakStatus.Day in
            guard let date = calendar.date(byAdding: .day, value: index - todayIndex, to: today) else { return .empty }
            if active.contains(date) { return .lit }
            return index == todayIndex ? .today : .empty
        }

        let didFinishToday = active.contains(today)
        var cursor = didFinishToday ? today : calendar.date(byAdding: .day, value: -1, to: today) ?? today
        var days = 0
        while active.contains(cursor) {
            days += 1
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }

        let state: StreakStatus.State = active.isEmpty ? .none : (days > 0 ? .active : .resting)
        return StreakStatus(state: state, days: days, week: week, todayIndex: todayIndex, didFinishToday: didFinishToday)
    }

    /// 8 PM on the last day that can keep the streak going, unless that's passed.
    static func alertDate(completions: [Date], now: Date = .now, calendar: Calendar = .current) -> Date? {
        guard status(completions: completions, now: now, calendar: calendar).state == .active,
              let last = completions.max(),
              let nextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: last)),
              let alert = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: nextDay),
              alert > now
        else { return nil }

        return alert
    }
}
