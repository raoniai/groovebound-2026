# Media contracts

## Classification and packaging

| Class | Typical location | Package |
|---|---|---|
| Runtime generated | `assets/generated/` and `assets/generated/campaign/` | Include when referenced |
| Generated source | `*-source.png`, `source-candidates/` | Exclude |
| Legacy first-party | `assets/legacy/` | Include only with provenance |
| Runtime audio | `assets/music/*.ogg`, approved SFX | Include |
| Runtime video | `assets/video/runtime/*.ogv` | Include |
| Source/reference video | `assets/video/*.mp4` | Exclude |
| Documentation art | root `docs/assets/` | Exclude from game package |
| Website copy | `landing-page/assets/` | Exclude from game package |

## Visual checks

Confirm dimensions, expected grid, equal cells, no cross-cell bleed, correct nearest-neighbour behavior, alpha edges, pivot/feet anchor, silhouette readability, palette continuity, and runtime mapping.

## Audio and video checks

Confirm codec, channels, sample rate, duration, intended loop points, gain, routing context, fade behavior, pause/resume, final-frame handling, and storyboard fallback.

## Provenance

Update `assets/generated/PROVENANCE.md` or `assets/legacy/PROVENANCE.md`. Record source, generator or owner, reference inputs, transformation, stable mapping, package status, and unresolved licensing requirements.
