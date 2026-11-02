# ASPHYR — Design decisions (Figma v2 refinement, 28 Oct 2026)

These decisions apply to Figma page **"05 — Hi-Fi v2 (Polished)"** and should carry into the SwiftUI build.

## Global
- **Dark mode is the default.** Light and System are options in Settings › Appearance.
- **Colors come from the Figma `COLOR` variables.** All matching fills, strokes and text colors are bound to the 9 variables (Background, Primary Surface, Elevated Surface, Primary Text, Secondary Text, Border, Primary Accent, Warning, Error).
  - The collection has two modes, **Dark** (the original values) and **Light**.
  - Each screen frame sets its mode explicitly. The light screens use Light.
  - These map 1:1 to `AppColors` and the asset-catalog color sets. Give each color set a Dark and a Light appearance.
- **Deliberately not tokenised:**
  - the primary-button gradient (#7DFF9B→#00E63B) and its dark label (#03140A);
  - the character colors and shirt swatches;
  - the white toggle knobs and glass buttons;
  - the Appearance previews;
  - the flame spirit.
- **Typography:** every text layer uses one of the 10 Figma text styles (Word Mark, DISPLAY, Screen Title, Section, Heading, Body, Body Semi Bold, Secondary, Caption Medium, Caption Regular). No in-between sizes. These should map 1:1 to `AppTypography`.
- **Primary button:** the original tight shadow (#2FAF4F, y 2, blur 4) and a Section (Space Grotesk Bold 20) label. No large green blur.
- **Active quest card:** a subtle glow only (y 4, blur 12, 30% green).
- **Selected archetype/aspiration card:** the original style, Elevated Surface fill + green drop shadow (y 1, blur 2). No solid green border.
- **Back button:** the iOS 26 **system** back button (round glass chevron). It keeps swipe-back working, so stop hiding it with `.navigationBarBackButtonHidden(true)`.
  - **Exception:** Welcome keeps it hidden, because going back to Splash gives the user nothing.
- **Demo data:** the account email is `lou@gmail.com`. The Google sign-in button uses the Google "G" logo.

## Screens
- **Screen names** use Angelo's convention: (default state) / (active state) / (invalid state).
- **Auth prompts** sit on one line: "Don't have an account? CREATE ACCOUNT".
- **Account Recovery** uses the flame spirit instead of the logo:
  - wave (default), focused (typing), surprised (invalid), cheer (success).
- **Resend email:** a toast ("Reset link sent again…") and a 30 s cooldown line.
- **Reset Progress:** after confirming, return to Settings with a success toast. The Level resets to 1 and 0/500 XP; identity is unchanged.
- **Quest Details timer:** a compact card with elapsed / total time, a linear progress bar, start time, time left and Pause.
- **Reward:** XP, Creativity and Discipline rows top to bottom, then Level up, then "New reward unlocked".
  - Tapping the reward card expands it in place (the achievement plus "View in Character"). There is no separate screen.
  - The spirit uses the cheer expression.
- **Empty/default states:**
  - Create Quest (default)
  - Journey (new user)
  - Character (new user)
  - Quest logs: all four filters
- **Profile & Identity:**
  - Aspiration and archetype are compact pull-down menus.
  - The photo button opens a sheet (Take photo / Choose from library → iOS PhotosPicker / Use my character / Remove).
  - **The photo appears only on Profile and Settings.** The character stays on Home and Character.

## Streaks (secondary, optional)
- A small green flame chip with the day count on Home. A "Rest" chip shows when the streak has lapsed.
- A Streak sheet with a week view and a "Show streak on Home" toggle. There is also a Streaks toggle in Settings.
- **Missing a day never removes XP, levels or attributes.** The copy for a missed day is gentle: "Your flame is resting."

## Light mode (COLOR variables, Light mode values)
- The core set covers: Home, Quests, Quest Details (active), Reward, Journey, Character and Settings, plus the Appearance sheet with Light and System selected.
- Any other screen can be switched to Light by setting its frame's COLOR mode to Light.

| Variable | Light value |
|---|---|
| Background | #F3F4F7 |
| Primary Surface | #FFFFFF |
| Elevated Surface | #ECEEF2 |
| Primary Text | #0B0D12 |
| Secondary Text | #5D6475 |
| Border | #DCDFE6 |
| Primary Accent | #00A82E |
| Warning | #B86E00 |
| Error | #E03131 |
