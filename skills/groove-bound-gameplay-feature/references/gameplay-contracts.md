# Gameplay contracts

## Ownership map

- `src/core/`: RNG, events, scheduler, pools, save, state machine, spatial hash.
- `src/game/entities/`: player, enemies, projectiles, gems, pickups, chests.
- `src/game/systems/`: combat, weapons, progression, spawn, stages, XP, VFX.
- `src/game/arena.lua`: arena geometry, obstacle blocking, movement resolution.
- `src/game/run_context.lua`: run seed, world, scoped lifecycle.
- `src/content/`: data definitions and validation.
- `src/ui/screens/run.lua`: presentation and state transitions around the run.

## Determinism

Use the named `loot`, `spawn`, `combat`, and `vfx` streams. Add a named stream only through an explicit compatibility decision. Do not use global randomness for run outcomes. Keep a seed in every reproducible report.

## Progression

Preserve legal offers, immediate anti-repeat behavior, full-inventory rank progression, exact fusion pairings, atomic evolution, and a reachable path to every advertised result.

## Performance

Exercise pooling and the spatial hash for high-count entities. Keep the existing 300-enemy and 150-projectile reference scenario. Treat machine timing as a signal, not a universal frame-rate guarantee.

## Manual evidence

Describe the exact setup: commit or dirty state, seed, character, stage, Admin settings, input device, expected behavior, observed behavior, and capture when useful.
