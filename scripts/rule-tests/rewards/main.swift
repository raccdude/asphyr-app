import Foundation
var failed = 0
func check(_ name: String, _ ok: Bool) { print((ok ? "pass " : "FAIL ") + name); if !ok { failed += 1 } }
func values(_ minutes: Int?, _ d: QuestDifficulty) -> [Int] { RewardRules.attributes(category: "development", difficulty: d, minutes: minutes).map(\.value) }
check("15m easy 1,1", values(15, .easy) == [1, 1])
check("15m moderate 3,1", values(15, .moderate) == [3, 1])
check("15m hard 4,2", values(15, .hard) == [4, 2])
check("30m moderate 5,2 is unchanged", values(30, .moderate) == [5, 2])
check("1h moderate 10,4", values(60, .moderate) == [10, 4])
check("2h+ moderate 15,6", values(120, .moderate) == [15, 6])
check("2h+ hard 24,9", values(120, .hard) == [24, 9])
check("no duration stays at the base", values(nil, .hard) == [8, 3])
let e = DifficultyEstimator.estimate
check("hard word in title is Hard", e("Tidy my calculus notes", "") == .hard)
check("hard word only in description isn't Hard", e("Clean my room", "before my exam") == .moderate)
check("easy word in description is still Easy", e("Chores", "do the laundry") == .easy)
check("title Walk with exam in description is Easy", e("Walk", "exam") == .easy)
func personal(_ xp: Int) -> Quest { Quest(type: .personalQuest, title: "P", description: "", objective: "", iconName: "", category: "OTHER", difficulty: .easy, durationMinutes: nil, xpReward: xp, attributeRewards: [], status: .available) }
func main3() -> Quest { Quest(type: .mainQuest, title: "M", description: "", objective: "", iconName: "", category: "OTHER", difficulty: .hard, durationMinutes: nil, xpReward: 0, attributeRewards: [], status: .available, steps: (0..<3).map { QuestStep(title: "\($0)") }) }
func setup(_ xp: Int) -> (QuestStore, Quest) {
    let a = personal(xp), m = main3(), b = personal(0)
    let s = QuestStore(quests: [a, m, b])
    s.start(a); _ = s.complete(s.quests[0])
    s.start(m); s.toggleStep(s.quests[1].steps[0], in: s.quests[1])
    s.start(b); _ = s.complete(s.quests[2])
    return (s, s.quests[1])
}
var (s, m) = setup(1100)
check("level 3 reached by a step gives Midnight", s.level == 3 && s.unlockedCloaks.map(\.level) == [3])
s.delete(m)
check("deleting the main quest drops the level", s.level == 2)
check("deleting takes the cloak back", s.unlockedCloaks.isEmpty)
(s, m) = setup(1100)
s.toggleStep(m.steps[0], in: m)
check("unticking takes the cloak back", s.level == 2 && s.unlockedCloaks.isEmpty)
(s, m) = setup(400)
check("level 2 badge earned by a step", s.earnedAchievements.contains(.levelTwo))
s.delete(m)
check("deleting takes the level 2 badge back", !s.earnedAchievements.contains(.levelTwo))
check("first quest badge stays", s.earnedAchievements.contains(.firstQuest))
(s, m) = setup(1400)
check("cloak stays when the level holds", { s.delete(m); return s.level == 3 && s.unlockedCloaks.map(\.level) == [3] }())
(s, m) = setup(1100); s.delete(m)
let again = personal(100); s.quests.append(again); s.start(again)
let done = s.complete(s.quests.last!)
check("level is announced again when re-earned", done?.didLevelUp == true && done?.newCloaks.map(\.level) == [3])
print(failed == 0 ? "ALL PASSED" : "\(failed) FAILED"); exit(failed == 0 ? 0 : 1)
