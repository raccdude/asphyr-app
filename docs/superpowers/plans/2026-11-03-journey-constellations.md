# Real Constellations Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Journey's arbitrary positions with a real constellation for each path, and add a zoomable sky map.

**Architecture:** A generated Swift data file holds each constellation's stars and lines. `JourneyPath` joins them to names and goals, and pure rule functions decide progress. `JourneyView` draws any shape from that data.

**Tech Stack:** SwiftUI, Observation, iOS 26.5 target. Python only in the scratchpad, to generate data.

**Spec:** `docs/JOURNEY-CONSTELLATIONS-SPEC.md`

## Global Constraints

- The developer runs all git commands and tests on the iPhone 18 Pro in Xcode. Claude never commits, and never drives a simulator.
- 5 to 10 stars per path. 20 quests per path, spread evenly from 1 to 20.
- Lines only join stars the real constellation connects. Star data is stored in the app, with no network use.
- The last star masters a skill and is never the aspiration itself.
- The project has no test target. Rule checks run as a scratchpad script compiling only pure model files with `swiftc`. Each task ends with a successful `xcodebuild` for `generic/platform=iOS Simulator`.
- Update `docs/IMPLEMENTATION-NOTES.md` on this branch, and add differences from Figma to "Figma updates for later". Don't edit Figma.

## Review Focus

- A constellation whose chosen stars leave a gap: every star must still connect, or the path can't be followed.
- A tall or wide shape near an edge: stars, labels and the spirit's bubble stay on screen at 402pt and 390pt.
- The current star at each position: the spirit and bubble don't cover it or its label.
- Pinching while a shake or the bubble is showing: nothing jumps or sticks, and zooming back in restores the view.
- A long star name: it wraps without overlapping a nearby star.

---

### Task 1: Confirm the unchecked stories

**Files:**
- Modify: `docs/JOURNEY-CONSTELLATIONS-SPEC.md`

**Interfaces:**
- Produces: the final constellation for all 13 paths, with a checked story for each.

- [ ] **Step 1: Search for Pegasus (Hippocrene and the Muses), Cygnus (Orpheus or poets), Perseus (the reflecting shield) and Ursa Minor (Polaris)**

Use a reliable source for each.

- [ ] **Step 2: Update the spec's table**

Mark each as checked. If a story doesn't hold up, replace the constellation with one of 5 or more stars in the data, record the change in the spec, and tell the developer in the handover. Ursa Minor has 7 stars in the data.

### Task 2: Generate the star data

**Files:**
- Create (scratchpad, never in the repo): `generate-constellations.py`
- Create: `Asphyr/Models/ConstellationData.swift`
- Create: `Asphyr/Resources/d3-celestial-LICENSE.txt`

**Interfaces:**
- Produces:
  - `struct Constellation { let id: String; let name: String; let meaning: String; let stars: [CGPoint]; let lines: [(Int, Int)] }`, with star positions from 0 to 1, in the order they light.
  - `Constellation.all: [String: Constellation]`, keyed by the data's id, such as `"Oph"`.

- [ ] **Step 1: Write the generator**

Read `lines.json` with `python3 -I`. For each chosen id, project coordinates around the constellation's center with RA scaled by cos(Dec), flip RA so the sky matches how it's seen from Earth, and fit to 0 to 1 keeping its proportions.

- [ ] **Step 2: Choose stars for constellations over 10**

For Ophiuchus, Centaurus, Hercules, Draco, Pegasus and Perseus, keep one connected chain of 10 or fewer stars from their main figure, listing the stars by hand in the script.

- [ ] **Step 3: Set the lighting order**

Walk the lines from one end, ending at the most meaningful star, so each newly lit star connects to one already lit.

- [ ] **Step 4: Write and run the data checks in the scratchpad**

```swift
for c in Constellation.all.values {
    precondition((5...10).contains(c.stars.count), c.id)
    precondition(c.lines.allSatisfy { $0.0 < c.stars.count && $0.1 < c.stars.count }, c.id)
    precondition(c.stars.allSatisfy { (0...1).contains($0.x) && (0...1).contains($0.y) }, c.id)
    // Each star after the first joins an earlier star, so the path can be followed
    for i in 1..<c.stars.count {
        precondition(c.lines.contains { ($0.0 == i && $0.1 < i) || ($0.1 == i && $0.0 < i) }, c.id)
    }
}
```

Expected: exit code 0. `ConstellationData.swift` imports only Foundation and CoreGraphics so the script can compile it.

- [ ] **Step 5: Add the license file**

Copy d3-celestial's license text, and confirm the app's folder sync picks it up in the build.

### Task 3: Path rules

**Files:**
- Modify: `Asphyr/Models/JourneyPath.swift`

**Interfaces:**
- Consumes: `Constellation`
- Produces:
  - `JourneyPath.constellation: Constellation`
  - `JourneyPath.questThresholds(starCount: Int) -> [Int]`

- [ ] **Step 1: Update the checks to fail first**

```swift
precondition(JourneyPath.questThresholds(starCount: 5) == [1, 6, 11, 15, 20])
precondition(JourneyPath.questThresholds(starCount: 6) == [1, 5, 9, 12, 16, 20])
precondition(JourneyPath.questThresholds(starCount: 10).first == 1)
precondition(JourneyPath.questThresholds(starCount: 10).last == 20)
```

For all 13 paths: the name and goal count equals its constellation's star count, names are unique, and the last star's name isn't the aspiration. "Doctor" uses `"Oph"`, and a custom aspiration uses `"UMi"`.

- [ ] **Step 2: Implement `questThresholds`**

Each is `1 + 19 * index / (count - 1)`, rounded to the nearest whole number.

- [ ] **Step 3: Rewrite each path's names and goals to its star count**

Keep today's ideas and destinations. Icons remain flag, target, the aspiration's icon, then repeating general icons, with the crown last.

- [ ] **Step 4: Run the checks and build**

Expected: exit code 0, then `** BUILD SUCCEEDED **`.

### Task 4: Draw any constellation

**Files:**
- Modify: `Asphyr/Views/Navigation/JourneyView.swift`

**Interfaces:**
- Consumes: `JourneyPath.constellation`

- [ ] **Step 1: Replace `Layout.stars` and `Layout.lines`**

Fit the 0 to 1 positions into a square inset by 44pt, leaving room for labels. Keep the node, line and label styles. The title shows the constellation's real name, such as "The Lyra constellation", with its meaning below on first open.

- [ ] **Step 2: Compute the spirit's position**

Place it 56pt beside the current star, on whichever side has more room, with the bubble above unless it wouldn't fit. Clamp both inside the canvas. Remove `SpiritPlacement.all`.

- [ ] **Step 3: Add a locked star tap**

Tapping shakes the star with `ShakeEffect`, moved to its own file, gives the warning vibration, and shows "N more quests to light this star" in the spirit's bubble for 3 seconds.

- [ ] **Step 4: Add previews for all 13 paths and build**

Expected: `** BUILD SUCCEEDED **`.

### Task 5: Sky map

**Files:**
- Create: `Asphyr/Views/Navigation/JourneySkyMap.swift`
- Modify: `Asphyr/Views/Navigation/JourneyView.swift`

**Interfaces:**
- Consumes: `Constellation.all`, `JourneyProgress`

- [ ] **Step 1: Build the map**

The current constellation sits at the center, bright with its progress. 4 other constellations from the data sit around it, faint, with no names or labels. Chosen by a fixed order, skipping the current one.

- [ ] **Step 2: Connect zooming**

A pinch below 1 or a map button moves to the sky map, with a smooth scale. Tapping the current constellation or a close button returns. Scale stays between the two views, and ends on one of them.

- [ ] **Step 3: Add the locked chapter tap**

Tapping a faint constellation shakes it and shows "This chapter opens later." as a toast.

- [ ] **Step 4: Update the notes and build**

Move these out of "Journey ideas (future)". Add the shapes, sky map and locked star messages to "Figma updates for later". Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 5: Hand over**

Give the developer the checklist, including every path's preview, and the full git sequence.
