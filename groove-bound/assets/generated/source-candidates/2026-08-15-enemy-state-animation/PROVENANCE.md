# Enemy state animation provenance

**Generated:** 2026-08-15

**Status:** Source boards, extracted frame records, and QA reviews. Runtime
strips are copied to `assets/generated/campaign/enemies/`; source boards and
reviews remain package-excluded under `/source-candidates/`.

## Generator and references

- Generator: Codex built-in image generation.
- Source ownership: existing first-party Groove Bound enemy artwork only.
- Third-party images: none.
- The built-in generator does not expose a selectable model name or separate
  per-call price in this interface.
- References: the six canonical campaign enemy atlases plus the previous
  generated walk frames under `../2026-08-14-enemy-animation/`.
- Complete generation brief: `PROMPTS.md`.

## Asset classes

- `<roster>/*-chroma-source.png`: selected untouched generator source boards.
- `frames/<enemy-id>/<state>/frame-*.png`: individual normalized 256x256 RGBA
  authoring records.
- `review/<roster>-all-states.png`: package-excluded visual QA sheets.
- `state-manifest.json`: frame mappings, dimensions, hashes, and runtime paths.
- `prepare_state_assets.py`: reproducible chroma removal, segmentation,
  normalization, strip build, manifest build, and review-sheet build.
- `assets/generated/campaign/enemies/<enemy-id>/<state>.png`: shipped horizontal
  runtime strips with 256x256 cells.

## Transformations and verification

1. Remove green or magenta chroma using a soft alpha threshold and edge despill.
2. Segment authored subjects across each board. Exact Soul and Disco hit grids
   use deterministic cell crops with only small top-boundary spill components
   removed; all other grids use component-aware isolation.
3. Normalize each state as a group to preserve within-sequence scale, bottom
   centre it in 256x256 transparent cells, and concatenate the runtime strip.
4. Generate one manifest and six roster review sheets from the resulting files.

Verified inventory: 49 unique enemy identities, 170 state strips, and 600
individual frames: 156 walk, 92 attack, 156 hit, and 196 death. Every shipped
strip is RGBA and uses 256x256 frame cells. Attack strips exist only for the 23
canonical projectile enemies. Breakbeat Bruiser is a new distinct visual rather
than the former Turntable Sentinel alias.
