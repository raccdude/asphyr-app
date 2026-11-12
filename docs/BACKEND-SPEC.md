# ASPHYR — Backend plan (Supabase)

Approved on 4 Nov 2026. **Step 1 is done:** project `qnotkiivqelufrqcnquu` (ASPHYR, Singapore, Free plan), with the tables and security rules applied. **Steps 2 and 3 are done, and checked by the developer on their iPhone on 4 Nov 2026:** email accounts, password reset, staying signed in, and the profile saved to the account. Settings are saved on the device. **Steps 4 to 6 are done, merged to `main` and deployed on 12 Nov 2026, and checked by the developer on their iPhone:** quests and rewards on the server, photos, Delete Account, and the Apple and Google sign-in code. Apple and Google stay unavailable until their accounts are set up (see Step 6 notes). Every backend step is done.

## Goal
Real accounts, with progress that survives relaunches and moves between devices, and rewards the server checks so they can't be earned by changing the phone's clock.

## Decisions so far
- **Backend:** Supabase.
- **Offline:** the first release doesn't work fully offline. It needs a connection, and shows clear loading and no-connection states.
- **Currency, Store and Inventory:** come after this work, and aren't part of this plan.
- **Device-only saving:** dropped, except Settings below.

## How it fits together
| Piece | Used for |
|---|---|
| Supabase Auth | Sign-up, login, password reset, and later Apple and Google. The session stays signed in between launches. |
| Postgres tables | Profiles, progress, quests, steps, cloaks and badges. |
| Row Level Security | Each person can only read their own rows. |
| Database functions | Every action that earns or removes rewards. They run in one transaction and use the server's clock. |
| Storage | Profile photos, in a private bucket. |
| One Edge Function | Delete Account, because removing a login needs a secret key that can't be in the app. |

**Why database functions and not Edge Functions for rewards:** a change to XP, attributes and quest status has to succeed or fail as one, which a database transaction gives for free. This changes what the earlier comparison assumed, but Supabase is still the right choice.

## Tables
| Table | Holds | Who can write |
|---|---|---|
| `profiles` | Name, color, aspiration, archetype, worn cloak, photo path | The user, for these fields |
| `player_progress` | Earned XP, attribute gains, announced level, Journey stars seen | Server functions only |
| `quests` | Type, title, description, objective, icon, category, difficulty, duration, XP, attribute rewards, status, the start, pause and completion times, bonus flag, the day a daily was generated | Server functions only |
| `quest_steps` | Quest, position, title, the time it was ticked | Server functions only |
| `unlocked_cloaks` | Cloak, when it unlocked | Server functions only |
| `earned_achievements` | Badge, when it was earned | Server functions only |

Deleting a login removes all of that person's rows.

**Staying on the device:** Appearance, sounds and haptics, reminders and the other `AppSettings`, because they belong to the device. They reset on relaunch today, so they move to `UserDefaults`.

## Server functions
These replace `QuestStore`'s rules, using the same numbers as `docs/XP-SYSTEM-SPEC.md`. They're in `supabase/migrations/20261112090000_quest_functions.sql`:
- `create_quest(p_type, p_title, p_description, p_category, p_duration_minutes, p_steps)`: checks the limits, then works out difficulty, XP and attributes itself.
- `start_quest(p_quest)` and `abandon_quest(p_quest)`.
- `pause_quest(p_quest, p_paused)`: takes the state wanted rather than toggling, so a retry after a dropped connection is safe.
- `set_step_done(p_step, p_done)`: was `toggle_step`, renamed for the same reason. Checks the 3-a-day limit and adds or removes XP.
- `complete_quest(p_quest)`: checks the steps and minimum time, then awards rewards, cloaks and badges, and returns what Reward shows under `reward`.
- `delete_quest(p_quest)`: removes step XP, and any level rewards that XP reached.
- `refresh_daily_quest(p_title, p_description, p_objective, p_icon_name, p_category)`: the app sends today's quest text, and the server sets its rewards from the profile's archetype and allows one a day.
- `renew_daily_quest(...)`: the same, after the aspiration or archetype changes. Added to match `QuestStore.renewDailyQuest`.
- `mark_journey_seen(p_lit_star_count)`: added, because Journey's seen stars are in `player_progress`, which only the server writes.
- `reset_progress()`.

**Replies:** each returns `quest` (the changed quest with its `steps`, or null) and `player` (XP, level, attribute gains, announced level, Journey stars seen, cloaks and badges), so the app updates from the reply without a second request.

**Errors:** a short code as the message, for the app to put into words: `not_signed_in`, `not_found`, `invalid_input`, `not_allowed`, `limit_reached` and `too_soon`.

**Days:** the daily limits count from the user's own midnight, using `profiles.time_zone`. It's `UTC` until the app saves the phone's time zone in step 4b. Changing the phone's time zone could give a few extra steps once, which the developer accepted.

**Minimum time:** `private.settings.minimum_time_fraction` is `0.01` during development, matching Debug builds. It's one setting so it can change without a new app build.

**Tests:** `zsh scripts/db-tests/run.sh` applies every migration to a fresh local database and runs `supabase/tests/quest_functions.test.sql`: 129 checks, including the same cases as `scripts/rule-tests`. They ran on Postgres 16 here; the project runs 17.

Streaks are still counted from finished quests, and Journey from the number completed, so neither needs its own table.

## In the app
- **Step 4b:** `RootView` owns `QuestStore` and loads it from `get_player_state` while Splash shows, which also saves the phone's time zone. Every quest action is in `Backend/QuestStore+Server.swift` and calls `Backend/QuestService.swift`. Replies are decoded by `Models/Quests/QuestRecords.swift`. A failed action shows a toast, and if the device was out of step it reloads. The worn cloak is saved with the profile.
- `QuestStore` keeps its job, but each action calls the server and updates from the reply. Screens change as little as possible.
- Login, Create Account and Account Recovery use real accounts. Onboarding answers are saved at the end of onboarding.
- Opening the app while signed in skips Splash's tap and auth, and goes to the tabs.
- **New states:** loading, no connection, and an action that failed, using the app's toast. Reward waits for the server's reply.
- **Keys:** the app only holds the publishable key. Secret keys never go in the app or the repo.

## Steps
Each is its own branch, and the next starts only after approval.

1. **Project and tables:** create the project, then add the tables and security rules as migrations in `supabase/migrations`. Check that one user can't read another's rows.
2. **Email accounts:** add the Supabase library, real sign-up, login, logout, password reset and staying signed in. Measure launch time before and after, because of what `PhotosUI` did.
3. **Profile and onboarding:** save and load the profile, and move `AppSettings` to `UserDefaults`.
4. **Quests and rewards:** the largest step, in two parts. **4a:** the server functions, with tests for every rule. **4b:** connect `QuestStore`, and save the phone's time zone with the profile.
5. **Photos and Delete Account:** Storage, the Edge Function, and real deletion.
6. **Apple and Google sign-in:** needs the paid Apple Developer account and a Google Cloud project.

After step 6 the Store comes next. The developer already runs the app on their iPhone from Xcode.

## Step 1 results
Checked with two throwaway users, which the test then removed:
- Signing up creates a profile and starting progress.
- A user can only read their own rows, and can only edit their own profile.
- A user can't add quests, change XP, give themselves cloaks, delete quests or wear a locked cloak.
- People who aren't signed in can't read anything.
- A second open main quest and a second daily quest on the same day are refused.
- Deleting a login removes that person's rows.

Supabase's security and performance advisors reported nothing.

**GitHub:** `raccdude/asphyr-app` is connected, with working directory `.`, deploy to production from `main`, and automatic branching off, which needs the Pro plan. New files in `supabase/migrations` apply to the database when they reach `main`. A migration already applied directly must keep the same version number in its filename, so it doesn't run twice.

## Step 2 notes
- **Supabase settings changed:** `asphyr://reset-password` is an allowed redirect, and Confirm email is off for development. Turn it back on before release. `signUp` then returns no session, so Create Account will need a check-your-email state.
- **Library:** `supabase-swift`, up to the next major version from 2.55.6.
- **Launch time:** adding the library took the simulator from 0.30s to about 1.17s to Splash, because it needs `AuthenticationServices`. Opened from the Home Screen on the developer's iPhone, launch felt fast with no still flame, so nothing needs changing.
- **Unknown emails:** a reset request for an email with no account still returns success, sends nothing, and shows the same success screen, so the screen can't reveal who has an account.
- **Email limits:** Supabase's built-in sender is limited, so a reset email may not arrive at every address until custom email sending is set up.

## Step 5 notes
- **Photos:** a private `avatars` bucket, JPEG only, up to 2 MB, from `supabase/migrations/20261112110000_profile_photos.sql`. Each person has one photo at `<their id>/avatar.jpg`, and Storage policies let only them read, add, replace or remove it. `profiles.photo_path` can only point at that path. The app shrinks photos to 1024 pixels on the long side before uploading.
- **Profile limits:** the name and aspiration are at most 100 characters. The app had no limit, so this is generous.
- **Delete Account:** `supabase/functions/delete-account`. It checks the caller's session, removes their photo, then deletes their login, which removes every row of theirs. If the photo can't be removed, the login stays so the user can try again. It reads the new secret key from `SUPABASE_SECRET_KEYS`, falling back to the older service role key, which Supabase retires at the end of 2026.
- **Deploying the function:** `supabase/config.toml` declares it, so the GitHub integration deploys it when it reaches `main`, as long as **Deploy to production** is on. Supabase ignores the file's other settings for production by default. After merging, check **Edge Functions** in the dashboard lists `delete-account`. If it doesn't, deploy it once with `supabase functions deploy delete-account`.
- **Tests:** `scripts/db-tests/run.sh` also runs `deno test` on the function, with fake Supabase clients, when Deno is installed.

## Step 6 notes
- **Google only, from 12 Nov 2026:** the developer removed the Apple button. `Backend/SocialSignIn.swift` now handles Google only, and the Apple code and `iconAppleLogo` are gone.
- **How it works:** Supabase's Google sign-in page opens in a secure browser sheet and returns to `asphyr://login-callback`. No new library was added. It creates the account the first time, then the profile load sends a new user to onboarding, like email sign-up.
- **Until set up:** the button says "This sign-in option isn't available yet. Use your email for now." Cancelling says nothing.
- **To turn on Google** (needs a free Google Cloud project):
  1. In Google Cloud, set up the OAuth consent screen, then create an OAuth client of type **Web application** with the redirect URI `https://qnotkiivqelufrqcnquu.supabase.co/auth/v1/callback`.
  2. In Supabase, **Authentication → Sign In / Providers → Google**: turn it on and paste the client ID and secret.
  3. In Supabase, **Authentication → URL Configuration → Redirect URLs**: add `asphyr://login-callback`.
- **App Review risk:** Apple's guideline 4.8 says an app offering a third-party login like Google must also offer an equivalent option that limits data to name and email, lets people hide their email, and doesn't track them. Sign in with Apple is the usual answer. Email and password sign-up may not count, as it doesn't hide the email. Check the current guideline before submitting; adding Apple back would need the paid Apple Developer account.

## Defaults, unless the developer says otherwise
- **Project:** a new project called ASPHYR, in the developer's own Supabase account.
- **Region:** Singapore (`ap-southeast-1`), for lower delay in the Philippines, where the developer lives.
- **Email confirmation:** off during development, and on before release.

## Before release, not in these steps
- Set `private.settings.minimum_time_fraction` to `0.5`, to match the app's Release builds.
- Custom email sending for sign-up and reset emails, as Supabase's built-in sender is limited.
- A privacy policy, from the developer.
- Password AutoFill: Associated Domains with an `apple-app-site-association` file on a website the developer owns. It needs the paid Apple Developer account, and could also replace the `asphyr://` reset link.
- Moving the existing Figma frames to any new states these steps add.

## Risks
- **Waiting on the network:** every action now takes a moment, so buttons need a busy state, and Reward can't appear instantly.
- **Two copies of some rules:** the app shows rewards on Create Quest before the server sets them. The tests must keep both in step.
- **Free plan:** projects pause when inactive. A real launch likely needs a paid plan, so check Supabase's current pricing first.
