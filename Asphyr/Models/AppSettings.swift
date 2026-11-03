//
//  AppSettings.swift
//  Asphyr
//

import SwiftUI

/// The preferences from Settings. Kept in memory until saving exists, so they
/// reset when the app relaunches. They belong to the device, so they survive
/// logging out and resetting progress.
@Observable
final class AppSettings {
    enum Appearance: String, CaseIterable, Identifiable {
        case dark = "Dark"
        case light = "Light"
        case system = "System"

        var id: Self { self }

        /// ASPHYR is dark-first. Nil follows the device.
        var colorScheme: ColorScheme? {
            switch self {
            case .dark: .dark
            case .light: .light
            case .system: nil
            }
        }
    }

    var appearance: Appearance = .dark
    /// Nothing counts streaks yet, so Home has no chip to hide.
    var showsStreaks = true
    var soundsAndHaptics = true

    /// Off until iOS has been asked for permission.
    var pushNotifications = false
    var dailyReminder = true
    var reminderHour = 8
    var reminderMinute = 0
    var reminderDays: Set<Int> = [0, 1, 2, 3, 4]
    /// Stored for when streaks exist.
    var streakAlerts = false
    /// Stored for when the backend can send email.
    var weeklySummary = false

    var reminderTime: Date {
        get {
            Calendar.current.date(bySettingHour: reminderHour, minute: reminderMinute, second: 0, of: .now) ?? .now
        }
        set {
            let parts = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            reminderHour = parts.hour ?? 8
            reminderMinute = parts.minute ?? 0
        }
    }

    var reminderTimeText: String {
        reminderTime.formatted(date: .omitted, time: .shortened)
    }
}
