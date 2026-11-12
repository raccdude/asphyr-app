//
//  AppSettings.swift
//  Asphyr
//

import SwiftUI

/// The preferences from Settings, saved on this device. They belong to the device,
/// not the account, so they survive logging out and resetting progress.
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

    var appearance: Appearance { didSet { defaults.set(appearance.rawValue, forKey: "appearance") } }
    /// Whether Home shows the streak. Streaks are still counted when it's off.
    var showsStreaks: Bool { didSet { defaults.set(showsStreaks, forKey: "showsStreaks") } }
    var soundsAndHaptics: Bool { didSet { defaults.set(soundsAndHaptics, forKey: "soundsAndHaptics") } }

    /// Off until iOS has been asked for permission.
    var pushNotifications: Bool { didSet { defaults.set(pushNotifications, forKey: "pushNotifications") } }
    var dailyReminder: Bool { didSet { defaults.set(dailyReminder, forKey: "dailyReminder") } }
    var reminderHour: Int { didSet { defaults.set(reminderHour, forKey: "reminderHour") } }
    var reminderMinute: Int { didSet { defaults.set(reminderMinute, forKey: "reminderMinute") } }
    var reminderDays: Set<Int> { didSet { defaults.set(Array(reminderDays), forKey: "reminderDays") } }
    var streakAlerts: Bool { didSet { defaults.set(streakAlerts, forKey: "streakAlerts") } }

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        func flag(_ key: String, _ fallback: Bool) -> Bool {
            defaults.object(forKey: key) as? Bool ?? fallback
        }

        appearance = defaults.string(forKey: "appearance").flatMap(Appearance.init(rawValue:)) ?? .dark
        showsStreaks = flag("showsStreaks", true)
        soundsAndHaptics = flag("soundsAndHaptics", true)
        pushNotifications = flag("pushNotifications", false)
        dailyReminder = flag("dailyReminder", true)
        reminderHour = defaults.object(forKey: "reminderHour") as? Int ?? 8
        reminderMinute = defaults.object(forKey: "reminderMinute") as? Int ?? 0
        reminderDays = (defaults.array(forKey: "reminderDays") as? [Int]).map(Set.init) ?? [0, 1, 2, 3, 4]
        streakAlerts = flag("streakAlerts", false)
    }

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
