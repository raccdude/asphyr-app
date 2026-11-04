# ASPHYR — Handoff

Read this first when picking up the project on another Mac or in a new session. Claude's memory stays on the Mac it was written on, so everything needed to continue is here. Last updated 4 Nov 2026.

## Where things stand
- **Screens, Figma revisions and cleanup:** done, apart from the small list under "Figma updates for later" in `IMPLEMENTATION-NOTES.md`.
- **Backend:** steps 1 to 3 of `BACKEND-SPEC.md` are done: Supabase project, email accounts, password reset, staying signed in, and the saved profile. Checked by the developer on their iPhone.
- **Next:** backend step 4, saving quests and rewards on the server. Wait for the developer's go-ahead.
- **After the backend:** teach the developer to deploy to their iPhone, then Store and Inventory, the Reward redesign, and the Figma prototype.

## Services
- **Figma:** file key `27W7B4MhKAFJ8LwiWJgcmD`, page `06 — Hi-Fi v3 (App revisions)`.
- **Supabase:** project `qnotkiivqelufrqcnquu`, organization ASPHYR, Singapore, Free plan. A project called Synapse belongs to another person's account: never use it. Check which organization the connector shows before writing.
- **GitHub:** `raccdude/asphyr-app`. Migrations in `supabase/migrations` deploy when they reach `main`.
- **Xcode signing:** the team in the project file is the developer's own. On another Mac, sign in to Xcode and pick the team again.

## How the developer works
These are on top of `WORKFLOW.md`:
- **Git:** the developer runs every commit, push, merge and branch command. Give exact commands, each in its own block. Claude only uses read-only git.
- **Steps:** one step per branch, and never start the next one without approval. When told to "take note" of something, record it and don't build it.
- **Tokens:** keep usage and messages short. Don't check the whole Figma file until asked, probably after the backend.
- **Figma:** edit it only when asked. List anything the app has that Figma doesn't under "Figma updates for later".
- **Testing:** the developer tests. Judge launch speed on a real iPhone opened from the Home Screen, as the simulator and Xcode's debugger add about a second. Report only what was actually run and seen.
- **Scope:** iPhone portrait, dark-first. VoiceOver, Reduce Motion and large text aren't in scope. Light mode only needs the essential screens.
- **Previews:** use `#Preview(traits: .dark)`.
- **Sample data:** Figma examples must match the app's code for Lou, The Strategist, Game Developer.
- **Decisions:** the developer's design direction wins over generic advice. Give a recommendation with its trade-offs, and let them decide.

## Checking the rules
```bash
zsh scripts/rule-tests/run.sh
```
This checks rewards, settings and onboarding without Xcode. The app itself has no test target yet.

## Moving to another Mac
1. Clone the repo, or `git pull` if it's already there, then open `Asphyr.xcodeproj`. Xcode downloads the Supabase library.
2. In Xcode, add an Apple ID under **Settings → Apple Accounts**, and pick the team under **Signing & Capabilities**.
3. Reconnect the Figma and Supabase connectors in Claude, and check they show the right accounts.
4. On a shared Mac, sign out of everything when finished. See below.

**On a shared Mac, sign out of:** the Apple ID in Xcode, GitHub, Figma, Supabase and Claude. Also remove saved GitHub credentials from Keychain, and remove the signing certificate if it was added.
