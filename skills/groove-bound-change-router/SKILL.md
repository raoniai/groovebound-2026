---
name: groove-bound-change-router
description: Classify and route Groove Bound requests before work begins. Use for broad updates, feature requests, planning, audits, or ambiguous changes that may affect the Lua/LÖVE runtime, game content, interface, media, release pipeline, desktop platforms, engine migration, handover record, or landing site.
---

# Groove Bound change router

Establish the canonical source, protected scope, acceptance contract, and specialist workflow before changing the project.

## Route the request

1. Locate the repository root and read `LATEST_VERSION_HANDOVER.md`.
2. Inspect the active branch, remotes, status, current diff, and untracked files. Run `scripts/project_snapshot.py` for a compact evidence record.
3. Classify every relevant item as canonical, reference-only, prototype, legacy, private, generated, or distribution output. Read [references/project-map.md](references/project-map.md) for the current map.
4. Translate the request into an acceptance contract:
   - outcome;
   - protected behavior and files;
   - expected files and systems;
   - automated checks;
   - manual checks;
   - approval gates;
   - destination and requested delivery state.
5. Route to the narrowest matching Groove Bound skill. Use more than one only when the request genuinely crosses boundaries.
6. Execute only when the user requested a change. For analysis, diagnosis, review, or planning, remain read-only.

## Routing table

- Mechanics, combat, entities, stages, progression behavior: `$groove-bound-gameplay-feature`
- Definitions, waves, values, build economy, balance: `$groove-bound-content-balance`
- Screens, HUD, menus, input, controllers, accessibility: `$groove-bound-interface-accessibility`
- Art, atlases, VFX, audio, music, video, provenance: `$groove-bound-media-pipeline`
- Bugs and regressions: `$groove-bound-regression-doctor`
- Tests, package, delivery state, commit or push readiness: `$groove-bound-release-verification`
- Windows, macOS, Linux native artifacts: `$groove-bound-desktop-distribution`
- Godot, MonoGame, Unity, or another runtime: `$groove-bound-engine-migration`
- Public landing page and copied web assets: `$groove-bound-site-sync`
- Latest state, task resume, or handoff: `$groove-bound-latest-handover`

## Enforce hard gates

- Preserve unrelated dirty work and never stage it by convenience.
- Derive mutable facts from live checks rather than status prose.
- Keep automated, graphical, manual, commit, push, merge, release, deployment, and public-live states separate.
- Keep signing, notarization, credentials, production deployment, destructive migration, and engine cutover human-gated.
- Stop a port, package, or release when its exact baseline cannot be identified.

## Return the contract

State the selected skill or skills, canonical source, protected scope, checks, manual acceptance, approval gates, and final delivery target before substantial implementation.
