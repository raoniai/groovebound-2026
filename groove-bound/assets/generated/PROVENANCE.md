# Generated Visual Asset Register

**Created:** 26 July 2026  
**Generator:** OpenAI image generation available in Codex  
**Rights source:** Original generated artwork; no third-party source image was
used as an input.

## Processing contract

All six new source images were generated from text prompts with no reference
images and a flat chroma-key background. The source files are retained for
editable provenance and excluded from the packaged `.love`. Production files
were made with the bundled `remove_chroma_key.py` helper and resized to their
runtime dimensions with nearest-neighbour filtering.

## Repository banner

- `../../../docs/assets/groove-bound-banner.png` — 2007×784 RGB banner used at
  the top of the repository README. It is documentation artwork and is not
  included in the packaged `.love`.
- **Generator:** OpenAI image generation available in Codex.
- **Reference inputs:** the project-owned generated source sheets for the
  player, enemy variants, evolved weapons, and environment props listed below.
  No third-party image was used.
- **Prompt specification:** extra-wide cinematic 16-bit pixel-art repository
  banner set on a dark neon concert floor; the teal-jacketed hero faces the
  music-machine horde and Static Baron among stage lights, speaker stacks,
  evolved weapons, projectiles, XP gems, and rhythmic shockwaves. The image
  carries exactly one centered gold pixel-display title: `GROOVE BOUND`.
- **Production constraints:** preserve the hero palette and identity, retain
  the supplied enemy and music-weapon language, keep crisp pixel clusters and
  safe wide framing, and avoid added copy, watermarks, UI panels, unrelated
  instruments, or third-party marks.

## First base-weapon atlas

- `weapon-icons-atlas-source.png` — untouched 1774×887 generator output with a
  chroma-key magenta background. It is retained as editable provenance and
  excluded from the packaged `.love`.
- `weapon-icons-atlas.png` — runtime 1024×512 RGBA atlas. Chroma key was
  removed with the bundled `remove_chroma_key.py` helper, then the result was
  resized with nearest-neighbour filtering.

## Final production prompt

> Create one strict 4-column by 2-row sprite atlas containing exactly eight
> separate square retro pixel-art weapon icons for a music-themed survival
> roguelike. Row 1 left to right: brass kazoo pistol, bass speaker emitting a
> shockwave, spinning golden cymbal blade, feedback microphone with electric
> loop. Row 2 left to right: marching drum with radial sticks, red trumpet
> firing a cone, purple vinyl record with scratch sparks, cyan synthesizer
> projecting a wave. Each object must be centered within its own equal cell,
> fully contained with generous transparent-safe padding, consistent
> three-quarter view, chunky 16-bit pixel clusters, bold dark outline, bright
> neon highlights, no text, no labels, no numbers, no frames, no UI panels, no
> overlap, no shadows crossing cells. Use a single flat chroma-key magenta
> background with no texture, gradients, glow, or magenta inside the objects.
> Canvas aspect ratio exactly 2:1.

## Stable mapping

| Cell | Stable weapon ID |
|---|---|
| Row 1, column 1 | `kazoo_pistol` |
| Row 1, column 2 | `bass_drop` |
| Row 1, column 3 | `cymbal_slicer` |
| Row 1, column 4 | `feedback_loop` |
| Row 2, column 1 | `drum_circle` |
| Row 2, column 2 | `trumpet_burst` |
| Row 2, column 3 | `vinyl_scratch` |
| Row 2, column 4 | `synth_wave` |

## Second base-weapon atlas

**Files:** `weapon-icons-atlas-2-source.png`,
`weapon-icons-atlas-2.png` (runtime 1024×512 RGBA)

**Prompt specification:** strict 4×2 retro pixel-art icon atlas on flat
chroma-key magenta; triangle tracer, cello lance, paired maracas, tuning fork;
keytar chord, bell tower, cassette repeater, laser harp. Each item is centered
and fully isolated in an equal cell, with chunky 16-bit clusters, dark outlines,
neon highlights, no text, frames, overlap, or cross-cell shadows.

| Cell | Stable weapon ID |
|---|---|
| Row 1, column 1 | `triangle_tracer` |
| Row 1, column 2 | `cello_lance` |
| Row 1, column 3 | `maraca_orbit` |
| Row 1, column 4 | `tuning_fork` |
| Row 2, column 1 | `keytar_chord` |
| Row 2, column 2 | `bell_tower` |
| Row 2, column 3 | `tape_repeater` |
| Row 2, column 4 | `laser_harp` |

## Support atlas

**Files:** `support-icons-atlas-source.png`,
`support-icons-atlas.png` (runtime 1024×512 RGBA)

**Prompt specification:** strict 4×2 retro pixel-art inventory atlas on flat
chroma-key magenta; winged sneaker, encore ticket, breath-control mask, power
amplifier; pickup magnet, overdrive pedal, echo chamber, safety vest. Consistent
three-quarter collectible icons, bold outlines, no text or cross-cell overlap.

| Cell | Stable support ID |
|---|---|
| Row 1, column 1 | `quickstep` |
| Row 1, column 2 | `encore` |
| Row 1, column 3 | `breath_control` |
| Row 1, column 4 | `power_amplifier` |
| Row 2, column 1 | `pickup_magnet` |
| Row 2, column 2 | `overdrive_pedal` |
| Row 2, column 3 | `echo_chamber` |
| Row 2, column 4 | `safety_vest` |

## Fused-weapon atlas

**Files:** `evolved-weapon-icons-atlas-source.png`,
`evolved-weapon-icons-atlas.png` (runtime 1024×512 RGBA)

**Prompt specification:** strict 4×2 legendary retro pixel-art weapon atlas on
flat chroma-key magenta. Each evolved weapon visibly combines the silhouette
and material cues of its base weapon and paired support, with brighter,
shinier, higher-tier color treatment: Kazoo + breath apparatus, Bass + power
amplifier, Cymbal + winged sneaker, Feedback mic + overdrive pedal; Drum +
encore ticket, Trumpet + safety vest, Vinyl + magnet, Synth + echo chamber.
No text, labels, frames, overlap, or shadows crossing cells.

| Cell | Stable evolved weapon ID |
|---|---|
| Row 1, column 1 | `brass_barrage` |
| Row 1, column 2 | `subwoofer_supernova` |
| Row 1, column 3 | `orbital_ovation` |
| Row 1, column 4 | `improvised_solo` |
| Row 2, column 1 | `thunderhead_ensemble` |
| Row 2, column 2 | `golden_fortissimo` |
| Row 2, column 3 | `gravity_groove` |
| Row 2, column 4 | `neon_crescendo` |

## Player directional sheet

**Files:** `player-v2-sheet-source.png`,
`player-v2-sheet.png` (runtime 1024×1024 RGBA)

**Prompt specification:** strict 4×4 sprite sheet of the same playable hero on
flat chroma-key magenta. Rows are down, up, left, right; columns are four walk
frames. The hero has warm brown skin, dark hair, teal bomber jacket, dark
trousers, and red shoes. Constant scale, pose continuity, fixed cell placement,
no weapon, text, ground shadow, or cross-cell overlap.

The runtime reads 256×256 cells and anchors the character at the feet.

## Enemy variant atlas

**Files:** `enemy-variants-atlas-source.png`,
`enemy-variants-atlas.png` (runtime 1024×512 RGBA)

**Prompt specification:** strict 4×2 retro pixel-art enemy atlas on flat
chroma-key magenta; Monotone, Tempo Leech, Metronome Guardian, Static Baron;
Syncopation Skitter, Feedback Phantom, Bass Brute, Noise Turret. Every enemy
has a distinct silhouette and threat profile, with consistent dark outlines,
isolated 256×256 cells, and no text or cross-cell overlap.

| Cell | Stable enemy ID |
|---|---|
| Row 1, column 1 | `monotone` |
| Row 1, column 2 | `tempo_leech` |
| Row 1, column 3 | `metronome_guardian` |
| Row 1, column 4 | `static_baron` |
| Row 2, column 1 | `syncopation_skitter` |
| Row 2, column 2 | `feedback_phantom` |
| Row 2, column 3 | `bass_brute` |
| Row 2, column 4 | `noise_turret` |

## Environment atlas

**Files:** `environment-atlas-source.png`,
`environment-atlas.png` (runtime 1024×512 RGBA)

**Prompt specification:** strict 4×2 retro pixel-art stage-prop atlas on flat
chroma-key magenta; speaker tower, road case, amplifier, drum riser; waveform
sign, coiled cables, light truss, wedge monitor. Each top-down/isometric prop is
isolated, readable against a dark concert floor, and contains no text or
cross-cell overlap.

The first row supplies solid collision obstacles. The second row supplies
non-blocking background decoration.
