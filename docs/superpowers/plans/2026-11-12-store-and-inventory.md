# Store and Inventory Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Pay Embers for completed quests, sell four cloaks for them in a Store, and move cloak choice into an Inventory, with the server checking every Ember.

**Architecture:** One new migration adds the balance, the price list and `buy_cloak`, and extends `complete_quest`, `reset_progress`, `player_json` and `get_player_state`. The app reads the new fields through the existing reply records, adds one action, and gains a Store screen opened from an Ember chip on Home. The CLOAKS grid moves from Character into a shared `CloakGrid`.

**Execution:** native, in this session (Claude's recommendation: four tightly linked tasks, and the database task is fully tested).

**Tech Stack:** Postgres (Supabase), plpgsql; SwiftUI, Observation, supabase-swift 2.55.

**Spec:** `docs/superpowers/specs/2026-11-12-store-and-inventory-design.md`

## Global Constraints

- 1 Ember per 10 XP the completed quest gives, rounded down (`floor(xp_reward / 10)`), using the reward as completed.
- Store cloaks: Green, Yellow, Snow, Teal at **200** each, in `private.store_items`.
- New error code: `not_enough_embers`. Existing codes are unchanged.
- `unlocked_cloaks` in replies stays level cloaks only; `owned_cloaks` lists every owned cloak.
- Commits are credited to Angelo Buedo with no Claude co-author lines. Log each step in `docs/PROJECT-LOG.md`.
- The cloud session has no Swift compiler. Database work is test-first; Swift is written carefully and built by the developer.
- Copy: "+10 Embers" on Reward; "Buy the Green cloak for 200 Embers?"; locked cloaks in Inventory read "200 Embers" or "Level 3" under the swatch, and tapping one says "Get it for 200 Embers in the Store." or "Reach level 3 to unlock this cloak."

## Review Focus

- A balance exactly equal to the price: the purchase succeeds and leaves 0.
- Buying a cloak already earned by level (Midnight): refused as not for sale, not charged.
- Losing a level after buying Green: Green stays owned and worn.
- Reset progress after buying: Embers 0 and Green gone, and a worn bought cloak is taken off.
- A bonus personal quest (10 XP): pays exactly 1 Ember.

---

### Task 1: Server — Embers, prices and buying

**Files:**
- Create: `supabase/migrations/20261112120000_store.sql`
- Test: `supabase/tests/quest_functions.test.sql` (new "Store" block before "Result")

**Interfaces:**
- Produces: `public.buy_cloak(p_cloak text) returns jsonb` → `{quest: null, player}`; `player_json` adds `embers int` and `owned_cloaks text[]` (ordered by level cloaks first, then store order); `complete_quest`'s `reward` adds `embers_earned int`; `get_player_state` adds `store: [{item text, price int}]` ordered Green, Yellow, Snow, Teal.

- [ ] **Step 1: Write the failing tests** — checks named for each Review Focus line plus: completing a 30m moderate quest pays 10 and `reward.embers_earned = 10`; a main quest of 3 moderate steps pays 30 on completion and nothing per tick; buying Green with 200 leaves 0 and adds Green to `owned_cloaks` but not `unlocked_cloaks`; buying again → `not_allowed`; buying `Plum` → `not_found`; buying with 199 → `not_enough_embers` and nothing changes; the profile can then wear Green; `get_player_state -> 'store'` lists 4 items at 200; anon can't call `buy_cloak`.
- [ ] **Step 2: Run** `zsh scripts/db-tests/run.sh` — expect failures (`buy_cloak` doesn't exist).
- [ ] **Step 3: Write the migration.** Add `player_progress.embers integer not null default 0 check (embers >= 0)`; create and fill `private.store_items (item text primary key, price integer check (price > 0), position integer)`; pay past quests once: `update player_progress set embers = (sum of floor(xp_reward/10) over that user's completed quests)`; `create or replace` `private.player_json`, `public.complete_quest`, `public.reset_progress`, `public.get_player_state`; add `public.buy_cloak` (lock progress first). Re-apply the grants for every replaced or new function.
- [ ] **Step 4: Run** `zsh scripts/db-tests/run.sh` — expect `ALL … CHECKS PASSED` and the Edge Function tests passing.
- [ ] **Step 5: Commit** `feat(backend): pay Embers and sell cloaks on the server`.

### Task 2: App — read Embers and buy

**Files:**
- Modify: `Asphyr/Models/Quests/QuestRecords.swift`, `Asphyr/Models/Quests/QuestStore.swift`, `Asphyr/Backend/QuestService.swift`, `Asphyr/Backend/QuestStore+Server.swift`

**Interfaces:**
- Consumes: Task 1's reply fields.
- Produces: `PlayerRecord.embers: Int`, `PlayerRecord.ownedCloaks: [String]`, `RewardRecord.embersEarned: Int`, `PlayerStateRecord.store: [StoreItemRecord]` with `StoreItemRecord { item: String; price: Int }`; `QuestStore.embers: Int`, `QuestStore.ownedCloakNames: Set<String>`, `QuestStore.storeItems: [StoreItemRecord]`, `QuestStore.owns(_ name: String) -> Bool`; `QuestCompletion.embersEarned: Int` (default 0); `QuestService.buyCloak(_ name: String) async throws -> QuestReply`; `QuestStore.buyCloak(_ name: String) async throws`; `QuestError.notEnoughEmbers` with message "You need more Embers for this. Complete quests to earn them."

- [ ] **Step 1:** Decode the new fields. `ownedCloaks` and `store` must decode when missing (older replies), defaulting to empty.
- [ ] **Step 2:** Apply them in `QuestStore.apply(_:)` and `load(_:)`; `clear()` resets them.
- [ ] **Step 3:** Add `buyCloak` to the service and the store, through the existing `send` so one request runs at a time and out-of-step errors reload.
- [ ] **Step 4:** Read the diff for compile errors by eye. No `scripts/rule-tests` change: there are no new device rules.

### Task 3: App — Store screen, Inventory, Home, Character, Reward

**Files:**
- Create: `Asphyr/Assets.xcassets/iconEmber.imageset/` (template SVG, 16×16), `Asphyr/Components/Character/CloakGrid.swift`, `Asphyr/Views/Store/StoreView.swift`, `Asphyr/Views/Store/StoreCloakCard.swift`
- Modify: `Asphyr/Views/Character/CharacterView.swift` (remove CLOAKS), `Asphyr/Views/Home/HomeView.swift` (Ember chip, push Store), `Asphyr/Views/App/MainTabView.swift` (`openInventory`), `Asphyr/Views/Quests/RewardView.swift` (Embers line, "VIEW IN INVENTORY")

**Interfaces:**
- Consumes: Task 2's `QuestStore` members and `buyCloak`.
- Produces: `CloakGrid(onLockedTap: (String) -> Void)`, reading `OnboardingProfile` and `QuestStore` from the environment; `StoreView(initialTab: StoreView.Tab)` with `enum Tab { case store, inventory }`; `EnvironmentValues.openInventory: () -> Void`.

- [ ] **Step 1:** `CloakGrid`: today's `cloakPicker` and `cloakOption` moved from `CharacterView`. A cloak is unlocked if `questStore.owns(cloak.rawValue)`. Locked detail: "Level N" for level cloaks, "200 Embers" (the store price) for store cloaks; the locked toast says "Reach level N to unlock this cloak." or "Get it for N Embers in the Store."
- [ ] **Step 2:** `StoreCloakCard(cloak:price:)`: the user's `CharacterArt` wearing the cloak, its name, and a button: **Buy · N** (dimmed below the price), **Wear**, or **Wearing**.
- [ ] **Step 3:** `StoreView`: header with the Ember balance, a two-option switch styled like the quest log's filters, the Store grid (2 columns) or `CloakGrid`, a confirmation alert before buying, and a toast after.
- [ ] **Step 4:** Home: an Ember chip (icon + balance, gold, same shape as the streak chip) left of the streak chip; tapping pushes `StoreView(initialTab: .store)`. `openInventory` switches to Home and pushes `StoreView(initialTab: .inventory)`.
- [ ] **Step 5:** Character: remove the CLOAKS section and its state. Reward: "+N Embers" line under the loot cards when N > 0, and the link reads "VIEW IN INVENTORY" and calls `openInventory`.
- [ ] **Step 6: Commit** `feat(store): add the Store and Inventory`.

### Task 4: Docs, deploy check, push

- [ ] Update `IMPLEMENTATION-NOTES.md` (Store section built, Character, Reward, Figma updates for later), `HANDOFF.md`, `PROJECT-LOG.md`.
- [ ] Commit `docs: record the Store and Inventory`, push the branch.
- [ ] After the developer merges, check the live project: the migration applied, past quests paid, `buy_cloak` exists and anon can't call it.
