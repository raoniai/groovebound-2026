# Engine parity contract

## Baseline evidence

- Clean commit and exact branch.
- Verified `.love` artifact and hash.
- Full test and lint result.
- Runtime asset manifest.
- Versioned save fixtures.
- Canonical seeded action traces.
- Performance and soak snapshot.
- Visual, audio, input, and campaign reference captures.

## Portable domain

Keep fixed tick, RNG, world state, combat, collision, progression, inventories, evolution, stage outcomes, and statistics independent of the presentation engine.

## Presentation adapters

Keep rendering, animation, UI, input devices, audio/video, assets, haptics, save paths, and export presets behind target-specific adapters.

## Hard gates

- Exact stable IDs, counts, choices, outcomes, and RNG states, except documented numeric tolerances.
- Non-destructive import of `{"version":1,"data":{...}}` saves.
- 300-enemy and 150-projectile scale proof.
- Desktop export and clean-machine boot.
- Manual visual, audio, controller, and full-campaign parity.
- Rollback artifact available throughout migration.

Do not introduce new mechanics, rebalance content, or redesign presentation during parity work.
