# Store and Inventory — Design

Written 12 Nov 2026. Builds on "Store and inventory (planned)" in `IMPLEMENTATION-NOTES.md`, agreed on 3 and 4 Nov. Where that left a choice open, this takes Claude's recommendation, as the developer asked on 12 Nov. Each choice says why, so it can be overruled.

## Goal
Give completed quests a second, spendable reward: **Embers**. Spend them on cosmetics in a **Store**, and see and wear what's owned in an **Inventory**. Cloak choice moves there from Character.

**Success:** a user completes quests, watches their Embers grow, buys a cloak, wears it, and it's still theirs after a relaunch or on another phone. Nobody can earn or spend Embers by editing the app or the phone's clock.

## Already decided (3–4 Nov)
- The currency is earned in the app only, never bought, and spent on cosmetics only. No real money in the first release.
- It's paid when a quest is completed, not per step, and is limited like full rewards.
- One screen with two tabs, **Store** and **Inventory**, opened from Home.
- The CLOAKS grid leaves Character for Inventory, and Reward's "View in Character" points to Inventory.
- Midnight, Oxblood and Plum stay level rewards and aren't sold. The first store items are the Green, Yellow, Snow and Teal cloaks, with their colors in `CharacterCloak`.

## Decisions made here

| Question | Choice | Why |
|---|---|---|
| Name | **Embers** | The working name. It fits the flame and ASPHYR's warm look. |
| How many | **1 Ember for every 10 XP the quest gives**, rounded down, when it's completed | Reuses the XP balance, so long or hard quests pay more with no new table. A daily gives 10, a bonus quest past the limit gives 1. |
| Main quests | Paid on completion from the quest's full XP (steps × step XP) | Step XP is paid per tick, but Embers wait for completion, so ticking and deleting earns nothing. |
| Prices | **200 Embers** per store cloak | About a week of steady use. One price, so no color looks "better". |
| Where the prices live | A server table, `private.store_items` | Changing a price needs no app update, and the server is the only judge. |
| Past quests | Each existing account is paid for the quests it already completed, once | Fair to early testers; costs nothing. |
| Reset progress | Clears Embers and bought cloaks too | It's "everything earned", and Embers are earned. |
| Home entry | **An Ember balance chip in Home's top row**, beside the streak chip and Settings | Shows the balance and opens the store in one control. Matches the streak chip. |
| Screen | Pushed from Home like Settings, with a Store / Inventory switch at the top | Same navigation as Settings, so nothing new to learn. |
| Store tab | One card per cloak: the user's own character wearing it, its name, and **Buy · 200**. Owned ones say **Owned** and offer **Wear** | Seeing yourself in it is the reason to buy. |
| Buying | A confirmation ("Buy the Green cloak for 200 Embers?"), then the server buys it and a toast offers **Wear** | Embers take a week to earn, so a mistap shouldn't spend them. |
| Not enough Embers | **Buy** is dimmed, and tapping it says how many more are needed | Explains instead of hiding. |
| Inventory tab | Today's CLOAKS grid, moved as it is: starter, level cloaks and store cloaks. Locked ones say why: "Level 3" or "200 Embers" under the swatch, and a tap explains how to get it | Reuses what works. |
| Reward screen | A line under the loot cards: "+10 Embers" | Small, because Reward is being redesigned next. |
| Icon | A new `iconEmber`: a small glowing coal shape, in the reward gold | Distinct from the streak's flame. |
| Figma | Built in the app first; frames added to "Figma updates for later" | Development comes first, as before. |

## How it works

### Server
- `player_progress.embers`: the balance, never below 0.
- `private.store_items (item, price)`: Green, Yellow, Snow and Teal at 200 each.
- `complete_quest` adds `floor(xp_reward / 10)` Embers, using the quest's reward as completed, so a bonus quest gives 1. Its reply's `reward` gains `embers_earned`.
- New `buy_cloak(p_cloak)`: checks the item is for sale, isn't owned, and the balance covers it. Then it takes the Embers and adds the cloak to `unlocked_cloaks`, all in one transaction. Errors: `not_found` (not for sale), `not_allowed` (already owned), `not_enough_embers`.
- `reset_progress` sets Embers to 0. It already removes every unlocked cloak.
- `player_json` gains `embers` and `owned_cloaks` (every cloak owned, level and bought). `unlocked_cloaks` stays level cloaks only, so the existing app keeps working.
- `get_player_state` gains `store`: the items for sale and their prices.
- Wearing a bought cloak already works: the profile check allows any cloak in `unlocked_cloaks`. Losing a level never removes a bought cloak, because only level cloaks are taken back.

### App
- `QuestStore` gains `embers`, `ownedCloakNames` and `storeItems`, filled from the server's replies.
- `QuestService.buyCloak` and `QuestStore.buyCloak`, like the other actions.
- New `Views/Store/StoreView.swift` (the screen and its switch), `StoreCloakCard`, and `Components/Character/CloakGrid.swift`, the grid moved out of `CharacterView`.
- Home: an Ember chip in the header opens the store. `MainTabView` gains `openInventory`, used by Reward.
- `QuestError` gains `notEnoughEmbers`.

## Errors
- Buying with no connection, or after the price changed: the server's answer wins, a toast explains, and the store reloads.
- Buying twice by double tapping: one request at a time, as with quests, and the server refuses a cloak already owned.

## Testing
- **Database**, in `supabase/tests/quest_functions.test.sql`: Embers paid on completion (including bonus quests and main quests), nothing for steps, buying (success, already owned, not for sale, not enough, exact balance), Embers never below 0, reset clears them, bought cloaks survive a level drop and can be worn, and the store list. Buying locks the player's progress first, like every action, so two buys at once can't overspend.
- **Past quests:** paid by a one-off update in the migration, which the local tests can't reach. Checked on the live project after it deploys.
- **App:** written without a Swift compiler in the cloud session. The developer builds it and checks it on the iPhone.

## Not in this step
- Any paid purchase, other item types, sales or changing prices in the app.
- The Reward redesign.
- Figma frames.
