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
| Journey | In review | `feat/journey-v2` |
| Character | Next | — |
| Settings | Not started | — |

## Navigation
- `RootView` owns the auth and onboarding `NavigationStack`. `AppRouter` owns its path and is read with `@Environment(AppRouter.self)`.
- **On the router:** Splash, Welcome, Create Account, Login, Recover, Recovery Success, Identity, Archetype. Each `AuthRoute` case maps to one screen in `RootView`.
- **Entering the app:** `router.enterApp()` swaps the root to `MainTabView` and clears the path, so nothing can swipe back to auth or onboarding. Log out in the Settings step needs the reverse.
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
- **Character colors:** `characterNovice*` are generated from Figma's green novice by swapping its tunic base, shade (base × 0.678) and tint. Figma has no novice variants for the other five colors. At the developer's request, Snow (`#F5F7FF`) replaced Figma's orange, and Midnight, Oxblood and Plum replaced cyan, red and purple.
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
- **Main quest card:** the status pill sits in the header, under the XP reward, when available or completed. The active card has no pill, as in Figma, because its green edge shows the state.

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
- **New Reward Unlocked:** appears only when a cloak unlocks, and expands in place, as in DESIGN-DECISIONS.md. "View in Character" comes with that screen.
- **Spirit line:** timed quests show the time taken; main quests show their step count, because they have no timer.

## Character moods
- **Home:** tapping the character cycles idle, happy, sleepy and focused, from `13.5 - Hooded traveler / Moods`. The mood resets when Home is recreated.
- **How it's drawn:** `CharacterPortrait` overlays a visor and the mood's face on the character image, so it works for all 30 color and archetype images without 90 more. The face uses `CharacterColor.faceColor`.
- **Not used:** happy's sparkles in that frame belong to the Strategist's orb, so they aren't drawn.

## UI polish for later
Don't build these until asked.
- **Expressions on achievements:** change the character's and the flame spirit's expressions when there's an achievement or a completion.
- **Character glow:** wherever the character appears, add a soft glow or ring around it in the user's chosen color. Not bright.
- **Character tap effect:** add a visual effect when the character is tapped. Tapping already cycles its expressions on Home.
- **Create Quest reward card:** redesign it, possibly as a dropdown.
- **Quest Details active banner:** redesign the active timer card.
- **XP bars:** animate every progress bar with a moving linear gradient.
- **Quest cards:** animate the outlines. The developer also suggested a circle animation, possibly for these; where it goes isn't decided.

## Journey
- **Stars:** completed quests light them in order, at 1, 3, 5, 8, 11, 15 and 20 quests. These numbers are ours; Figma only shows "2 quests until Apprentice". Quests earning only the small bonus still count.
- **Paths (`JourneyPath`):** each aspiration has its own seven star names and goals: the 5 listed on Identity and the 7 others in Create Aspiration's popular choices. Matching ignores capitals and spacing. A custom aspiration, or none after Login, gets the general path. All of this copy is ours; Figma's "Swift" stars were samples. Add new aspirations to `paths`.
- **Destination:** the last star masters one skill, like "Anatomy Master", as Figma's "Swift Master" does. It's never the aspiration itself, because no one becomes a doctor in 20 quests.
- **States:** new user, on the way, star unlocked (shown once, until leaving the tab), welcome back (no completed quest for 3 days) and all lit. All lit is ours; Figma has no frame. There's no next chapter yet.
- **Welcome back can't appear in the app yet:** progress resets on relaunch. Check it in the preview.
- **Layout:** Figma's fixed positions at 402pt wide, so the constellation keeps its shape. The header is pinned, and the rest scrolls. Spirit positions beside Consistency, Debugger, Scholar and Master are ours; Figma only places it at First Steps, Apprentice and Builder.

## Journey ideas (future)
Not built, and needs a design first.
- **Real constellations:** each path uses a real constellation that represents the aspiration, instead of arbitrary positions.
- **Sky map:** zoom out to see other constellations as later chapters of the user's path.
- **Locked stars:** tapping one shakes it and says how many quests are left.

## Daily quests (future)
System generated, renewing every 24 hours, from both the aspiration and the archetype. The Journey paths can feed this.

## Quest rules
- **Active quests:** at most two at once: the main quest plus one other, either the daily or a personal quest. When one is done, the other stays active. Enforced by `QuestStore.canStart`; a blocked Accept is dimmed, with the reason above it.
- **Quest limits:** one open main quest and five open personal quests at a time, as built in Create Quest.
- **Deleting quests:** swipe left on a main or personal quest in the quest log, tap Delete, then confirm. Daily quests can't be deleted because the system renews them, and completed quests stay as a record. The cards are `List` rows, because swipe actions need one. Deleting a main quest takes back the XP from its ticked steps, and can lower the level, but earned cloaks stay.

## XP and rewards
The rules and their numbers are in [XP-SYSTEM-SPEC.md](XP-SYSTEM-SPEC.md).
- **Code:** `RewardRules` holds XP, attributes, the level curve and cloaks. `DifficultyEstimator` is the only place that decides difficulty.
- **Difficulty:** keywords for now, from the title and description. Add words to its lists as new quests get misjudged. Hard wins over Easy, and no match means Moderate.
- **On-device AI trial (3 Nov 2026):** couldn't run, because Apple Intelligence isn't enabled on this Mac, so it's still unproven. Enable it to retry; the titles are in the plan.
- **Cloaks:** recorded as unlocked, and listed on Reward. A cloak reached by ticking steps is awarded the next time any quest is completed. Wearing them comes with the Character screen.
- **Still placeholders:** the sample daily quest's fixed rewards, and generating and renewing daily quests.

## Your Character
- **Character art:** `characterNovice{Color}{Archetype}` holds the 24 combinations, one image each, so the hand stays in front of the item. `CharacterColor.noviceImageName(holdingItemOf:)` picks the image, and without an archetype it returns the empty-handed novice. Figma only has the Strategist's orb on the novice, so the book, brush and lantern come from `13.3 - Archetypes`, scaled from 134pt to 126pt.
- **Item colors:** items use the tunic's base and shade. Oxblood, Midnight and Plum use their bright tint instead, because dark items disappear against the cloak and background.
- **Selection:** tapping the selected card deselects it, as on Identity. With nothing selected, the title reads "WHO WILL YOU BECOME?" and BEGIN shows "Choose an archetype."

## Unlockable cloaks (future)
Midnight, Oxblood and Plum are planned as unlockable cloaks: the starter character's look plus a tinted cloak. The unlock rules aren't decided, and nothing is built yet. Use the same tunic and tint as the starter color, and these cloak values:

| Cloak | Cloak top | Cloak bottom |
|---|---|---|
| Midnight | `#22386F` | `#0E1730` |
| Oxblood | `#5A1A28` | `#2A0A12` |
| Plum | `#3F2268` | `#1D0F33` |

In the character art, these replace `#2B303D` (top) and `#12141A` (bottom). The hand color `#3A3F4C` becomes the cloak top × 1.25.

## Figma updates for later
- **Identity frames:** add a ring on the selected color swatch. Figma doesn't mark the selection.
- **Identity frames:** move the content down 14pt to match the lowered back button, and add the "Enter your name." and "Choose an aspiration." errors.
- **Create Aspiration:** add a saved custom aspiration on the "Something else" card, the "Enter an aspiration." error, and the sheet's 8pt floating margin.
- **Identity frames and `13.4 - Colours`:** replace orange (`#FF9F40`) with snow (`#F5F7FF`), and red, cyan and purple with Oxblood (`#4A0F1C`), Midnight (`#16264F`) and Plum (`#2F1650`).
- **Home:** move the header down 14pt to match the auth screens.
- **Quests frames:** move the content down 14pt to line up with Home's header.
- **`8 - Quests (All)`, `(Active)` and `(Available)`:** the default state has only the daily quest, marked available. Main and personal quests appear only after the user creates them. The Active frame's daily card and the "no logs" frames also need revisiting, because the daily quest means ALL and Available are never empty by default.
- **Quest Details frames:** move the content down 14pt to match the lowered back button, and add the dimmed button states with their notices above the button, the daily step limit toast, a main quest version with steps and no timer, the paused state, "Time's up", the abandon confirmation and a completed state.
- **`7 - Reward Screen`:** move the content down 14pt, use `PrimaryButtonV2`'s button, add states with no level up and no attribute rewards, the main quest line, and the expanded New Reward Unlocked card.
- **Home:** make the character tappable through its moods.
- **Journey frames:** move the content down 14pt, replace the Swift samples with the aspiration paths, and add the all lit state and the spirit's other positions.
- **Home:** change the section title by state ("ACTIVE QUEST", "TODAY'S QUEST", "AVAILABLE QUEST"), add the available state for any quest type, and `9.2`'s copy for more than one completed quest.
- **`8 - Quests (All)`:** completed quests don't appear under ALL.
- **Home:** make the available card the default for new and ongoing users. `9.1` stays as the state after a quest is started.
- **Create Quest frames:** add the quest type selection (Main and Personal, Personal selected by default, the disabled states and the "Finish a quest to create a new one." error), Development selected by default, the XP changing with duration, and the steps section with its "Add at least 3 steps." error. The sheet's content is taller as a result, so it can scroll.
- **Main quest card:** add the available state, with the status pill in the header under the XP reward.
- **Create Quest frames:** move the reward card directly under the description, hide Estimated Duration for Main, with XP for each step in the reward card, add the attributes and difficulty that update while typing, the bonus state and the limit toasts.
- **`7 - Reward Screen`:** show cloaks in the unlocked card, and add the bonus reward state with "Small progress is still progress."
- **Quest Details frames:** add the bonus reward note and amounts.
- **Quests frames:** add the swipe-to-delete action and its confirmation.
- **`DESIGN-DECISIONS.md` or active quest cards:** the doc says the active card has a glow (y 4, blur 12, 30% green), but Figma has a hard green edge (y 1, blur 2, 100% green). The app follows Figma.
- **Your Character:** add the unselected state and the "Choose an archetype." error, and move the content down 14pt to match the lowered back button.
- **Character:** add the novice holding the book, brush and lantern, and each item in all six colors. Include the dark details on Snow and Yellow, and the white book lines on the dark colors.
- **Character:** the five non-green novice characters are generated outside Figma, including Snow's dark crest. Add them to Figma if you want it to stay the source of truth.

Development comes first. Make these only when asked. Add to this list as the code moves ahead of Figma.

- **Back button and wordmark:** move them down 14pt on `4 - Login` and the Account Recovery frames (back button top from 62pt to 76pt), and everything below them with it.
- **`2 - Welcome`:** move the wordmark down 20pt so it lines up with the other auth screens. The rest of the frame stays where it is.
- **Login frames `4` to `4.2`:** end "Forgot password?" at the field's right edge (about 6pt in), and center the "Don’t have an account? CREATE ACCOUNT" row (about 6pt left).
- **Create Account frames `3` to `3.5`:** add the back button, with the same header as Login.
- **Create Account:** add a frame for a weak password on submit, with the checklist showing unmet items and no error row.
- **Password field:** add the open-eye icon for the revealed state. The app uses the SF Symbol `eye` for now.
- **`2 - Welcome`:** center the "Already have an account? LOG IN" row. It sits about 5pt right of center, and the app centers it.

## Known issues
From the codebase inspection on 2 Nov 2026. Remove each one when it is fixed.

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
- **Medium:** Character and Settings are bare placeholders that follow the device appearance, so they can show white with the tab bar's dark fade. Fix in their steps.
- **Medium:** the app follows the device appearance instead of defaulting to dark, and the color sets have no Light values.
- **Low:** Figma's "Already have an account? LOG IN" row on Welcome sits about 5pt right of center. The code centers it deliberately; update Figma to match if that's agreed.
- **Medium:** Home has no back control and no log out. Fix with the Settings step.
