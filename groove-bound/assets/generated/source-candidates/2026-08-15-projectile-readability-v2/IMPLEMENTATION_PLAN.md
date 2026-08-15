# Projectile readability sprite regeneration — implementation plan

**Status:** integrated into the v0.9.5 runtime candidate; not released

**Runtime baseline protected:** Groove Bound v0.9.4 source commit
`28fa8e5255138e63a159c5dc502f0795f1f34543`, merged into `main` at
`4d8758d24b636407dfb71cdcc34c1af48b3c1ffa`

## Outcome

Replace the visually dense v0.9.4 projectile art with quieter, larger-source
animation sheets rendered at or below native scale. Preserve every stable
weapon ID and current gameplay behavior while changing only visual timing and
presentation.

## Asset contract

- One PNG file for each of the 32 stable weapon/projectile IDs.
- One projectile or effect core per frame. Never bake a fan, volley, radial
  group, orbit group, or multi-target storm into a frame.
- Eight genuinely authored animation frames in a 4-column by 2-row sheet.
- Target source canvas: 2048 x 1024 RGBA; target cell: 512 x 512.
- Transparent background, no checkerboard, no black fill, no labels, no UI.
- The active silhouette should normally occupy 55–80% of its cell without
  touching cell edges. Long beams may use 85% of cell width but remain narrow.
- Use an airy construction: translucent interior, open negative spaces, soft
  falloff, restrained highlights, and sparse particles. Avoid solid discs,
  opaque walls, dense particle clouds, and full-cell flashes.
- Base attacks use one dominant hue plus a small neutral highlight. Evolutions
  may add one secondary hue, but retain simple silhouettes.
- Animation sequence is authored motion, not uniform scaling of one frame.

## Eight-frame vocabulary

| Frame | General purpose | Beam-specific purpose |
|---|---|---|
| 1 | anticipation / faint seed | emitter glint |
| 2 | ignition / directional cue | short ignition ray |
| 3 | early formed state | half-length beam with clear end cap |
| 4 | stable formed state | full authored beam |
| 5 | peak variation | full beam with a restrained travelling pulse |
| 6 | breakup | segmented fracture without widening |
| 7 | recoil / dissolve | retracting beam with fading end cap |
| 8 | transparent remnant | sparse afterglow |

Bombs use seed, two flight states, impact, translucent bloom, open shock ring,
falling fragments, and remnant. Area effects use a faint seed, open arcs, two
different pulse states, a peak ring with large gaps, breakup arcs, dissolve,
and remnant. Storms contain one strike only; orbitals contain one orbiting
object only; waves contain one wave segment only; deployables contain one node
only.

## Runtime integration implemented for v0.9.5

1. All 32 sheets were visually reviewed before runtime promotion.
2. The loader now reads eight 512 x 512 cells in a 4 x 2 grid without changing
   stable IDs.
3. Attack-family transforms render at native scale or smaller and are capped
   at 1.0.
4. Collision and coverage geometry remain independent from visual dimensions.
   Large range must not imply a screen-filling opaque sprite.
5. Counts greater than one reuse the same single-projectile animation with
   deterministic 0–60 ms visual phase offsets. Simulation timing is unchanged.
6. For beams, use the authored full-length states and uniform scaling only.
   Never stretch width and length independently.
7. Retain v0.9.4 cooldowns, damage windows, deterministic RNG, immutable firing
   snapshots, pooling, spatial indexing, and evolution reachability.
8. Tests cover eight-frame loading, stable mappings, native-scale transforms,
   deterministic phase offsets, and source-candidate package exclusion.
9. Media, full-suite, lint, package, boot, and unlocked gameplay readability
   checks remain release gates.

## Acceptance checks for this asset-only pass

- Exactly 32 candidate PNGs, one per stable ID.
- Every file is RGBA with transparent pixels and no runtime path changes.
- Every sheet presents eight separated states with no cross-cell bleed.
- Multi-shot attacks show one projectile/effect core per frame.
- Beam sheets show one crafted beam with ignition, full, fracture, retraction,
  and afterglow states, not a short tile intended for stretching.
- Candidate files remain under `source-candidates/` and are excluded from the
  current package.
- Prompt and provenance records are saved beside the generated files.

## Delivery boundary

Runtime assets and Lua integration are approved for v0.9.5. Public release,
signing, notarization, site deployment, and manual gameplay acceptance remain
separate gates.
