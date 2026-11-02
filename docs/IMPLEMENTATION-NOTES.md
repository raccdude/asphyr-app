# ASPHYR — Implementation notes

The running record of how the app is being built. Design intent lives in [DESIGN-DECISIONS.md](DESIGN-DECISIONS.md). Update this file on the same branch as the work it describes.

## Workflow
See [WORKFLOW.md](WORKFLOW.md) for how we work. Screens are implemented one at a time from Figma page "05 — Hi-Fi v2 (Polished)".

## Progress
| Step | Status | Branch |
|---|---|---|
| Navigation shell | Merged | `fix/navigation-shell` |
| Splash and Welcome inspection | Done | — |
| Splash and Welcome polish | In review | `fix/splash-welcome-polish` |
| Create Account | Next | — |
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

## Platform scope
- **Current target:** iPhone only, portrait only.
- **Future work:** landscape, iPad and other screen sizes. Enabling them means changing the device family and orientation build settings, and designing and testing layouts for each.
- **Not in scope for now:** VoiceOver and Reduce Motion work. Leave the support already in the code in place, but don't plan or test it.
- **Still in scope:** large text sizes. Don't truncate copy; let layouts wrap or scroll.

## Fonts
- The app bundles **Inter 3.19** (`Inter Desktop` OTFs from the [official release](https://github.com/rsms/inter/releases/tag/v3.19)), with its license in `Fonts/Inter-LICENSE.txt`.
- **Why this version:** Figma's Inter has Slant and Weight axes but no Optical Size, which points to Inter 3. Modern Inter's static cuts are narrower, so don't swap in Google Fonts' Inter.
- **Measured on Welcome's first message line:** the 24pt cut was 320pt wide, the 18pt cut 329pt, and Inter 3.19 is 337pt, the same as Figma.
- Space Grotesk matches Figma.

## Known issues
From the codebase inspection on 2 Nov 2026. Remove each one when it is fixed.

- **High:** `MainTabView` is unreachable, so sign-up and login end on a bare `HomeView`. Fix with the Login and Your Character steps.
- **High:** onboarding input is discarded, and Home shows hardcoded data ("Lou").
- **Medium:** Create Account has no back control.
- **Medium:** the keyboard pushes auth headers under the Dynamic Island.
- **Medium:** the app follows the device appearance instead of defaulting to dark, and the color sets have no Light values.
- **Low:** Figma's "Already have an account? LOG IN" row on Welcome sits about 5pt right of center. The code centers it deliberately; update Figma to match if that's agreed.
- **Medium:** Home has no back control and no log out. Fix with the Settings step.
- **Medium:** iOS offers "Use Strong Password" on Create Account and "Save Password?" after mock login and sign-up. Decide how to handle this with the Create Account step.
