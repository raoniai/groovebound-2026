# Enemy animation candidate provenance

**Generated:** 2026-08-14

**Status:** Package-excluded source candidates. Nothing in this directory is
loaded, referenced, or shipped by the game.

## Generator and inputs

- Generator path: Codex built-in image generation.
- Source ownership: existing Groove Bound generated enemy atlases.
- Third-party images: none.
- References:
  - `assets/generated/enemy-variants-atlas.png`
  - `assets/generated/campaign/stage2-enemies-atlas.png`
  - `assets/generated/campaign/funk-enemies-atlas.png`
  - `assets/generated/campaign/soul-enemies-atlas.png`
  - `assets/generated/campaign/disco-enemies-atlas.png`
  - `assets/generated/campaign/jazz-enemies-atlas.png`
- Complete prompt record: `PROMPTS.md`.

The built-in generator does not expose a user-selectable model name or a
separate per-call price in this interface.

## Candidate classes

- `*-chroma-source.png`: untouched selected generator output.
- `*-magenta-rejected-source.png`: preserved rejected generation whose key
  conflicted with native violet/magenta subject details.
- `*-transparent.png`: chroma-removed intermediate; not safe for direct use
  where subjects cross nominal cells.
- `*-normalized-transparent.png`: Jazz-only nearest-neighbour normalization of
  the 887x1774 transparent intermediate to an exact 1024x2048 4x8 grid.
- `*-clean.png`: atlas-wide connected-component isolation followed by uniform
  per-enemy scaling, bottom-centred 12px anchoring, and clean-cell rebuilding.
- `frames/<enemy-id>/frame-*.png`: clean 256x256 RGBA candidate frames.
- `frames/<enemy-id>/preview-strip.png`: static review strip.
- `frames/<enemy-id>/preview.gif`: dark-background ping-pong review animation;
  documentation only, never a runtime target.
- `candidate-manifest.json`: generated hashes, mappings, frame counts, alpha
  bounds, and QA metadata.
- `prepare_candidates.py`: reproducible candidate slicing and validation build.

## Transformations

1. Generate one motion sheet per roster while preserving the source identity.
2. Remove flat chroma with the bundled image-generation helper, soft matte,
   despill, and one-pixel edge contraction.
3. Regenerate Orbit and Jazz on green after magenta-key inspection showed a
   conflict with project-native violet accents. Preserve the rejected sources.
4. Normalize Jazz to 256x256 cells using nearest-neighbour resampling.
5. Segment alpha components across each whole atlas, assign every component to
   exactly one authored frame, discard isolated noise under four pixels, and
   rebuild clean cells with a 12px safe gutter.
6. Slice per-enemy frames and generate non-runtime review strips/GIFs.

## Verified candidate facts

- 6 rosters.
- 48 unique enemy visuals.
- 49 content IDs mapped; `breakbeat_bruiser` is an explicit visual alias of
  `turntable_sentinel` in current content.
- 152 candidate frames: 40 enemies x 3 frames plus 8 Jazz enemies x 4 frames.
- Every clean frame is 256x256 RGBA.
- Clean atlas geometry: five 1024x1536 4x6 atlases and one 1024x2048 4x8 Jazz
  atlas.
- Zero opaque-corner failures and zero clean-frame edge crossings.
- Candidate output is excluded by the existing package rule for
  `/source-candidates/`.

Visual feel, loop timing, crowded-combat readability, and the
`breakbeat_bruiser` alias decision remain human approval gates.

