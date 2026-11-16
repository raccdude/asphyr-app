# ASPHYR — Project log

What was done, in order, with the commands that matter. Newest at the bottom. For where things stand now, read `HANDOFF.md` first. Each entry says what was **tested** and what was only **written**.

## 12 Nov 2026 — cloud session

### Inspection
- Read the whole project: SwiftUI app (about 12,000 lines), Supabase backend, docs. Findings were reported in chat: quests didn't survive a relaunch, Delete Account only signed out, profile saves failed silently, no length limits on profile text, `photo_path` could point anywhere. All but the silent save were fixed in the steps below.
- Checked the connectors: Supabase shows organization **ASPHYR** with project `qnotkiivqelufrqcnquu`; Figma is signed in as `ylobldmr` and opens the ASPHYR file `27W7B4MhKAFJ8LwiWJgcmD`.

### Decisions (the developer's answers)
- Step 4 split into 4a (server) and 4b (app).
- Daily limits count from each user's own midnight (`profiles.time_zone`).
- The quest minimum time is a database setting, `private.settings.minimum_time_fraction`: `0.01` now, `0.5` before release.
- Claude commits and pushes only to its session branch, `claude/gifted-archimedes-l90m2f`. Commits are credited to Angelo Buedo, with no Claude co-author lines.
- From the Store onwards, Claude goes with its own recommendations and records each one here and in the spec.

### Backend step 4a — server functions
- Added `supabase/migrations/20261112090000_quest_functions.sql`: every quest and reward rule as a database function, using the server's clock.
- Added `supabase/tests/supabase-stub.sql` (a stand-in for Supabase's roles, Auth and Storage) and `supabase/tests/quest_functions.test.sql`.
- Added `scripts/db-tests/run.sh`, which builds a fresh local database, applies every migration and runs the tests:
  ```bash
  zsh scripts/db-tests/run.sh
  ```
- **Tested:** 129 checks passed on a local Postgres 16. A rule was loosened on purpose to prove the tests catch it.

### Backend step 4b — the app uses the server
- `RootView` owns `QuestStore` and loads it with the profile. Every quest action goes through `Backend/QuestStore+Server.swift` and `Backend/QuestService.swift`.
- Added `supabase/migrations/20261112100000_player_state.sql`: `get_player_state`, and replies with times as seconds since 1970.
- **Tested:** 135 database checks. The Swift was written without a compiler; the developer built and tested it on their iPhone afterwards.

### Backend step 5 — photos and Delete Account
- Added `supabase/migrations/20261112110000_profile_photos.sql`: a private `avatars` bucket, rules so only the owner can reach their photo, and length limits on the name and aspiration.
- Added the `delete-account` Edge Function in `supabase/functions/delete-account`, declared in `supabase/config.toml` so the GitHub integration deploys it.
- **Tested:** 144 database checks, plus 8 Deno tests for the function. Deno was installed from npm for this, outside the repo.

### Backend step 6 — Apple and Google sign-in
- Added `Backend/SocialSignIn.swift` and made the buttons on Login and Create Account work. They say "not available yet" until the accounts are set up (see `BACKEND-SPEC.md`, Step 6 notes).
- **Not tested:** needs the paid Apple Developer account and a Google Cloud project.

### Pushing
- The first pushes failed with 403 until the developer connected GitHub and installed the Claude GitHub App.
- Before pushing, a backup was made, then the four commits were re-credited to Angelo Buedo:
  ```bash
  git branch backup/before-author-fix
  git bundle create asphyr-backup-before-author-fix.bundle 15a7feb..backup/before-author-fix
  ```
- Pushed to `claude/gifted-archimedes-l90m2f`.

### "Something went wrong" after login
- **Cause:** the app called `get_player_state`, which returned 404, because the new migrations weren't on `main` yet, so Supabase hadn't applied them. Found in Supabase's API logs.
- **Fix:** the developer merged to `main`:
  ```bash
  git switch main
  git pull
  git merge --ff-only claude/gifted-archimedes-l90m2f
  git push
  ```
- **Checked on the live project:** all four migrations applied, 12 public functions, signed-out visitors can't call them, the `avatars` bucket and its 4 rules exist, and `delete-account` is active. Supabase's security advisor flagged the 12 functions as callable by signed-in users, which is intended, and leaked-password protection being off, which is worth turning on before release.
- The developer then tested everything on their iPhone, and it worked.

### Store and Inventory
- **Design:** `docs/superpowers/specs/2026-11-12-store-and-inventory-design.md`. Following the developer's instruction to go with Claude's recommendations: Embers at 1 per 10 XP, cloaks at 200 each, an Ember chip on Home, past quests paid once, and reset clearing Embers.
- **Plan:** `docs/superpowers/plans/2026-11-12-store-and-inventory.md`, run in this session.
- **Server, test first:** the new tests in `supabase/tests/quest_functions.test.sql` were run before the migration existed and failed as expected. Then `supabase/migrations/20261112120000_store.sql` was added, and all 159 checks and the 8 function tests passed:
  ```bash
  zsh scripts/db-tests/run.sh
  ```
- **App:** `QuestStore` reads Embers, owned cloaks and prices; `buyCloak` spends them. New `StoreView`, `StoreCloakCard` and `CloakGrid`, the `iconEmber` icon, the Ember chip on Home, and Reward's Embers line. The CLOAKS grid left Character. **Not built:** no Swift compiler in the cloud session.
- **Calls made while building**, recorded so they can be overruled:
  - After buying, the card's own button turns to WEAR; the toast only confirms, as the app's toasts have no buttons.
  - Inventory keeps a CLOAKS heading and a one-line explanation, like Character's sections.
  - The past-quest payment can't be tested locally, so it's checked on the live project after deploying.
- **To do on the Mac:** build, fix any compiler errors, test on the iPhone, then merge to `main`. After merging, Claude checks the live project.
- **Review:** a self-review of the whole Store change against the spec found nothing critical. Two small things to check on the iPhone: Reward's "VIEW IN INVENTORY" when the quest was opened from Home (it closes Quest Details and opens the Store at once), and that the Ember chip fits beside the streak chip on a smaller iPhone.
- **Merged and deployed:** the developer merged to `main` (`5a5fd68`), and Supabase applied `20261112120000_store`. Checked on the live project: the four cloaks are on sale at 200, `buy_cloak` is open to signed-in users only, and the one-off payment matched (the account with 2 completed quests got the 15 Embers they were worth).

### Profile saves no longer fail silently
- **Problem**, from the first inspection: a profile change made in the tabs (name, color, aspiration, cloak) that failed to save, for example offline, was dropped without a word.
- **Fix:** `RootView.saveProfileChanges` tries again after 2, 4 and 8 seconds, then shows "Your profile changes weren't saved. Check your connection and change them again." The toast that showed expired reset links now covers both, renamed `alertMessage`.
- **Not tested:** Swift, no compiler here. To try on the iPhone: turn on Airplane Mode, change your name in Profile & Identity, and wait about 15 seconds for the toast.
- **Also corrected** in the notes: the known issue about the phone's clock was fixed by backend step 4.
- **Tidied** the known issues: onboarding answers have been saved since backend step 3, and the duplicate silent-save entry was removed.

### Developer's batch of changes (12 Nov 2026)
- **Google only:** removed the Apple button, `SocialSignIn.swift`'s Apple code and `iconAppleLogo`. The button reads "Continue with Google". Recorded an App Review risk in `BACKEND-SPEC.md` (guideline 4.8).
- **Weekly email removed:** the EMAIL section in Notifications and `AppSettings.weeklySummary`.
- **Small bugs:** step field kept in view on Create Quest, no "Passwords don't match" flash from the eye button, no suggestions for a revealed password. The fast-typing drop was left, with the reason in Known issues.
- **Tab bar:** solid backdrop from the bar down, fading in above it.
- **Long names** wrap on Home, Character, Settings and Reward.
- **Screen sizes:** every screen was read for fixed sizes and offsets. Fixed: Journey's 402pt canvas now scales to narrower phones; sheets scroll when they don't fit (Reset Progress was 700pt, taller than an iPhone SE); Home's wordmark shrinks instead of cutting off. Splash and Account Loading keep their offsets, which match the launch screen.
- **Large text:** attribute names no longer break mid-word, and Create Aspiration's header stacks instead of overlapping.
- **Noted, not done:** turn email confirmation on (after building a check-your-email screen), delete the test accounts, and turn on leaked-password protection. See `BACKEND-SPEC.md`, Before release.
- **Not tested:** no Swift compiler or simulator here. Check on the iPhone 12 Pro Max, and on a small simulator such as iPhone SE or 13 mini: Journey, Reset Progress, the Home header, the tab bar, Create Quest's steps and Create Account's password fields.

### Second batch from the developer (12 Nov 2026, testing on an iPhone 12 Pro Max)
- **Google button did nothing:** Supabase's API logs showed `/auth/v1/authorize` answering 400, because the Google provider isn't turned on yet (it needs the Google Cloud project). The app now reads Supabase's public `/auth/v1/settings` first and says "This sign-in option isn't available yet" when Google is off. The message now shows under the Google button, so the email fields no longer turn red.
- **Tab bar too high, and covering content:** it sat a fixed 22pt above the edge, and its backdrop rose 150pt, dimming Journey's guide card and the last cards. `TabBarMetrics` now works from the phone's own safe area; see Screen sizes in `IMPLEMENTATION-NOTES.md`. Journey's guide card gap was trimmed to match the other tabs.
- **Text limits** on every field, in `TextLimits.swift`.
- **Edit quest** on a long press, test first: the new tests failed before `update_quest` existed, then all 168 database checks and the 8 function tests passed.
- **Green flash in the quest log:** each filter tap animated the whole list, cross-fading the active quest's green card. Now only the pill animates.
- **Keyboard:** Save Changes on Profile & Identity rises above the keyboard like Create Quest, which is standard iOS. This reverses the 3 Nov choice to keep it down, at the developer's request to follow the standard.
- **Back swipe in Settings:** kept. It's standard iOS, and every pushed screen already has it.
- **Not possible here:** running the app on different screen sizes. The layout was fixed from the code; check it on the 12 Pro Max and a small simulator.

### Edit quest didn't save
- **Cause:** Supabase's API logs showed `/rest/v1/rpc/update_quest` answering 404, ten times. The edit's migration was still only on the branch, so Supabase hadn't applied it. Same cause as the earlier login error.
- **Fix:** merge to `main`. The app now says "This needs a server update that isn't live yet" for this case (PostgREST code `PGRST202`) instead of "Something went wrong".
- **Rule recorded** in `HANDOFF.md`: when a branch adds a migration, merge before testing on the phone.
- **Merged:** at the developer's request, Claude fast-forwarded `main` to `1d0ecf0` (no merge commit). Supabase had already applied `20261112130000_edit_quest` from the developer's earlier merge. Checked live: `update_quest` is open to signed-in users only.

### Back on the MacBook (15 Nov 2026)
- **Setup:** the repo is cloned to `~/Documents/ILO/asphyr-app` on the MacBook, and work continues in the Claude desktop app, which edits these files directly. The lab sessions ran in the browser, on a temporary cloud copy that only reached the Mac through GitHub.
- **Inspection:** the Mac's `main` matched GitHub. The app built and the rule tests passed. No secrets are in the repo; the only key is Supabase's publishable key.
- **History:** the 19 commits from 12 Nov were replayed without the cloud session's signatures (`git rebase --force-rebase --committer-date-is-author-date --no-gpg-sign e4a2e54`), so every commit reads the same. `main` was force-pushed by the developer, and `claude/gifted-archimedes-l90m2f` was deleted.
- **Workflow:** back to approving each step first. Recorded in `HANDOFF.md`.

### Build warnings and notes cleanup
- **Warnings:** the build's 11 distinct warnings are fixed, and it now builds without warnings from the app's code.
  - Passing `Quest.init(record:)` and similar straight to `map` made them nonisolated function values. They're closures now, which keep the main actor.
  - `CharacterPortrait` reads its ripple color before the keyframe closure, which runs off the main actor.
  - `ProfileService.Row` is `nonisolated`, so Supabase can decode it in the background.
  - The photo upload uses Supabase's renamed `upload(_:data:options:)`.
  - Tab switching from Reward and the Streak sheet goes through a `TabNavigator` object instead of closures in the environment, which SwiftUI couldn't compare. The unused `openCharacter` is gone.
- **Notes:** the progress table no longer lists merged work as unmerged.
- **Not tested:** only the build was checked. The developer tests in Xcode.

### Reward redesign
- **Why:** the developer felt Reward was empty, with a narrow header above full-width cards.
- **Options shown:** a hero card, a spotlight band and a summary card. The developer picked the band and kept the tilted loot cards. Design in `docs/superpowers/specs/2026-11-15-reward-header-design.md`.
- **Built:** the spotlight band. Option A, a hero card, was tried and dropped: its compact card left more empty space, which was the original complaint.
- **Added:** the XP bar fills from the old XP to the new (through a level up), each loot card's number rolls up with a light haptic as it lands, and a tap anywhere skips to the finished screen. The reveal now runs on steps, so skipping can jump straight to the end.
- **Known limit:** the bar's starting point assumes the quest's full XP was earned. If a daily limit cut the XP, the bar starts a little low.
- **Google sign-in:** confirmed working by the developer on their iPhone.
- **Not tested:** only the build was checked.

### Reward next steps
- **Find another quest:** a gray text button under Continue opens the Quests tab, gray so it reads as the second choice. It only shows inside the tabs, so previews don't offer it.
- **Back from Reward:** Reward was presented by Quest Details, and SwiftUI only runs a cover's dismiss handler after it has slid away, so Quest Details (or, after a first fix, its empty background) flashed by. Reward is now presented by the tabs through `TabNavigator.rewardCompletion`, and Quest Details closes underneath it straight away, so Continue reveals the screen the quest was opened from.
- **Streak line:** on the day's first finished quest, Reward shows the flame and "N-day streak", arriving with the Embers. It follows the Show streaks setting.
- **Not tested:** only the build was checked.

### Light mode colors
- **Decision:** at the developer's question, Light applies only inside the app. Sign-in and onboarding stay dark: they're the brand's first impression, and the appearance is chosen in Settings, after them.
- **Fixed:** glass buttons followed Dark only, the Light border was nearly invisible, Light amber text was too faint on white, and the tab bar's shadow was a smudge on Light.
- **Checked:** in the iPhone 18 Pro Simulator, in Light, signed in by the developer. Settings, Quest Details, Reward and the Store weren't checked in Light.

### Before-release plan
- **Decision:** Google first for the friends test. Supabase's built-in email only reaches the project's team, so email confirmation stays off and custom email waits for the public release. Leaked password protection needs the Pro plan, so it's skipped.
- **Not done yet**, at the developer's request: they have issues to fix first. Their how-to is `docs/RELEASE-CHECKLIST.md`.

### Fixes for the presentation (15 Nov 2026)
- **Splash went Light on relaunch:** a returning user counts as "in the app" while the splash loads, so the Light setting applied to the splash. Dark now holds until the tabs show.
- **Tab bar on the developer's iPhone 12 Pro Max:** the bar sat about 34pt too high, content showed and could be tapped below it, and it covered Journey's message. The bar was an overlay told to ignore the bottom safe area, which that phone's iOS didn't honor; the iOS 27.2 Simulator did, so it looked right there. It now lives in a bottom safe-area inset, lowered toward the edge with an offset, on a solid background that reaches the edge. Checked on the iPhone 18 Pro Simulator.
- **Home spacing:** the character sat 6pt over the name, as in Figma, so a long name like the demo account's nearly touched it. It now starts 12pt below the name.
- **Demo account:** `supabase/demo/demo-account.sql` fills one account with 100 finished quests with real titles (all Journey chapters, a 100-day streak), one quest in progress with steps, two waiting, level 20 (43,700 XP), 2,500 Embers, and every cloak and achievement. Nothing in the app unlocks above level 8, so the higher level is for show. The developer signs up the account in the app and runs the script in the SQL Editor. Not run yet, and not tested against a database, since there's no local Postgres here.

### After the presentation prep (16 Nov 2026)
- **Decided by the developer:** TestFlight waits (no budget for the $99 Apple Developer Program); the iPhone SE check is skipped; Quests' ALL filter leaves out completed quests on purpose.
- **Later:** the before-friends steps in `RELEASE-CHECKLIST.md`, the Figma updates and the prototype.
- **Next:** character stages at levels 10 and 20, with new designs.
- **Character stages:** recommended three stages (Novice 1–9, Adept 10–19, Ascended 20+, hood kept on so cloaks still fit), to build after the presentation. Recorded in `IMPLEMENTATION-NOTES.md`, Character evolution.

### Profile icon (17 Nov 2026)
- **Problem:** on the GitHub profile, ASPHYR's icon looked smaller than NEPHLUX's at the same 72px width. `asphyr-icon.png` is 640×640 with a transparent margin and shadow, so the rounded square fills only about 75% of it; NEPHLUX's icon fills its whole frame.
- **Decision (developer):** add a separate copy instead of changing the original, so this README's header keeps its look. `docs/assets/logo/asphyr-icon-square.png` is the 480×480 rounded square, cut from the original without resizing, with the faint corner shadow cleared.
- **Profile README:** point the ASPHYR `<img>` at `https://raw.githubusercontent.com/raccdude/asphyr-app/main/docs/assets/logo/asphyr-icon-square.png`, width 72. The link works once this is merged to `main`.
