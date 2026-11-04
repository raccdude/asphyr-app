# ASPHYR — Backend plan (Supabase)

Approved on 4 Nov 2026. **Step 1 is done:** project `qnotkiivqelufrqcnquu` (ASPHYR, Singapore, Free plan), with the tables and security rules applied. **Steps 2 and 3 are built, and waiting on the developer's check:** email accounts, and the profile saved to the account. Settings are saved on the device.

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
These replace `QuestStore`'s rules, using the same numbers as `docs/XP-SYSTEM-SPEC.md`:
- `create_quest`: checks the limits, then works out difficulty, XP and attributes itself.
- `start_quest`, `pause_quest` and `abandon_quest`.
- `toggle_step`: checks the 3-a-day limit and adds or removes XP.
- `complete_quest`: checks the steps and minimum time, then awards rewards, cloaks and badges, and returns what Reward shows.
- `delete_quest`: removes step XP, and any level rewards that XP reached.
- `refresh_daily_quest`: the app sends today's quest text, and the server sets its rewards and allows one a day.
- `reset_progress`.

Streaks are still counted from finished quests, and Journey from the number completed, so neither needs its own table.

## In the app
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
4. **Quests and rewards:** the server functions, with tests for every rule, then connect `QuestStore`. This is the largest step.
5. **Photos and Delete Account:** Storage, the Edge Function, and real deletion.
6. **Apple and Google sign-in:** needs the paid Apple Developer account and a Google Cloud project.

After step 6, the developer is taught how to deploy to their iPhone. The Store comes next.

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
- **Launch time:** adding the library took the simulator from 0.30s to about 1.17s to Splash, because it needs `AuthenticationServices`. Measure on a real iPhone before deciding what to do.
- **Email limits:** Supabase's built-in sender is limited, so a reset email may not arrive at every address until custom email sending is set up.

## Defaults, unless the developer says otherwise
- **Project:** a new project called ASPHYR, in the developer's own Supabase account.
- **Region:** Singapore (`ap-southeast-1`), for lower delay in the Philippines, where the developer lives.
- **Email confirmation:** off during development, and on before release.

## Before release, not in these steps
- Custom email sending for sign-up and reset emails, as Supabase's built-in sender is limited.
- A privacy policy, from the developer.
- Password AutoFill: Associated Domains with an `apple-app-site-association` file on a website the developer owns. It needs the paid Apple Developer account, and could also replace the `asphyr://` reset link.
- Moving the existing Figma frames to any new states these steps add.

## Risks
- **Waiting on the network:** every action now takes a moment, so buttons need a busy state, and Reward can't appear instantly.
- **Two copies of some rules:** the app shows rewards on Create Quest before the server sets them. The tests must keep both in step.
- **Free plan:** projects pause when inactive. A real launch likely needs a paid plan, so check Supabase's current pricing first.
