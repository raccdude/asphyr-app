# ASPHYR — XP and rewards spec

Replaces the placeholder XP, level, attribute and reward logic. Approved design from 3 Nov 2026; build it on its own branch after `feat/reward-v2` merges.

## Goal
Rewards are inferred by the system, so users can't choose how much a quest is worth. It works on the device, with no backend or cloud AI.

## Difficulty
- **Levels:** Easy, Moderate and Hard.
- **Source:** the quest's title and description, never its duration. "Calculus" stays Hard at 15 minutes.
- **When:** worked out when the quest is created, then stored. The user can't edit it. Create Quest shows it updating as they type.
- **Default:** Moderate when nothing matches.
- **Sample daily quest:** keeps its fixed Moderate.

The difficulty code is one swappable piece, with one input (title and description) and one output (a difficulty). Nothing else knows how it decides.

1. **Keyword list:** always available. Words like "calculus", "thesis" and "marathon" mean Hard; words like "tidy" and "walk" mean Easy.
2. **Apple's on-device model (Foundation Models):** used where available, falling back to keywords on iPhones without Apple Intelligence, when it's turned off, or on any failure. This depends on a trial first: run real quest titles through it and report the results. If it judges them poorly, ship keywords only.

The same quest could score differently on different iPhones when both are in use. That's accepted for now.

## XP
Timed quests earn the duration's base multiplied by difficulty:

| Duration | Base | Easy ×1 | Moderate ×2 | Hard ×3 |
|---|---|---|---|---|
| 15m | 25 | 25 | 50 | 75 |
| 30m | 50 | 50 | 100 | 150 |
| 1h | 100 | 100 | 200 | 300 |
| 2h+ | 200 | 200 | 400 | 600 |

Main quests have no duration. Each step earns XP when ticked, and loses it when unticked: 50 for Easy, 100 for Moderate, 150 for Hard. The total on the card is the step amount multiplied by the number of steps.

To stop XP being farmed, only 3 main quest steps can be ticked per day, counted by calendar day. Unticking frees one up again. Deleting a main quest takes back the XP from its ticked steps. There's still no deadline.

Only 3 personal quests can earn full rewards per day, counted by calendar day. Later ones earn a flat +10 XP and +1 of the category's main attribute, whatever their difficulty or duration, because small progress is still progress. Quest Details says so before the user starts or completes them. Daily and main quests don't count towards this.

Main quests need at least 3 steps, so at most one can be finished per day.

## Attributes
Earned when a quest is completed, based on its category and difficulty. The amounts are for the main and second attribute:

| Difficulty | Main | Second |
|---|---|---|
| Easy | +2 | +1 |
| Moderate | +5 | +2 |
| Hard | +8 | +3 |

| Category | Main attribute | Second attribute |
|---|---|---|
| Development | Problem Solving | Knowledge |
| Learning | Knowledge | Discipline |
| Health | Discipline | — |
| Creative | Creativity | — |
| Career | Discipline | Problem Solving |
| Social | Creativity | — |
| Other | Discipline | — |

The sample daily quest keeps its Creativity +5 and Discipline +2. Every attribute starts at 10.

## Levels
Level 1 needs 500 XP, and each level after that needs 200 more, which matches Figma's level 2 at 700.

| To reach | XP for that level | Total XP | Days at 200 XP a day |
|---|---|---|---|
| Level 2 | 500 | 500 | 2.5 |
| Level 3 | 700 | 1,200 | 6 |
| Level 5 | 1,100 | 3,200 | 16 |
| Level 8 | 1,700 | 7,700 | 38.5 |
| Level 11 | 2,300 | 14,000 | 70 |

200 XP a day is a daily quest plus one personal quest, both 30m at Moderate.

XP carries over to the next level. A step unticked below a level boundary lowers the level again.

## Unlocked rewards
| Level | Reward |
|---|---|
| 3 | Midnight cloak |
| 5 | Oxblood cloak |
| 8 | Plum cloak |

- New Reward Unlocked appears on Reward when a completed quest finds a cloak not yet unlocked at the current level, and names it. The level-up banner announces each level once.
- A level reached by ticking a main quest's steps is announced the next time any quest is completed.
- If several cloaks are waiting, the card lists each one.
- The store records which cloaks are unlocked. Unticking below a level doesn't remove a cloak already earned.
- Wearing a cloak and "View in Character" come with the Character screen.

## Screens that change
- **Create Quest:** the reward card uses the new XP and shows the difficulty. Main quests show XP for each step.
- **Quest Details:** shows the stored difficulty, and attribute rewards for created quests.
- **Home:** the level, bar and "XP to level" use the new curve.
- **Reward:** the experience bar uses the new curve, and the unlocked card shows real cloaks.

## Not included
Saving progress across relaunches, generating and renewing daily quests, cloud AI, a daily XP cap, and wearing cloaks.

## Known limit
No system can tell whether a quest is honest: someone can title an easy task "Calculus". The minimum completion time and the daily limits cap how much XP can be farmed.

## How it's checked
The XP, attribute and level rules are plain functions, so they can have unit tests if a test target is added. Otherwise each is on the developer's Xcode checklist with the expected numbers above.
