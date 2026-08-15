# Groove Bound Enemy Animation Asset Implementation Plan

> Superseded on 2026-08-15 by
> `ENEMY_STATE_ANIMATION_IMPLEMENTATION_PLAN.md`. This document describes the
> rejected v0.9.3 movement-only implementation and is retained for provenance.

**Date:** 2026-08-14  
**Current delivery state:** committed and pushed as v0.9.3; automated, media,
renderer, source-package, native macOS/Windows boot, payload-parity, GitHub
publication, exact local-mirror, site deployment, and public-live checks passed.
The 420-file site bundle is byte-verified on HTTPS with rollback
`20260815-153846-v0.9.3`; both stable desktop download routes resolve to the
v0.9.3 GitHub assets.
**Approval received:** 2026-08-15. The current `breakbeat_bruiser` visual alias
is retained so implementation matches the canonical enemy definitions.

## 1. Outcome and protected scope

This pass produced package-excluded animation candidates for every enemy visual
currently present in the canonical runtime content. It deliberately did not
modify enemy loading, content definitions, entity updates, rendering, gameplay,
tests, packages, version labels, site assets, or release artifacts.

Protected invariants for the later implementation:

- no changes to enemy IDs, HP, speed, size, damage, XP, coins, brains, attacks,
  cooldowns, windups, projectile behavior, hurtboxes, collision, navigation,
  wave composition, deterministic RNG, or save data;
- preserve the current horizontal flip behavior for left-facing movement;
- animation time is visual-only and must not feed simulation outcomes;
- no per-frame image allocation or disk loading during gameplay;
- retain the current static sprite as a fail-safe when an animation mapping or
  asset cannot be resolved;
- keep editable/generated sources outside the packaged game.

## 2. Canonical sources and classifications

| Material | Path | Classification |
|---|---|---|
| Enemy definitions | `groove-bound/src/content/enemies.lua` | Canonical runtime content |
| Current enemy loader/drawer | `groove-bound/src/assets.lua` | Canonical runtime code |
| Enemy animation clock/draw call | `groove-bound/src/game/entities/enemy.lua` | Canonical runtime code |
| Existing Backbeat atlas | `groove-bound/assets/generated/enemy-variants-atlas.png` | Runtime reference |
| Existing Orbit atlas | `groove-bound/assets/generated/campaign/stage2-enemies-atlas.png` | Runtime reference |
| Existing World Tour atlases | `groove-bound/assets/generated/campaign/{funk,soul,disco,jazz}-enemies-atlas.png` | Runtime references |
| New candidate root | `groove-bound/assets/generated/source-candidates/2026-08-14-enemy-animation/` | Generated, package-excluded |
| Candidate manifest | `groove-bound/assets/generated/source-candidates/2026-08-14-enemy-animation/candidate-manifest.json` | Generated technical record |
| Candidate provenance | `groove-bound/assets/generated/source-candidates/2026-08-14-enemy-animation/PROVENANCE.md` | Reference record |
| Prompt record | `groove-bound/assets/generated/source-candidates/2026-08-14-enemy-animation/PROMPTS.md` | Reference record |

The existing package builder explicitly excludes any path containing
`/source-candidates/`, so none of the new files can enter a `.love` or desktop
package in their current location.

## 3. Delivered asset structure

```text
groove-bound/assets/generated/source-candidates/2026-08-14-enemy-animation/
├── candidate-manifest.json
├── prepare_candidates.py
├── PROMPTS.md
├── PROVENANCE.md
├── backbeat/
├── orbit/
├── funk/
├── soul/
├── disco/
└── jazz/
    ├── <roster>-movement-atlas-chroma-source.png
    ├── <roster>-movement-atlas-transparent.png
    ├── <roster>-movement-atlas-clean.png
    └── frames/<enemy-id>/
        ├── frame-01.png
        ├── frame-02.png
        ├── frame-03.png
        ├── frame-04.png        # Jazz only
        ├── preview-strip.png
        └── preview.gif         # review only
```

Orbit and Jazz also retain rejected magenta-key sources for provenance. Jazz
retains a normalized transparent intermediate because its selected generator
source arrived at 887x1774 and was normalized to exact 256x256 cells.

### Clean atlas contracts

| Roster | Clean candidate | Grid | Frames | Runtime IDs covered |
|---|---|---:|---:|---:|
| Backbeat | `backbeat/backbeat-movement-atlas-clean.png` | 4x6, 256px cells | 3 each | 8 |
| Orbit | `orbit/orbit-movement-atlas-clean.png` | 4x6, 256px cells | 3 each | 8 plus 1 alias |
| Funk | `funk/funk-movement-atlas-clean.png` | 4x6, 256px cells | 3 each | 8 |
| Soul | `soul/soul-movement-atlas-clean.png` | 4x6, 256px cells | 3 each | 8 |
| Disco | `disco/disco-movement-atlas-clean.png` | 4x6, 256px cells | 3 each | 8 |
| Jazz | `jazz/jazz-movement-atlas-clean.png` | 4x8, 256px cells | 4 each | 8 |

Five 4x6 atlases keep each source column fixed: rows 1-3 are frames for the
original first roster row, and rows 4-6 are frames for the original second
roster row. Jazz is row-based: one enemy per row, frames 1-4 from left to
right.

## 4. Complete enemy mapping

Every frame folder below is relative to the candidate root. Proposed FPS is a
starting value for visual review, not an implemented balance value.

### Backbeat Streets

| Enemy ID | Frame folder | Frames | Motion | Proposed FPS |
|---|---|---:|---|---:|
| `monotone` | `backbeat/frames/monotone/` | 3 | lurching foot/arm weight shift | 6 |
| `tempo_leech` | `backbeat/frames/tempo_leech/` | 3 | alternating mechanical legs | 9 |
| `metronome_guardian` | `backbeat/frames/metronome_guardian/` | 3 | heavy march and pendulum sway | 5 |
| `static_baron` | `backbeat/frames/static_baron/` | 3 | planted speaker/antenna pulse | 5 |
| `syncopation_skitter` | `backbeat/frames/syncopation_skitter/` | 3 | fast spider-leg cycle | 10 |
| `feedback_phantom` | `backbeat/frames/feedback_phantom/` | 3 | floating cloth/tendril wave | 7 |
| `bass_brute` | `backbeat/frames/bass_brute/` | 3 | heavy speaker-body stomp | 6 |
| `noise_turret` | `backbeat/frames/noise_turret/` | 3 | planted dish scan/recoil | 5 |

### Orbit Line

| Enemy ID | Frame folder | Frames | Motion | Proposed FPS |
|---|---|---:|---|---:|
| `vinyl_drone` | `orbit/frames/vinyl_drone/` | 3 | hover, turntable rotation, claw cycle | 8 |
| `trumpet_ray` | `orbit/frames/trumpet_ray/` | 3 | leg cycle and brass recoil | 7 |
| `drum_wheel` | `orbit/frames/drum_wheel/` | 3 | rolling stomp and core pulse | 7 |
| `theremin_jelly` | `orbit/frames/theremin_jelly/` | 3 | tentacle curl and hover bob | 7 |
| `amp_hound` | `orbit/frames/amp_hound/` | 3 | quadruped walk | 10 |
| `keyboard_centipede` | `orbit/frames/keyboard_centipede/` | 3 | travelling multi-leg wave | 8 |
| `turntable_sentinel` | `orbit/frames/turntable_sentinel/` | 3 | heavy advance, platter and dish motion | 5 |
| `grand_orchestrator` | `orbit/frames/grand_orchestrator/` | 3 | monumental weight/cymbal/speaker pulse | 4 |
| `breakbeat_bruiser` | alias: `orbit/frames/turntable_sentinel/` | 3 | current shared visual mapping | 5 |

`breakbeat_bruiser` currently points to the same source cell as
`turntable_sentinel` in `enemies.lua`. The candidate manifest preserves that
truth. If a separate Breakbeat Bruiser identity is wanted, generate and approve
it before runtime integration; do not silently split the alias in code.

### Funk World

| Enemy ID | Frame folder | Frames | Motion | Proposed FPS |
|---|---|---:|---|---:|
| `pocket_gremlin` | `funk/frames/pocket_gremlin/` | 3 | jaunty sneaker walk | 9 |
| `slapback_hound` | `funk/frames/slapback_hound/` | 3 | quadruped walk and tail bounce | 10 |
| `groove_guard` | `funk/frames/groove_guard/` | 3 | heavy speaker march | 6 |
| `talkbox_oracle` | `funk/frames/talkbox_oracle/` | 3 | float, keyboard and hose pulse | 6 |
| `boogie_tank` | `funk/frames/boogie_tank/` | 3 | spider-leg/turntable cycle | 5 |
| `funkadelic_wasp` | `funk/frames/funkadelic_wasp/` | 3 | wingbeat and stinger flex | 11 |
| `mothership_of_funk` | `funk/frames/mothership_of_funk/` | 3 | hover and piano-ring pulse | 4 |
| `pocket_phantom` | `funk/frames/pocket_phantom/` | 3 | smoky floating sway | 7 |

### Soul World

| Enemy ID | Frame folder | Frames | Motion | Proposed FPS |
|---|---|---:|---|---:|
| `choir_automaton` | `soul/frames/choir_automaton/` | 3 | step and microphone sway | 6 |
| `string_sentinel` | `soul/frames/string_sentinel/` | 3 | mechanical legs and bow motion | 7 |
| `organ_walker` | `soul/frames/organ_walker/` | 3 | cathedral march | 5 |
| `harmony_linker` | `soul/frames/harmony_linker/` | 3 | paired-mask orbit and cable arc | 7 |
| `gospel_moth` | `soul/frames/gospel_moth/` | 3 | stained-glass wingbeat | 10 |
| `velvet_knight` | `soul/frames/velvet_knight/` | 3 | shield/staff march | 6 |
| `organ_colossus` | `soul/frames/organ_colossus/` | 3 | monumental organ-leg stomp | 4 |
| `velvet_titan` | `soul/frames/velvet_titan/` | 3 | heavy robe/horn-speaker pulse | 4 |

### Disco World

| Enemy ID | Frame folder | Frames | Motion | Proposed FPS |
|---|---|---:|---|---:|
| `prism_roller` | `disco/frames/prism_roller/` | 3 | roller-skate stride | 10 |
| `mirror_drone` | `disco/frames/mirror_drone/` | 3 | rotor spin and hover bob | 9 |
| `laser_fan` | `disco/frames/laser_fan/` | 3 | mirrored fan opening pulse | 7 |
| `reflection_twin` | `disco/frames/reflection_twin/` | 3 | opposing synchronized weight shift | 7 |
| `platform_pouncer` | `disco/frames/platform_pouncer/` | 3 | platform-creature lunge | 9 |
| `glitter_guard` | `disco/frames/glitter_guard/` | 3 | heavy shield march | 6 |
| `laser_conductor` | `disco/frames/laser_conductor/` | 3 | planted baton sweep | 5 |
| `prism_monarch` | `disco/frames/prism_monarch/` | 3 | floating facet/speaker pulse | 4 |

### Jazz World

| Enemy ID | Frame folder | Frames | Motion | Proposed FPS |
|---|---|---:|---|---:|
| `syncopated_imp` | `jazz/frames/syncopated_imp/` | 4 | jaunty drumstick/jester step | 9 |
| `blue_note_bat` | `jazz/frames/blue_note_bat/` | 4 | musical wingbeat | 11 |
| `walking_bass_bot` | `jazz/frames/walking_bass_bot/` | 4 | bass-body walking cycle | 7 |
| `scat_cannon` | `jazz/frames/scat_cannon/` | 4 | squat leg and cannon recoil cycle | 7 |
| `bebop_behemoth` | `jazz/frames/bebop_behemoth/` | 4 | heavy drummer march | 5 |
| `brushfire_skitter` | `jazz/frames/brushfire_skitter/` | 4 | spider-leg/brush ripple | 10 |
| `brass_regent` | `jazz/frames/brass_regent/` | 4 | saxophone step and cape motion | 5 |
| `midnight_maestro` | `jazz/frames/midnight_maestro/` | 4 | floating conductor/baton cycle | 5 |

## 5. Candidate QA completed

- Reconciled 49 canonical enemy IDs to 48 unique source visuals.
- Generated 152 frames: 120 across Backbeat, Orbit, Funk, Soul, and Disco;
  32 across Jazz.
- Confirmed all clean frames are 256x256 RGBA with transparent corners.
- Confirmed zero clean-frame edge crossings after atlas-wide component
  isolation.
- Confirmed all six clean atlas dimensions and grids.
- Preserved untouched selected sources and rejected key-conflict sources.
- Wrote SHA-256 hashes, alpha bounds, frame paths, aliases, and preview paths to
  `candidate-manifest.json`.
- Visually inspected all six cleaned atlases for identity continuity, gross
  chroma damage, and cross-cell contamination.
- Confirmed the existing package exclusion for `/source-candidates/`.

This is structural and visual-candidate QA. It does not prove in-game loop
feel, crowded readability, performance, boss-scale presentation, or physical
controller play.

## 6. Implementation plan after approval

### Phase A — approve and promote assets

1. Review each `preview.gif` and record accept/regenerate decisions.
2. Decide whether `breakbeat_bruiser` remains a deliberate visual alias or
   receives a unique commissioned design.
3. Promote only the six approved `*-movement-atlas-clean.png` files to a new
   runtime directory such as
   `groove-bound/assets/generated/campaign/enemy-animation/`.
4. Add the promoted filenames, source hashes, prompt references, stable mapping,
   package status, and alias decision to
   `groove-bound/assets/generated/PROVENANCE.md` without replacing source files.

### Phase B — loader and quad mapping

1. In `groove-bound/src/assets.lua`, preload each movement atlas once and set
   nearest-neighbour filtering.
2. Build an `enemy.animation_quads` mapping keyed by existing atlas ID and
   source cell. Do not parse JSON at runtime.
3. For 4x6 rosters, derive a three-quad list from the existing source column and
   source row group. For Jazz, derive a four-quad list from its row-major source
   cell index.
4. Extend `Assets:draw_enemy_variant()` with an optional animation frame. When
   the frame or mapping is absent, retain the current static quad.
5. Keep the draw origin, `sprite_size`, tint, flash/windup color, and `flip_x`
   behavior unchanged.

### Phase C — visual-only entity clock

1. In `groove-bound/src/game/entities/enemy.lua`, keep the legacy six-frame
   fallback clock separate from the new variant-frame index.
2. Select frame count and FPS from immutable visual metadata. Start with the
   table above, then tune only through manual visual review.
3. Use a deterministic visual phase derived from stable spawn coordinates or a
   spawn ordinal so large groups do not animate in perfect lockstep. The phase
   must never consume a gameplay RNG stream.
4. Continue animating `brain == "static"` enemies with their authored planted
   pulse/scan motion; do not translate their world position.
5. Pass the selected frame to `draw_enemy_variant()` and keep horizontal
   direction flipping exactly as it works now.

### Phase D — tests and audits

Add or extend tests for:

- all promoted animation files exist, are RGBA, and have exact dimensions;
- every enemy sprite definition resolves to a valid animation mapping;
- every mapping returns exactly three or four in-bounds quads;
- `breakbeat_bruiser` resolves through the explicitly approved alias;
- advancing animation changes only visual frame state, not position, HP,
  cooldowns, windup, AI timing, rewards, RNG state, or attacks;
- left-facing draw keeps `flip_x` and right-facing draw does not;
- missing animation data falls back to the existing static sprite;
- reset/reuse through the enemy pool resets animation state cleanly;
- package audit includes promoted runtime atlases and excludes this entire
  candidate directory, prompts, previews, script, manifests, and rejected
  sources.

Run, in order:

1. focused enemy/content/media tests;
2. full LuaJIT suite through the project test target;
3. lint;
4. media audit;
5. package integrity and `.love` inclusion/exclusion check;
6. desktop boot smoke only after the source/package checks pass.

### Phase E — manual acceptance

Verify at 1280x720 and 800x600:

- every enemy and both boss scales in all playable stages;
- three-frame and four-frame loop cadence without visible popping;
- feet/hover anchor stability and no per-frame size jitter;
- left/right flipping, chargers, ranged orbiting, static enemies, knockback,
  attack windups, hit flash, reduced flash, death, and crowd overlap;
- readability at representative 300-enemy / 150-projectile pressure;
- no new frame shimmer, alpha fringe, floor shadow, or magenta/green key damage;
- acceptable CPU/GPU behavior with no per-frame allocations;
- physical-controller play remains unchanged because this feature must not own
  input behavior.

## 7. Approval decisions required

Before implementation, confirm:

1. the six cleaned rosters are visually approved or list specific enemies to
   regenerate;
2. Jazz should keep its richer four-frame loop while the other rosters use
   three frames;
3. `breakbeat_bruiser` should remain a `turntable_sentinel` visual alias or get
   a unique design;
4. the proposed visual-only FPS values are acceptable as the first tuning pass.

After that confirmation, implementation can proceed through loader wiring,
entity animation, tests, package verification, and manual gameplay QA. Commit,
push, release, deployment, and public-site synchronization remain separate
approval/delivery states.
