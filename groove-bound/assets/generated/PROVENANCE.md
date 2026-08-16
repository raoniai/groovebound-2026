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

## World Tour catalog emblem suite

**Generated:** 2026-08-14 with OpenAI image generation in Codex built-in mode

| Runtime file | World identity | SHA-256 |
|---|---|---|
| `campaign/world-emblems/jazz.png` | Jazz brass-and-piano crest | `f1ba475c274c69832ccf493cc89df31f702a44aaa73fb3936daba7bc586d7a9a` |
| `campaign/world-emblems/house.png` | House club-speaker crest | `5e5f3a7e960ec5ccd9f93c2be8a77dc2d46eb2498dc009fd1a71a6d017da6634` |
| `campaign/world-emblems/techno.png` | Techno synth-circuit crest | `169e7e40c2ff1160b0983c4d57e191fde705add9878c47853f84ba553c0e6d7f` |
| `campaign/world-emblems/cosmic-boogie.png` | Cosmic Boogie rocket-dancer crest | `d28dbe864713285ddafa90e9726b6c16806a49dc1fca0cf554baf0f21860699b` |
| `campaign/world-emblems/soulful-garage.png` | Soulful Garage shutter-and-heart crest | `41e8995de0df7b33790e5667d04196f4b3c37da96975b80d95891cd049bde94a` |
| `campaign/world-emblems/future-funk.png` | Future Funk neon-bass crest | `16060b13b564fc362e66a6850736c06a2fd3ec63c2d61ce8e5f2dc00ca0a2623` |

Each prompt requested one centered, text-free world emblem in the established
Groove Bound dense pixel-painted style, with gold bevels, cyan-magenta edge
light, generous isolation and a uniform chroma-green background. The existing
`world-interface-atlas.png` was supplied as the visual reference; the subject
brief then specified the instrument, architecture or cosmic motif unique to
each world.

Untouched 1536-pixel chroma sources are retained below
`source-candidates/2026-08-14-world-emblems/` and excluded from packages. The
bundled soft-matte/despill helper removed the green background, and macOS image
tools normalized each runtime emblem to a 512x512 RGBA PNG. Runtime dimensions,
alpha support and loader mappings are regression-tested.

## Jazz World catalog emblem

**Generated:** 2026-08-14 with OpenAI image generation in Codex built-in mode

| File | Classification | Dimensions | SHA-256 |
|---|---|---:|---|
| `source-candidates/2026-08-14-jazz-catalog/jazz-emblem-source.png` | Untouched generated source; reference-only and package-excluded | 1254×1254 RGB | `6b915e769dfb0f272aec26a923913fe6f9062aef7b99fd24c97d6fd4b2ae7afd` |
| `../../../landing-page/assets/world-tour/emblems/jazz.png` | Transparent public Catalog identity; excluded from the desktop game payload | 1254×1254 RGBA | `e24d914100af6ab042acd2b774c0689f15bbe6dca173ce544492e36772a76826` |

The prompt requested a standalone, text-free Jazz World emblem: a central
golden saxophone and luminous blue note inside a circular midnight-vinyl crest,
with brass mechanical trim and a violet cosmic gem in detailed Groove Bound
pixel art. It required a flat `#ff00ff` chroma background, no magenta in the
subject, and no robots, crowns, weapons, watermark, or lettering.

The bundled media-pipeline chroma helper removed the flat background and edge
spill. The final file was visually inspected, confirmed RGBA with transparent
corners and alpha bounds `(78, 63, 1176, 1203)`, then saved to the public
Catalog path above. It is deliberately outside the runtime campaign directory,
so this site-only addition cannot silently mutate the released v0.8.4 payload.

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

## Accessible CTA, menu, settings and final-stat suite

**Generated:** 2026-08-12 with OpenAI image generation in Codex built-in mode

| Runtime file | Grid / role |
|---|---|
| `campaign/ui/menu-stat-icons-v1.png` (1600x1600 RGBA) | 4x4 menu-action and final-stat icon atlas |
| `campaign/ui/settings-icons-v1.png` (1600x1600 RGBA) | 4x4 options/control icon atlas |
| `campaign/ui/cta-frame-v1/` | Nine-slice monochrome CTA surface |
| `campaign/ui/cta-focus-v1/` | Nine-slice focus outline derived from the same CTA source |

The menu/stat prompt requested exactly sixteen isolated symbols in a 4x4 grid:
continue, new game, World Tour, settings, perk catalog, quit, replay, back,
stages, time, score, max combo, damage, coins, enemies cleared and bosses
defeated. The settings prompt requested master, music, SFX, mute, fullscreen,
deadzone, keyboard, shake, hit flash, aim assist, zoom, vibration, audio, system,
gameplay and confirm symbols. Both explicitly require a single cyan hue family,
strong low-noise silhouettes, equal cells, safe padding, no text, no particles,
and a uniform green chroma background.

The CTA prompt requested one empty, front-on 4.5:1 panel with a quiet dark navy
interior, cyan outer and inner strokes, four small corner notches, repeatable
edges, no icon, no text, no particles, and no object-like ornament. Raw 8-bit
RGB generator outputs are preserved as
`source-candidates/menu-stat-icons-v1-source.png`,
`source-candidates/settings-icons-v1-source.png`, and
`source-candidates/cta-frame-v1-source.png`; they remain package-excluded.

The bundled chroma-key helper was used to validate clean alpha extraction.
`scripts/build_accessible_ui_assets.py` then applies a deterministic cyan hue
lock while preserving luminance depth, normalises each icon independently into
400x400 cells with 64px safe insets, clears hidden RGB, and builds scalable CTA
surface/focus nine-slice parts. Runtime mappings, exact dimensions, RGBA colour
type, layout, hold-repeat input and package inclusion are regression-tested.

## Level-point CTA and alert icons

**Generated:** 2026-08-13 with OpenAI image generation in Codex built-in mode

| Runtime file | Grid / role | SHA-256 |
|---|---|---|
| `campaign/ui/level-points-alert-icons-v1.png` | 3x2 atlas: level point, evolution, danger, pickup, upgrade and information | `8c8443804e9e95232b0dcb82ff78920b6e06e22de42d27b2dbf2f28293b34dec` |

The primary prompt requested six isolated, text-free, chunky pixel-art symbols
with dark navy outlines and Groove Bound's cyan, violet, gold, red and green
accents. The symbols were arranged in equal 512x512 cells on a flat green
chroma background. A separate magenta-key source regenerated the green upgrade
chevrons and gold star so key removal could preserve that symbol's intended
colour.

Raw sources are preserved as
`source-candidates/level-points-alert-icons-v1-source.png` (SHA-256
`76a1d27c3f5e19e580efad997faa15938b09ad10bbadbceb540f5ee439fcdf76`)
and `source-candidates/level-upgrade-icon-v1-source.png` (SHA-256
`0b82b420ae5e4dd07a1fa270ed8b61aa4c2a13b595160e987a33641a9743a4ef`).
They remain package-excluded. The bundled chroma helper produced alpha PNGs;
FFmpeg then normalized the replacement icon into its 512x512 cell and rebuilt
the exact 1536x1024 RGBA atlas. Runtime dimensions, alpha type and package
inclusion are regression-tested.

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

## Persistent HUD badge and segmented-bar kit

**Generated:** 2026-08-13 with OpenAI image generation in Codex built-in mode

| Runtime file | Role | SHA-256 |
|---|---|---|
| `campaign/ui/hud-interface-kit-v1/rank-badge.png` | Empty number device shared by weapon, passive, perk, player-level and point counters | `abeb70ef230785d5c74936b30417c12ca43b63d107d8c095f86da892fc970096` |
| `campaign/ui/hud-interface-kit-v1/max-badge.png` | Same-size highlighted max-state device with no text | `17b1607560d4a4ac1af673ef0e68bf6991dedf5f4e7fea9f6606bd7fc2af9dc9` |
| `campaign/ui/hud-interface-kit-v1/bar-left.png` | Fixed left status-bar cap | `6887b8a105b95a6a6eababcf6539e770b5f6140fd1a06a1a048b075f2d65f079` |
| `campaign/ui/hud-interface-kit-v1/bar-middle.png` | Horizontally repeated status-bar rail | `3cce27e7c5159f75cffd2ce2aea72b7ee04db34fe0c52a7e27fdd9ea2e4afaf4` |
| `campaign/ui/hud-interface-kit-v1/bar-right.png` | Fixed right status-bar cap | `bdc8206e2ddb827e4c152bb4f18eb4e28ad0164d67f92ced76a9590b2cf67fdc` |
| `campaign/ui/hud-interface-kit-v1/bar-fill.png` | Horizontally repeated neutral segmented fill, tinted by runtime status | `10307e4a9f86edbeab50cfcdbfd41ce4e5fecf27ed6bc8a511be5d2eb7a1eb9b` |

The prompt used the approved level-point alert atlas and transparent HUD frame
as style references. It requested a strict text-free 3x2 source grid containing
an empty circular rank badge, a same-size highlighted max badge, compatible
left/middle/right horizontal bar pieces, and a neutral segmented fill tile in
the established dark-navy, cyan, violet and gold arcade-pixel palette. The
background was required to be uniform chroma green with generous cell padding,
no shadows, particles, watermark, embedded letters or numbers.

The untouched generated source is retained as
`source-candidates/hud-interface-kit-v1-source.png` (SHA-256
`02d9f9f18a1286dcbe0a111a2a39df65cf6825b7fc35c0e6f6776a3881f8386f`)
and remains package-excluded. The bundled soft-matte/despill helper removed the
chroma background. `scripts/build_hud_interface_kit.py` then normalized the two
badges, cropped stable bar caps and repeatable rail/fill samples, cleared hidden
RGB, enforced RGBA dimensions and wrote the runtime files above.

## Jazz World runtime suite

**Generated:** 2026-08-13 with OpenAI image generation in Codex built-in mode

| Runtime file | Grid / role | SHA-256 |
|---|---|---|
| `campaign/jazz-enemies-atlas.png` | 4x2 RGBA atlas for eight Jazz enemy definitions | `e3e7cf764dce7a2c1b6fff1cfcb7b1bb066374b4e41521e0fcdc3af977140591` |
| `campaign/jazz-environment-atlas.png` | 4x2 RGBA arena-prop atlas | `15d9c0b92fe4696325ea99bc47220de872fb4cd25a218fd01ec03d5f6167e942` |
| `campaign/jazz-floor-atlas.png` | 2x2 RGB top-down floor atlas | `45664fa035d1f1723f2a5086ca29372237742eb7610521a0508a70d5b35a481c` |
| `campaign/jazz-world-logo.png` | Jazz identity mark promoted from the project-owned site asset | `af8fccb7a02cc40f4e32c498a04d91ddcc9c6b473a72e43cabab9b1633c33d7b` |

The enemy prompt requested Syncopated Imp, Blue Note Bat, Walking Bass Bot,
Scat Cannon, Bebop Behemoth, Brushfire Skitter, Brass Regent and Midnight
Maestro as eight isolated, text-free cosmic instrument robots. The environment
prompt requested eight independently extractable club, brass, speaker, bass,
fountain, planter, bench and spotlight props. Both used existing project atlases
as style/layout references and required uniform chroma green, generous cell
padding and no cross-cell effects. The floor prompt requested four full-bleed,
top-down midnight Jazz textures with low combat contrast and exact quadrant
boundaries.

Untouched generator outputs are preserved below
`source-candidates/2026-08-13-jazz-world/` and excluded from packages. The
bundled soft-matte/despill helper removed chroma backgrounds; FFmpeg then
normalized the runtime sprite atlases with nearest-neighbour scaling. The Jazz
logo is an unchanged byte-for-byte runtime promotion of the project-owned
`landing-page/assets/world-tour/logos/jazz.png`; the website source remains a
separate public surface. Runtime dimensions, PNG colour types and loader paths
are regression-tested.

## Separate player attack animation strips

**Generated:** 2026-08-14 with OpenAI image generation in Codex built-in mode

| File | Classification / role | Dimensions | SHA-256 |
|---|---|---:|---|
| `source-candidates/2026-08-14-projectile-v091/stage-board-base-a-chroma-source.png` | Untouched source for base attacks 1-8; package-excluded | 1402x1122 RGB | `04d4e03b7403722c946b967994897a2fb92d10808fef5e1a78da0a35ef235125` |
| `source-candidates/2026-08-14-projectile-v091/stage-board-base-a-transparent.png` | Keyed build source | 1402x1122 RGBA | `09d8cbff1b2f8d46489348fc45c92f98cf13060357e6a6df3b008198d13e15b8` |
| `source-candidates/2026-08-14-projectile-v091/stage-board-base-b-chroma-source.png` | Untouched source for base attacks 9-16; package-excluded | 1672x941 RGB | `559b9ab57cb6df19062a8849a6ff081785d7b7a86415e7e17dee0d22e5d21d7b` |
| `source-candidates/2026-08-14-projectile-v091/stage-board-base-b-transparent.png` | Keyed build source | 1672x941 RGBA | `430332acaee7c62b82d8a06d83df5dcdf730d87a4d38089b5ab972c95da02cb6` |
| `source-candidates/2026-08-14-projectile-v091/stage-board-evolved-a-chroma-source.png` | Untouched source for evolved attacks 1-8; package-excluded | 1536x1024 RGB | `586219f0e94a7f199158aa45e866078cd64548b57d20ac90939a32cf51d6406c` |
| `source-candidates/2026-08-14-projectile-v091/stage-board-evolved-a-transparent.png` | Keyed build source | 1536x1024 RGBA | `1f2d4558627d77a4bd3edea087dfb236cc155e8ee15317b9e06e45638b56fe9f` |
| `source-candidates/2026-08-14-projectile-v091/stage-board-evolved-b-chroma-source.png` | Untouched source for evolved attacks 9-16; package-excluded | 1619x971 RGB | `22539a43b8682a0a1b52b31776b329cda4689ee2847e2f3f6017e0cb254b7abb` |
| `source-candidates/2026-08-14-projectile-v091/stage-board-evolved-b-transparent.png` | Keyed build source | 1619x971 RGBA | `f9ee2c9f8b4feaa79269d369474a21607bf51d108b274f25e5db2afcd959455d` |
| `projectiles/<weapon-id>.png` | 32 separate runtime animation strips | 1920x128 RGBA each | Five unique frame hashes and unique per-file hashes verified by the build script |

The source prompt is recorded beside the source images in `PROMPTS.md`. The
v0.9.1 projectile atlas and combat-effects atlas were used only as visual
references. The rejected shared attack atlas guided the category list but was
not copied into this branch. The earlier concept board is retained as
reference-only. Four accepted stage boards replace it as build inputs and paint
all five states for every attack with controlled glow and generous empty space.

`scripts/build_projectile_animations.py` splits the four source boards in
stable row and stage order and produces five distinct 384x128 frames for every
weapon ID. It preserves authored stage art and aspect ratio; it does not
manufacture motion from a single frame or create a combined runtime atlas.
`src/assets.lua` loads each strip independently from
`assets/generated/projectiles/`. The retired
`campaign/projectile-atlas.png` is removed from runtime and packaging; its old
source candidate remains reference-only for historical provenance.

## v0.9.5 projectile readability animation sheets

**Generated:** 2026-08-15 with OpenAI image generation in Codex built-in mode

The 32 files under `projectiles/<weapon-id>.png` are promoted from the accepted
`source-candidates/2026-08-15-projectile-readability-v2/sheets/` set. Every
runtime file is a separate 2048x1024 RGBA sheet containing eight authored
512x512 frames in a 4x2 grid. Stable weapon IDs and runtime paths are unchanged.

The new art uses one projectile or effect core per frame, large transparent
gutters, partial alpha, sparse particles, and visible anticipation, formation,
peak, breakup, retraction, and remnant states. Beam sheets contain authored
start and end caps rather than a short texture intended for non-uniform
stretching. Runtime transforms are uniform and capped at native scale; gameplay
coverage and collision remain independent from visual size. Multi-shot attacks
reuse the same sheet with deterministic 0-60 ms visual offsets and do not
consume gameplay RNG.

Untouched chroma sources, keyed intermediates, rejected Neon Crescendo output,
prompts, build script, validation manifest, exact hashes, and implementation
record are preserved beside the accepted sheets and excluded from packages.
The previous five-frame strips remain documented above as superseded v0.9.4
runtime provenance; they are no longer loaded in the v0.9.5 candidate.

## Enemy movement animation suite

**Generated:** 2026-08-14 with OpenAI image generation in Codex built-in mode
**Promoted to runtime:** 2026-08-15 for v0.9.3

| Runtime file | Grid / role | SHA-256 |
|---|---|---|
| `campaign/enemy-animation/backbeat-movement-atlas.png` | 4x6 RGBA atlas; three frames for eight Backbeat visuals | `c2bddc0b4b1392fae8f7c5491656172e7d5c8cccd0d46e8455827d37f6677a1a` |
| `campaign/enemy-animation/orbit-movement-atlas.png` | 4x6 RGBA atlas; three frames for eight Orbit visuals | `fb1acb6f17f0b9682d8ff59d7abfebc767b7b52ca31097cd74bdd9f079bc3bdf` |
| `campaign/enemy-animation/funk-movement-atlas.png` | 4x6 RGBA atlas; three frames for eight Funk visuals | `9422e1eb841d39748ca4cbee13e5c51642f8e4ff6c8217a871ace5a822d67a6d` |
| `campaign/enemy-animation/soul-movement-atlas.png` | 4x6 RGBA atlas; three frames for eight Soul visuals | `383a777749ffdd2a2efaae5d91b5409a9d5c1411e34c74e113fb95323fe48270` |
| `campaign/enemy-animation/disco-movement-atlas.png` | 4x6 RGBA atlas; three frames for eight Disco visuals | `ce30f223a853ba4a852a6de2d5de2dec9d89d682e190130f2c8236b69e834c67` |
| `campaign/enemy-animation/jazz-movement-atlas.png` | 4x8 RGBA atlas; four frames for eight Jazz visuals | `986eef555664b80e1524936cfafb18312e0f88cf673cb3d90ce00258b46edfa8` |

The six existing Groove Bound enemy atlases were the only visual references.
The prompts preserved every established silhouette while requesting a
character-specific walk, hover, pulse, recoil, wingbeat or planted motion.
Untouched generator outputs, rejected key-conflict sources, prompts, manifests,
build script, per-enemy frames, and review GIFs remain below
`source-candidates/2026-08-14-enemy-animation/` and are package-excluded.

The runtime atlases are promoted byte-for-byte from the verified `*-clean.png`
candidate atlases. Five use three vertical frames per original source cell;
Jazz uses one enemy per row with four horizontal frames. The runtime mapping
covers all 49 enemy definitions and 48 unique visuals. `breakbeat_bruiser`
continues to share the current `turntable_sentinel` Orbit visual explicitly.
Animation phase is derived deterministically without consuming gameplay RNG;
the existing static atlas remains the renderer fallback when no frame is
requested.

## Individual enemy state animation suite

**Generated and prepared:** 2026-08-15 with OpenAI image generation in Codex
built-in mode

The package runtime now contains 170 individual RGBA animation strips under
`campaign/enemies/<enemy-id>/`: walk, hit, and death for all 49 enemy IDs plus
attack for the 23 definitions with `attack_kind`. The strips contain 600
256x256 frames. `breakbeat_bruiser` has a new, independent orange-and-black
drum-machine brawler identity instead of the former Turntable Sentinel alias.

The prior movement atlases and every established Groove Bound enemy sprite
were the only visual references. No third-party images were used. Generator
boards, individual source frames, the reproducible preparation script, and the
complete hash/path/frame manifest are preserved below
`source-candidates/2026-08-15-enemy-state-animation/` and excluded from
packages. The built-in generator does not expose a user-selectable model name
or separate per-call price.

`prepare_state_assets.py` normalizes generator boards to exact 256px cells,
removes and despills their flat chroma backgrounds, preserves a transparent
gutter, slices every state into individual frames, and writes one horizontal
runtime strip per enemy/state. `state-manifest.json` records all source-frame
and runtime hashes, dimensions, counts, and mappings.
