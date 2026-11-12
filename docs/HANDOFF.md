# ASPHYR — Handoff

Read this first when picking up the project on another Mac or in a new session. `PROJECT-LOG.md` has what was done, step by step. Claude's memory stays on the Mac it was written on, so everything needed to continue is here. Last updated 12 Nov 2026.

## Where things stand
- **Screens, Figma revisions and cleanup:** done, apart from the small list under "Figma updates for later" in `IMPLEMENTATION-NOTES.md`.
- **Backend:** all six steps of `BACKEND-SPEC.md` are done, merged to `main` and deployed on 12 Nov 2026, and checked by the developer on their iPhone: accounts, the saved profile and photo, quests and rewards checked by the server, and Delete Account. Google sign-in waits on a Google Cloud project; the Apple button was removed (see `BACKEND-SPEC.md`, Step 6 notes).
- **Store and Inventory:** built on 12 Nov 2026, merged to `main` and deployed. The server side is tested (159 database checks). See `IMPLEMENTATION-NOTES.md`, Store and inventory.
- **Next:** the Reward redesign. Ask the developer what feels wrong first.
- **After that:** the Figma prototype, and the Figma frames listed under "Figma updates for later".

## Services
- **Figma:** file key `27W7B4MhKAFJ8LwiWJgcmD`, page `06 — Hi-Fi v3 (App revisions)`.
- **Supabase:** project `qnotkiivqelufrqcnquu`, organization ASPHYR, Singapore, Free plan. A project called Synapse belongs to another person's account: never use it. Check which organization the connector shows before writing.
- **GitHub:** `raccdude/asphyr-app`. Migrations in `supabase/migrations`, and the Edge Functions declared in `supabase/config.toml`, deploy when they reach `main`.
- **Xcode signing:** the team in the project file is the developer's own. On another Mac, sign in to Xcode and pick the team again.

## How the developer works
These are on top of `WORKFLOW.md`:
- **Git:** the developer runs every merge to `main`. Give exact commands, each in its own block. In a cloud session, whose files are temporary, Claude commits and pushes only to that session's own branch. Commits are credited to the developer (Angelo Buedo) with no Claude co-author lines, so Claude isn't listed as a contributor.
- **Steps:** one commit per step, with its docs. Since 12 Nov 2026, Claude carries on to the next step without waiting for approval, and the developer tests on the iPhone and merges to `main`. When told to "take note" of something, record it and don't build it.
- **Tokens:** keep usage and messages short. Don't check the whole Figma file until asked, probably after the backend.
- **Figma:** edit it only when asked. List anything the app has that Figma doesn't under "Figma updates for later".
- **Testing:** the developer tests. Judge launch speed on a real iPhone opened from the Home Screen, as the simulator and Xcode's debugger add about a second. Report only what was actually run and seen.
- **Scope:** iPhone portrait, dark-first, on every current iPhone size (checked against 375pt to 440pt wide). Large text bugs get fixed when found, since 12 Nov 2026; VoiceOver and Reduce Motion aren't in scope. Light mode only needs the essential screens.
- **Previews:** use `#Preview(traits: .dark)`.
- **Sample data:** Figma examples must match the app's code for Lou, The Strategist, Game Developer.
- **Decisions:** from 12 Nov 2026, Claude goes with its own recommendation instead of asking, and records the choice and its trade-offs in the spec and `PROJECT-LOG.md`. The developer's design direction still wins: anything they've already decided stands, and they can overrule a choice afterwards.
- **Record keeping:** log every step, command and decision that matters to the project in `PROJECT-LOG.md`, on the same branch as the work.

## Checking the rules
```bash
zsh scripts/rule-tests/run.sh
```
This checks rewards, settings and onboarding without Xcode. The app itself has no test target yet.

```bash
zsh scripts/db-tests/run.sh
```
This checks the server's quest, reward, photo and security rules on a fresh local database, then the `delete-account` Edge Function. It needs a local Postgres (`brew install postgresql@17`, then `brew services start postgresql@17`) and, for the function, Deno (`brew install deno`).

## Moving to another Mac
1. Clone the repo, or `git pull` if it's already there, then open `Asphyr.xcodeproj`. Xcode downloads the Supabase library.
2. In Xcode, add an Apple ID under **Settings → Apple Accounts**, and pick the team under **Signing & Capabilities**.
3. Reconnect the Figma and Supabase connectors in Claude, and check they show the right accounts.
4. On a shared Mac, sign out of everything when finished. See below.

**On a shared Mac, sign out of:** the Apple ID in Xcode, GitHub, Figma, Supabase and Claude. Also remove saved GitHub credentials from Keychain, and remove the signing certificate if it was added.
