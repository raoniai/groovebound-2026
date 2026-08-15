# Enemy State Animation Implementation Plan

**Date:** 2026-08-15

**Target release:** v0.9.4

**Status:** implemented, committed, pushed, packaged, released as v0.9.4, and
public-live verified on GitHub and the Groove Bound site.

## Corrected outcome

Replace the v0.9.3 shared movement-only contract with individual state strips
for every canonical enemy. Each enemy owns a stable directory keyed by its
content ID. Movement, hit, and death are mandatory; attack exists only where
`src/content/enemies.lua` defines `attack_kind`.

| Coverage | Enemies | Strips | Frames per strip | Total frames |
|---|---:|---:|---:|---:|
| Walk | 49 | 49 | 3 or 4 | 156 |
| Attack | 23 | 23 | 4 | 92 |
| Hit | 49 | 49 | 3 or 4 | 156 |
| Death | 49 | 49 | 4 | 196 |
| **Total** | **49** | **170** | **3-4** | **600** |

`breakbeat_bruiser` now has a unique orange drum-machine brawler identity and
no longer uses the Turntable Sentinel runtime artwork.

## Asset locations

Runtime files, included in `.love`, macOS, and Windows packages:

```text
groove-bound/assets/generated/campaign/enemies/<enemy-id>/
├── walk.png
├── attack.png       # only for the 23 attack-capable enemies
├── hit.png
└── death.png
```

Every runtime file is a horizontal RGBA strip of 256x256 cells. Sources,
individual frames, generator boards, preparation script, and manifest remain
package-excluded:

```text
groove-bound/assets/generated/source-candidates/
└── 2026-08-15-enemy-state-animation/
    ├── <roster>/*-atlas-chroma-source.png
    ├── breakbeat_bruiser/*-chroma-source.png
    ├── frames/<enemy-id>/<state>/frame-*.png
    ├── prepare_state_assets.py
    └── state-manifest.json
```

## Runtime architecture

- `src/assets.lua` preloads each individual strip as a `SpriteSheet` and maps
  it by enemy ID and state.
- `src/render/enemy_animation.lua` owns frame counts and visual-only cadence.
- `src/game/entities/enemy.lua` selects states with priority `hit > attack >
  walk`. Attack frames map windup, release, and recovery to the existing attack
  timing; hit frames use an independent 0.22-second presentation clock.
- `src/game/systems/vfx_system.lua` owns death snapshots after the live enemy
  has been removed from collision and pooling.
- `src/game/systems/combat_system.lua` emits the death snapshot while rewards,
  score, drops, boss gates, and kill events retain their original timing.

## Protected invariants

- No change to enemy stats, attacks, cooldowns, projectiles, wave composition,
  collision, rewards, save data, or named RNG streams.
- Animation never consumes gameplay RNG.
- Death presentation never keeps a killed entity alive or collidable.
- Left-facing horizontal flip and static-sprite fallback remain available.
- Source candidates stay excluded from distribution packages.

## Verification gates

1. Confirm 49 directories, 170 runtime strips, 600 frames, and 23 attackers.
2. Confirm every strip is RGBA, each cell is 256x256, corners are transparent,
   no frame touches its cell edge, and chroma spill is visually acceptable.
3. Inspect walk, attack, hit, and death contact sheets for all 49 identities.
4. Run the full LuaJIT suite and lint.
5. Run media audit and package inclusion/exclusion checks.
6. Launch LÖVE and inspect crowded combat, ranged windups, repeated hits, every
   boss scale, deaths, reduced-flash behavior, and left/right facing.
7. Bump all source, landing, macOS, Windows, and GitHub release surfaces to
   v0.9.4 only after the preceding gates pass.
8. Build `.love`, macOS DMG, and Windows ZIP from one clean commit; compare
   shared payload manifests and boot all three artifacts.
9. Commit, push, publish GitHub release, update the website, then verify public
   version labels and stable Mac/Windows download routes.

## Rollback

The v0.9.3 movement atlases remain in the repository as a renderer fallback
during validation. Reverting the v0.9.4 implementation commit restores the
released v0.9.3 behavior without modifying saves or content IDs.
