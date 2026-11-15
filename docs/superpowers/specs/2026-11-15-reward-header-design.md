# Reward redesign — design

Approved by the developer on 15 Nov 2026. A small change.

## Why
The Reward screen felt empty: the title, spirit and message sat in a narrow centered column while the cards below filled the width.

## Approaches
- **A, hero card (tried second):** spirit and text side by side in a full-width card. Lines everything up, but shrinks the spirit.
- **B, spotlight band (picked):** a tinted band runs edge to edge behind the title, a larger spirit and the message. Fills the width by making the moment bigger, not by adding boxes.
- **C, summary card:** one card with a receipt-style reward list. Easiest to read, but feels least like a reward.

The developer picked B and asked to keep the tilted loot cards, tried A, then went back to B on Claude's recommendation: B fills the screen by making the win bigger, where A's compact card left more empty space.

## Design
- **Band:** full screen width, behind "QUEST COMPLETE", the quest title, the spirit and its message. A faint accent tint with a hairline above and below.
- **Spirit:** 150pt, up from 120pt.
- **XP bar fills:** from the XP before this quest to the XP after. On a level up it fills the old level, empties, the new level number pops, then it fills to the new amount.
- **Numbers roll up:** each loot card's number rolls up from zero as the card lands, with a light tap of haptics per card. Haptics follow Sounds & haptics in Settings.
- **Tap to skip:** a tap anywhere outside the buttons shows the finished screen at once.
- **Unchanged:** the tilted loot cards, their order and timing, Embers, the bonus line, the unlocked cloak and Continue.
- **Non-goals:** "Next quest" and the streak line, which add new features and come later.

## Builder's calls
The band's tint and padding, and spacing below it, are the builder's to tune by eye.
