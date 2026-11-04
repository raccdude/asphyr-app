import Foundation
var failed = 0
func check(_ n: String, _ ok: Bool) { print((ok ? "pass " : "FAIL ") + n); if !ok { failed += 1 } }
let d = UserDefaults(suiteName: "asphyr.test.\(UUID())")!
let a = AppSettings(defaults: d)
check("defaults: dark, streaks on, push off, 8:00 weekdays", a.appearance == .dark && a.showsStreaks && !a.pushNotifications && a.reminderHour == 8 && a.reminderDays == [0,1,2,3,4])
a.appearance = .light; a.showsStreaks = false; a.pushNotifications = true; a.reminderHour = 21; a.reminderMinute = 30; a.reminderDays = [5,6]; a.streakAlerts = true
let b = AppSettings(defaults: d)
check("changes survive a relaunch", b.appearance == .light && !b.showsStreaks && b.pushNotifications && b.reminderHour == 21 && b.reminderMinute == 30 && b.reminderDays == [5,6] && b.streakAlerts)
let p = OnboardingProfile()
check("new profile isn't onboarded", !p.isComplete)
p.name = "Lou"; p.aspiration = "Game Developer"
check("no archetype isn't onboarded", !p.isComplete)
p.archetype = .strategist
check("all answers is onboarded", p.isComplete)
p.clear(); check("clear resets it", !p.isComplete)
print(failed == 0 ? "ALL PASSED" : "\(failed) FAILED"); exit(failed == 0 ? 0 : 1)
