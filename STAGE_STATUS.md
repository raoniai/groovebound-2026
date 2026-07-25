# Groove Bound Remake — Stage Status

**Status date:** 26 July 2026  
**Canonical local runtime:** `groove-bound/`  
**Upstream foundation:** remake PR head `fe79d6f`  
**Delivery status:** Stages 0–4 vertical slice locally complete; uncommitted and unpushed

## Stage board

| Stage | Status |
|---|---|
| 0 — Canonical foundation and contracts | **Locally complete** |
| 1 — Movement, controls, options, lifecycle | **Locally complete for vertical slice** |
| 2 — Combat foundation | **Locally complete for vertical slice** |
| 3 — Progression, inventory, cards, evolution | **Locally complete for vertical slice** |
| 4 — Complete run vertical slice | **Locally complete** |
| 5 — Groove system | Next |
| 6 — Content and balance | Planned |
| 7 — Meta, art, audio, accessibility | Legacy visual/audio bridge imported; production pass planned |
| 8 — Release engineering | Planned |

## Stage 0 delivered

- Restored the clean 2026 remake foundation locally.
- Retained its 100 inherited unit tests.
- Added a bounded runtime tuning model.
- Added a rendered Admin Controls modal.
- Added title and pause menu access plus F1 access.
- Added keyboard, mouse, and gamepad input routes.
- Connected game-speed and player-speed controls.
- Registered combat, projectile, enemy, reward, and BPM controls for their
  owning stages.
- Added stable-ID weapon inventory.
- Added active weapon-emitter runtime.
- Added immutable projectile stat snapshots.
- Added validated evolution content.
- Added atomic evolution with rollback.
- Added exact inventory/runtime consistency checks.
- Reconciled the mechanics research into a rank-10 Resolve evolution contract.
- Added distinct Studio and Live Kazoo evolution choices.
- Made lint blocking in CI.
- Added a LÖVE boot-smoke mode and CI step.
- Added repository ignore/editor rules.
- Added the canonical execution, admin-control, and evolution specifications.

## Stages 1–4 delivered

- Imported an isolated, provenance-recorded subset of original Groove Bound
  sprite sheets, floor art, UI imagery, pixel font, and SFX.
- Added animated player and enemy rendering.
- Added deterministic timed waves, distinct enemy brains, miniboss and boss.
- Added eight base weapons, automatic targeting/firing, four firing patterns,
  color-coded projectiles, and pooled projectiles.
- Added spatial-hash collisions, damage, death, invulnerability frames, and
  enemy contact damage.
- Added XP gem drops, attraction and lossless multi-threshold levelling.
- Added a paused three-card choice at every level, reroll, skip, four weapon
  slots, four passive slots, legal filtering and seeded offers.
- Added original generated weapon icon art, illustrated level-up cards, a
  four-slot HUD weapon rack, and a navigable Arsenal Database.
- Added live Arsenal status cross-checks for inventory ownership, active
  emitter identity, slot, rank, level-up availability, and evolution
  eligibility.
- Added live passive effects, guard, healing, coins, score and combo.
- Made Studio/Live Kazoo evolution reachable through rank 10, Breath Control,
  the Metronome Guardian Resolve reward and the real choice UI.
- Added Static Baron, boss health, ranged boss damage, hard timeout, victory,
  defeat, authoritative results, replay and return-to-title.
- Added persistent options, screen shake/hit flash/aim/vibration controls,
  controller dead-zone control, conflict-checked keyboard rebinding and seed
  copy.
- Added active-run admin tools for level, legal evolution setup and final boss.
- Rebuilt the Admin Controls modal as an icon-led, segmented dashboard with
  bounded value bars and direct Arsenal access.
- Added health/guard/XP/time/inventory/boss/entity/pool/frame-time HUD.
- Connected every current admin control except BPM to its runtime consumer.
- Preserved the pre-existing `dist/_archive/groove-bound-bkp-01.love` while
  rebuilding the current package.

## Verification evidence

| Check | Result |
|---|---|
| Headless LuaJIT tests | **164 tests, 0 failures** |
| Luacheck | **0 warnings, 0 errors across 84 files** |
| LÖVE version | **11.5 installed locally** |
| Source boot smoke | **Passed; content validated and title state entered** |
| Packaged `.love` boot smoke | **Passed** |
| Package ZIP integrity | **No errors** |
| Package size | **1,103,278 bytes** |
| Package SHA-256 | `0e59d3290fdc90b01c78e240c843764c98eb07d6e204edfb63ea97327b38304e` |
| Admin title-menu entry | **Visually verified** |
| Admin modal rendering | **Visually verified at 1280×720** |
| Live admin adjustment | **Fire rate changed from 1.0× to 1.1×** |
| Complete live run | **Victory at 01:00; 31 kills, 125 shots, 270 XP, level/rank 6** |
| Visible combat entities | **Enemies, bullets, XP gems, player animation, and results verified** |
| Evolution choice UI | **Both Live and Studio branches visually verified** |
| Live evolved emitter | **Studio selection changed HUD/runtime to Brass Barrage and fired immediately** |
| Boss HUD | **Static Baron spawn, label, health bar and combat visually verified** |
| Arsenal Database | **10-weapon roster, filters, icons, stats and acquisition status visually verified** |
| Visual admin dashboard | **Eight segments, vector icons, value bars and Arsenal entry visually verified** |
| Illustrated level-up cards | **Weapon/passive art, rank, pattern and live stats visually verified** |
| Seeded full-run simulation | **Miniboss → Resolve → Studio evolution → final boss → victory passed** |
| Scale reference | **300 enemies + 150 projectiles passed the 250 ms headless safety gate** |
| Evolution inventory/runtime tests | **Passed** |
| Evolution rollback test | **Passed** |
| Studio/Live branch identity test | **Passed** |
| Old/new projectile snapshot test | **Passed** |

## Scope boundary

Stages 1–4 are complete for the current three-minute vertical-slice scope.
This does not mean the whole game is finished. Stage 5 still owns BeatClock,
track metadata and groove; Stage 6 owns the ten-minute content/balance target;
Stage 7 owns meta progression, production art/audio and full accessibility;
Stage 8 owns signed cross-platform release engineering.

Music volume is persisted but has no soundtrack consumer until Stage 5/7.
The legacy font license and any final production assets still require the
release provenance gate.

The build is not committed, pushed, merged, tagged, or publicly deployed.

## Next stage entry

Stage 5 begins with deterministic track metadata and BeatClock, then connects
the existing BPM admin override, beat pulse, grace window and groove meter.
