# Groove Bound project map

## Authority

| Area | Canonical source | Notes |
|---|---|---|
| Runtime | `groove-bound/` | Lua/LÖVE 11.5 game |
| Runtime source | `groove-bound/src/` | Core, content, gameplay, rendering, UI, audio |
| Tests | `groove-bound/tests/` | Headless LuaJIT regression suite |
| Runtime assets | `groove-bound/assets/` | Package only approved runtime material |
| Latest handover | `LATEST_VERSION_HANDOVER.md` | Canonical human-readable project state |
| Public site | `landing-page/` | Static public presentation; not runtime authority |
| Design and research | Root dossiers and plans | Reference and decision context, not executable truth |
| CI | `.github/workflows/ci.yml` | Current automated checks |

## Classification

- Canonical: runtime source, tests, approved content, handover decisions.
- Reference-only: research dossiers, migration plan, prompt catalogues, screenshots.
- Legacy: `groove-bound/assets/legacy/`; preserve provenance and replacement path.
- Generated runtime: processed files under `assets/generated/` used by source.
- Generated source: source candidates and `*-source` files; exclude from packages.
- Distribution output: `groove-bound/dist/`; regenerate and do not hand-edit.
- Website copy: `landing-page/assets/`; compare with canonical source before updating.

## Status language

Use only the state proven by evidence: planned, drafted, locally implemented, tests passed, package verified, manual QA verified, committed, pushed, merged, released, deployed, or public-live verified.

## Protected invariants

- Stable content IDs and versioned save envelope.
- Named deterministic RNG streams and seeded outcomes.
- Event cleanup, state-stack integrity, pooling, spatial indexing, and content validation.
- Joe, Lyra Vex, the two-stage campaign, and the music-meets-cosmic-robot identity unless explicitly revised.
- Runtime/source asset separation and provenance records.
- Keyboard, mouse, and gamepad behavior appropriate to the changed surface.
