# ASPHYR — Implementation notes

The running record of how the app is being built. Design intent lives in [DESIGN-DECISIONS.md](DESIGN-DECISIONS.md). Update this file on the same branch as the work it describes.

## Project structure
- **`Components`:** reusable pieces, grouped by feature: `Auth`, `Buttons`, `Cards`, `Character`, `Common`, `Effects`, `Inputs`, `Journey`, `Quests`.
- **`Backend`:** the connection to Supabase, and account actions.
- **`DesignSystem`:** colors and typography.
- **`Models`:** data and rules, grouped as `Journey`, `Profile`, `Quests`, `Settings`.
- **`Views`:** one folder per area: `App` (root, router and tabs), `Authentication`, `Onboarding`, `Home`, `Quests`, `Journey`, `Character`, `Settings`.
- **Names:** one main type per file, and the file carries its name. `SettingsComponents.swift` is the exception, as it holds Settings' small shared pieces.
- **Previews:** use `#Preview(traits: .dark)`, or `#Preview("Name", traits: .dark)`, so the canvas matches the dark-first app. The trait is in `DesignSystem/DarkPreview.swift`.
- **Adding files:** the project uses a synchronized folder, so new or moved files in `Asphyr` join the app without touching the project file.

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
| Figma revisions | Merged. Prototype and a few small items remain, listed under Figma updates | `docs/figma-revisions` |
| Code cleanup, file grouping and launch speed | Merged | `docs/figma-revisions` |
| Reward rules and Delete Account | On a branch, not merged | `feat/reward-rules-delete-account` |
| Backend step 1: project and tables | Done, not merged | `feat/backend-setup` |
| Backend steps 2 and 3: email accounts and profile | Done, ready to merge | `feat/backend-accounts` |
| Backend step 4: quests and rewards on the server | Merged and deployed, checked on iPhone | `claude/gifted-archimedes-l90m2f` |
| Backend step 5: photos and Delete Account | Merged and deployed, checked on iPhone | `claude/gifted-archimedes-l90m2f` |
| Backend step 6: Apple and Google sign-in | Merged. Waits on the Apple and Google accounts | `claude/gifted-archimedes-l90m2f` |
| Store, Inventory and Embers | Written 12 Nov 2026, server tested. App not built in Xcode yet | `claude/gifted-archimedes-l90m2f` |

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
- **Bundled weights:** only the ones in use: Inter Regular, Medium and SemiBold, and Space Grotesk Medium and Bold. To use another weight, add its file to `Fonts`, the project and `UIAppFonts`.

## Create Account
- **Components for Figma v2 auth screens:** `AuthTopBar`, `AsphyrInputField`, `FieldErrorRow`, `PasswordChecklist`, `SocialSignInRow`, `OrDivider`, `AuthSwitchPrompt`. Login uses these too.
- **Input field taps:** keep the focus tap gesture behind the text field. On top of it, iOS reads the tap as a second tap and selects the whole word, so the next key replaces the value.
- **Validation:** errors appear when leaving a field and on submit, and clear when that field is edited. A weak password blocks submit and keeps the checklist visible, a state Figma has no frame for.
- **Header (all auth screens):** Create Account, Login, Account Recovery and Recovery Success share `AuthScreen` and `AuthHeader`, so change spacing there and it applies everywhere. Welcome also uses `AuthScreen`, with `showsBackButton: false`, so its wordmark sits in the same position. Home has its own wordmark; line it up in the Home step. `AuthTopBar` draws a custom glass back button and hides the system bar, an exception recorded in DESIGN-DECISIONS.md. Swipe-back is turned on only while that screen is visible, so Welcome and Home stay unaffected. The back button starts at 76pt on iPhone 18 Pro.
- **Backend choice:** Supabase, chosen on 4 Nov 2026 over Firebase. ASPHYR's data is connected and suits tables, Edge Functions can check rewards on the server, and standard Postgres avoids lock-in. The first release doesn't need to work fully offline, as decided on the same day, so it won't build offline sync. It still needs clear loading and no-connection states.
- **Opening the app:** a signed-in user sees Splash without its prompt while the profile loads, for at least 1.2 seconds so the animation plays, then the tabs, or Build Your Identity if onboarding wasn't finished. Tapping moves on as soon as the profile is ready. There's no tap requirement, because this is an app people open daily. With no connection, `AccountLoadingView` offers Try again and Log out.
- **Profile:** `ProfileService` saves it when onboarding finishes, and half a second after a change in the tabs. Settings are saved on the device.
- **Email accounts are real:** sign-up, login, logout, password reset and staying signed in use Supabase, through `Backend/AccountService.swift`. The Apple and Google buttons work from backend step 6, once their accounts are set up (see `BACKEND-SPEC.md`, Step 6 notes).
- **`StatusError`** is now `#FF5C5C`, Figma's Error value.
- **Password prompts are kept on purpose.** iOS's "Use Strong Password" and "Save Password?" come from the correct field types, which password managers rely on.

## Login
- **Password suggestions:** on the developer's iPhone, they work on Create Account (4 Nov 2026). Linking saved passwords to the app fully needs Associated Domains, which needs the paid Apple Developer account and a website the developer owns. Check this before release.
- **Errors:** a malformed email, an empty field or wrong details show "Incorrect email or password", and connection and rate-limit problems show their own message. All clear on edit.
- **After login:** goes to the tabs through `router.enterApp()`.
- **Save Password prompt:** iOS offers this after logging in, and it stays on purpose. It's standard, and the same field settings let password managers fill in the login.

## Account Recovery
- **Spirit:** `SpiritView` shows wave, focused, surprised or cheer, and crossfades between them. The assets are original-color SVGs in the catalog. Add other moods there when their screens are built.
- **Reset email:** Supabase sends the link, which opens `asphyr://reset-password` and then `SetNewPasswordView`. These links don't send a password recovery event, so `RootView` opens the screen itself. Each link works once, and an expired or used one shows a toast. Resend starts a 30-second countdown. An unknown email still shows success, so the screen can't reveal who has an account. The link must be opened on the device that asked for it.
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
- **Completion card:** from `9.2 - Home (completion)`, shown under "TODAY'S PROGRESS" once nothing is active or available. It counts every completed quest and totals their XP, and its button opens Create Quest. The count should become today's only when daily quests renew. The copy for more than one quest is ours. New and ongoing users start on the available card. Once started, it uses the active style and elapsed-time row from `9.1 - Home (active quest)`.
- **Streak chip:** built and checked, but hidden while `streakDays` is 0. Nothing counts streaks yet.
- **Unused now:** the `Character` component is left over from the old Home and Your Character. Delete it in a cleanup.

## Quests list
- **Who creates each quest type:**
  - **Daily:** system generated. It renews every 24 hours and is based on the user's aspiration and archetype. This isn't built yet; `Quest.sampleDaily` is a fixed placeholder.
  - **Main and personal:** user generated, through Create Quest. Neither appears by default. The developer stated this for main quests; personal is treated the same because it's also offered on Create Quest.
- **Data:** `QuestStore` is created in `RootView`, loaded from the server with the profile while Splash shows, and read from the environment. Every action goes through `Backend/QuestStore+Server.swift`, which calls the server and updates from its reply. A failed action shows a toast, and if the device was out of step it reloads. `QuestStore`'s own actions are the device copy of the rules, for previews and `scripts/rule-tests`.
- **Filters:** ALL shows every open quest, available or active, and completed quests appear only under Completed so they don't pile up. The others match on status. Sections with no matching quests are hidden. Each filter has its own empty state.
- **Testing other states:** by default ALL and Available show the daily quest, and Active and Completed show their empty states. `QuestsView` has "All quest types", "No quests" and "Completed quest" previews for the rest.

## Create Quest
- **Presentation:** a system sheet at the large detent, opened by the + button in the quest log. iOS shows this detent edge to edge, seen on the iPhone 17 simulator, so it uses a 20pt margin instead of the 12pt margin on Create Aspiration's floating sheet. The content is taller than the screen, so the reward card needs a scroll.
- **Quest type selection:** our own version, because Figma has no design yet. Two cards, Main and Personal, sit above Estimated Duration. Daily isn't offered because the system creates it. It uses the same selected style as this screen's duration and category controls.
- **Default state:** Personal, 30m and Development (the first category) are selected, with an empty title and description. Type, duration and category always keep a selection.
- **Validation:** on submit only. The title is required and the description is optional. Main quests also need at least 3 steps. Each error clears on edit.
- **Main quest steps:** our own version. A STEPS section appears on this screen when Main is selected, with 3 to 10 steps that can be removed before saving. Text left in the step field is added on submit. Checking steps off comes with Quest Details.
- **Quest limits:** one open main quest and five open personal quests at a time; completed quests don't count. A card at its limit is dimmed and reads "Already created" or "Limit reached", and tapping it shows a toast explaining the limit. If Personal is at its limit, Main is selected instead. If both are, "Finish a quest to create a new one." appears and Create Quest does nothing.
- **Main quests have no time limit:** Estimated Duration is hidden when Main is selected, and they save with no duration. Users go at their own pace.
- **Saving:** sends the quest to the server, which works out its difficulty, XP and attributes, then closes the sheet. A failure keeps the sheet open with a toast. Titles and categories are stored in capitals to match the other quests.
- **Placeholders:** main quests use the book icon and personal quests the hammer.

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
- **Data:** `QuestStore.completeQuest` returns a `QuestCompletion` built from the server's reply, which holds the quest, time taken, levels, XP and new cloaks at that moment.
- **Loot cards:** XP in the middle, with up to two attributes tilted beside it. A quest with no attribute rewards shows XP alone. They fade and pop in one by one when the screen opens, XP first, then left, then right, with a success haptic.
- **Level up:** the banner appears when a completion finds a level Reward hasn't shown yet, including one reached earlier by ticking steps. Each level is announced once.
- **New Reward Unlocked:** appears only when a cloak unlocks, and expands in place, as in DESIGN-DECISIONS.md. "View in Character" sits under the expanded card and opens the Character tab.
- **Spirit line:** timed quests show the time taken; main quests show their step count, because they have no timer.

## Character moods
- **Home:** tapping the character cycles idle, happy, sleepy and focused, from `20.5 - Hooded traveler / Moods`. The mood resets when Home is recreated.
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
- **Welcome back:** progress is saved on the server from backend step 4, so it can now appear in the app.
- **Sky:** `StarField` fills the screen with small stars that stay put, and the sky map adds more.
- **Layout (`JourneyLayout`):** the constellation is 340pt across and centered in the space above the guide card, the header is pinned, and the rest scrolls. The flame spirit stays in a guide card under the constellation, replacing Figma's following spirit, speech bubble and banner. Its top line is the spirit's message, up to two lines, and its bottom line is the next star, or that star's goal right after one lights. Other goals appear when a star is tapped. The current star and destination always get a label; other labels only show if they have room.
- **Figma:** frames `14` to `14.8` on `06` follow the app, with Lou's Game Developer path. Star field positions use the same seeds as the app. `21.5 - Journey (Light)` still shows the old design and waits for light mode. The star shake and sky map zoom are motion, so Figma can't show them.
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
- **Difficulty:** keywords for now. Only the title can make a quest Hard, and Easy words count in the title or description. Add words to its lists as new quests get misjudged. Hard wins over Easy, and no match means Moderate.
- **Attributes:** scale with duration, with 30 minutes as the base: 15m ×0.5, 1h ×2 and 2h+ ×3, rounding up. Main and daily quests earn the base.
- **Level rewards need their XP:** if unticking or deleting a main quest drops the level, cloaks and level badges above it go too, and a worn cloak returns to the starter look. The level is announced again when it's earned back. Other badges, like First Quest, stay.
- **On-device AI trial (3 Nov 2026):** couldn't run, because Apple Intelligence isn't enabled on this Mac, so it's still unproven. Enable it to retry; the titles are in the plan.
- **Cloaks:** recorded as unlocked, and listed on Reward. A cloak reached by ticking steps is awarded the next time any quest is completed. They're worn from the Character screen.

## Your Character
- **Character art:** `CharacterArt` draws each color and archetype from layers, with the hands in front of the item, and without an archetype it shows the character empty-handed. See Cloak art. Figma only has the Strategist's orb on the novice, so the book, brush and lantern come from `20.3 - Hooded traveler / Archetypes`, scaled from 134pt to 126pt.
- **Item colors:** items use the tunic's base and shade. Oxblood, Midnight and Plum use their bright tint instead, because dark items disappear against the cloak and background.
- **Selection:** tapping the selected card deselects it, as on Identity. With nothing selected, the title reads "WHO WILL YOU BECOME?" and BEGIN shows "Choose an archetype."

## Character
- **Data:** the name, archetype, aspiration, level, XP and attributes come from `OnboardingProfile` and `QuestStore`, in memory like the rest of the app. Changing color here also changes it on Home.
- **Cloaks:** chosen in the Inventory since the Store was built (see Store and inventory). The worn cloak still shows on Character and Home.
- **Attribute bars:** attributes have no maximum, so each bar fills towards the next multiple of 25. This matches Figma's main frame, where 10 fills 40% and 15 fills 60%. Figma's new user frame shows 10 as empty, so that frame doesn't match.
- **Achievements:** our rules, since Figma only names them. First Quest: complete one quest. Level 2: reach level 2. Consistency: complete quests on 3 different days. Scholar: 25 Knowledge. Builder: 25 Problem Solving. Master: reach level 5. They're checked when a quest is completed and stay earned, like cloaks. Tapping a badge shows its rule in a toast.
- **Earned icons:** Figma only has icons for the first three badges. Scholar and Builder use their attribute's icon, and Master uses the crown.

## Cloak art
- **Layers:** `CharacterArt` builds every character from 40 images: shared base, cloak and hand layers, 6 tunics and 30 sets of details. This replaces 120 whole images, and the app uses it everywhere, including onboarding. Each rebuilt starter matched its original at 252pt.
- **Adding a cloak:** add its colors to `CharacterCloak`, with no new art. Only the cloak and hands are tinted, so crests and items don't change.
- **Hands:** the cloak's top color × 1.25.
- **Store cloaks:** Green, Yellow, Snow and Teal are sold in the Store for Embers. Their colors still need checking on screen.
- **Redesign planned:** the character art will be redesigned. Nothing is decided yet. New art should keep the same layers (base, cloak back, tunic, cloak front, details, hands), so `CharacterArt` and the cloak colors keep working.

## Store and inventory
Built on 12 Nov 2026 from `docs/superpowers/specs/2026-11-12-store-and-inventory-design.md`, which records every choice and why. The server side is tested; the app side was written without a Swift compiler.
- **Embers:** 1 for every 10 XP a quest gives, rounded down, paid when it's completed. Steps pay nothing, so ticking and deleting earns nothing. A bonus quest gives 1. Existing accounts were paid once for quests they had already completed. The server keeps the balance in `player_progress.embers`.
- **Prices:** Green, Yellow, Snow and Teal cloaks at 200 Embers each, in `private.store_items` on the server. Change a price there; the app needs no update.
- **Buying:** `buy_cloak` checks the item is for sale, isn't owned and is affordable, then takes the Embers and adds the cloak, in one go. The app asks to confirm first. Short of Embers, the price is dimmed and a tap says how many more are needed.
- **Home:** an Ember chip in the top row, beside the streak chip and Settings, shows the balance and opens the Store.
- **Store screen:** `Views/Store/StoreView.swift`, pushed like Settings, with a STORE / INVENTORY switch. Each store card shows the user's own character wearing the cloak, with its price, WEAR or WEARING.
- **Inventory:** the cloak grid moved from Character into `Components/Character/CloakGrid.swift`. Locked cloaks say "Level 3" or "200 Embers", and a tap explains how to get them.
- **Reward:** "+10 Embers" under the loot cards, and "VIEW IN INVENTORY" in place of "VIEW IN CHARACTER".
- **Kept:** Midnight, Oxblood and Plum stay level rewards, not for sale. A bought cloak is never taken back when XP drops. Reset progress clears Embers and bought cloaks.
- **Icon:** `iconEmber`, a small cut gem drawn for this, in the reward gold.

| Cloak | Cloak top | Cloak bottom |
|---|---|---|
| Green | `#14532B` | `#07210F` |
| Yellow | `#6B5314` | `#2B2108` |
| Snow | `#8B90A3` | `#3A3D4A` |
| Teal | `#12565E` | `#06252A` |

## Reward redesign (planned)
The developer still doesn't like the Reward screen, even after option B, so it needs another redesign. Nothing is decided and nothing is built. Start by asking what feels wrong, then propose options before changing Figma or the app.

## Settings
- **Account rows:** Log out, then Reset progress, then Delete account.
- **Delete Account:** required by Apple for apps with accounts. It calls the `delete-account` Edge Function, which removes the photo, the login and every row of the account's data, then stops reminders, clears the device and returns to Welcome. If it fails, the user stays signed in and sees why. A privacy policy is also needed before release, supplied by the developer.
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
- **Photo:** Take photo is hidden where there's no camera, such as the simulator. Remove photo only shows when there's a photo. The photo is saved in Storage from backend step 5, shrunk to 1024 pixels on the long side, and a failed upload shows a toast.

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
- **Splash:** the flame carries on from the launch screen and pops, then the name and tap prompt appear. See App icon and launch.
- **Expressions on completion:** on Reward, the spirit starts surprised, then becomes cheerful, or happy for a small bonus. The character on Home and Character is happy for 4 seconds after a quest is finished.
- **Character glow:** `CharacterArt` has a soft glow in the user's color, except in the Settings and Profile avatars.
- **Character tap effect:** a small bounce and a ripple in the user's color, only when tapped.
- **Angry character:** 5 taps within 2 seconds make the character angry for 3 seconds, with an angry face and flickering flames in the character's color, drawn by `FlameShape` to match Figma's `20.7` sheet, with an outline inside each flame, a shake and a heavy vibration. `CharacterTapCounter` holds the rule, and `CharacterButton` is shared by Home and Character.
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
The character should change as the user levels up, as in Figma's section 11 (`20.2 - Hooded traveler / Stages`). Only Novice is built, so nothing changes with level yet.

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
Light mode works but needs its own design pass. Nothing here is built yet. Figma only needs Light versions of the essential screens: Home, Quests, Quest Details, Reward, Journey, Character, Settings and Appearance, not every screen. When a Dark frame changes, copy it again, because copies lose the opacity of colors bound to variables and must have it restored.
- **Components:** review every screen's components and designs in Light.
- **Settings icon:** the gear on Home looks off.
- **Outlines:** many are hard to see. The Light border `#DCDFE6` is very close to the Light background `#F3F4F7`.
- **Colors in screens:** colors written directly into screens, like the character art and star fields, don't change with the mode.

## Figma updates for later
Every place the app has moved ahead of Figma, by screen. Development comes first, so make these only when asked, and add to this list as the code changes.

Revisions are made on the page `06 — Hi-Fi v3 (App revisions)`, a copy of `05 — Hi-Fi v2 (Polished)`, one group at a time. `05` stays untouched. Each item leaves this list once it's done.

**Sample data:** every example must match the app's code for the sample user: Lou, The Strategist, Game Developer. The daily quest comes from `DailyQuests`, and rewards from `RewardRules` and `DifficultyEstimator`.

**Sample data done on:** Home, Quests, Create Quest, Quest Details, Reward, Journey and Character.

**Main quest card:** the developer's `10.9` design is the layout everywhere: step count at the top right, then the same status and XP row as every other card, including ACTIVE. Long titles wrap.

**Prototype later:** the screens are numbered and organized. Build the interactive prototype when the developer asks.

**Copying a page:** Figma's page copy lost the opacity of colors bound to variables, so see-through fills turned solid and bright on 167 layers. These were restored from `05`, and a fingerprint of fills, strokes and effects then matched on every frame. Copying frames loses them too, and so does binding a new color to a variable, so set the opacity afterwards and check after any copy.

**Frame numbers on `06`:** organized in app-flow order, one row per section, with each section's notes at the end of its row.

| Section | Frames |
|---|---|
| 01 Splash & Welcome | `1` Splash, `2` Welcome |
| 02 Create Account | `3` to `3.7` |
| 03 Log in & recovery | `4` to `4.2` Login, `5` to `5.2` Account Recovery, `5.3` and `5.4` Recovery Success |
| 04 Identity & archetype | `6` to `6.3` Identity Creation, `7` to `7.2` Create Aspiration, `8` to `8.2` Archetype Selection |
| 05 Home | `9` to `9.4` |
| 06 Quests | `10` to `10.12` |
| 07 Create Quest | `11` to `11.7` |
| 08 Quest Details | `12` to `12.10` |
| 09 Reward | `13` to `13.4` |
| 10 Journey | `14` to `14.8` |
| 11 Character | `15` to `15.5` |
| 12 Streaks | `16` to `16.4` |
| 13 Settings | `17` to `17.6` |
| 14 Profile & Identity | `18` to `18.6` |
| 15 Notifications | `19` to `19.2` |
| 16 Character art | `20.1` to `20.8` |
| 17 Light mode | `21.1` to `21.8`: only the essential screens, copied from the current Dark frames and set to the Light color mode |

**Done on `06`:** every revision group above the list below: auth, onboarding, Home, Quests, Create Quest, Quest Details, Reward, Journey, Character, Streaks, Settings and character art, with the app's toast style, side margins on sheets, 76pt back buttons and swatch outlines. `20.6` to `20.8` are built from the app's own SVG layers. The developer preferred the sheet's angry flames to the old `flame.fill` symbol, so the app now draws the sheet's shape, with an inner outline added to both. Behaviour that a still frame can't show is written beside each group as `Notes / ...`, and motion is in `Notes / Motion`. None of it is wired up as a Figma prototype yet.

### Accounts
- Add a Set New Password frame, matching `SetNewPasswordView`, and the busy state on the primary button.
- Add the no-connection screen, matching `AccountLoadingView`.
- Add the new account errors on Create Account, Login and Account Recovery if they should have frames.

### Planned designs
Figma doesn't have these yet, because the app doesn't either.
- **Store and Inventory:** built in the app first, so Figma needs: the Store and Inventory frames, the Ember chip on Home's frames, the CLOAKS grid removed from Character (`15` to `15.5`), the Embers line and "VIEW IN INVENTORY" on Reward (`13` to `13.4`), and the `iconEmber` icon. See Store and inventory.
- **Reward:** new frames for `13` to `13.4` once a redesign is chosen. See Reward redesign.
- **Character art:** new art and the level stages, when that work starts, keeping its layers. See Character evolution.

**Full Figma checks:** the developer will ask for a pass over the whole file, probably after the backend. Don't run one before then, because it uses a lot of tokens.


## App icon and launch
- **App icon:** `AppIcon` comes from `Logo / Prism icon` on `03 — Design System`, rendered at 1024 with square corners and no transparency, because iOS rounds the corners itself. The diagonal line is part of that design. The dark and tinted slots use the same image for now.
- **Launch screen:** `LaunchScreen.storyboard` shows the Prism mark on a fixed dark background, `#0B0D12`. It's a storyboard because the `UILaunchScreen` color was ignored on the iPhone 18 Pro simulator, which showed white behind the logo. iOS draws it before the app runs, so it stays dark even if Light is chosen in Settings.
- **If the flame moves in Splash, update the storyboard's centerY constant,** or the flame will jump on launch. The -95pt comes from Splash's -64 offset plus half of the 21pt gap and the name's line height.
- **Splash:** the flame starts visible, to carry on from the launch screen, then pops. The halo, name and tap prompt then appear.
- **Launch speed:** on the simulator, or when run from Xcode, the flame can sit still for about a second, because `AuthenticationServices`, which Supabase's login library needs, is slow to load there. Opened from the Home Screen on the developer's iPhone (4 Nov 2026), launch felt fast, with no still flame, so no workaround is needed. Judge launch speed on a real iPhone, opened from the Home Screen.
- **Stale launch screens:** iOS caches them. If an old one shows, delete the app from the device and run it again.

## Deploying to a phone (teach at the end)
After the backend is implemented, Claude walks the user through putting the app on their own iPhone, step by step. Not before then.

## Known issues
From the codebase inspection on 2 Nov 2026. Remove each one when it is fixed.

- **Low:** the data script that generates `ConstellationData.swift` isn't in the repo.
- **Medium:** the minimum time and daily limits use the device clock, so changing the date gets around them until there's a backend. Read from the code; not tried.
- **Low:** a word in the title can still make a quest Hard, so a title can be inflated. The daily limits cap what that earns, and proper checking waits for better difficulty judging.
- **Low:** typing immediately after pressing return in the step field can drop characters. Seen at automated typing speed only; a 2-second gap was fine.
- **Low:** a newly added step field on Create Quest can be partly hidden behind the button.
- **Low:** at large text sizes, words break mid-word on Home's attribute cards ("KNOWLED / GE", "CREATIVIT / Y"). Seen at Accessibility Large on 3 Nov 2026.
- **Low:** `CreateAspirationView`'s header uses the same stacked layout Create Quest had, so Cancel can overlap its title at large text sizes. Inferred from the code; not checked on screen.
- **Low:** using the eye button while a password field is focused briefly drops focus, so "Passwords don't match" can appear while the user is still typing. The error clears on the next edit.
- **Low:** the keyboard's suggestion bar can still offer words for a revealed password.

- **High:** onboarding answers are only kept in memory, so they reset on relaunch. Fix when the backend arrives.
- **Fixed in backend step 4:** quests, XP, attributes, cloaks, badges and the worn cloak are saved on the server.
- **Fixed in backend step 5:** the profile photo is saved in Storage.
- **Low:** if a profile change fails to save in the tabs, nothing tells the user. It saves with the next change.
- **Fixed in backend step 5:** Delete Account deletes the login and its data through the `delete-account` Edge Function.
- **Medium:** Light mode has Figma's values for the main color sets, but colors written directly in screens, like the character art and star fields, don't change with it. Check each screen and add to UI polish.
