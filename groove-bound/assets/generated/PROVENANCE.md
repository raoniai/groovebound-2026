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

## World Tour V1 interface and mechanic atlases

Created 10 August 2026 with OpenAI image generation from text-only prompts;
no third-party image was supplied. The untouched RGB generator outputs remain
in `source-candidates/`. Runtime atlases were normalized with nearest-neighbour
scaling and keyed from chroma green to RGBA with FFmpeg.

| Runtime file | Grid / role |
|---|---|
| `campaign/chest-luck-reveal-atlas.png` | 5×2 vinyl luck-spinner and reward-stage frames |
| `campaign/funk-pocket-pad-atlas.png` | 5×1 Funk pocket timing-pad animation |
| `campaign/world-tour-ui-atlas.png` | 5×2 campaign/world emblems and rank medallions |
| `campaign/menu-button-icons-atlas.png` | 5×2 main-menu actions, divider and reset-warning symbols |
| `campaign/completion-ui-atlas.png` | 4×2 campaign/Funk completion crests and pictorial result badges |

The chest atlas depicts a single increasingly energized vinyl selector in its
top row and a transforming arcade reward-card stage in its bottom row. The
Funk strip moves from dormant speaker pad through cyan/magenta warning states
to a gold downbeat lock. The World Tour atlas contains campaign, Funk, Soul,
locked-world and portal emblems plus five empty rank medallions. All grids use
isolated, centered pixel-art silhouettes with no generated typography.

The menu atlas gives Continue, New Game, World Tour Catalog, Settings, Quit and
Reset Campaign their own musical-machine icons. Its second row also supplies the
authored equalizer divider and both stages of the protected campaign-reset flow.
The untouched generator output is retained at
`source-candidates/menu-button-icons-atlas-source.png`.

The chest runtime atlas was regenerated from
`source-candidates/chest-luck-reveal-atlas-v2-source.png` after the first
fullscreen playtest exposed cross-cell edge bleed and a visually overloaded
reward-card row. The replacement retains the vinyl luck chest, adds safe cell
padding, and uses five restrained speaker-texture card backplates. The runtime
consumer also samples each cell with a two-pixel UV inset.

### Atlas isolation repair

Repaired 11 August 2026 with
`scripts/extract_world_tour_runtime_sprites.py`. The repair covers the 147
transparent World Tour cells used by the game across enemy, environment,
chest, mechanic, interface, perk, menu and expansion-evolution atlases. It
segments connected alpha components across each full source sheet, assigns
every component to one authored cell, removes isolated pixel noise, and then
rebuilds the same grid with uniformly scaled, centred sprites and at least an
eight-pixel transparent gutter. This prevents neighboring subjects and edge
fragments from appearing in adjacent frames without changing runtime loaders,
row/column mappings, content IDs, mechanics or timing.

The musical chest sheet was additionally normalised from a malformed square
1256×1256 canvas, whose 4×2 mapping produced 314×628 cells, to a 1600×800
4×2 atlas with eight square 400×400 cells. This corrects the chest animation's
proportions while retaining its existing frame order. Tightly cropped audit
derivatives and their hashes live under
`campaign/world-tour-sprites/`; they are build intermediates and are excluded
from the packaged game. The original generated source candidates remain
unchanged under `source-candidates/`.

`source-candidates/completion-ui-atlas-source.png` supplies the asset-driven
Backbeat Streets, Orbit Line, campaign victory and Funk mastery crests plus
encore chest, resonance, enemy and boss badges. Both new sources were generated
with OpenAI image generation and converted from flat chroma green to RGBA using
the project image-generation helper with a soft matte, despill and one-pixel
edge contraction.

## Funk World playable visual package

Created 10 August 2026 with OpenAI image generation from text-only prompts;
no third-party image or trademarked character was supplied.

| Runtime file | Grid / role |
|---|---|
| `campaign/funk-enemies-atlas.png` (1600x800 RGBA) | 4x2 Funk-specific enemy and boss roster |
| `campaign/funk-environment-atlas.png` (1600x800 RGBA) | 4x2 Funk obstacles and layered scenery |
| `campaign/funk-floor-atlas.png` (1024x1024 RGB) | 2x2 low-contrast Funk floor surfaces |

The enemy atlas maps Pocket Gremlin, Slapback Hound, Groove Guard, Talkbox
Oracle, Boogie Tank, Funkadelic Wasp, Mothership of Funk and Pocket Phantom in
stable row-major order. The environment atlas maps a boombox barricade, record
kiosk, amp wall, turntable console, disco palm, talkbox streetlight, vinyl
stack and hologram dancer. The floor atlas provides four orthographic dark
street and club surfaces designed to preserve combat readability.

Untouched generator outputs are retained under `source-candidates/`. Runtime
enemy and environment atlases were normalized to exact 400x400 cells and
converted from sampled chroma green to alpha with the bundled soft-matte,
despill and one-pixel contraction helper. The floor atlas was normalized to
four opaque 512x512 cells. Runtime dimensions, color types and cell mappings
are regression-tested.

## Application icon

**Current files:** `source-candidates/app-icon-character-source.png`
(1254×1254 RGB generator output), `campaign/app-icon.png` (512×512 RGBA
runtime icon), `source-candidates/app-icon-gb-source.png` (1254×1254 RGB
generator output), and `docs/assets/app-icons/app-icon-gb.png` (512×512 RGBA
documentation-only alternate)

**Superseded source retained:** `source-candidates/app-icon-source.png`

The current runtime icon blends Joe and Lyra Vex into one circular adventure
emblem. Joe retains his teal-and-gold street-funk identity and sonic blaster;
Lyra retains her purple, magenta, and cyan live-wire identity and keytar. A
rising cyan waveform divides and reconnects the two heroes inside the original
gold vinyl/cosmic-talisman language. The characters and outer silhouette remain
recognizable at 64×64 and distinct at 32×32.

The alternate mark uses an interlocking gold `GB` monogram. Its `G` contains a
vinyl groove and stylus, while its `B` contains waveform and speaker forms;
cyan and magenta character silhouettes keep Joe and Lyra present without
competing with the letters. The alternate is documentation art and is excluded
from the runtime package.

Both images were created with the built-in OpenAI image-generation workflow
using project-owned Joe and Lyra portraits plus the superseded app icon as
identity, palette, and visual-language references. The generated sources were
preserved separately and downsampled with Lanczos filtering into RGBA outputs.

The complete normalized prompts are recorded in
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

## Musical chest and stage-floor atlases

**Generated:** 2026-08-09 with OpenAI image generation in Codex built-in mode

| Runtime file | Grid / role |
|---|---|
| `campaign/musical-chest-atlas.png` (1256×1256 RGBA) | 4×2 seamless eight-frame rare chest loop |
| `campaign/backbeat-floor-atlas.png` (1254×1254 RGB) | 2×2 subtle urban grime floor variations |
| `campaign/orbit-floor-atlas.png` (1254×1254 RGB) | 2×2 cosmic dust and micro-crystal floor variations |

The chest prompt specified one consistent purple-and-gold musical road-case
and amplifier silhouette across eight frames: closed idle, anticipation,
equalizer glow, opening, music-note light, peak flash, settle, and a visual
bridge back to the first frame. It was generated on a flat green chroma key,
converted with the bundled soft-matte/despill helper, resized to exact 4×2 cell
dimensions, and visually inspected with alpha intact.

The Backbeat prompt specified low-contrast charcoal asphalt and worn concrete
with restrained violet grime, fine cracks and scuffs. The Orbit prompt specified
near-black navy mineral dust with sparse cyan and amethyst micro-crystals. Both
requested four orthographic, text-free, grid-free, evenly lit variations with
no large props or dramatic effects so combat remains readable. The opaque
atlases and their cell dimensions were validated before runtime integration.

## Interface chrome and defeat presentation

**Generated:** 2026-08-10 with OpenAI image generation in Codex built-in mode

| Runtime file | Role |
|---|---|
| `campaign/aim-reticle.png` (512×512 RGBA) | Transparent mouse/gamepad aim marker |
| `campaign/hud-slot-frame.png` (512×512 RGBA) | Transparent inventory frame decomposed into fixed corners and repeatable edge strips at runtime |
| `campaign/game-over-v2.png` (1672×941 RGB) | Full-screen defeat illustration |
| `campaign/joe-logo.png` | First-party Joe logo copied from the separate landing-page asset set |
| `campaign/lyra-vex-logo.png` | First-party Lyra Vex logo copied from the separate landing-page asset set |

Source candidates preserve the original generated outputs and remain excluded
from packages. The first 6×4 UI atlas is retained as
`source-candidates/ui-chrome-atlas-opaque-reference.png`; screenshot review
showed its cell backgrounds and non-uniform scaling were unsuitable for runtime.
The game no longer loads that atlas.

The UI prompt requested 24 isolated, text-free pixel-art sprites: weapon and
support slots; health and XP bars; number and timer holders; health, guard,
warning, critical, level, chest, damage, cooldown, projectile count, speed,
reroll, skip, score, combo, stage, clock, aim, and boss symbols. The palette is
the established dark navy, cyan, magenta, and restrained gold interface family.

The refinement prompts used that atlas only as a style reference. One prompt
requested a square cyan/violet pixel-art reticle with four cardinal ticks and a
central dot. The other requested a thin gold square inventory outline with
restrained cyan/violet corner accents and an empty interior. Both were generated
on uniform green chroma, converted to alpha with the bundled soft-matte/despill
helper, center-cropped, resized to 512×512, and visually inspected. Their chroma
and transparent high-resolution sources are stored under `source-candidates/`.
Runtime draws the slot frame as four fixed corners plus tiled top, bottom, left,
and right strips, so rectangular blocks extend without stretching the art.
General HUD semantic glyphs remain code-drawn; upgrade-card attributes use the
dedicated generated atlas documented below. HUD panel shades remain separate
translucent layout elements.

The game-over prompt used only project-owned Joe/Lyra portraits, the current
title background, and the obsolete first-party game-over panel as references.
It requested a 16:9 neon Backbeat defeat scene with both heroes visibly tired
but defiant, clean upper title space, lower statistics space, no embedded text,
no logos, no gore, and no watermark.

## Encore Gate stage-clear chest

**Generated:** 2026-08-10 with OpenAI image generation in Codex built-in mode

| Runtime file | Role |
|---|---|
| `campaign/stage-clear-chest.png` (1024x1024 RGBA) | Unique boss-clear objective chest |

The project-owned musical chest atlas was used only as a visual-style
reference. The prompt requested one new, closed, three-quarter-view chest with
a crown silhouette, vinyl crest, cyan speaker-reactor, deep-purple cabinet,
magenta waveform lighting and gold hardware. It explicitly excluded text, UI,
characters, loose particles and a scene background, and required legibility at
72-108 gameplay pixels. The flat green source is preserved as
`source-candidates/stage-clear-chest-source.png`; the runtime image was
converted locally with the bundled soft-matte and despill helper. Alpha bounds,
dimensions and transparent RGBA colour type were inspected before integration.
The runtime copy was then center-cropped around its alpha bounds and resized
with nearest-neighbour sampling so its crown and speaker remain focal at play
scale; the uncropped 1254x1254 source remains preserved.

## Complete evolution icon set, second atlas

**Generated:** 2026-08-11 with OpenAI image generation in Codex built-in mode

| Runtime file | Grid / role |
|---|---|
| `evolved-weapon-icons-atlas-2.png` (1600x800 RGBA) | 4x2 atlas for the eight expansion-weapon evolutions |

The source prompt required exactly eight isolated, text-free arcade pixel-art
icons with at least twelve-percent safe padding per cell: Prismatic Triangle,
Velvet Impaler, Carnival Superorbit, Resonance Rupture, Stadium Keytar,
Cathedral Overdrive, Infinite Mixtape and Aurora Harp. The untouched 1717x916
generator output is retained at
`source-candidates/evolved-weapon-icons-atlas-2-source.png`.

The runtime atlas was center-cropped to the exact 4x2 aspect, resized with
nearest-neighbour sampling, keyed from chroma green to RGBA and inspected for
cell-boundary isolation. Runtime projectile art deliberately aliases the
matching base-weapon projectile cell; only the inventory/evolution identity
uses the new atlas, avoiding a hidden expansion of the 6x4 projectile contract.

## Level-up and reward interface sprites

**Generated:** 2026-08-11 with OpenAI image generation in Codex built-in mode

| Runtime file | Role |
|---|---|
| `campaign/ui/new-tag.png` (512x214 RGBA) | Dedicated magenta NEW corner badge for progression cards |
| `campaign/ui/reward-backplate.png` (241x214 RGBA) | Tight reusable reward/card backplate promoted from the project chest reveal atlas extraction |

The NEW-tag prompt requested one isolated arcade pixel-art corner badge with
the exact word NEW, hot-magenta enamel, cyan edge light, restrained gold
hardware, no extra text, no shadow and a uniform green chroma background. The
untouched generated source is retained at
`source-candidates/ui-new-tag-source.png`; the runtime image was converted with
the bundled soft-matte/despill helper and resized with nearest-neighbour
sampling. The reward backplate is first-party project art extracted from
`campaign/chest-luck-reveal-atlas.png`; this promoted tight crop prevents atlas
padding from shrinking information inside wide and tall runtime cards.

## Scalable upgrade-card construction kit

**Generated:** 2026-08-11 with OpenAI image generation in Codex built-in mode

| Runtime file | Role |
|---|---|
| `campaign/ui/upgrade-card-frame-v2/top-left.png` | Fixed upper-left corner |
| `campaign/ui/upgrade-card-frame-v2/top.png` | Horizontally extendable top middle |
| `campaign/ui/upgrade-card-frame-v2/top-right.png` | Fixed upper-right corner |
| `campaign/ui/upgrade-card-frame-v2/left.png` | Vertically extendable left middle |
| `campaign/ui/upgrade-card-frame-v2/center.png` | Scalable dark honeycomb interior |
| `campaign/ui/upgrade-card-frame-v2/right.png` | Vertically extendable right middle |
| `campaign/ui/upgrade-card-frame-v2/bottom-left.png` | Fixed lower-left corner |
| `campaign/ui/upgrade-card-frame-v2/bottom.png` | Horizontally extendable bottom middle |
| `campaign/ui/upgrade-card-frame-v2/bottom-right.png` | Fixed lower-right corner |
| `campaign/ui/upgrade-attribute-icons-atlas.png` (1600x800 RGBA) | 4x2 semantic stat-icon atlas |

The card prompt requested one front-on portrait equipment-rack frame with
decoration concentrated in the corners, quiet repeatable middle edges, a dark
navy honeycomb interior, restrained cyan/magenta/violet/gold hardware, no text,
no icons, no perspective and a uniform green chroma surround. The untouched
source is retained at
`source-candidates/upgrade-card-frame-v2-source.png`. The keyed result was
trimmed and divided into nine independent runtime PNGs by
`scripts/build_upgrade_card_frame.py`; runtime scales only the relevant middle
or centre piece while keeping each corner independent.

The attribute-atlas prompt requested exactly eight isolated icons in a strict
4x2 grid: damage, fire rate, projectile count, projectile speed, health, guard,
coins and total rank. It prohibited text, shared particles and cell crossings.
The untouched source is retained at
`source-candidates/upgrade-attribute-icons-atlas-source.png`; the runtime atlas
was keyed with the bundled soft-matte/despill helper, normalised to 1600x800
RGBA and visually inspected before integration.

## Menu navigation sprite kit

**Generated:** 2026-08-11 with OpenAI image generation in Codex built-in mode

| Runtime file | Role |
|---|---|
| `campaign/ui/menu-category-icons-atlas-v2.png` (1600x1200 RGBA) | Strict 4x3 atlas for Admin, Settings and control-category identities |
| `campaign/ui/menu-focus-frame-v2/top-left.png` through `bottom-right.png` | Nine independent focus-frame corners, repeatable edges and transparent centre |

The category-atlas prompt requested exactly twelve isolated, text-free,
front-on pixel-art symbols for overview, simulation, route, player, combat,
projectile, enemy, rewards, groove, audio, display and controller settings. It
required a strict 4x3 layout, consistent scale, generous cell gutters and no
cross-cell particles. The focus-frame prompt requested one high-contrast wide
cyan/gold/magenta equipment rail with fixed mechanical corners, quiet middle
edges, no text or icons and an empty chroma interior specifically intended for
nine-slice use. Untouched generated sources are retained at
`source-candidates/menu-category-icons-atlas-v2-source.png` and
`source-candidates/menu-focus-frame-v2-source.png`.

`scripts/build_menu_ui_assets.py` pads the atlas to square cells without
cropping, converts chroma green with edge despill, normalises the runtime atlas
to 1600x1200 and divides the keyed focus frame into nine separate PNGs. Runtime
menus reuse the existing upgrade-card kit for backplates and the existing menu
action atlas for Resume, Settings, Exit and Back CTAs; the new art is limited
to semantic categories and the selected-state overlay.
