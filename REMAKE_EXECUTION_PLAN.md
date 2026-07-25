# Groove Bound Remake — Canonical Execution Plan

**Plan version:** 1.0  
**Created:** 26 July 2026  
**Runtime:** LÖVE 11.5 / LuaJIT  
**Canonical candidate:** local `groove-bound/`, restored from remake PR head `fe79d6f`  
**Current delivery state:** Stages 0–4 vertical slice locally complete; uncommitted and unpushed

## Outcome

Build one complete, stable Groove Bound game that preserves the strongest
milestones from the original project while replacing its broken wiring,
duplicated ownership, listener leaks, string-matched upgrades, dead content,
and unverified release process.

The target game must support:

- responsive keyboard/mouse and gamepad play;
- automatic music-themed weapons;
- large enemy waves;
- XP, levels, cards, passives, reroll, and skip;
- limited weapon/passive slots;
- deterministic weapon upgrades and evolutions;
- bosses, victory, defeat, results, and rewards;
- beat-aware combat and a readable groove system;
- configurable controls and accessibility options;
- a development-only admin tuning panel;
- repeatable headless tests and packaged-build verification;
- production-safe original IP and licensed assets.

## Non-negotiable engineering rules

1. Stable IDs drive logic. Display names are presentation only.
2. Every gameplay fact has one owner.
3. Inventory is authoritative for owned weapons and levels.
4. The weapon runtime is authoritative for what is actively firing.
5. Evolution is an atomic transaction across inventory and weapon runtime.
6. Existing projectiles keep immutable stat snapshots.
7. Run-scoped listeners and timers die with the run.
8. All authored content is validated at boot.
9. All randomness comes from named, seeded run streams.
10. Gameplay tuning comes from content, configuration, or the bounded tuning
    service—not scattered numeric literals.
11. Admin controls are disabled in public builds.
12. A stage is complete only when its acceptance checks pass.

## Source boundaries

| Source | Role |
|---|---|
| Local `groove-bound/` | Canonical development candidate |
| 2026 remake PR #2 | Upstream provenance for the restored foundation |
| Original `004_GrooveBound` | Behavioral and asset reference |
| Prototype 1 and Prototype 2 | Regression and design reference only |
| Dropbox | Editable art/audio and provenance-review archive |
| Public `0_0_14` app | Frozen legacy reference, not a release base |

## Milestone map

Every original milestone is retained, but its order changes so a complete run
exists before content expansion.

| Original capability | New stage |
|---|---|
| Movement, aim, camera, gamepad | Stage 1 |
| Auto-fire, projectiles, damage | Stage 2 |
| Waves, enemy types, minibosses | Stages 2 and 4 |
| XP, loot, level-up, inventory | Stage 3 |
| Weapon levels, shop/cards, power-ups | Stage 3 |
| Weapon evolution | Stage 3, foundation contract starts in Stage 0 |
| Pause, HUD, game over | Stages 1 and 4 |
| Score/combo | Stage 4 |
| Boss, win condition, results | Stage 4 |
| Beat checker and groove bonus | Stage 5 |
| Sprites, SFX, visual effects | Stages 5–7 |
| Meta shop and unlocks | Stage 7 |
| Public packaging | Stage 8 |

## Design decisions absorbed from the mechanics research

The companion
[`SURVIVOR_ROGUELIKE_MECHANICS_RESEARCH_DOSSIER.md`](SURVIVOR_ROGUELIKE_MECHANICS_RESEARCH_DOSSIER.md)
changes several requirements from optional ideas into the working vertical-slice
direction:

- four initial active weapon slots, expandable through evolution to six;
- four passive/support slots;
- ten ranks per base weapon;
- behavioral changes at ranks 4 and 7;
- evolution eligibility at rank 10;
- one compatible support per evolution;
- a visible fusion choice that consumes the rank-10 base weapon and paired
  support, replaces the exact emitter, and frees future build space;
- on-beat play adds upside but never disables baseline combat;
- the initial groove meter combines survival/collection with kill-flow variety;
- defense is designed across health, guard, avoidance, and sustain;
- initial meta progression is primarily horizontal;
- recipes, eligibility, damage summaries, and trigger order are visible in UI;
- hard budgets exist for enemies, projectiles, particles, audio voices, and
  effect opacity;
- telemetry records offers shown as well as choices taken.

### Initial offer contract

Each normal level-up presents three valid cards:

1. an owned upgrade where possible;
2. a synergy or new-build option;
3. a defense, economy, or wildcard option.

The vertical slice starts with one reroll and unlimited skip for a small
XP/coin return. Banish waits until the content pool is large enough to justify
it. Impossible, capped, duplicated, or slot-invalid cards are excluded before
weighting.

### Research decisions still requiring playtest evidence

- movement-only auto-aim versus directional auto-aim as the default;
- relaxed power fantasy versus demanding action, or selectable modes;
- exact groove gain/loss curve;
- the percentage of a successful run that should feel dominant;
- armor formula and guard recharge cadence;
- final full-run length after the ten-minute slice;
- minimum-hardware enemy/projectile/effect/audio budgets.

These must be resolved before large-scale content production, not guessed while
implementing dozens of weapons.

## Stage 0 — Canonical foundation and contracts

### Deliverables

- Restore the tested 2026 foundation locally.
- Record exact upstream provenance.
- Keep one runtime root: `groove-bound/`.
- Preserve the dossier outside runtime code.
- Maintain state machine, scoped event bus, scheduler, RNG, save migrations,
  logger, pooling, spatial hash, content validation, run context, and tests.
- Make lint blocking.
- Add a LÖVE boot smoke check.
- Add the admin tuning model and functional modal UI.
- Add stable-ID weapon inventory.
- Add weapon runtime cross-checking.
- Add atomic evolution transactions and recipe validation.
- Document controls, evolution, and stage gates.

### Acceptance

- Unit suite passes with zero failures.
- Lint passes with zero findings.
- LÖVE reaches title screen without boot errors.
- Content validation includes evolution recipes.
- Admin values clamp, reset, and format correctly.
- F1 opens/closes the admin modal from title, run, and pause.
- Player speed and game speed use live tuning values.
- A rank-10 Kazoo Pistol plus Breath Control produces exactly one legal
  stable-ID fusion offer.
- The selected result replaces the exact inventory slot.
- The active emitter becomes that selected result in the same slot.
- A stale emitter blocks evolution.
- A failed runtime replacement rolls all state back.
- Existing Kazoo projectiles retain their original snapshots.

### Current state

Locally complete:

- 172 tests pass with zero failures;
- luacheck reports zero warnings/errors across 86 files;
- LÖVE 11.5 source and packaged-build smoke checks pass;
- the title entry and admin panel were visually verified at 1280×720;
- a live fire-rate adjustment was verified.

The stage is not committed, pushed, merged, tagged, or released.

## Stages 1–4 completion checkpoint

The current three-minute vertical slice now closes the functional Stage 1–4
loop:

- Stage 1: persistent options, resize-safe menus, keyboard/mouse/gamepad input,
  conflict-checked keyboard remapping, adjustable dead zone, repeat-run
  ownership and seed copy.
- Stage 2: pooled enemies/projectiles, knockback, four enemy brains, combat
  counters and the 300-enemy/150-projectile reference gate.
- Stage 3: lossless multi-threshold XP, three-card offers every level, four
  initial weapon/passive slots, reroll/skip, eight live supports and eight
  reachable consumable fusions.
- Stage 4: timed waves, a three-phase countdown, miniboss, Static Baron, boss
  health and attack, score/combo, deterministic defeat/victory, complete
  results and restart.

The seeded end-to-end simulation proves miniboss kill → bonus reroll → legal
Kazoo/support fusion → active Brass Barrage emitter → final-boss kill →
victory. The
packaged clean-machine acceptance remains a Stage 8 release gate; local
packaged boot and ZIP integrity are required at every checkpoint.

## Stage 1 — Movement, controls, options, and lifecycle

### Deliverables

- Final movement acceleration/deceleration and feel.
- Keyboard, mouse, and gamepad parity.
- Controller reconnect handling.
- Rebindable actions with conflict detection.
- Input-device prompts that switch automatically.
- Options screen:
  - master/music/SFX volume;
  - fullscreen/window mode;
  - resolution;
  - screen shake;
  - hit flash;
  - vibration;
  - aim assist;
  - dead zones;
  - accessibility timing window.
- Resize-safe title, run, pause, options, and HUD.
- Repeated title/run/pause lifecycle.
- Seed display and copy function.

### Acceptance

- Keyboard-only, mouse/keyboard, and gamepad-only navigation all work.
- No unreachable action binding.
- Two consecutive run/title loops leave one state stack and zero stale
  run-scoped listeners.
- Pause freezes run clock and all run systems.
- Window resizing never clips required controls.
- Settings persist through application restart and migrate from older schemas.
- Reference-machine movement remains stable at 60 FPS.

## Stage 2 — Combat foundation

### Deliverables

- Enemy entity and pool.
- Spawn director consuming validated wave data.
- Weapon activation scheduler.
- Projectile pool and hard active-projectile cap.
- Collision and faction filters through spatial hash.
- Damage, invulnerability, knockback, death, and drops.
- Kazoo Pistol fully playable.
- Monotone and Tempo Leech with distinct behavior.
- Admin consumers:
  - fire-rate multiplier;
  - damage multiplier;
  - bullet speed;
  - extra bullets per shot;
  - maximum bullets;
  - enemy speed;
  - spawn rate;
  - maximum enemies;
  - invincibility.
- Combat counters: enemies, projectiles, pools, collisions, frame time.

### Acceptance

- One weapon owns one emitter and fires from its current inventory slot.
- No display string participates in combat logic.
- Enemy XP value is preserved exactly.
- Damage is applied once per valid hit.
- Dead objects return to pools.
- Safety caps prevent unbounded spawn/projectile growth.
- 300 enemies plus 150 active projectiles meet the agreed frame-time target.
- The admin panel changes combat values without restart.
- Resetting admin values restores the designed baseline.

## Stage 3 — Progression, inventory, cards, and evolution

### Deliverables

- Single-owner XP and level system.
- Multi-threshold XP gains.
- XP gem attraction and pickup.
- Coins.
- Four weapon slots and passive-slot limit.
- Three-card offers generated from actual inventory/content state.
- New weapon, weapon level, passive, passive level, reroll, and skip.
- Rarity and weighting.
- Weapon/support fusion offers at level-up when a recipe becomes legal.
- HUD inventory with weapon/passive levels and evolution readiness.
- Admin commands for:
  - grant XP;
  - add/level a weapon;
  - add/level a passive;
  - spawn an evolution chest;
  - force a legal evolution;
  - refuse an illegal evolution with a visible reason.

### Evolution acceptance

- Eligibility checks exact stable IDs, levels, trigger, and passive conditions.
- No evolution appears when the base weapon is missing or under-levelled.
- No evolution appears when a required passive is missing.
- The result cannot be duplicated.
- Every fusion result and ingredient remains a distinguishable stable ID.
- Slot order is preserved.
- Current emitter and future shots use the evolved weapon.
- Existing shots preserve their original stats.
- HUD, run stats, and inventory all report the same result.
- Save/result serialization records stable IDs and evolution provenance.
- Ten seeded simulations produce no impossible offers or duplicate slots.

## Stage 4 — Complete run vertical slice

### Deliverables

- Timed wave progression.
- Wave announcements.
- Miniboss.
- Static Baron boss.
- Miniboss bonus-reroll reward.
- Player death.
- Victory.
- Game-over and results screens.
- Kills, time, damage, XP, coins, weapons, and evolutions in results.
- Score/combo system where it supports—not obscures—the survivor loop.
- Restart and return-to-title.

### Acceptance

- Both victory and defeat resolve deterministically.
- No run can idle forever after its final wave.
- Ten consecutive complete runs do not leak state/listeners.
- Results equal authoritative run statistics.
- Boss rewards cannot be claimed twice.
- A packaged internal build completes a full run on a clean machine.

## Stage 5 — Groove system

### Deliverables

- Track metadata: BPM, offset, time signature, loop points.
- Deterministic BeatClock.
- Beat/subdivision events.
- Visual beat pulse.
- On-beat grace window.
- Groove meter.
- Weapon beat policies:
  - free-running;
  - beat-quantized;
  - on-beat bonus;
  - every N beats.
- Beat-aware enemy/boss patterns.
- Admin controls for BPM override, beat offset, grace window, and metronome.
- Audio latency calibration.

### Acceptance

- BeatClock remains stable across pause and loop boundaries.
- Audio latency calibration persists.
- Missing a beat never breaks baseline weapon function.
- On-beat upside is readable in dense combat.
- Photosensitive and audio accessibility controls are available.
- Track metadata, not hard-coded timers, drives musical events.

## Stage 6 — Content and balance

### Deliverables

- First production vertical slice:
  - at least 16 base weapons;
  - at least eight compatible supports;
  - at least eight fused evolutions;
  - at least six ordinary enemy roles;
  - two elites;
  - one miniboss;
  - one final boss;
  - one stage;
  - one groove model;
  - one guard/armor model;
  - ten-minute run.
- Polished-demo expansion target:
  - at least eight weapons;
  - at least eight enemies;
  - at least eight passives;
  - two bosses.
- Rarity/balance tables.
- Character variants.
- Original, legally safe names and mythology.
- Seeded balance simulations.
- Results telemetry:
  - damage by weapon/status/synergy;
  - evolution time;
  - groove-tier uptime;
  - damage taken by source;
  - healing and guard prevention;
  - rerolls/skips;
  - FPS percentiles and peak entity/effect/audio counts.

### Acceptance

- Every weapon has a distinct role.
- Every evolution has a valid acquisition path.
- No dead content table exists.
- Simulations flag impossible recipes, offer starvation, damage outliers, and
  entity-cap violations.
- Content can be added without engine edits.

## Stage 7 — Meta progression, art, audio, and accessibility

### Deliverables

- Meta currency and shop.
- Unlockable characters/content.
- Pixel-art production pass.
- Animation and effects.
- Original/licensed soundtrack.
- Final SFX mix.
- Asset provenance register.
- Accessibility pass:
  - remapping;
  - reduced flash;
  - reduced shake;
  - high-contrast pickups;
  - volume separation;
  - timing assistance;
  - readable text scale.

### Acceptance

- Meta save migrates and survives corruption fallback.
- No imported asset ships without recorded provenance and license.
- No real musician likeness/name ships without clearance.
- Audio loudness and format targets pass.
- The game remains legible without color or audio alone.

## Stage 8 — Release engineering

### Deliverables

- Blocking lint and tests.
- Automated LÖVE boot smoke.
- Seeded simulation suite.
- Windows, macOS, Linux, and `.love` builds.
- Groove Bound bundle name and owned identifiers.
- macOS signing and notarization.
- Checksums and manifest.
- Changelog, tags, releases, and accurate version page.
- Development/admin code disabled in release mode.
- Legacy public page relabelled or replaced.

### Acceptance

- Artifact content matches its tagged commit.
- Clean-machine install and launch pass on supported platforms.
- Public build contains no admin menu, test content, private sources, or
  unlicensed assets.
- Version labels agree across Git tag, executable, website, and download.
- The public download is independently verified after deployment.

## Admin control surface

The admin panel is a developer tool, not player progression. It must:

- open with F1 in development builds;
- pause underlying gameplay while open;
- support keyboard, mouse, and gamepad;
- show category, label, current value, help, and bounds;
- adjust only registered stable IDs;
- clamp unsafe values;
- reset one value or all values;
- expose performance safety caps;
- report active enemies/projectiles and frame-time health;
- be forcibly disabled during release packaging.

Current registered controls:

| Control | Consumer stage |
|---|---|
| Game speed | Stage 0, connected |
| Player speed | Stage 0, connected |
| Player invincibility | Stage 2 |
| Fire-rate multiplier | Stage 2 weapon runtime |
| Damage multiplier | Stage 2 projectile snapshots |
| Bullet speed | Stage 2 projectile snapshots |
| Extra bullets per shot | Stage 2 projectile snapshots |
| Maximum active bullets | Stage 2 projectile manager |
| Enemy speed | Stage 2 enemy movement |
| Spawn-rate multiplier | Stage 2 spawn director |
| Maximum active enemies | Stage 2 spawn director |
| XP multiplier | Stage 3 XP owner |
| Pickup radius | Stage 3 pickup system |
| BPM override | Stage 5 BeatClock |

Controls are registered early so later systems consume one tested contract.
They are not considered connected until their named stage is verified.

## Improvement register

### Product improvements

- Validate the groove mechanic before producing large content quantities.
- Reward on-beat play; avoid punishing players who cannot or do not want to
  play rhythmically.
- Keep office-worker-versus-musical-fantasy identity central.
- Use original genre-spirit bosses instead of real artists.
- Make evolution requirements visible and learnable in the HUD/collection.

### Control improvements

- Full action remapping with duplicate/conflict feedback.
- Adjustable stick dead zones and aim assist.
- Gamepad focus that never disappears.
- Optional manual-fire mode alongside auto-fire.
- Hold/toggle choices for relevant actions.
- Runtime input-device prompt switching.
- Debug step-frame and pause controls after combat exists.

### Engineering improvements

- Make lint blocking.
- Add automated boot and simulation checks.
- Add performance budgets per system.
- Record event ownership.
- Keep content schema versioned.
- Add asset and dependency license manifests.
- Add deterministic replay traces for difficult bugs.
- Keep public releases reproducible and traceable to a commit.

## Current next gate

Begin Stage 5 with deterministic track metadata and BeatClock, then connect
the existing BPM admin override, beat pulse, grace window, and groove meter.
The local toolchain runs unit tests, blocking lint, source/package boot smoke,
and package-integrity checks reliably.
