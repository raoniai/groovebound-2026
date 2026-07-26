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
- Reconciled evolution into a rank-10 weapon plus compatible support contract.
- Added eight distinct, consumable stable-ID fusion recipes.
- Made lint blocking in CI.
- Added a LÖVE boot-smoke mode and CI step.
- Added repository ignore/editor rules.
- Added the canonical execution, admin-control, and evolution specifications.

## Stages 1–4 delivered

- Imported a provenance-recorded subset of original floor art, UI imagery,
  pixel font, and SFX, then added six original generated visual atlases.
- Added a new four-direction player, eight enemy variants, 16 base-weapon
  icons, eight support icons, eight fused-weapon icons, and environment art.
- Added deterministic timed waves, eight enemy variants across four behavior
  families, miniboss and boss.
- Added 16 base weapons, automatic targeting/firing, seven firing patterns,
  color-coded projectiles, and pooled projectiles.
- Added solid speaker/case/amplifier/stage obstacles and non-blocking arena
  decorations.
- Added spatial-hash collisions, damage, death, invulnerability frames, and
  enemy contact damage.
- Added XP gem drops, attraction and lossless multi-threshold levelling.
- Added a paused three-card choice at every level, reroll, skip, four initial
  weapon slots, four support slots, legal filtering and seeded offers.
- Added category-balanced seeded offer rotation, immediate anti-repeat
  protection, guaranteed new weapons while slots are open, and guaranteed
  owned-rank choices when both inventories are full.
- Added illustrated level-up/fusion cards, expandable HUD weapon/support racks,
  and a navigable Arsenal Database covering 24 weapons plus eight supports.
- Added live Arsenal status cross-checks for inventory ownership, active
  emitter identity, slot, rank, level-up availability, and evolution
  eligibility.
- Added eight live support effects spanning speed, health, damage, attraction,
  cooldown stability, fire rate, projectile count, and guard.
- Made eight fusions reachable through rank 10 plus their paired support, with
  a five-second evolution-ready notification and real illustrated choice UI.
- Added a default-on Admin toggle for on-card fusion pairings and a level-up
  guide showing exact missing rank/support requirements.
- Made fusion atomic across weapon inventory, support inventory, active
  emitters, modifier refresh, slot-capacity expansion, and rollback.
- Added Static Baron, boss health, ranged boss damage, hard timeout, victory,
  defeat, authoritative results, replay and return-to-title.
- Added persistent options, screen shake/hit flash/aim/vibration controls,
  controller dead-zone control, conflict-checked keyboard rebinding and seed
  copy.
- Added active-run admin tools for level, legal evolution setup and final boss.
- Rebuilt the Admin Controls modal as an icon-led, segmented dashboard with
  bounded value bars and direct Arsenal access.
- Added health/guard/XP/stage countdown/inventory/support/boss/entity/pool/
  frame-time HUD.
- Added three automatic 60-second phases with countdown and clear banners.
- Connected every current admin control except BPM to its runtime consumer.
- Preserved the pre-existing `dist/_archive/groove-bound-bkp-01.love` while
  rebuilding the current package.

## Verification evidence

| Check | Result |
|---|---|
| Headless LuaJIT tests | **177 tests, 0 failures** |
| Luacheck | **0 warnings, 0 errors across 86 files** |
| LÖVE version | **11.5 installed locally** |
| Source boot smoke | **Passed; content validated and title state entered** |
| Packaged `.love` boot smoke | **Passed** |
| Package ZIP integrity | **No errors** |
| Package size | **4,850,502 bytes** |
| Package SHA-256 | `ba6e4f0bbc5554297dd1b9598a89e677ef93e21a40fda77c6bf632303b2259a4` |
| Admin title-menu entry | **Visually verified** |
| Admin modal rendering | **Visually verified at 1280×720** |
| Live admin adjustment | **Fire rate changed from 1.0× to 1.1×** |
| Complete live run | **Victory at 01:00; 31 kills, 125 shots, 270 XP, level/rank 6** |
| Visible combat entities | **Enemies, bullets, XP gems, player animation, and results verified** |
| Earlier evolution prototype | **Prior Kazoo branch UI/emitter was visually verified before the fusion expansion** |
| Boss HUD | **Static Baron spawn, label, health bar and combat visually verified** |
| Expanded build visual pass | **Pending manual unlock; generated PNGs inspected, automated package boot passed** |
| Visual admin dashboard | **Eight segments, vector icons, value bars and Arsenal entry visually verified** |
| Illustrated level-up cards | **Weapon/passive art, rank, pattern and live stats visually verified** |
| Seeded full-run simulation | **Miniboss → reroll → fusion → final boss → victory passed** |
| Scale reference | **300 enemies + 150 projectiles passed the 250 ms headless safety gate** |
| Evolution inventory/runtime tests | **Passed** |
| Evolution rollback test | **Passed** |
| Fusion readiness/consumption tests | **Passed** |
| Old/new projectile snapshot test | **Passed** |

## Scope boundary

Stages 1–4 are complete for the current three-phase vertical-slice scope.
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
