# ASPHYR — Implementation notes

The running record of how the app is being built. Design intent lives in [DESIGN-DECISIONS.md](DESIGN-DECISIONS.md). Update this file on the same branch as the work it describes.

## Workflow
See [WORKFLOW.md](WORKFLOW.md) for how we work. Screens are implemented one at a time from Figma page "05 — Hi-Fi v2 (Polished)".

## Progress
| Step | Status | Branch |
|---|---|---|
| Navigation shell | Merged | `fix/navigation-shell` |
| Splash and Welcome inspection | Done | — |
| Splash and Welcome polish | Merged | `fix/splash-welcome-polish` |
| Create Account | Merged | `feat/create-account-v2` |
| Login | Merged | `feat/login-v2` |
| Account Recovery and Recovery Success | Merged | `feat/account-recovery-v2` |
| Build Your Identity and Create Aspiration | Merged | `feat/identity-v2` |
| Your Character | Merged | `feat/archetype-selection-v2` |
| Tab bar and Home | Merged | `feat/home-v2` |
| Quests list | Merged | `feat/quests-v2` |
| Create Quest | Merged | `feat/create-quest-v2` |
| Quest Details | Merged | `feat/quest-details-v2` |
| Reward | Merged | `feat/reward-v2` |
| XP system | Merged | `feat/xp-system` |
| Journey | Merged | `feat/journey-constellations` |
| Character | Merged | `feat/character-v2` |
| Cloak layers | Merged | `feat/cloak-layers` |
| Settings | Merged | `feat/settings-v2` |
| Streaks | Merged | `feat/streaks-v2` |
| Figma revisions | In progress: auth, onboarding, Home, Quests, Create Quest, Quest Details and Reward done | `docs/figma-revisions` |

## Navigation
- `RootView` owns the auth and onboarding `NavigationStack`. `AppRouter` owns its path and is read with `@Environment(AppRouter.self)`.
- **On the router:** Splash, Welcome, Create Account, Login, Recover, Recovery Success, Identity, Archetype. Each `AuthRoute` case maps to one screen in `RootView`.
- **Entering the app:** `router.enterApp()` swaps the root to `MainTabView` and clears the path, so nothing can swipe back to auth or onboarding. `router.logOut()` is the reverse, returning to Welcome.
- **Tabs:** Home and Quests each sit in their own `NavigationStack`, created in `MainTabView`. Home reaches Settings with `.navigationDestination(isPresented:)`, and both reach Quest Details with `.navigationDestination(item:)`. Journey and Character still create their own stacks.
- Any `#Preview` of a screen that reads the router needs `.environment(AppRouter())`, or the preview crashes.
- **Rules for a path-bound root stack (tested on the iOS 27.0 Simulator, 2 Nov 2026):**
  - Do not add a `NavigationStack` to a pushed screen. It sends the app back to the root screen. Changing `[AuthRoute]` to `NavigationPath` does not help.
  - Do not use a view-destination `NavigationLink { SomeView() }`. It crashes with `AnyNavigationPath.Error.comparisonTypeMismatch`. Use a `Button` that calls the router.

## Platform scope
- **Current target:** iPhone only, portrait only.
- **Future work:** landscape, iPad and other screen sizes. Enabling them means changing the device family and orientation build settings, and designing and testing layouts for each.
- **Not in scope for now:** VoiceOver and Reduce Motion work. Leave the support already in the code in place, but don't plan or test it.
- **Large text:** don't truncate copy; let layouts wrap or scroll. It isn't checked on screen, to save tokens. The quest screens were checked once at Accessibility Large on 3 Nov 2026, and the two issues left are under Known issues.

## Fonts
- The app bundles **Inter 3.19** (`Inter Desktop` OTFs from the [official release](https://github.com/rsms/inter/releases/tag/v3.19)), with its license in `Fonts/Inter-LICENSE.txt`.
- **Why this version:** Figma's Inter has Slant and Weight axes but no Optical Size, which points to Inter 3. Modern Inter's static cuts are narrower, so don't swap in Google Fonts' Inter.
- **Measured on Welcome's first message line:** the 24pt cut was 320pt wide, the 18pt cut 329pt, and Inter 3.19 is 337pt, the same as Figma.
- Space Grotesk matches Figma.

## Create Account
- **Components for Figma v2 auth screens:** `AuthTopBar`, `AsphyrInputField`, `FieldErrorRow`, `PasswordChecklist`, `SocialSignInRow`, `OrDivider`, `AuthSwitchPrompt`. Login uses these too. Delete `AsphyrTextField` once the recovery and Identity screens move off it.
- **Input field taps:** keep the focus tap gesture behind the text field. On top of it, iOS reads the tap as a second tap and selects the whole word, so the next key replaces the value.
- **Validation:** errors appear when leaving a field and on submit, and clear when that field is edited. A weak password blocks submit and keeps the checklist visible, a state Figma has no frame for.
- **Header (all auth screens):** Create Account, Login, Account Recovery and Recovery Success share `AuthScreen` and `AuthHeader`, so change spacing there and it applies everywhere. Welcome also uses `AuthScreen`, with `showsBackButton: false`, so its wordmark sits in the same position. Home has its own wordmark; line it up in the Home step. `AuthTopBar` draws a custom glass back button and hides the system bar, an exception recorded in DESIGN-DECISIONS.md. Swipe-back is turned on only while that screen is visible, so Welcome and Home stay unaffected. The back button starts at 76pt on iPhone 18 Pro.
- **Backend and sign-in are on hold.** Screens come first. Authentication stays mocked and the Apple and Google buttons stay display only until the Supabase or Firebase decision is made and the go-ahead given. Real sign-in is needed before release.
- **`StatusError`** is now `#FF5C5C`, Figma's Error value.
- **Password prompts are kept on purpose.** iOS's "Use Strong Password" and "Save Password?" come from the correct field types, which password managers rely on.

## Login
- **Mock validation:** "Incorrect email or password" appears on submit for a malformed email or an empty field, and clears on edit. Any well-formed email with a password logs in. Replace this in `LoginView.submit()` when the backend arrives.
- **After login:** goes to the tabs through `router.enterApp()`.

## Account Recovery
- **Spirit:** `SpiritView` shows wave, focused, surprised or cheer, and crossfades between them. The assets are original-color SVGs in the catalog. Add other moods there when their screens are built.
- **Mock behaviour:** no email is sent. Resend shows the toast and starts a 30-second countdown, which resets when the screen is left. Replace this in `RecoverySuccessView.resend()` when the backend arrives.
- **Keyboard:** the email field sits low, so Recovery scrolls it into view when focused. `AuthTopBar` has a solid background so scrolling content doesn't show behind the wordmark. Use the same scroll approach on any screen with a low field.
- **`AsphyrToast`** is reusable, with a Reset Progress toast planned in DESIGN-DECISIONS.md.

## Build Your Identity
- **Onboarding answers:** `OnboardingProfile` is created in `RootView` and read from the environment. It holds the name, color and aspiration in memory, so they reset on relaunch. Your Character adds the archetype, and Home reads all of it in its own step.
- **Character colors:** the tunics and details are generated from Figma's green novice by swapping its tunic base, shade (base × 0.678) and tint. Figma has no novice variants for the other five colors. At the developer's request, Snow (`#F5F7FF`) replaced Figma's orange, and Midnight, Oxblood and Plum replaced cyan, red and purple.
- **Dark colors:** Midnight (`#16264F`, tint `#7FA6FF`), Oxblood (`#4A0F1C`, tint `#FF7A8A`) and Plum (`#2F1650`, tint `#B58CFF`) use a brighter tint, because 50% white would dull the eyes, smile and crest.
- **Details on pale colors:** tint details disappear on the pale tunics and items, so Snow and Yellow use a dark crest (`#12141A`, center `#5A6172`) and dark lines on the orb and book. Their eyes and smile stay pale.
- **Book lines on dark colors:** Oxblood, Midnight and Plum books have a tint cover, so their lines are white.
- **Create Aspiration:** a system sheet. iOS floats it 8pt in from the screen edge, so its 12pt padding lines up with the 20pt screen margin. Saved text replaces "Something else" on the card, and choosing a listed card clears it. Tapping any selected card deselects it; the sheet keeps the last custom text if reopened.
- **Top bar:** `AuthScreen(onboardingStep:)` shows the step indicator in place of the wordmark.

## Tab bar and Home
- **Tab bar:** `MainTabBar` is custom because iOS's bar can't match Figma's shape. `TabView` still keeps each tab's state, with its own bar hidden. `.mainTabBar()` is applied inside each tab's root so pushed screens cover the bar.
- **Home data:** the name, color, archetype and aspiration come from `OnboardingProfile`. Login skips onboarding until real accounts exist, so it shows "Traveler" and a green character with no item, and hides the archetype and aspiration.
- **Progress:** the level and XP bar come from `QuestStore`, and attributes start at 10 and rise when a quest is completed.
- **Home's quest (`QuestStore.homeQuest`):** the active daily or personal quest first, then today's daily if it isn't finished, then the active main quest, then any available quest. The section reads "ACTIVE QUEST" for any active quest, "TODAY'S QUEST" for an available daily and "AVAILABLE QUEST" for any other available quest. Which quest was accepted first doesn't matter: a daily or personal quest always shows ahead of an active main quest, because its timer is running and the main quest has no deadline.
- **Completion card:** from `9.2 - Home Screen (Completion)`, shown under "TODAY'S PROGRESS" once nothing is active or available. It counts every completed quest and totals their XP, and its button opens Create Quest. The count should become today's only when daily quests renew. The copy for more than one quest is ours. New and ongoing users start on the available card. Once started, it uses the active style and elapsed-time row from `9.1 - Home Screen (Active Quest)`.
- **Streak chip:** built and checked, but hidden while `streakDays` is 0. Nothing counts streaks yet.
- **Unused now:** the `Character` component is left over from the old Home and Your Character. Delete it in a cleanup.

## Quests list
- **Who creates each quest type:**
  - **Daily:** system generated. It renews every 24 hours and is based on the user's aspiration and archetype. This isn't built yet; `Quest.sampleDaily` is a fixed placeholder.
  - **Main and personal:** user generated, through Create Quest. Neither appears by default. The developer stated this for main quests; personal is treated the same because it's also offered on Create Quest.
- **Data:** `QuestStore` is created in `MainTabView` and read from the environment. It starts with only the daily quest and is kept in memory, so changes will reset on relaunch. Replace it when the backend arrives.
- **Filters:** ALL shows every open quest, available or active, and completed quests appear only under Completed so they don't pile up. The others match on status. Sections with no matching quests are hidden. Each filter has its own empty state.
- **Testing other states:** by default ALL and Available show the daily quest, and Active and Completed show their empty states. `QuestView` has "All quest types", "No quests" and "Completed quest" previews for the rest.
- **Unused now:** `iconGamepad` is left over from the old card. Delete it in a cleanup.

## Create Quest
- **Presentation:** a system sheet at the large detent, opened by the + button in the quest log. iOS shows this detent edge to edge, seen on the iPhone 17 simulator, so it uses a 20pt margin instead of the 12pt margin on Create Aspiration's floating sheet. The content is taller than the screen, so the reward card needs a scroll.
- **Quest type selection:** our own version, because Figma has no design yet. Two cards, Main and Personal, sit above Estimated Duration. Daily isn't offered because the system creates it. It uses the same selected style as this screen's duration and category controls.
- **Default state:** Personal, 30m and Development (the first category) are selected, with an empty title and description. Type, duration and category always keep a selection.
- **Validation:** on submit only. The title is required and the description is optional. Main quests also need at least 3 steps. Each error clears on edit.
- **Main quest steps:** our own version. A STEPS section appears on this screen when Main is selected, with 3 to 10 steps that can be removed before saving. Text left in the step field is added on submit. Checking steps off comes with Quest Details.
- **Quest limits:** one open main quest and five open personal quests at a time; completed quests don't count. A card at its limit is dimmed and reads "Already created" or "Limit reached", and tapping it shows a toast explaining the limit. If Personal is at its limit, Main is selected instead. If both are, "Finish a quest to create a new one." appears and Create Quest does nothing.
- **Main quests have no time limit:** Estimated Duration is hidden when Main is selected, and they save with no duration. Users go at their own pace.
- **Saving:** adds an available quest to `QuestStore` and closes the sheet. Titles and categories are stored in capitals to match the other quests.
- **Placeholders:** main quests use the book icon and personal quests the hammer.
- **Unused now:** nothing calls `AsphyrTextField` anymore. Delete it in a cleanup.

## Quest Details
- **Data:** opened with a quest's id and read from `QuestStore`, so the timer and status stay live on Home and in the log.
- **Timer:** daily and personal quests time themselves from Accept, using `Quest.startedAt`, `pausedAt` and `pausedDuration`, so it keeps counting in the background. It doesn't stop at the duration: the bar stays full and the time left reads "Time's up".
- **Minimum time:** a timed quest can be completed only after half its duration has passed (`QuestReward.minimumTimeFraction`), and paused time doesn't count. Until then, Complete Quest is dimmed, with "Available in 12 min." above it. Tapping a locked button shakes that notice with a warning vibration. **Debug builds use 1%** so testing stays quick, so 30 minutes needs 18 seconds in Xcode and 15 minutes in release. Main quests have no minimum.
- **Complete Quest:** marks the quest completed, awards its XP and opens Reward.
- **Abandon quest:** asks for confirmation and returns the quest to available, resetting the timer. A main quest keeps its ticked steps and their XP.
- **Daily personal reward limit:** 3 personal quests a day earn full rewards (`RewardRules.maxFullRewardPersonalQuestsPerDay`). Later ones earn a flat +10 XP and +1 main attribute. Open quests past the limit show the bonus on Home, in the log and on Quest Details (`QuestStore.withCurrentRewards`), going back to full rewards the next day. Reward shows the small cards with "Small progress is still progress." There's no overall daily XP cap.
- **Daily step limit:** 3 main quest steps a day (`RewardRules.maxStepsPerDay`), counted by calendar day across main quests. A blocked tick shows a toast, and unticking frees one up. It uses the device clock, so changing the date can get around it until there's a backend.
- **Main quests (our own version):** no timer. A STEPS section with a progress bar replaces the timer card, and steps can be ticked once the quest is accepted. Completing needs every step ticked, otherwise the button is dimmed with "Finish every step first." above it.
- **Hidden when empty:** quests created by users have no objective, so that section is hidden.
- **Completed quests:** open read-only, with no buttons.

## Reward
- **Presentation:** a full-screen cover over Quest Details. Continue closes it and returns to where the quest was opened, so back can't reach it again.
- **Data:** `QuestStore.complete` returns a `QuestCompletion`, which holds the quest, time taken, levels and XP at that moment.
- **Loot cards:** XP in the middle, with up to two attributes tilted beside it. A quest with no attribute rewards shows XP alone. They fade and pop in one by one when the screen opens, XP first, then left, then right, with a success haptic.
- **Level up:** the banner appears when a completion finds a level Reward hasn't shown yet, including one reached earlier by ticking steps. Each level is announced once.
- **New Reward Unlocked:** appears only when a cloak unlocks, and expands in place, as in DESIGN-DECISIONS.md. "View in Character" sits under the expanded card and opens the Character tab.
- **Spirit line:** timed quests show the time taken; main quests show their step count, because they have no timer.

## Character moods
- **Home:** tapping the character cycles idle, happy, sleepy and focused, from `13.5 - Hooded traveler / Moods`. The mood resets when Home is recreated.
- **How it's drawn:** `CharacterPortrait` overlays a visor and the mood's face on the character image, so it works for all 30 color and archetype images without 90 more. The face uses `CharacterColor.faceColor`.
- **Not used:** happy's sparkles in that frame belong to the Strategist's orb, so they aren't drawn.

## Journey
- **Constellations:** each aspiration uses a real constellation, in [JOURNEY-CONSTELLATIONS-SPEC.md](JOURNEY-CONSTELLATIONS-SPEC.md). `ConstellationData.swift` is generated from the d3-celestial data, whose license is in `Resources`. Don't edit its positions by hand.
- **Stars:** every constellation takes 20 quests, spread evenly across its 5 to 10 stars, and quests earning only the small bonus still count. Tapping a star shows its name, goal and progress in the guide card for 4 seconds, and a locked star also shakes with a warning vibration.
- **Chapters:** every aspiration has 5 constellations and 100 quests in total. Every chapter's stars are written for the aspiration (`JourneyPath` for chapter 1, `JourneyChapterStars` for the rest), and custom aspirations use shared themed stars for chapters 2 to 5: practice, depth, craft and giving back. All of this copy is ours. Finishing a chapter moves straight to the next, with a message once.
- **Sky map:** pinch out or tap the header button to see all 5 chapters along a path that winds out from chapter 1 at the center, in a different layout for each aspiration (`JourneySkyLayout`). Reached chapters can be opened, and later ones are faint and unnamed, and shake with a toast. Later chapters use constellations chosen to suit the aspiration, from the same 13.
- **Paths (`JourneyPath`):** each aspiration has its own seven star names and goals: the 5 listed on Identity and the 7 others in Create Aspiration's popular choices. Matching ignores capitals and spacing. A custom aspiration, or none after Login, gets the general path. All of this copy is ours; Figma's "Swift" stars were samples. Add new aspirations to `paths`.
- **Destination:** the last star masters one skill, like "Anatomy Master", as Figma's "Swift Master" does. It's never the aspiration itself, because no one becomes a doctor in 20 quests.
- **States:** new user, on the way, star unlocked (shown once, until leaving the tab), welcome back (no completed quest for 3 days) and all lit. All lit is ours; Figma has no frame. There's no next chapter yet.
- **Welcome back can't appear in the app yet:** progress resets on relaunch. Check it in the preview.
- **Sky:** `StarField` fills the screen with small stars that stay put, and the sky map adds more.
- **Layout (`JourneyLayout`):** the constellation is 340pt across and centered in the space above the guide card, the header is pinned, and the rest scrolls. The flame spirit stays in a guide card under the constellation, replacing Figma's following spirit, speech bubble and banner. Its top line is the spirit's message, up to two lines, and its bottom line is the next star, or that star's goal right after one lights. Other goals appear when a star is tapped. The current star and destination always get a label; other labels only show if they have room.
- **Data generator:** `ConstellationData.swift` came from a script outside the repo, with stars chosen by hand. Stars under 34pt apart on screen were merged, and Auriga's two small stars beside Capella were left out so it can end on Capella.

## Journey ideas (future)
Not built, and needs a design first.
- **After 5 chapters:** the journey ends at all lit. More chapters could come later.

## Daily quests
- **Source (`DailyQuests`):** written by hand, with three quests for each of the 12 aspirations plus the general set, for each of the 4 archetypes. They rotate by day. Custom aspirations and Login use the general set, and Login uses the Explorer's. AI could replace this later.
- **Archetype:** shapes the objective and the main attribute: Strategist is Problem Solving, Scholar is Knowledge, Creator is Creativity and Explorer is Discipline. The aspiration's category gives the second attribute.
- **Rewards:** a fixed 30 minutes at Moderate, so +100 XP, +5 and +2.
- **Renewal:** by calendar day when the tabs appear or the app returns to the foreground. An untouched daily is replaced, a started one stays until finished, and completed ones stay as a record.

## Quest rules
- **Active quests:** at most two at once: the main quest plus one other, either the daily or a personal quest. When one is done, the other stays active. Enforced by `QuestStore.canStart`; a blocked Accept is dimmed, with the reason above it.
- **Quest limits:** one open main quest and five open personal quests at a time, as built in Create Quest.
- **Main quest card:** the title and step count share the top row, with the status and XP under them, like every other card. An active main quest shows ACTIVE as well as its green edge. Long titles wrap.
- **Deleting quests:** swipe left on a main or personal quest in the quest log, tap Delete, then confirm. Daily quests can't be deleted because the system renews them, and completed quests stay as a record. The cards are `List` rows, because swipe actions need one. Deleting a main quest takes back the XP from its ticked steps, and can lower the level, but earned cloaks stay.

## XP and rewards
The rules and their numbers are in [XP-SYSTEM-SPEC.md](XP-SYSTEM-SPEC.md).
- **Code:** `RewardRules` holds XP, attributes, the level curve and cloaks. `DifficultyEstimator` is the only place that decides difficulty.
- **Difficulty:** keywords for now, from the title and description. Add words to its lists as new quests get misjudged. Hard wins over Easy, and no match means Moderate.
- **On-device AI trial (3 Nov 2026):** couldn't run, because Apple Intelligence isn't enabled on this Mac, so it's still unproven. Enable it to retry; the titles are in the plan.
- **Cloaks:** recorded as unlocked, and listed on Reward. A cloak reached by ticking steps is awarded the next time any quest is completed. They're worn from the Character screen.

## Your Character
- **Character art:** `CharacterArt` draws each color and archetype from layers, with the hands in front of the item, and without an archetype it shows the character empty-handed. See Cloak art. Figma only has the Strategist's orb on the novice, so the book, brush and lantern come from `13.3 - Archetypes`, scaled from 134pt to 126pt.
- **Item colors:** items use the tunic's base and shade. Oxblood, Midnight and Plum use their bright tint instead, because dark items disappear against the cloak and background.
- **Selection:** tapping the selected card deselects it, as on Identity. With nothing selected, the title reads "WHO WILL YOU BECOME?" and BEGIN shows "Choose an archetype."

## Character
- **Data:** the name, archetype, aspiration, level, XP and attributes come from `OnboardingProfile` and `QuestStore`, in memory like the rest of the app. Changing color here also changes it on Home.
- **Cloaks:** chosen from a CLOAKS grid, which Figma doesn't have. Locked ones shake and explain themselves, and the worn cloak shows on Character and Home. A cloak unlocks when a quest is completed at its level, as on Reward.
- **Attribute bars:** attributes have no maximum, so each bar fills towards the next multiple of 25. This matches Figma's main frame, where 10 fills 40% and 15 fills 60%. Figma's new user frame shows 10 as empty, so that frame doesn't match.
- **Achievements:** our rules, since Figma only names them. First Quest: complete one quest. Level 2: reach level 2. Consistency: complete quests on 3 different days. Scholar: 25 Knowledge. Builder: 25 Problem Solving. Master: reach level 5. They're checked when a quest is completed and stay earned, like cloaks. Tapping a badge shows its rule in a toast.
- **Earned icons:** Figma only has icons for the first three badges. Scholar and Builder use their attribute's icon, and Master uses the crown.

## Cloak art
- **Layers:** `CharacterArt` builds every character from 40 images: shared base, cloak and hand layers, 6 tunics and 30 sets of details. This replaces 120 whole images, and the app uses it everywhere, including onboarding. Each rebuilt starter matched its original at 252pt.
- **Adding a cloak:** add its colors to `CharacterCloak`, with no new art. Only the cloak and hands are tinted, so crests and items don't change.
- **Hands:** the cloak's top color × 1.25.
- **Coming soon:** Green, Yellow, Snow and Teal show as locked until the store exists, with their colors still to be checked on screen.
- **Redesign planned:** the character art will be redesigned. Nothing is decided yet. New art should keep the same layers (base, cloak back, tunic, cloak front, details, hands), so `CharacterArt` and the cloak colors keep working.

## Store and inventory (planned)
Agreed on 3 Nov 2026. The store isn't built yet. The cloak art and the three new cloaks are done. The order from here is: build Settings, add saving on the device, then build the currency, Store and Inventory. Real money waits until after the backend.
- **Store:** cosmetics only, bought with a separate currency earned from quests, never with XP. The name isn't final; Embers is the suggestion.
- **Earning:** paid when a quest is completed, not per step, and limited like full rewards, so it can't be farmed by ticking steps and deleting a quest.
- **Level cloaks:** Midnight, Oxblood and Plum stay earned by level and aren't for sale.
- **New cloaks:** Green, Yellow, Snow and Teal are the first store items, and show as locked with "Coming soon" until the store exists. Starting values, to check on screen:

| Cloak | Cloak top | Cloak bottom |
|---|---|---|
| Green | `#14532B` | `#07210F` |
| Yellow | `#6B5314` | `#2B2108` |
| Snow | `#8B90A3` | `#3A3D4A` |
| Teal | `#12565E` | `#06252A` |

- **Inventory:** a full screen of what's owned and what's locked, opened from "View all" on Character. The CLOAKS row stays as a shortcut.

## Settings
- **Screens:** Settings, Profile & Identity and Notifications are pushed from Home, with the system back button. Appearance, Reset Progress, Profile Photo and Reminder Time are sheets.
- **Preferences:** `AppSettings` holds them in memory, so they reset on relaunch until saving exists. They survive logging out and resetting progress.
- **Appearance:** dark by default. Light and System work through the color sets, using Figma's Light values. Warning and the second accent keep one value, as Figma's Light frames don't define them.
- **Notifications:** the daily quest reminder is a real local notification, scheduled by `ReminderNotifications` from the time and days chosen. Push starts Off, not On as in Figma, until iOS has been asked. If it's refused, the toggle stays off and a toast explains.
- **Stored only:** the Weekly progress summary needs the backend to send email.
- **Sounds & haptics:** turns off all haptics through `hapticFeedback`, and the reminder's sound. The app has no other sounds yet.
- **Reset Progress:** also clears cloaks and badges, and returns to the Starter cloak, because they're tied to XP and levels. Identity and preferences stay. A new daily quest appears straight away.
- **Log out:** returns to Welcome and clears the profile. A sheet in the Reset Progress style warns that progress will be lost, since nothing is saved yet.
- **Profile & Identity:** name, aspiration and archetype apply on Save Changes. The photo applies immediately, with a toast, because Save Changes only covers the fields below it. Email is read-only until real accounts exist. Changing aspiration changes Journey's constellations right away, keeping quest progress. Changing aspiration or archetype also swaps a daily quest that hasn't been started. One that's started or finished today stays, so it can't earn a second daily quest.
- **Sheets:** partial-height sheets float with side margins on iOS 26, which is the system's own style, so they don't reach the screen's edges as in Figma.
- **Photo:** Take photo is hidden where there's no camera, such as the simulator. Remove photo only shows when there's a photo. The photo is in memory only.

## Streaks
- **What counts:** a day with any finished quest, including bonus-reward ones. Ticking a main quest's step doesn't count, as Figma says "Finish any quest". Rules are in `StreakRules`, counted from the finished quests, so resetting progress clears them.
- **Active:** a streak stays alive until the end of the day after the last finished quest, so today shows as open until a quest is finished.
- **Resting:** with nothing finished yesterday or today, Home shows the Rest chip and the sleeping character, and the sheet offers Find a Quest, which opens Quests. The next quest starts again from 1. Nothing is ever taken away.
- **Spirit:** tapping it in the sheet cycles its expressions, like the character on Home. It opens happy, or sleepy when resting.
- **New users:** Home shows no chip until the first quest is finished, so the flame appears as a small reward. A greyed-out 0 was tried and dropped, as it shows a score nobody has earned yet.
- **Toggles:** Show streak on Home and the Settings toggle are the same setting. Off hides the chip and the sleeping character, and stops the alert.
- **Streak alerts:** a real local notification at 8 PM on the last day that keeps the streak going. Finishing a quest moves it to the next day.
- **Known limit:** streaks use the phone's clock and reset on relaunch until saving exists.

## UI polish
- **Splash:** the flame pops in with a spring, then the name, then the tap prompt fades in.
- **Expressions on completion:** on Reward, the spirit starts surprised, then becomes cheerful, or happy for a small bonus. The character on Home and Character is happy for 4 seconds after a quest is finished.
- **Character glow:** `CharacterArt` has a soft glow in the user's color, except in the Settings and Profile avatars.
- **Character tap effect:** a small bounce and a ripple in the user's color, only when tapped.
- **Angry character:** 5 taps within 2 seconds make the character angry for 3 seconds, with an angry face and flickering flames in the character's color, a shake and a heavy vibration. `CharacterTapCounter` holds the rule, and `CharacterButton` is shared by Home and Character.
- **Create Quest:** QUEST TITLE and DESCRIPTION section titles, and the categories as two even rows that end at the same edges.
- **Dropped:** the circle animation, as the comet covers it.
- **Create Quest reward card:** a dropdown. XP and difficulty always show, and attributes appear when it's tapped.
- **Reward:** QUEST COMPLETE and the quest title are at the top, centered, with a larger spirit and its message below, then the cards and XP. The level up banner is now part of the XP row, with a pop, and the message says the level reached. The spirit and message pop in like the reward cards, and the content is centered above the button.
- **Global accent:** `AccentColor` is the app's green, which also colors system alerts' buttons.
- **Tab icons:** a tab's icon and label swap color instantly. Animating the color flashed purple for about half a second, measured at `116,8,151` in a simulator recording. After the change, a recording of the same quick taps showed none.

## Quest timer
- **Timer bar:** `QuestTimerBar` shows a timed quest's progress on Quest Details and Home, with a glowing dot at its leading edge. It replaces the elapsed time and timer icon. A halfway tick and a "Complete in 3 min" status were tried and dropped, as they needed explaining and repeated the notice above the button.
- **Countdown:** the big number is the time left, rounded up. The corner only shows "Paused" or "Time's up". Time's up takes nothing away, and the quest can still be completed.
- **When it can be completed:** the notice above the button says so.

## Animated cards and bars
- **Comet border:** `CometBorder` sends a point of light clockwise around Home's active card every 5 seconds, over a faint green edge. The quest log keeps the solid green edge, as two comets were too much.
- **Green bars:** every `XPBar` uses the primary button's gradient, `#00E63B` to `#7DFF9B`, with a rounded end. The comet uses the same two colors, so they read as one. Most bars flow slowly. The timer bar stops flowing when paused, and Character's four attribute bars fill once when they appear, so that screen stays calm. A cyan version was tried and dropped.

## Character evolution (later)
The character should change as the user levels up, as in Figma's section 11 (`13.2 - Hooded traveler / Stages`). Only Novice is built, so nothing changes with level yet.

| Stage | Levels | Figma's description |
|---|---|---|
| Novice | 1–4 | Trim and sash |
| Apprentice | 5–9 | Mantle and core |
| Adept | 10–19 | |
| Ascended | 20+ | Hood off and circlet |

Plan this together with the character art redesign, and keep the layers so cloaks still work. Ascended's hood off will need the cloak layers rethought.

## Gender (idea)
Whether users can choose a gender is undecided, and nothing is built. The character is hooded and reads as neutral today, so this would mostly affect the art. Decide with the character art redesign. If it's added, it should be optional.

## Light mode (later)
Light mode works but needs its own design pass. Nothing here is built yet.
- **Components:** review every screen's components and designs in Light.
- **Settings icon:** the gear on Home looks off.
- **Outlines:** many are hard to see. The Light border `#DCDFE6` is very close to the Light background `#F3F4F7`.
- **Colors in screens:** colors written directly into screens, like the character art and star fields, don't change with the mode.

## Figma updates for later
Every place the app has moved ahead of Figma, by screen. Development comes first, so make these only when asked, and add to this list as the code changes.

Revisions are made on the page `06 — Hi-Fi v3 (App revisions)`, a copy of `05 — Hi-Fi v2 (Polished)`, one group at a time. `05` stays untouched. Each item leaves this list once it's done.

**Sample data:** every example must match the app's code for the sample user: Lou, The Strategist, Game Developer. The daily quest comes from `DailyQuests`, and rewards from `RewardRules` and `DifficultyEstimator`.

**Sample data done on:** Home, Quests, Create Quest, Quest Details and Reward. Character still needs checking.

**Main quest card:** the developer's `8.2` design is the layout everywhere: step count at the top right, then the same status and XP row as every other card, including ACTIVE. Long titles wrap.

**At the end, when the developer says so:** number and organize every screen on `06` in order, then build the interactive prototype.

**Copying a page:** Figma's page copy lost the opacity of colors bound to variables, so see-through fills turned solid and bright on 167 layers. These were restored from `05`, and a fingerprint of fills, strokes and effects then matched on every frame. Copying frames loses them too, and so does binding a new color to a variable, so set the opacity afterwards and check after any copy.

**Done on `06`:** Welcome (`2`), Create Account (`3` to `3.5`, plus new `3.6` weak password and `3.7` password revealed), Login (`4` to `4.2`) Account Recovery (`5` to `5.2`), Build Your Identity (`7`, plus new `7.1` errors and `7.2` custom aspiration), Create Aspiration (`7.5`, plus new `7.5b` error), Your Character (`8`, plus new `8.1` unselected and `8.2` error), `13.4 - Colours`, Home (`9` to `9.3`, plus new `9.2b` two quests and `9.4` personal quest) Quests (`8`, plus new `8.1` default, `8.2` main available, `8.3` swipe, `8.4` delete confirmation and `8.5` bonus), Create Quest (plus new main quest, limits reached and small bonus frames), Quest Details (`6`, `6.1`, plus new `6.2` to `6.9`) and Reward (`7`, plus new `7.1` to `7.4`). Also done: the simplified timer, the button's gradient on every bar, Reward as option B, and Create Quest's section titles, even category rows and reward dropdown, with a new reward expanded frame. Behaviour that a still frame can't show is written beside each group as `Notes / ...`, and isn't wired up as a Figma prototype.

### All screens
- **Header position:** screens with a back button or top header sit 14pt lower than Figma (back button top 76pt, not 62pt). Move the content below down with it.
- **Toasts:** add the app's toast style wherever it's used: limits on Create Quest, the sky map and step limits.

### Character
- Replace the six old swatches under CUSTOMIZE with the app's six character colors.
- Add the CLOAKS grid with Starter, Midnight, Oxblood, Plum, Green, Yellow, Snow and Teal, in unlocked, locked, Coming soon and worn states, and the locked cloak toasts.
- Show the character wearing each cloak.
- Redesign the character art when that work starts, keeping its layers.
- Make the character tappable through its moods.
- Add earned icons for Scholar, Builder and Master, and the toast with a badge's rule.
- Fill the new user frame's attribute bars so 10 shows 40%, matching the main frame.

### Streaks
- Hide the chip on Home until the first quest is finished.
- Make the sheet's spirit tappable through its expressions.
- Add a state for a one-day streak: "You took a step today." or "You took a step yesterday."

### Motion and character effects
A still frame can't show these, so write them as notes beside the screens.
- The Comet border on Home's active card, the flowing bars, the splash logo popping in, Reward's pop-ins and its surprised then cheerful expressions.
- Add the character glow, and note the tap bounce and ripple.
- Add the angry character with flames in each character color.

### Contrast
- Add a 1pt outline to every color swatch, so Snow and the dark colors stay visible.
- Raise Journey's unlit lines, locked stars, and the sky map's path and locked shapes.

### Settings
- Add "Cloaks and badges" to Reset Progress's list, and make the sheet taller to fit.
- Add the Log out sheet, Push notifications off by default, and the permission refused toast.
- Add a success toast to `12.3 - Settings (progress reset)`, which has none.
- Pin the version line to the bottom of Settings, 30pt above the screen's edge.
- Show Save Changes as the green button at 40% when there's nothing to save, replacing the gray one.
- Show sheets with iOS 26's side margins.
- Add "Changes saved." on Profile & Identity, and show Remove photo only when there's a photo.
- Replace the Light accent `#00C934` on the Appearance preview only if it should match the Light token `#00A82E`.

### Character art
- Add the novice holding the book, brush and lantern, with each item in all six colors, the dark details on Snow and Yellow, and the white book lines on the dark colors.
- The five non-green novice characters were generated outside Figma, including Snow's dark crest. Add them if Figma should stay the source of truth.
- Add the three character mood faces for every color, as Home now uses them.

### Journey (`10`)
- Move the content down 14pt, replace Swift samples with the 13 real constellations and aspiration paths, and add the meaning line under the chapter.
- Replace the following spirit, speech bubble and banner with the guide card and its messages.
- Add five chapters with their own stars for each aspiration, the chapter complete message and the all lit state.
- Add the denser star field, the larger constellation, tap details on stars and the locked star shake.
- Add the sky map with its button, with chapter 1 at the center and a path winding out around it, in a different layout for each aspiration, showing completed, current and locked chapters, with the locked chapter toast.

### Design documents
- `DESIGN-DECISIONS.md` says the active card has a glow (y 4, blur 12, 30% green), but Figma has a hard green edge (y 1, blur 2, 100% green). The app follows Figma.

## Known issues
From the codebase inspection on 2 Nov 2026. Remove each one when it is fixed.

- **Low:** the data script that generates `ConstellationData.swift` isn't in the repo.
- **Medium:** attribute points don't scale with duration, so 15m quests earn them eight times faster than 2h+ ones. The daily limit caps the total.
- **Medium:** the minimum time and daily limits use the device clock, so changing the date gets around them until there's a backend. Read from the code; not tried.
- **Low:** a keyword anywhere in the description makes a quest Hard, so any quest can be inflated.
- **Low:** a level and cloak reached by ticking steps can be claimed by completing another quest, and the cloak stays after the main quest is deleted and its XP is taken back.
- **Low:** typing immediately after pressing return in the step field can drop characters. Seen at automated typing speed only; a 2-second gap was fine.
- **Low:** a newly added step field on Create Quest can be partly hidden behind the button.
- **Low:** at large text sizes, words break mid-word on Home's attribute cards ("KNOWLED / GE", "CREATIVIT / Y"). Seen at Accessibility Large on 3 Nov 2026.
- **Low:** `CreateAspirationView`'s header uses the same stacked layout Create Quest had, so Cancel can overlap its title at large text sizes. Inferred from the code; not checked on screen.
- **Low:** using the eye button while a password field is focused briefly drops focus, so "Passwords don't match" can appear while the user is still typing. The error clears on the next edit.
- **Low:** the keyboard's suggestion bar can still offer words for a revealed password.

- **High:** onboarding answers are only kept in memory, so they reset on relaunch. Fix when the backend arrives.
- **Medium:** Light mode has Figma's values for the main color sets, but colors written directly in screens, like the character art and star fields, don't change with it. Check each screen and add to UI polish.
- **Low:** Figma's "Already have an account? LOG IN" row on Welcome sits about 5pt right of center. The code centers it deliberately; update Figma to match if that's agreed.
