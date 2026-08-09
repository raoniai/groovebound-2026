---
name: groove-bound-content-balance
description: Add, revise, or balance Groove Bound data-driven content. Use for characters, weapons, supports, fusions, enemies, bosses, stages, waves, reward economy, offer probabilities, build diversity, run pacing, difficulty ramps, or tuning that should preserve stable IDs and progression reachability.
---

# Groove Bound content and balance

Change content through validated definitions and measured outcomes while keeping design proposals distinct from proven player behavior.

## Workflow

1. Read `LATEST_VERSION_HANDOVER.md` and [references/content-contracts.md](references/content-contracts.md).
2. Identify every stable ID, definition, runtime consumer, UI representation, asset mapping, test, database entry, and site copy affected by the change.
3. Preserve existing IDs. Introduce a new ID only for genuinely new content or an explicit migration.
4. Define the intended role, strengths, trade-offs, counters, stage context, and build relationships before editing values.
5. Update content definitions and validation together.
6. Exercise multiple deterministic seeds for offers, progression, fusion reachability, waves, and boss timing.
7. Check capped inventories, repeated offers, rank limits, reward fallbacks, and stage carryover.
8. Update the Arsenal and player-facing explanations when visible contracts change.
9. Run full tests and lint. Perform manual feel/readability checks before calling balance accepted.
10. Update the latest handover after a material accepted change.

## Guardrails

- Preserve the bright urban-supernatural, music-meets-cosmic-robot identity unless the user changes the canon.
- Avoid opaque recipes, blocked builds, forced metas, negligible upgrades, and RNG that prevents coherent builds.
- Label simulated outcomes, designer hypotheses, and player observations separately.
- Do not rebalance unrelated content as cleanup.
