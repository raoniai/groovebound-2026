---
name: groove-bound-gameplay-feature
description: Implement or modify deterministic Groove Bound gameplay systems in the Lua/LÖVE runtime. Use for combat, enemies, weapons, projectiles, pickups, collision, navigation, stage flow, spawning, bosses, rewards, progression behavior, evolution mechanics, camera behavior, run simulation, or the future groove and BeatClock layer.
---

# Groove Bound gameplay feature

Implement mechanics without breaking deterministic runs, lifecycle ownership, content contracts, or presentation fallbacks.

## Workflow

1. Read `LATEST_VERSION_HANDOVER.md`, inspect current changes, and identify the smallest owning module.
2. Read [references/gameplay-contracts.md](references/gameplay-contracts.md) and the existing focused tests before editing.
3. Separate pure simulation behavior from rendering, input, audio, and UI concerns.
4. Add or update the narrow regression test first when the behavior is mechanically observable.
5. Implement through the existing owner instead of adding a parallel authority.
6. Preserve deterministic stream ownership, stable IDs, immutable projectile snapshots, event cleanup, pool release, and state transitions.
7. Add a bounded Admin or test-mode route only when it materially improves repeated verification.
8. Run focused tests, the full suite, lint, and any relevant seeded full-run or scale test.
9. Perform or explicitly defer the exact manual gameplay checks. Automated checks do not prove navigation quality, animation, timing feel, audio, or readability.
10. Route asset, interface, balance, packaging, or site work to the corresponding skill.

## Acceptance

- Cover happy path, boundary, failure, teardown, and repeatability.
- Compare multiple seeds when RNG behavior changes.
- Keep content definitions data-driven and validate cross-references.
- Check simultaneous events, stage transitions, pause/resume, and capped inventories when relevant.
- Report each requested criterion individually and leave unverified visual criteria open.
