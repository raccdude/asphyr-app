# ASPHYR — Real constellations spec

Replaces Journey's arbitrary star positions. Agreed on 3 Nov 2026 and built.

## Goal
Each aspiration's path is a real constellation that represents it, so the sky means something. Zooming out shows that it's one chapter of a much longer journey.

## Constellations
| Aspiration | Constellation | Meaning | Stars used | Story checked? |
|---|---|---|---|---|
| Doctor | Ophiuchus | Asclepius, god of medicine | 9 | Yes |
| Musician | Lyra | The lyre of Orpheus | 6 | Yes |
| Teacher | Centaurus | Chiron, teacher of heroes | 9 | Yes, one tradition |
| Athlete | Hercules | The twelve labors | 8 | Yes |
| Entrepreneur | Vela | The sails of the Argo, a great venture | 8 | Yes, through Argo Navis |
| Mechanical Engineer | Horologium | The pendulum clock | 5 | Yes |
| Engineer | Auriga | Erichthonius, inventor of the four-horse chariot | 7 | Yes, one tradition |
| Designer | Corona Borealis | A crown crafted by Hephaestus | 7 | Yes |
| Game Developer | Draco | The dragon guarding the golden apples | 10 | Yes, sources differ |
| Artist | Pegasus | The spring that inspired the Muses | 9 | Yes |
| Writer | Cygnus | Orpheus, changed into a swan | 9 | Yes, one tradition |
| Psychologist | Perseus | Facing Medusa through a reflection | 9 | Yes, story of the hero |
| Custom or none | Ursa Minor | Polaris, the star that guides you | 7 | Yes |

Pictor, Circinus and Norma fit by name, but have only 3 or 4 stars in the data, so they were replaced.

Star positions come from the d3-celestial data (BSD license, by Olaf Frohn). Its license text must ship with the app. Positions are stored in the app, with no network use.

## Stars and pace
- **Size:** 5 to 10 stars. Larger constellations keep their most recognizable stars and lines, and the shape must still be recognizably the real one.
- **Pace:** 20 quests for every constellation, spread evenly from 1 to 20, so 6 stars light at 1, 5, 9, 12, 16 and 20. Every aspiration moves at the same pace.
- **Order:** stars light along the real lines, starting from one end, ending at the constellation's brightest or most meaningful star where the lines allow. Corona Borealis is a single arc, so it ends at the arc's tip rather than its central gem. Stars too close to tell apart on screen count as one. No line is drawn between stars the real constellation doesn't connect.
- **Names and goals:** rewritten per path to match its star count, keeping today's idea. The last star masters a skill and is never the aspiration itself.
- **Story:** one short line says what the constellation represents, shown once it's first opened.

## Sky map
- Pinch out, or tap a button, to zoom from the constellation to the full sky.
- The current constellation stays bright, with its progress. Future chapters show as faint locked shapes, with no names.
- Tapping a locked chapter shakes it and says it opens later. Tapping the current one zooms back in.

## Locked stars
Tapping a locked star shakes it, gives the warning vibration, and shows how many quests are left in the guide card.

## Spirit
It stays in a guide card under the constellation, not beside the star, so it never covers the sky. The card shows the spirit's message and the next step. Tapping a star shows its name, goal and progress there for a few seconds.

## Not included
Saving progress, and generating paths for custom aspirations. Daily quests and five playable chapters have since been built; see IMPLEMENTATION-NOTES.md.

## How it's checked
Plain rule checks cover every path's star count, thresholds, unique names, and that each line joins two real stars. The developer checks each shape and spirit position in Xcode, through previews for all 13 paths.
