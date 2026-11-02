# ASPHYR — Implementation notes

The running record of how the app is being built. Design intent lives in [DESIGN-DECISIONS.md](DESIGN-DECISIONS.md). Update this file on the same branch as the work it describes.

## Workflow
- One step per branch. A branch merges to `main` only after review and approval.
- Each step changes only the files that belong to it.
- Screens are implemented one at a time from Figma page "05 — Hi-Fi v2 (Polished)".

## Progress
| Step | Status | Branch |
|---|---|---|
| Navigation shell | In review | `fix/navigation-shell` |
| Splash and Welcome inspection | Next | — |
| Create Account | Not started | — |
| Login | Not started | — |
| Account Recovery | Not started | — |
| Recovery Success | Not started | — |
| Build Your Identity | Not started | — |
| Your Character | Not started | — |
| Tab bar and Home | Not started | — |
| Quests, Quest Details, Create Quest, Reward | Not started | — |
| Journey, Character, Settings | Not started | — |

## Navigation
- `RootView` owns the app's one `NavigationStack`. `AppRouter` owns its path and is read with `@Environment(AppRouter.self)`.
- **On the router:** Splash, Welcome, Create Account, Login, Recover, Recovery Success, Identity, Archetype. Each `AuthRoute` case maps to one screen in `RootView`.
- Home is pushed onto the root stack for now. It reaches Settings with `.navigationDestination(isPresented:)`, which works inside the path-bound stack.
- Any `#Preview` of a screen that reads the router needs `.environment(AppRouter())`, or the preview crashes.
- **Rules for a path-bound root stack (tested on the iOS 27.0 Simulator, 2 Nov 2026):**
  - Do not add a `NavigationStack` to a pushed screen. It sends the app back to the root screen. Changing `[AuthRoute]` to `NavigationPath` does not help.
  - Do not use a view-destination `NavigationLink { SomeView() }`. It crashes with `AnyNavigationPath.Error.comparisonTypeMismatch`. Use a `Button` that calls the router.
- **Before `MainTabView` is connected:** `HomeView` no longer has its own stack, so the Home tab must wrap it in a `NavigationStack`, or the Settings gear won't navigate. This also affects `MainTabView`'s preview today.
- **Unreachable screens not converted yet:** `QuestDetailsView`, `RewardView` and `CreateQuestView` still push a new `HomeView`. Fix them when they are rebuilt.

## Known issues
From the codebase inspection on 2 Nov 2026. Remove each one when it is fixed.

- **High:** `MainTabView` is unreachable, so sign-up and login end on a bare `HomeView`. Fix with the Login and Your Character steps.
- **High:** onboarding input is discarded, and Home shows hardcoded data ("Lou").
- **Medium:** Create Account has no back control.
- **Medium:** the keyboard pushes auth headers under the Dynamic Island.
- **Medium:** in landscape, Welcome's wordmark and LOG IN go off-screen.
- **Medium:** the app follows the device appearance instead of defaulting to dark, and the color sets have no Light values.
- **Medium:** Home has no back control and no log out. Fix with the Settings step.
- **Medium:** iOS offers "Use Strong Password" on Create Account and "Save Password?" after mock login and sign-up. Decide how to handle this with the Create Account step.
- **Low:** a blank white launch screen shows before Splash in light mode.
