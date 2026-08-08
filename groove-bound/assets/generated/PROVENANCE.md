# Generated Visual Asset Register

**Created:** 26 July 2026  
**Generator:** OpenAI image generation available in Codex  
**Rights source:** Original generated artwork; no third-party source image was
used as an input.

## Processing contract

Initial source images were generated from text prompts without third-party
reference images and, where transparency was required, a flat chroma-key
background. The replacement 2×1 character-selection portrait atlas used only
the project-owned earlier Joe/Lyra portrait candidate as a consistency
reference. Source files are retained for editable provenance and excluded from
the packaged `.love`. Keyed production files were made with the bundled
`remove_chroma_key.py` helper and nearest-neighbour processing.

The second-stage campaign additions follow the same contract. Their normalized
final prompt set is recorded in
[`../../docs/STAGE2_VISUAL_PROMPTS.md`](../../docs/STAGE2_VISUAL_PROMPTS.md).

## Repository banners

- `../../../docs/assets/groove-bound-campaign-banner.png` — 2006×784 RGB
  two-character, two-stage campaign banner currently used at the top of the
  repository README.
- `../../../docs/assets/groove-bound-banner.png` — retained 2007×784 RGB
  Stage 1 banner superseded by the campaign version.
- `source-candidates/readme-campaign-banner-source.png` — editable copy of the
  current campaign banner source. Documentation banners and source candidates
  are excluded from the packaged `.love`.
- **Generator:** OpenAI image generation available in Codex.
- **Reference inputs:** the project-owned earlier banner, Joe/Lyra portrait
  atlas, and Orbit Line enemy atlas. No third-party image was used.
- **Prompt specification:** transform the Stage 1 banner into an extra-wide
  cinematic campaign panorama. Joe defends neon Backbeat Streets on the left;
  Lyra Vex defends the cyan/violet Orbit Line on the right; the city and cosmic
  rail settings transition seamlessly behind the exact centered gold title
  `GROOVE BOUND`. Static Baron and Grand Orchestrator silhouettes frame their
  respective stages as secondary threats.
- **Production constraints:** exactly two heroes with identities, outfits, and
  weapons preserved from the supplied art; exact two-word title; crisp
  detailed 16-bit pixel clusters; safe responsive framing; no other copy, UI,
  watermarks, extra protagonists, unrelated instruments, or third-party marks.

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

## Two-stage campaign additions

Generated source candidates are retained in `source-candidates/` and excluded
from release packages. Runtime assets are:

| Runtime file | Grid / role |
|---|---|
| `campaign/joe-action-sheet.png` | 8×4 directional idle, walk, run, hurt/action |
| `campaign/lyra-action-sheet.png` | 8×4 directional idle, walk, run, hurt/action |
| `campaign/joe-talking-strip.png` | 2×1 closed/open-mouth cutscene portrait |
| `campaign/lyra-talking-strip.png` | 2×1 closed/open-mouth cutscene portrait |
| `campaign/character-portraits-atlas.png` | 2×1 landscape character-selection portraits |
| `campaign/stage2-enemies-atlas.png` | 4×2 Orbit Line roster |
| `campaign/stage2-environment-atlas.png` | 4×2 collision and decorative props |
| `campaign/backbeat-environment-expansion-atlas.png` | 4×2 Backbeat trees, barriers, street equipment, and decoration |
| `campaign/orbit-environment-expansion-atlas.png` | 4×2 Orbit Line crystal trees, rails, beacons, debris, and gates |
| `campaign/projectile-atlas.png` | 6×4 unique base/evolved weapon bullets |
| `campaign/combat-fx-atlas.png` | 4×4 impacts, explosions, deaths, damage |
| `campaign/app-icon.png` | 512×512 RGBA application/window icon |
| `campaign/groove-bound-logo.png` | menu logo extracted from the repository banner |
| `cutscenes/prologue-atlas.png` | 2×2 prologue storyboard |
| `cutscenes/campaign-atlas.png` | 2×2 transition and ending storyboard |

All character and keyed gameplay sheets use a transparent RGBA production
output. Cinematic atlases and the extracted menu logo intentionally retain
their illustrated backgrounds.

## Application icon

**Files:** `source-candidates/app-icon-source.png` (1254×1254 RGB generator
output), `campaign/app-icon.png` (512×512 RGBA runtime icon)

The icon uses a single gold vinyl-record and speaker artifact crossed by a cyan
waveform and wrapped in magenta/cyan cosmic energy. The circular silhouette is
deliberately text-free and remains recognizable at 64×64. The project-owned
menu logo and Stage 2 enemy atlas were used only as palette and visual-language
references. Deep-indigo outer pixels were removed with the bundled chroma-key
helper before the runtime icon was downsampled.

The complete normalized prompt is recorded in
[`../../docs/STAGE2_VISUAL_PROMPTS.md`](../../docs/STAGE2_VISUAL_PROMPTS.md).

## Five-times-area environment expansions

**Source candidates:**
`source-candidates/environment/backbeat-expansion-chroma.png`,
`source-candidates/environment/orbit-expansion-chroma.png`

**Runtime files:**
`campaign/backbeat-environment-expansion-atlas.png` (1536×1024 RGBA),
`campaign/orbit-environment-expansion-atlas.png` (1660×948 RGBA)

Generated with OpenAI image generation on 2026-08-08 using the existing
environment atlases as style references. Both prompts requested a strict 4×2
pixel-art prop grid on flat chroma-key magenta, consistent top-down/isometric
perspective, no text, no characters, no shadows crossing cell boundaries, and
clear silhouettes at gameplay scale.

The Backbeat sheet contains neon speaker trees, graffiti speaker barricades,
road cases, a synth streetlamp, a smaller tree, a poster column without text,
cable cones, and a street vent. The Orbit sheet contains crystal speaker trees,
energy rails, a satellite speaker, a signal pillar, a smaller crystal tree, a
beacon, cable/debris clusters, and a cosmic gate.

The bundled chroma-key removal helper converted the magenta source backgrounds
to alpha. The Orbit runtime sheet was then resampled to dimensions divisible by
the authored 4×2 grid. Source candidates remain excluded from release packages.

## Full-screen title-menu layers

**Runtime files:**
`campaign/title-background-v2.png` (1672×941 RGB),
`campaign/groove-bound-title-v2.png` (1683×935 RGBA)

Generated with OpenAI image generation on 2026-08-08 using the previous
repository title banner as the visual-identity reference. The background pass
removed all title typography and rebuilt the neon supernatural music venue as
a full-bleed 16:9 scene with a calm central menu zone. The title pass preserved
the exact two-line gold pixel-arcade treatment on a flat green chroma key.

The bundled chroma-key helper removed that green field with a soft matte and
despill pass. The resulting title asset was visually inspected with its alpha
channel intact before runtime integration. Neither runtime asset contains a
watermark or additional copy.

## World-overview title background and collectible atlases

**Generated:** 2026-08-09 with OpenAI image generation in Codex

**Runtime files:**

| File | Mode | Role |
|---|---|---|
| `campaign/title-background-v3.png` (1672×941 RGB) | Edit with project-owned references | Full-screen two-world panorama with Joe and Lyra outside a clean central UI lane |
| `campaign/pickup-consumables-atlas.png` (1774×887 RGBA) | New 4×2 keyed atlas | Heal, magnet, damage, defense and speed pickups in cells 1–5 |
| `campaign/xp-gems-atlas.png` (1254×1254 RGBA) | New 2×2 keyed atlas | Common, uncommon, rare and legendary XP reward tiers |

The title edit used `title-background-v2.png` as its base and the project-owned
Joe/Lyra character portrait atlas as an identity reference. Its prompt required
Backbeat City on the left, Resonance Orbit on the right, large inward-facing
heroes at the outer thirds, peripheral enemies and landmarks, no typography,
and a dark low-contrast central 42% safe area for the separate logo and menu.

The consumable prompt required a strict 4×2 arcade pixel-art grid on solid
green chroma key: heart capsule, XP magnet, amplifier lightning badge,
soundwave shield and winged sneaker, followed by three empty cells. The XP
prompt required a strict 2×2 family of increasingly valuable crystal rewards:
mint shard, cyan diamond, gold cluster and magenta cosmic cluster. The final XP
source used a red chroma field to preserve the green common gem.

Both gameplay atlases were converted to transparent RGBA locally. Alpha and
cell layout were inspected after key removal; the XP atlas received a small
key-spill cleanup on its navy outlines. The original generator outputs remain
in Codex's generated-image store rather than the release package. No third-party
images, typography, watermarks or external copyrighted assets were introduced.
