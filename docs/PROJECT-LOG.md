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

