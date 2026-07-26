# Groove Bound (remake)

A survival roguelike where the groove is the game. This local copy was
restored from clean-remake PR head `fe79d6f` and is governed by
[`../REMAKE_EXECUTION_PLAN.md`](../REMAKE_EXECUTION_PLAN.md). The old
prototypes remain GitHub references; they are not part of this runtime tree.

This is a development build with a complete first-draft two-stage narrative
campaign. Both stages default to ten minutes and can be shortened independently
in the Admin dashboard for testing. It is not yet a public release.

## Playable slice

The current build now includes:

- an illustrated prologue, character intros, inter-stage scene, and ending with
  manual advance, automatic timing, and confirmed skip;
- a professional title flow and two-character selection screen;
- Joe and Lyra Vex with distinct stats, passive traits, starting weapons, and
  directional idle, walk, high-speed run, and hurt animations;
- two stage-specific environments and sixteen enemy variants;
- validated timed enemy waves, deterministic edge spawning, solid obstacles,
  and decorative arena elements;
- 16 base weapons, seven distinct firing patterns, auto-targeting and
  auto-fire;
- pooled projectiles, enemies, and XP gems;
- damage, contact damage, invulnerability frames, death, and drops;
- gem attraction, multi-threshold XP and a paused three-card choice every level;
- seeded randomized offers with immediate anti-repeat protection, guaranteed
  new-weapon variety while slots are open, and owned-rank cards when both
  inventories are full;
- illustrated new-weapon, owned-rank, passive, heal, guard and coin decisions;
- one reroll and a bounded skip reward;
- four support slots and eight live stat-enhancing support items;
- eight rank-10 weapon + support fusion recipes;
- a visible evolution-ready notification and illustrated fusion card;
- optional on-card evolution recipes and a missing-requirements guide,
  controlled from Admin → Rewards;
- an atomic fusion transaction that consumes both ingredients, replaces the
  exact firing emitter, reopens the support slot, and expands weapon capacity
  up to six;
- distinct chase, zigzag, charge, orbit, ranged-note, pulse and boss behaviors;
- a miniboss and final boss in each stage, including the Stage 2 Turntable
  Sentinel and megazord-like Grand Orchestrator;
- a two-stage countdown with persistent build, recovery beat, illustrated
  transition, and automatic Orbit Line entry;
- weapon-specific projectile art plus hit, explosion, death-flicker, knockback,
  enemy attack, and player hurt feedback;
- deterministic victory, defeat, score/combo, results and restart flows;
- a more legible HUD for health, guard, XP, rank, inventory, boss health,
  campaign progress, score, seed and frame time;
- a navigable Arsenal Database with roster filters, icon cards, rank-one to
  rank-ten stats, live ownership/emitter status, level-up availability and
  visible evolution recipes;
- a segmented visual Admin dashboard with category icons, value bars, live
  tools and direct Arsenal access;
- persistent options, conflict-checked keyboard rebinding and seed copy;
- a `Tab` toggle for the debug overlay;
- legacy floor art and SFX combined with campaign sprite, projectile, combat
  effect, environment, portrait, and cutscene atlases.

The next production step is canon and balance refinement, supplied cinematic
video/audio, and the BeatClock groove layer.

## Requirements

- [LÖVE 11.5](https://love2d.org/) to play
- LuaJIT to run the headless test suite (`apt install luajit` / `brew install luajit`)

## Run

```sh
cd groove-bound
make run        # or: love .
```

## Test / lint

```sh
make test       # headless unit tests (no LÖVE needed)
make lint       # luacheck
```

## Layout

| Path | Contents |
|---|---|
| `src/core/` | Engine-agnostic plumbing: class, event bus, state machine, scheduler, RNG, log, save |
| `src/content/` | **Data only** — weapons, enemies, passives, characters, waves; validated at boot |
| `src/config/` | Engine/feel tunables (never gameplay numbers) |
| `src/game/` | Entities and systems (from Phase 1) |
| `src/ui/` | Screens, widgets, fonts |
| `src/debug/` | Overlay, tuning tools |
| `tests/` | Headless unit tests + runner |

## Development admin controls

Press **F1** from the title screen, an active run, or the pause screen to open
the bounded, segmented admin tuning dashboard. It supports keyboard, mouse,
and gamepad.
Game-speed, player, combat, projectile, enemy, pickup, and XP controls are live.
The BPM override remains registered but intentionally waits for the Stage 5
BeatClock.

During an active run the admin panel also exposes **Grant Level**,
**Prepare Evolution**, **Rank-1 Evolve**, **Spawn Boss**, and **Clear Stage**
tools. Prepare Evolution creates a legal rank-10 recipe and opens the normal
fusion choice. Rank-1 Evolve is an explicit, toggle-gated Admin-only shortcut;
normal progression still requires rank 10.

See:

- [`docs/ADMIN_CONTROLS.md`](docs/ADMIN_CONTROLS.md)
- [`docs/FIRST_DRAFT_CANON.md`](docs/FIRST_DRAFT_CANON.md)
- [`docs/STAGE2_VISUAL_PROMPTS.md`](docs/STAGE2_VISUAL_PROMPTS.md)
- [`docs/WEAPON_DATABASE.md`](docs/WEAPON_DATABASE.md)
- [`docs/WEAPON_EVOLUTION.md`](docs/WEAPON_EVOLUTION.md)

## Ground rules

1. Content is keyed by stable `id`s; display names are never used for logic.
2. Every per-run listener/timer attaches through a run-scoped owner and dies with it.
3. No numeric tunables inline in `src/game/` — they live in `content/` or `config/`.
4. Every new system ships with unit tests; `main` stays green.
