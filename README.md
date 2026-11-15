# Tock

A small time-rewind puzzle-adventure. A boy with a pocket watch can un-happen the world:
rewind a rolling boulder, a swinging pendulum, a falling bridge, or his own last mistake, and
spend the sand in the watch to try the courtyard again.

The goal is the great clock at the top of the clockmaker's courtyard.

## Controls

| Input | Action |
| --- | --- |
| WASD / arrows | Move |
| Space | Jump |
| E | Use the nearest object |
| Hold R | Rewind time |
| Mouse | Orbit the camera |
| Esc | Release the mouse |

## What's in it

- A full rewind system: the player, the crate, the boulder, the pendulum and the drawbridge all
  record their state and run backwards while R is held, draining the sand dial.
- Death is not a restart. The watch pulls you back a few seconds, so the courtyard keeps its
  state and you keep your progress.
- A brass spring pad that flings Tock onto the balcony, out of reach of a normal jump.
- Interactables with floating markers: a windlass that locks the drawbridge up, an hourglass
  that adds sand, and the clock itself.
- Hand-built low-poly level: cobbled courtyard, stair, terrace, pit and tower hall, lit for
  golden hour with a treeline and hills beyond the walls.

## Running it

1. Install Godot 4.7.
2. Open `project.godot` and press F5.

The project uses the Compatibility renderer, so it runs on older GPUs as well.

## Layout

- `main.tscn` — entry scene; `scripts/main.gd` builds the world and owns the game state.
- `scripts/world_builder.gd` — the courtyard, tower, hazards, props and interactables.
- `scripts/player.gd`, `scripts/boy_visual.gd` — movement and the boy's procedural model.
- `scripts/time_control.gd` — the rewind autoload and sand economy.
- `assets/` — imported models and textures. `library/` — lighting rigs and sounds.

## Credits

Third-party art and audio are listed in [CREDITS.md](CREDITS.md).
