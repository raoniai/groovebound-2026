---
name: groove-bound-engine-migration
description: Assess, plan, spike, implement, or verify a Groove Bound engine or language migration while preserving behavior. Use for Godot and C#, MonoGame, Unity, GDScript, another engine, portable simulation extraction, deterministic replay, save import, platform export, performance parity, rollback, or cutover decisions.
---

# Groove Bound engine migration

Treat the Lua/LÖVE build as the golden reference until a target release passes explicit parity and rollback gates.

## Select the mode

1. Assess feasibility and current official engine/platform support.
2. Freeze a clean, reproducible baseline.
3. Run a bounded feasibility spike.
4. Port through differential parity stages.
5. Cut over only after release acceptance.

Read `LATEST_VERSION_HANDOVER.md`, `ENGINE_MIGRATION_RESEARCH_AND_PLAN.md`, and [references/parity-contract.md](references/parity-contract.md).

## Workflow

1. Revalidate current stable engine versions, export support, licensing, and target-platform requirements. Treat old research versions as historical evidence.
2. Refuse a full port from an unidentified or dirty baseline. Preserve source, package, saves, manifests, seeded runs, performance captures, and visual/audio references.
3. Keep deterministic simulation independent from rendering, UI, input, audio, assets, haptics, and OS paths.
4. Define an action-level replay schema and compare Lua and target results tick by tick.
5. Import versioned saves non-destructively. Preserve originals and record migration checksums.
6. Prove content IDs, RNG state, progression, collision, stage outcomes, statistics, input, timing, media, and package behavior.
7. Run the 300-enemy and 150-projectile scale scenario plus soak tests.
8. Keep parity work and post-parity improvements in separate backlogs.
9. Stop at the spike if a hard gate fails. Evaluate the fallback engine or remain on LÖVE.
10. Keep the LÖVE release available until cutover stabilization is accepted.

## Default decision boundary

Use Godot with a pure C# simulation domain as the leading desktop candidate and MonoGame/C# as the code-first fallback, subject to live revalidation. Treat Godot 4 C# web export as unsupported until official documentation proves otherwise.
