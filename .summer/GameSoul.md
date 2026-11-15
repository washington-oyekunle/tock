# Tock — Game Soul

## One line
A small boy with a pocket watch can un-happen the world: he rewinds time itself to undo
falling stones, missed jumps and his own mistakes, in a golden-hour clockmaker's courtyard.

## The player
Tock — a boy in a cream shirt, blue shorts, red scarf and a brass pocket watch. Procedural
low-poly model in `scripts/boy_visual.gd`. He runs, jumps, pushes heavy things and uses `E`
to work whatever is nearest. Holding `R` rewinds everything (player, crate, boulder, pendulum,
bridge) at about 1.9x speed and burns "sand", which slowly refills. Death is never a restart:
the watch pulls him back.

## The world
A walled courtyard at golden hour, then a stair up to a terrace, a heavy plate and a
drawbridge over a deep pit, and finally a tower hall where a giant pendulum guards the great
clock. All geometry, props placement and puzzle wiring live in `scripts/world_builder.gd`.
Outside the walls: a conifer treeline on rolling ground, then hazy hills — built in
`_build_backdrop()` so the horizon is never empty.

## How it should feel
- Warm, storybook, hand-painted low poly. Stone, timber and brass; no sci-fi surfaces.
- Golden hour: long readable shadows, warm cream light, cool blue-violet shadows, warm haze.
- Clockwork everywhere: brass rings inlaid in the plaza, pendulum, windlass, hourglass, the
  great clock face. Brass glows faintly; nothing else glows except time-stuff.
- Sound is sparse: a soft clockwork tick under the rewind, one warm folk loop, wooden
  thunks, a brass "boing" for the spring pad.

## Look constants (keep these when adding to the scene)
- Sun: rotation `(-48, 22, 0)`, energy `2.15`, color `(1.0, 0.80, 0.56)`.
- Environment: fog `0.0026`, fog color `(0.94, 0.72, 0.52)`, ambient `(0.58, 0.64, 0.76)` at
  `0.5`, exposure `0.9`, saturation `1.12`, contrast `1.06`. Rewind shifts saturation to
  `0.5` and exposure to `1.08` — the world goes grey and overexposed while time runs back.
- Sky: top `(0.19, 0.36, 0.66)`, horizon `(0.98, 0.70, 0.44)`.
- Palette: warm limestone, honey wood, aged brass `(0.93, 0.71, 0.32)`, deep pine green,
  dusty terracotta. Crimson only for Tock's scarf and the wall banners.

## Interactions
- `E` uses the nearest interactable: windlass (locks the drawbridge up), hourglass (adds 3 s
  of sand and disappears), the great clock (wins the game).
- The brass spring pad in the courtyard east side is the one big jump: it launches Tock onto
  the balcony so he can reach the windlass and the hourglass.
- Prompts are short verbs: "Turn the windlass", "Pocket the sand", "Wind the great clock".

## Rules for future work
- New props must come from the same low-poly medieval set or be built from the same palette.
- Never add a second, unrelated high-jump source; the spring pad is the special place.
- Time rewinding is the signature mechanic: anything that moves must register with
  `TimeControl` and restore cleanly.
- Keep the HUD a quiet brass-and-cream band; the world is the show.
