# Groove Bound — Visual Asset Research and Generation Plan

**Status:** Planned only  
**Date:** 26 July 2026  
**Canonical runtime reviewed:** `groove-bound/`  
**External actions taken:** Research only. No assets were downloaded, generated, imported, or published.

## 1. Recommendation

Groove Bound should not become a generic neon rhythm game. Its strongest visual
identity is the collision of:

- exhausted, after-hours office life;
- mischievous musical magic;
- dark top-down survival combat;
- the purple Wizard of Groove iconography;
- bright, readable notes, pickups, and attack effects.

The working art direction is:

> **After-hours office occult:** drab corporate objects and tired workers
> transformed by loud, playful, handmade musical magic.

Use a hybrid production strategy:

1. **Prototype with clearly licensed CC0 packs.** Use free office props, generic
   monster silhouettes, instrument icons, UI pieces, and VFX to test density,
   scale, readability, and integration.
2. **Generate or commission signature assets.** Joe, the Wizard of Groove,
   named enemies, weapons, bosses, groove feedback, portraits, and the final UI
   must share one deliberate style and should not look like a collection of
   unrelated asset packs.
3. **Finish every generated asset by hand.** Generation should create concepts,
   key poses, palette candidates, and first animation passes. A pixel-art cleanup
   step must normalize anatomy, palette, pivots, silhouettes, frame timing,
   transparency, and sprite-sheet layout.

The free assets are best treated as a visual prototype and donor library, not as
the final identity.

## 2. Current visual state

The remake currently uses a small isolated legacy bridge:

| Runtime asset | Current implementation | Main limitation |
|---|---|---|
| Joe | 64×64 cells; four-direction idle and run | No hurt, death, victory, casting, groove, or portrait set |
| Enemies | One 64×64 four-direction body, recolored for every enemy | Monotone, Tempo Leech, miniboss, and boss do not have unique silhouettes |
| Projectile | One 27×27 image for every weapon | Weapon roles are not visually distinct |
| XP | One 64×64 gem image | No value tiers or high-contrast alternative |
| Arena | Eight dark 128×128 floor crops | Low environmental storytelling and weak landmarks |
| UI | Programmatic panels plus one wizard icon and one game-over image | Functional, but not a unified production UI |
| VFX | Tint, glow circles, camera shake, and a few notices | Impacts, deaths, beat response, evolution, and boss telegraphs are missing |

The current runtime already establishes useful technical constraints:

- nearest-neighbour filtering;
- 64×64 animation cells;
- four directions in the order **down, up, left, right**;
- a 2000×1600 bounded arena;
- dark purple background colours, gold focus, mint XP, coral damage, and
  magenta boss feedback;
- a target of hundreds of simultaneous enemies and projectiles.

### Highest-value changes

The first visual pass should prioritize:

1. unique enemy silhouettes;
2. weapon-specific projectiles and impacts;
3. a richer office arena with memorable landmarks;
4. readable pickup and hazard families;
5. progression cards with icons;
6. boss telegraphs and groove feedback;
7. character personality animations;
8. consistent title, HUD, pause, level-up, and results presentation.

## 3. Art direction and production rules

### 3.1 Native resolution

| Asset type | Native target |
|---|---:|
| Standard character/enemy cell | 64×64 px |
| Joe visible body | approximately 24–32 px wide and 34–46 px tall inside the cell |
| Small enemy visible body | approximately 24–40 px inside a 64×64 cell |
| Miniboss cell | 96×96 px |
| Final boss cell | 128×128 px |
| Inventory/passive icon | 32×32 px, authored so it remains legible at 24×24 |
| Small projectile | 16×16 or 24×24 px |
| Large projectile/area marker | 32×32 or 64×64 px |
| Floor module | 128×128 px |
| Small environment prop | 32×32 or 64×64 px |
| Large environment prop | 128×128 px |
| UI nine-slice source | 16 px corners, scaled in integer multiples |

Author at the target resolution. Do not generate a smooth high-resolution
illustration and merely apply a pixelation filter.

### 3.2 Core palette

Use a compact shared palette. Small accent variations are allowed, but all
assets should begin with this family:

| Role | Colour |
|---|---|
| Deep ink | `#0F0C1A` |
| Office shadow | `#1D1829` |
| Bruise purple | `#594C80` |
| Dusty lavender | `#8A7DA6` |
| Paper ivory | `#E8D9B8` |
| Groove gold | `#F2C239` |
| XP mint | `#33E6B3` |
| Signal cyan | `#37B8D9` |
| Bass indigo | `#5549D9` |
| Danger coral | `#E8495F` |
| Static magenta | `#F12A80` |
| Tempo orange | `#F28A32` |

Per 64×64 sprite, prefer 12–18 opaque colours plus transparency. Use one dark
outline colour, two or three body values, and one or two effect accents.

### 3.3 Shape language

- **Joe and allies:** soft squares, rounded shoulders, readable faces, practical
  office clothing, slightly oversized expressive hands.
- **Groove magic:** curves, waves, loops, stars, hand-drawn notes, brass arcs,
  elastic anticipation.
- **Static enemies:** jagged steps, broken scan lines, clipped corners, cables,
  paper shards, rigid repetition.
- **Studio evolutions:** aligned geometry, clean rhythm, restrained gold/cyan
  accents, precise spacing.
- **Live evolutions:** asymmetric arcs, magenta/orange accents, wider poses,
  improvised timing, stronger secondary motion.
- **Bosses:** occupy more screen space through silhouette and effects, not
  through fine detail alone.

### 3.4 Lighting and texture

- Light from the upper left.
- One-pixel dark outline on characters and interactive objects.
- No soft airbrush shading.
- Limited ordered dithering only on large surfaces.
- Opaque hard edges for gameplay sprites.
- Semi-transparency is reserved for glows, ghosts, telegraphs, and particles.
- Office surfaces should feel worn: carpet seams, sticky notes, cable runs,
  coffee rings, paper scraps, scuffed laminate, and subtle CRT noise.

### 3.5 Animation language

- Idle: restrained office fatigue plus one memorable personality beat.
- Movement: clear contact and passing poses; no frame-to-frame body resizing.
- Groove state: posture opens, tie/hair moves, gold accents pulse on beat.
- Hit: two or three readable frames; avoid full-screen white flashes.
- Death: silhouette breaks into thematic parts—paper, static blocks, tape, or
  notes—rather than generic gore.
- Boss telegraphs: at least 400–600 ms of readable anticipation at normal speed.
- Every dangerous event must have shape and motion cues, not colour alone.

### 3.6 Camera and pivot conventions

- Low top-down / three-quarter RPG view.
- Feet or contact point remain on the same baseline in every frame.
- Character pivot: bottom-centre contact point.
- Projectile pivot: geometric centre.
- Prop pivot: centre of floor footprint.
- Animation jitter at the pivot must not exceed one native pixel.
- Left-facing frames may be mirrored only when handedness and asymmetry do not
  matter.

## 4. Free and royalty-free research

“Royalty-free” does not automatically mean “free,” “attribution-free,” or safe
to redistribute. For the first test, prefer CC0 sources and keep an asset
register even when attribution is not required.

### 4.1 Best first-test sources

| Source | License stated by source | Useful content | Recommended use |
|---|---|---|---|
| [Pixel Office Asset Pack by 2dPig](https://2dpig.itch.io/pixel-office) | CC0; attribution not required | Five human characters, office furniture, computers, plants, decor, PNG and Aseprite source | **Best environment donor.** Test office storytelling and prop density |
| [Ninja Adventure by Pixel-Boy and AAA](https://pixel-boy.itch.io/ninja-adventure-asset-pack) | CC0; commercial use allowed; attribution not required | 50+ characters, 30+ monsters, nine bosses, items, tiles, UI, VFX, audio | **Best broad prototype pack.** Use selected monsters, effects, and UI only; its 16×16 fantasy style should not replace Groove Bound’s identity |
| [CC0 Music Icons by AntumDeluge](https://opengameart.org/content/cc0-music-icons) | CC0 | 24×24 and 32×32 instruments including brass, drums, guitar, accordion, flute, violin, and more | **Best icon donor.** Recolour and simplify for temporary weapon/passive cards |
| [Animated Monsters by stealthix](https://opengameart.org/content/animated-monsters) | CC0 | Zombie, skeleton, and witch with idle, walk, punch, hurt, and fall; transparent sheets; Endesga 32 palette | **Good animation benchmark.** Use as temporary silhouettes or timing reference |
| [71 Monsters Animations](https://opengameart.org/content/71-monsters-animations) | CC0 | A large range of small animated monsters | **Variety test only.** Audit visual scale and animation format before import |
| [Pixel Magic Effects by Foozle](https://foozlecc.itch.io/pixel-magic-sprite-effects) | CC0 | Ten 32×32 spell effects with icons | **Good VFX donor.** Prototype impacts, portals, and area attacks after palette conversion |
| [Explosions — Pixel Art by Aim Studios](https://aim-studios.itch.io/explosions-pixel-art) | CC0 | Multiple 32×32 and 64×64 animated explosions | **Good death/impact donor.** Use only selected effects and recolour them |
| [Kenney Pixel UI Pack](https://kenney.nl/assets/pixel-ui-pack) | CC0 | 750 pixel panels and buttons | **Best UI construction kit.** Build temporary nine-slice panels and focus states |
| [Kenney Input Prompts Pixel](https://kenney.nl/assets/input-prompts-pixel) | CC0 | 800 keyboard, mouse, gamepad, handheld, arcade, and touch glyphs | **Production-capable utility asset.** Use for control hints and remapping |
| [Kenney Roguelike Modern City](https://kenney.nl/assets/roguelike-modern-city) | CC0 | 1,036 urban pixel tiles | **Secondary environment donor.** Use for exterior/industrial details, not as the main office |
| [Kenney Particle Pack](https://kenney.nl/assets/particle-pack) | CC0 | 80 particle/VFX textures | **Prototype only.** Downsample and harden edges before use in pixel scenes |

Creative Commons explains that CC0 allows copying, modification, distribution,
and commercial use without asking permission, but it provides no warranty and
does not clear trademarks, patents, publicity rights, privacy rights, or
third-party material. See the [CC0 deed](https://creativecommons.org/publicdomain/zero/1.0/)
and [legal code](https://creativecommons.org/publicdomain/zero/1.0/legalcode.en).

### 4.2 Conditional sources

These can be used, but they add attribution or source-specific obligations and
are unnecessary for the first test:

| Source | Stated terms | Recommendation |
|---|---|---|
| [Top-Down Tileset 16×16 by bitsmall](https://bitsmall.itch.io/topdown) | CC BY 4.0; attribution, license link, and change notice required | Use only if it fills a real gap; record exact credit text |
| [Bloomseed by Cocophany](https://cocophany.itch.io/bloomseed) | Free commercial use with credit; no redistribution of the pack, including modified versions | Attractive but tonally cosy; not a first choice |
| [Office pixel art assets by flojiq](https://flojiq.itch.io/office-assets-by-flojiq) | Free personal/commercial use; a Steam credit request applies in a stated scenario | Avoid for the cleanest prototype chain because the custom terms need separate tracking |

### 4.3 Existing project material

- Keep current first-party legacy exports available as visual references.
- Treat the Dropbox `Explosions and Powers Sprites` collection as
  **license-review required** until its source URL, vendor, tier, commercial
  terms, redistribution rules, and actual licensed files are confirmed.
- Do not infer that a file is usable because it was previously downloaded or
  included in a working folder.
- Do not use real musicians, recognizable likenesses, trademarked costumes,
  band logos, album art, or branded instruments as generation references.

## 5. First-test asset plan

No downloads should happen until this shortlist is approved.

### Test A — CC0 kitbash

Purpose: prove scale, composition, and readability in the running game without
claiming final art.

1. Retain the current Joe, wizard icon, game-over art, font, and palette.
2. Use 2dPig office props to build one after-hours office arena mockup.
3. Use CC0 Music Icons for temporary weapon and passive cards.
4. Use three clearly different Ninja Adventure or Animated Monsters silhouettes
   as temporary enemy-role probes.
5. Use selected Foozle/Aim effects for projectile impact, enemy death, and
   level-up.
6. Use Kenney Pixel UI and Input Prompts for temporary cards, panels, and
   controls.
7. Recolour every imported donor asset into the Groove Bound palette and retain
   the untouched original in a provenance-only folder.

**Pass condition:** at 1280×720 and normal zoom, the player, five enemy roles,
projectiles, pickups, hazards, and progression cards remain distinguishable
without reading labels.

### Test B — generated signature set

Purpose: establish whether a generation workflow can produce a coherent,
editable house style.

Generate only these probes after approval:

1. one Joe reference turnaround;
2. one Monotone four-direction walk;
3. one Tempo Leech four-direction walk;
4. one Kazoo Pistol icon, projectile, and impact;
5. one seamless office-carpet module;
6. one level-up card frame;
7. one Static Baron attack telegraph.

Do not generate the entire inventory until these seven probes pass style,
readability, frame consistency, and cleanup-cost review.

### Recommended generation workflow

For top-down animated characters, [PixelLab](https://www.pixellab.ai/) is the
most relevant specialized option found: it advertises four/eight-direction
rotation, top-down views, transparent backgrounds, reference-based animation,
tilesets, and sprite export. Its documentation supports 64×64 animation frames
and explicit direction controls. Its advanced animation routes are paid-tier
features, so use its free trial only as a quality probe and archive the current
terms before production.

[Scenario](https://www.scenario.com/) is relevant for consistent game-asset
families and custom models. Its current terms state that users own generated
assets and may use them commercially, while also warning that outputs are not
guaranteed to be unique, original, or non-infringing. It is more useful for
icons, props, portraits, and style families than for trusting raw animation
sheets without cleanup.

Free cleanup/assembly options include:

- [Piskel](https://www.piskelapp.com/) — browser and offline sprite editor with
  GIF, PNG, and sprite-sheet export;
- [Pix2D](https://pix2d.com/) — free/open-source sprite editor with animation,
  layers, palettes, and browser support;
- the existing editable `Joe-v1.aseprite`, if Aseprite is available.

### Generation sequence

1. Approve a master style reference.
2. Lock palette, perspective, outline, native scale, and lighting.
3. Generate one clean south-facing key pose.
4. Generate rotations from that approved reference, not independently.
5. Generate one action at a time from the same reference and seed.
6. Remove bad frames; do not repair identity drift with more random variants.
7. Hand-clean the surviving keyframes at native resolution.
8. Assemble and tag animations in the required runtime order.
9. Test at 1× native resolution and in a crowded combat capture.
10. Store source prompt, tool/model/version, seed, date, reference inputs, and
    editor changes in the asset register.

## 6. Complete sprite inventory

### 6.1 Priority legend

- **P0:** required to make the current playable slice feel authored.
- **P1:** required for the first production vertical slice.
- **P2:** polished-demo variety and narrative support.

### 6.2 Characters and narrative

| Priority | Asset | Deliverables |
|---|---|---|
| P0 | Joe production sprite | Idle 4×4 directions, run 8×4, hit 2×4, death 8, victory 8, groove idle 4×4 |
| P0 | Joe portrait | Neutral, worried, determined, grooving, hurt, victory |
| P1 | Wizard of Groove | 4-direction idle, appear, gesture, vanish; six portrait expressions |
| P1 | Joe loadout silhouette | 32×32 and 64×64 selection icon |
| P2 | Nia, late-shift sound engineer | Full Joe-equivalent animation set; working expansion concept |
| P2 | Omar, office percussionist | Full Joe-equivalent animation set; working expansion concept |
| P2 | Character select portraits | Neutral and selected/glowing variant for each playable character |

### 6.3 Core and expansion enemies

The first four names are current content. The remaining names are working visual
concepts to satisfy the roadmap’s five ordinary roles and two elites without
using real-world references.

| Priority | Enemy | Visual role | Animation set |
|---|---|---|---|
| P0 | Monotone | Common chaser; grey cubicle wraith in shirt and tie, speaker-like blank face | Idle 4×4, walk 6×4, hit 2×4, death 8 |
| P0 | Tempo Leech | Fast zigzag enemy; orange cassette/tape parasite with cable tail | Hover 6×4, dash 4×4, hit 2×4, death 8 |
| P0 | Metronome Guardian | Miniboss charger; tall clockwork security guard with pendulum chest | Idle 6×4, march 8×4, charge 6×4, stagger 4, death 12 |
| P0 | Static Baron | Final boss; floating executive broadcast tower with torn suit, CRT head, aerial crown | Idle 8, cast 8, radial burst 10, beam 10, summon 8, stagger 4, death 16 |
| P1 | Feedback Bee | Small swarmer; office headset becomes a buzzing speaker insect | Fly 6×4, attack 4×4, death 6 |
| P1 | Paper Jammer | Ranged enemy; possessed desktop printer spitting jagged paper notes | Idle 4×4, roll 6×4, aim 6×4, jam burst 6, death 8 |
| P1 | Deadline Drummer | Tank/pusher; hunched calendar creature with drum-clock belly | Walk 8×4, wind-up 6×4, slam 8×4, death 10 |
| P1 | Noise Auditor | Elite buffer; severe spectral auditor with clipboard waveform shield | Float 6×4, shield 8, debuff 8, stagger 4, death 12 |
| P1 | Syncopation Brute | Elite disruptor; broken office chair and bass cabinet fused into a stomping brute | Walk 8×4, stomp 10, shoulder charge 8×4, death 12 |
| P2 | Maestro Monotone | Optional second boss; conductor made from filing cabinets and black batons | Full 128×128 boss set |
| P2 | DJ Discord | Optional second boss; original masked radio pirate with turntable halo | Full 128×128 boss set |

### 6.4 Weapons and evolutions

Current content contains four base weapons plus the Kazoo’s two branch
evolutions. `Drone Tambourine` is the best fifth weapon candidate because it is
already part of the established concept and the source archive contains a drone
sprite.

| Priority | Weapon | Required art |
|---|---|---|
| P0 | Kazoo Pistol | 32×32 icon, held/aim overlay, 16×16 buzzing note projectile, muzzle puff, impact |
| P0 | Bass Drop | 32×32 icon, 24×24 bass-note projectile, ground-ring impact, pierce trail |
| P0 | Cymbal Slicer | 32×32 icon, 16×16 spinning cymbal blade, spark impact, return/expire effect |
| P0 | Feedback Loop | 32×32 icon, 16×16 pulse projectile, connecting waveform trail, feedback burst |
| P0 | Brass Barrage | 32×32 evolved icon, three brass projectiles, clean studio muzzle flash, piercing impact |
| P0 | Improvised Solo | 32×32 evolved icon, two asymmetric live notes, speed trail, volatile impact |
| P1 | Drone Tambourine | 32×32 icon, 32×32 orbiting drone, idle spin, strike, damaged flicker |
| P1 | Studio Bass evolution — **Subwoofer Stack** | Working name; icon, heavy square pulse, aligned shock rings |
| P1 | Live Bass evolution — **Earthquake Encore** | Working name; icon, uneven expanding floor wave, debris notes |
| P1 | Studio Cymbal evolution — **Precision Hi-Hats** | Working name; icon, paired thin discs, measured cross-cut |
| P1 | Live Cymbal evolution — **Golden Crash** | Working name; icon, oversized golden crash disc, flare impact |
| P1 | Studio Feedback evolution — **Clean Signal** | Working name; icon, cyan sine-wave bolt, precise beam nodes |
| P1 | Live Feedback evolution — **Wall of Noise** | Working name; icon, magenta waveform wall, distortion particles |
| P1 | Studio Drone evolution — **Rhythm Satellite** | Working name; icon, one engineered orbital unit, lock-on pulse |
| P1 | Live Drone evolution — **Percussion Swarm** | Working name; icon, three varied hand-percussion drones, chaotic orbit |
| P2 | Power Chord | Reserve weapon; guitar-neck icon, straight chord beam, harmonic impact |
| P2 | Snare Scatter | Reserve weapon; snare icon, pellet-note fan, rimshot impact |
| P2 | Mic Drop | Reserve weapon; microphone icon, falling area marker, stage-light explosion |

### 6.5 Passives and rewards

| Priority | Asset | Icon concept |
|---|---|---|
| P0 | Quickstep | Office shoe leaving two gold rhythm ticks |
| P0 | Encore | Raised hand and heart under a tiny spotlight |
| P0 | Breath Control | Calm mouth profile with circular breath waveform |
| P1 | Sound Check | Working passive; headphones enclosing a shield |
| P1 | Stage Presence | Working passive; gold spotlight widening around a figure |
| P0 | Resolve | Purple-and-gold stamped record token |
| P0 | Coin | Square-edged gold coin with abstract note mark, no currency symbol |
| P0 | Health | Coffee cup with heart-shaped steam |
| P0 | XP small/medium/large | Mint eighth note, paired notes, crystalline chord cluster |
| P1 | Boss reward case | Portable equipment case with a pulsing gold latch |
| P1 | Reroll | Two circular arrows made from cassette tape |
| P1 | Skip reward | Exit sign arrow transformed into a note, no text |

### 6.6 Arena and props

| Priority | Asset family | Required sprites |
|---|---|---|
| P0 | Carpet/floor | Eight seamless 128×128 modules: clean, seam, coffee stain, paper, cable, vent, scuff, subtle groove crack |
| P0 | Walls/bounds | Straight, inner/outer corners, doorway, damaged wall, purple magical barrier |
| P0 | Landmark props | Cubicle cluster, meeting table, reception desk, photocopier, vending machine, server rack, break-room counter |
| P0 | Small clutter | Office chair, bin, files, loose paper, mugs, keyboard, monitor, plant, cables, sticky notes |
| P1 | Groove contamination | Floating notes, purple fungus-like sound foam, gold cable roots, oscillating lamps, possessed speakers |
| P1 | Arena landmarks | Wizard portal, broken lift, jam room corner, broadcast booth, boss stage |
| P1 | Hazard set | Exposed cable spark, rolling chair, printer paper fan, feedback puddle, falling ceiling marker |
| P1 | Destruction states | Intact, hit, broken for printer, monitor, chair, speaker, vending machine |
| P2 | Alternate stage set | Rooftop broadcast office: rooftop tiles, antennas, HVAC, neon reflections, storm clouds |

### 6.7 UI

| Priority | Asset family | Required sprites |
|---|---|---|
| P0 | Logo | Horizontal and compact Groove Bound mark; purple hat, gold notes; no borrowed type |
| P0 | Nine-slice UI | Small/medium/large panel, button, selected button, disabled button, tooltip |
| P0 | Progression cards | Weapon, passive, upgrade, evolution, locked, rare, Studio, Live |
| P0 | HUD frames | HP, guard, XP, groove, boss HP, weapon slots, passive slots |
| P0 | Status icons | Damage, speed, cooldown, pierce, area, duration, pickup radius, guard, max HP |
| P0 | Combat indicators | Player arrow, target reticle, off-screen enemy arrow, boss arrow, danger marker |
| P1 | Screen illustrations | Title vignette, victory, defeat, pause cassette, results ticket |
| P1 | Character select | Portrait frames, locked silhouette, starting weapon badge |
| P1 | Meta shop | Record token, price plate, purchased stamp, locked chain |
| P1 | Control prompts | Use Kenney CC0 glyphs with Groove Bound frames rather than redrawing platform marks |

### 6.8 VFX

| Priority | Effect | Animation target |
|---|---|---|
| P0 | Generic hit spark | 5 frames, 32×32 |
| P0 | Enemy death burst | 8 frames, 64×64; thematic variants for paper, tape, static, and brass |
| P0 | XP pickup | 6 frames, 32×32 |
| P0 | Level up | 10 frames, 96×96 |
| P0 | Damage flash alternative | Outline pulse, 4 frames; no full-screen flash |
| P0 | Boss telegraph | Ring, cone, line, target marker; 8-frame pulse each |
| P1 | Groove beat pulse | 8 frames, tileable ring and UI accent |
| P1 | Groove tier-up | 12 frames, 128×128 |
| P1 | Evolution Studio | 16 frames, precise gold/cyan geometric assembly |
| P1 | Evolution Live | 16 frames, magenta/orange improvised spiral |
| P1 | Resolve earned | 10 frames, stamped-record burst |
| P1 | Spawn effects | Static tear, cable portal, paper cyclone |
| P1 | Boss attacks | Static bolt, broadcast beam, radial interference, falling channel marker |
| P2 | Environment ambience | Dust motes, monitor flicker, paper drift, tiny note fireflies |

## 7. Prompt system

### 7.1 Shared style block

Prepend this to every generation prompt:

```text
Original game asset for Groove Bound, a darkly comic top-down survival
roguelike about an exhausted office worker restoring music to an after-hours
corporate world. Native-resolution pixel art, low top-down three-quarter RPG
view, hard one-pixel dark outline, crisp square pixels, no antialiasing, compact
12-to-18-colour palette using deep ink, bruise purple, dusty lavender, paper
ivory, groove gold, XP mint, signal cyan, danger coral, static magenta and tempo
orange. Upper-left lighting, readable silhouette at 1x scale, playful musical
magic colliding with worn office materials. Original IP only.
```

### 7.2 Shared negative block

Append this to every generation prompt:

```text
Transparent background unless a seamless tile is requested. No text, letters,
numbers, logos, watermarks, brand marks, celebrities, real musicians, album art,
recognizable copyrighted characters, realistic photography, smooth vector art,
3D render, isometric view, side-scroller view, soft blur, antialiasing, excessive
glow, colour gradients, subpixel detail, inconsistent pixel size, cropped body,
duplicate limbs, changing costume, changing proportions, or changing light
direction.
```

### 7.3 Sprite-sheet suffix

For an animation, add:

```text
Each frame is exactly {CELL_WIDTH}x{CELL_HEIGHT} pixels on a strict rectangular
grid. Keep the same character identity, proportions, palette, outline, lighting,
floor contact point, scale and equipment in every frame. Place the pivot at the
bottom centre. Leave at least four transparent pixels around the visible
silhouette. Output frames only, evenly spaced, with no labels or preview mockup.
```

Generate each direction as a separate strip. Assemble the final sheet manually
in the runtime order **down, up, left, right**.

## 8. Full generation prompt catalog

Every prompt below is intended to be combined with the shared style and negative
blocks. Working expansion names can change without affecting the core style.

### 8.1 Master references

#### P01 — Groove Bound master style sheet

```text
Create a single pixel-art style reference board, not a finished game screen.
Show Joe, the Wizard of Groove, a Monotone, a Tempo Leech, the Metronome
Guardian, and the Static Baron at their correct relative scales. Add a small
palette strip, one office carpet tile, a cubicle prop, a Kazoo Pistol icon, a
mint XP note, a groove-gold hit spark, and one UI card corner. Low top-down
three-quarter perspective throughout. Separate every element with transparent
space. No labels and no text.
```

#### P02 — Joe turnaround reference

```text
Create Joe, an original tired office worker hero in his late thirties: rumpled
paper-ivory shirt, loosened muted-purple tie, dark trousers, practical brown
shoes, short warm-brown hair, light stubble, determined but weary expression,
small golden kazoo held like a ridiculous heroic sidearm. Produce four static
64x64 reference sprites facing down, up, left and right. Keep clothing,
proportions and handedness consistent. Joe must read as an ordinary office
worker, not a soldier, celebrity, rock star or fantasy warrior.
```

#### P03 — enemy family scale reference

```text
Create a transparent lineup of nine original music-disruption enemies in a
shared pixel-art family: Monotone, Tempo Leech, Feedback Bee, Paper Jammer,
Deadline Drummer, Noise Auditor, Syncopation Brute, Metronome Guardian and
Static Baron. Show front-facing neutral poses at correct gameplay scale: small
swarmer, standard enemies, elites, 96x96 miniboss and 128x128 final boss.
Emphasize nine unmistakably different silhouettes. Office materials should
become monsters through static, cables, paper, speakers and broken rhythm.
```

### 8.2 Joe and allies

#### P04 — Joe idle

```text
Joe in a subtle four-frame idle loop facing {DIRECTION}: tired breathing, slight
shoulder slump, loosened tie settling, kazoo kept ready. On the fourth frame his
foot taps once as if remembering the beat. 64x64 cells, four frames.
```

#### P05 — Joe run

```text
Joe in an energetic eight-frame run cycle facing {DIRECTION}: clear contact,
down, passing and lift poses, office shoes and tie with restrained secondary
motion, kazoo held safely forward, determined posture. No sliding feet or body
size change. 64x64 cells, eight frames.
```

#### P06 — Joe hit

```text
Joe taking a readable non-gory hit facing {DIRECTION}: two-frame recoil followed
by two-frame recovery, shoulders twist, tie flicks, one coral edge accent, kazoo
remains in hand. Preserve floor contact and silhouette. 64x64 cells, four
frames.
```

#### P07 — Joe defeated

```text
Joe in an eight-frame non-gory defeat animation: staggers, drops to one knee,
gold notes fade, tie falls still, then sits exhausted beside the kazoo. Somber
but comic, no corpse detail, no text. 64x64 cells, eight frames, south-facing.
```

#### P08 — Joe victory

```text
Joe in an eight-frame victory loop: disbelief, small smile, raises the kazoo,
plays one triumphant note, tie and gold note particles bounce on the beat.
Earnest and slightly awkward, not a rock-star pose. 64x64 cells, eight frames,
south-facing.
```

#### P09 — Joe groove idle

```text
Joe in a four-frame powered groove idle facing {DIRECTION}: posture opens,
shoulders loosen, foot taps, kazoo catches a gold highlight, a restrained pulse
travels through the tie on the final frame. Keep gameplay silhouette identical
to normal Joe. 64x64 cells, four frames.
```

#### P10 — Joe portrait set

```text
Create six original 96x96 pixel-art bust portraits of Joe with exactly the same
face, hair, stubble, shirt and purple tie: neutral tired, worried, determined,
surprised by magic, fully grooving, relieved victory. Three-quarter portrait
view, transparent background, strong expression at small scale, no text.
```

#### P11 — Wizard of Groove

```text
Create the Wizard of Groove as an original small floating mentor: enormous
soft-brimmed bruise-purple wizard hat covered in simple groove-gold notes,
mostly shadowed face with kind mint eyes, tiny ivory gloves, trailing cable-like
robe hem. Whimsical rather than grand. Provide 64x64 south-facing key poses for
idle hover, welcoming gesture, pointing, magical appearance and magical vanish.
No resemblance to an existing wizard character.
```

#### P12 — Nia expansion character

```text
Create Nia, an original late-shift office sound engineer and future playable
character: dark skin, compact natural curls, teal headphones, charcoal office
jumpsuit with rolled sleeves, utility belt carrying audio adapters, confident
calm stance, small feedback tuner in hand. Four static 64x64 directional
reference sprites, low top-down view, practical contemporary design, no brand
logos.
```

#### P13 — Omar expansion character

```text
Create Omar, an original office percussionist and future playable character:
olive skin, salt-and-pepper beard, burgundy cardigan over a pale shirt, dark
slacks, two improvised drumsticks made from pens, warm sturdy silhouette.
Four static 64x64 directional reference sprites, low top-down view, no
celebrity resemblance.
```

### 8.3 Enemies

#### P14 — Monotone

```text
Create Monotone, the common chaser: a hunched grey cubicle wraith in a repetitive
shirt and tie, compact speaker grille for a blank face, stapler-like hands,
paperwork trailing from its back, rigid square shoulders. The silhouette should
communicate slow relentless pursuit. Generate a six-frame walk cycle facing
{DIRECTION}, 64x64 cells.
```

#### P15 — Monotone death

```text
Monotone eight-frame death animation: its speaker face loses signal, rigid body
breaks into paper rectangles and two small static blocks, tie lands last. No
gore, no explosion fire, readable at 1x scale. 64x64 cells, eight frames.
```

#### P16 — Tempo Leech

```text
Create Tempo Leech, a fast zigzag enemy: an orange cassette-tape parasite with a
speaker-mouth, two tiny office-chair caster legs, magnetic reel eyes and a long
black cable tail drawing an S-curve. Generate a six-frame hovering scuttle cycle
facing {DIRECTION}; the cable alternates sides to sell zigzag motion. 64x64
cells.
```

#### P17 — Tempo Leech dash

```text
Tempo Leech four-frame dash animation facing {DIRECTION}: compress, cable coils,
sharp orange launch, stretched final pose with two blocky afterimages. Keep the
body readable and the hit footprint visually stable. 64x64 cells, four frames.
```

#### P18 — Feedback Bee

```text
Create Feedback Bee, a tiny swarm enemy made from a broken office headset:
earcups form the wings, microphone boom becomes a stinger, tiny speaker body,
cyan static eyes, jagged magenta buzz marks. Six-frame directional flight loop,
64x64 cells with a visible body no larger than 24x24 pixels.
```

#### P19 — Paper Jammer

```text
Create Paper Jammer, a possessed desktop printer ranged enemy: squat ivory and
grey office printer body, cable legs, magenta warning eye, paper tray as a mouth,
one jagged sheet loaded like a projectile. Generate a six-frame rolling walk
cycle facing {DIRECTION}, then a separate six-frame firing strip that pulls in,
jams, and spits a sharp paper note. 64x64 cells.
```

#### P20 — Deadline Drummer

```text
Create Deadline Drummer, a tank enemy: hulking hunched body built from a wall
calendar, time clock and padded office chair, round drum-clock belly, two heavy
stamp hands, torn red deadline tabs. Eight-frame walk cycle facing {DIRECTION},
slow weighty contact and visible anticipation. 64x64 cells.
```

#### P21 — Deadline Drummer slam

```text
Deadline Drummer eight-frame ground slam: raises both stamp hands, drum-clock
belly flashes coral, impacts the floor, releases one blocky circular paper-and-
sound shock ring, then recovers. South-facing, 96x96 cells to contain the effect.
```

#### P22 — Noise Auditor

```text
Create Noise Auditor, an elite floating bureaucratic spectre: narrow charcoal
suit, featureless receipt-paper face, clipboard shaped like a waveform shield,
mint audit stamps, trailing black cables instead of legs. Six-frame float loop
facing {DIRECTION}, 64x64 cells. It must read as a support enemy, not a melee
brute.
```

#### P23 — Noise Auditor shield

```text
Noise Auditor eight-frame shield cast: checks clipboard, stamps once, unfolds a
large translucent rectangular waveform barrier with alternating mint blocks and
dark gaps, then holds it. South-facing, 96x96 cells, clear anticipation.
```

#### P24 — Syncopation Brute

```text
Create Syncopation Brute, an elite disruptor: broken rolling office chair fused
with a squat bass cabinet, asymmetrical speaker shoulders, one long arm and one
short arm, purple upholstery torn by gold waveform seams. Eight-frame heavy
walk cycle facing {DIRECTION}, 96x96 cells.
```

#### P25 — Metronome Guardian

```text
Create Metronome Guardian, the miniboss: tall clockwork night security guard,
brass metronome pendulum visible in the chest, purple peaked cap without logos,
speaker pauldrons, baton-like arms, heavy polished shoes. Original design. Six-
frame idle march and eight-frame directional walk, 96x96 cells. The pendulum
must remain the visual focus.
```

#### P26 — Metronome Guardian charge

```text
Metronome Guardian six-frame charge facing {DIRECTION}: pendulum slows at one
side, body crouches, chest flashes gold, then launches in a rigid straight line
with two geometric beat afterimages. 96x96 cells, strong anticipation, stable
feet pivot.
```

#### P27 — Static Baron

```text
Create Static Baron, original final boss: a floating executive broadcast tower,
torn charcoal suit forming a broad triangular silhouette, vintage CRT monitor
head filled with magenta static, aerials forming an uneven crown, cable
tentacles, gold cuff links, one paper-white gloved hand. Menacing but darkly
comic, no resemblance to a real executive or existing character. Create a
south-facing 128x128 neutral key sprite.
```

#### P28 — Static Baron idle

```text
Static Baron eight-frame idle loop: floats heavily, CRT static crawls in blocky
bands, aerial crown twitches, cable tentacles lag, one cuff link catches a gold
beat. 128x128 cells, no body resizing.
```

#### P29 — Static Baron radial burst

```text
Static Baron ten-frame radial attack: aerial crown folds inward, CRT becomes one
bright magenta line, cables pull tight, then eight original static wedges burst
out on a circular rhythm before fading. 192x192 cells, readable telegraph before
damage, no continuous full-screen white flash.
```

#### P30 — Static Baron broadcast beam

```text
Static Baron ten-frame beam cast: turns CRT head toward target, narrow gold
scanline telegraph appears first, screen blooms magenta, then emits a straight
blocky broadcast beam with broken scanline edges. Separate boss and beam layers,
transparent background, 128x128 boss cells plus a tileable 64x64 beam segment.
```

#### P31 — Static Baron death

```text
Static Baron sixteen-frame defeat: crown aerials snap, CRT cycles through simple
abstract static patterns, cables unwind, suit collapses into paper and dark
blocks, final gold note rises from the dead screen. Non-gory, triumphant,
128x128 cells.
```

### 8.4 Weapons, projectiles, and evolutions

#### P32 — core weapon icon set

```text
Create a cohesive set of five 32x32 transparent inventory icons: Kazoo Pistol,
Bass Drop, Cymbal Slicer, Feedback Loop and Drone Tambourine. Each uses one
strong silhouette, one-pixel outline, no text, no hands, consistent upper-left
lighting and scale. Kazoo is gold and playful; Bass is indigo and heavy; Cymbal
is thin gold and sharp; Feedback is cyan-magenta and looping; Drone is purple
with tiny tambourine jingles.
```

#### P33 — Kazoo Pistol projectile family

```text
Create the Kazoo Pistol attack family on transparent background: one 16x16
buzzing gold eighth-note projectile facing right with two purple vibration
pixels; a four-frame 24x24 muzzle puff shaped like compressed air; a five-frame
32x32 gold-and-purple note impact. Hard pixels and restrained glow.
```

#### P34 — Bass Drop projectile family

```text
Create the Bass Drop attack family: a 24x24 heavy indigo bass clef fragment
projectile with a square pressure halo; a four-frame thick trailing wave; an
eight-frame 64x64 ground impact expanding as two low circular rings with tiny
office dust pixels. It must feel slow, heavy and piercing.
```

#### P35 — Cymbal Slicer projectile family

```text
Create the Cymbal Slicer attack family: 16x16 thin spinning brass disc with one
notch for rotation readability, eight rotation frames; five-frame 24x24 cutting
spark with gold and paper-ivory arcs; one faded expire frame. No saw teeth.
```

#### P36 — Feedback Loop projectile family

```text
Create the Feedback Loop attack family: 16x16 cyan pulse node with magenta
centre, four-frame oscillation; tileable 16x8 waveform trail segment; six-frame
32x32 impact that curls back into itself. It must read as controlled electronic
feedback, not lightning.
```

#### P37 — Drone Tambourine

```text
Create a 32x32 orbiting Drone Tambourine: compact purple office-tech drone with
a gold tambourine ring, four small jingles, single cyan lens, no propeller.
Provide eight-frame idle rotation, six-frame strike animation and four-frame
damaged flicker, all in 48x48 cells.
```

#### P38 — Kazoo Studio evolution

```text
Create Brass Barrage, the Studio Kazoo evolution: precise gold three-horn emblem
in a 32x32 icon; three distinct 16x16 brass note projectiles aligned as a clean
fan; six-frame cyan-and-gold piercing impact. Symmetrical, engineered, polished,
no text.
```

#### P39 — Kazoo Live evolution

```text
Create Improvised Solo, the Live Kazoo evolution: asymmetrical bent gold kazoo
wrapped by a magenta waveform in a 32x32 icon; two varied 16x16 note projectiles
with different silhouettes; six-frame orange-magenta volatile impact. Lively
but still readable.
```

#### P40 — Bass Studio and Live evolutions

```text
Create two related 32x32 evolution icons and attack families. Studio:
Subwoofer Stack, aligned indigo speaker blocks with gold level meters and a
precise square pressure wave. Live: Earthquake Encore, tilted bass cabinet,
cracked groove-gold floor line and an irregular circular shockwave. Keep both
clearly descended from Bass Drop without sharing the same silhouette.
```

#### P41 — Cymbal Studio and Live evolutions

```text
Create two related 32x32 evolution icons and attack families. Studio: Precision
Hi-Hats, paired thin brass discs with cyan timing ticks and crossing measured
cuts. Live: Golden Crash, one oversized battered gold cymbal with magenta rim
and a broad flare impact. Original instrument designs, no brand marks.
```

#### P42 — Feedback Studio and Live evolutions

```text
Create two related 32x32 evolution icons and attack families. Studio: Clean
Signal, a perfect cyan sine loop passing through three gold nodes and a precise
beam. Live: Wall of Noise, layered magenta and orange waveforms forming a wide
distortion wall with controlled holes for readability. No radio or software
logos.
```

#### P43 — Drone Studio and Live evolutions

```text
Create two related 32x32 evolution icons and orbiting units. Studio: Rhythm
Satellite, one symmetrical purple-and-gold engineered satellite with cyan
lock-on ring. Live: Percussion Swarm, three small mismatched hand-percussion
drones—tambourine, shaker and woodblock—with a loose magenta orbit. No real
product designs.
```

#### P44 — reserve weapon icon set

```text
Create three optional 32x32 transparent weapon icons in the same family: Power
Chord, an abstract guitar-neck lightning chord; Snare Scatter, a compact snare
with five outward note pellets; Mic Drop, a hanging microphone above a gold
target ring. Original silhouettes, no brand marks and no text.
```

### 8.5 Pickups and passives

#### P45 — passive icon set

```text
Create five cohesive 32x32 passive icons on transparent background: Quickstep,
an office shoe with two gold rhythm ticks; Encore, a raised hand and heart under
a spotlight; Breath Control, calm profile with circular breath waveform; Sound
Check, headphones enclosing a purple shield; Stage Presence, a widening gold
spotlight around a figure. No text, strong silhouette, distinct shapes.
```

#### P46 — XP note tiers

```text
Create three mint XP pickups at increasing value: small single crystalline
eighth note in 16x16; medium paired notes in 24x24; large chord cluster in
32x32. Use the same mint core and ivory highlight, distinct silhouettes and
sizes, four-frame gentle pulse for each, transparent background.
```

#### P47 — rewards and recovery

```text
Create four 32x32 pickup icons: groove-gold square-edged coin with an abstract
note mark and no currency symbol; paper coffee cup with heart-shaped coral
steam; purple-and-gold Resolve token resembling a stamped vinyl record but with
no label; compact equipment reward case with pulsing gold latch. Transparent,
no text.
```

#### P48 — reroll and skip

```text
Create two 32x32 UI action icons: reroll shown as cassette tape becoming two
circular arrows; skip shown as an exit arrow bending into an eighth note. Use
gold and lavender, no text, no familiar platform or application logo.
```

### 8.6 Arena and props

#### P49 — seamless office carpet

```text
Create eight separate seamless 128x128 top-down office carpet tiles in a dark
ink-purple palette: clean low-pile carpet; subtle seam; old coffee ring; two
loose paper scraps; cable crossing; square ventilation grate; scuffed rolling-
chair path; faint groove-gold magical crack. Low contrast so combat sprites stay
readable. Edges must tile perfectly. No perspective walls and no lighting
gradient across the tile.
```

#### P50 — office prop atlas

```text
Create a transparent top-down pixel-art prop atlas with separate objects and
consistent scale: office chair, waste bin, file box, paper stack, coffee mug,
keyboard, monitor, desk phone without branding, potted plant, cable coil, sticky
notes and small speaker. Each object fits a 32x32 or 64x64 cell and has a clear
floor footprint.
```

#### P51 — office landmark atlas

```text
Create separate top-down office landmark props: four-desk cubicle cluster,
meeting table with six chairs, reception desk, photocopier, vending machine
without brands or readable labels, server rack, break-room counter and damaged
speaker stack. 64x64 or 128x128 cells, transparent background, consistent
upper-left lighting.
```

#### P52 — groove contamination atlas

```text
Create a transparent atlas of magical office contamination: purple acoustic-foam
growth, gold cable roots shaped like waveforms, floating blocky notes,
oscillating desk lamp, possessed speaker cone, paper spiral, static crack and
small wizard portal residue. Each asset fits 32x32 or 64x64 and remains low
contrast outside its bright accent.
```

#### P53 — arena wall and boundary tiles

```text
Create a modular top-down office boundary tileset on a 32x32 grid: straight wall
segments, inner corners, outer corners, door opening, glass partition, damaged
section, cable conduit and purple magical barrier overlay. All connections must
tile, with a solid dark collision edge and subtle gold beat accent only on the
barrier.
```

#### P54 — wizard portal landmark

```text
Create a 128x128 top-down Wizard of Groove portal embedded in an office floor:
soft collapsed purple hat shape forming the rim, three original gold notes
orbiting, mint inner darkness, nearby papers lifting slightly. Provide eight
animation frames for idle pulse, transparent outside the circular footprint.
```

#### P55 — boss stage landmark

```text
Create a 256x128 top-down boss-stage environment prop: improvised office
broadcast platform built from meeting tables, server racks, cables and speakers,
with a central dark CRT dais and worn purple carpet. No text, logos or readable
signage. Keep the combat centre uncluttered.
```

### 8.7 UI

#### P56 — logo exploration

```text
Create three original pixel-art Groove Bound logo symbols with no lettering:
the established floppy bruise-purple wizard hat plus groove-gold notes, a cable
loop forming a portal, and one subtle office tie detail. Produce horizontal,
square and tiny-icon compositions on transparent background. Do not imitate any
existing fantasy franchise logo.
```

#### P57 — UI nine-slice kit

```text
Create a cohesive pixel UI construction kit on transparent background: dark ink
panel with purple bevel, gold-focused border, lavender normal border, disabled
grey border, small tooltip, square icon socket, and three button states. Use
16-pixel corners suitable for nine-slice scaling. Hard pixels, no text, minimal
decoration.
```

#### P58 — level-up card frames

```text
Create eight transparent 160x220 pixel card frames sharing one layout: weapon,
passive, weapon upgrade, passive upgrade, evolution, locked, Studio branch and
Live branch. Leave clear empty areas for runtime text and a 64x64 icon. Studio
uses precise gold/cyan corners; Live uses asymmetric magenta/orange corners.
No baked-in text or numbers.
```

#### P59 — HUD frame set

```text
Create a modular pixel HUD frame set with empty interiors: health bar with heart
notch, guard bar with shield notch, mint XP bar, gold-purple groove meter, boss
health frame, four weapon sockets and four passive sockets. Transparent
background, compact enough for 1280x720, no labels or numbers.
```

#### P60 — status stat icons

```text
Create nine 16x16 monochrome-readable stat icons: damage, movement speed,
cooldown, pierce, area, duration, pickup radius, guard and maximum health.
Use ivory silhouette plus one category accent. Each must be distinct when
converted to greyscale. No text.
```

#### P61 — targeting and danger indicators

```text
Create a transparent set of gameplay indicators: 24x24 player locator arrow,
32x32 target reticle, 24x24 off-screen standard enemy arrow, 32x32 boss arrow,
48x48 circular danger marker, 64x32 line telegraph cap and 64x64 area telegraph
ring. Use shape animation and dashed timing, not colour alone.
```

#### P62 — victory and defeat vignettes

```text
Create two separate 320x180 pixel-art screen vignettes without text. Victory:
Joe in the after-hours office raising the kazoo as gold notes relight the room
and the Wizard hat floats behind him. Defeat: Joe seated exhausted beside the
kazoo while magenta static creeps over dark monitors. Same Joe design, restrained
composition with space for runtime headings.
```

### 8.8 VFX

#### P63 — hit and death effects

```text
Create a transparent VFX sheet containing: generic five-frame 32x32 hit spark;
eight-frame 64x64 paper burst; eight-frame 64x64 cassette-tape unravel; eight-
frame 64x64 static block dissolve; eight-frame 64x64 brass-note burst. Each
effect starts small, reaches one clear peak, then fully disappears.
```

#### P64 — XP and level-up effects

```text
Create a six-frame 32x32 mint XP pickup effect that contracts into the centre,
and a ten-frame 96x96 level-up effect with one rising gold ring, three tiny
notes and a brief purple star. No text, no continuous flashing, transparent.
```

#### P65 — groove beat pulse

```text
Create an eight-frame 128x128 transparent groove beat pulse: a thin gold ring
expands exactly once, four small purple ticks mark quarter directions, opacity
falls cleanly, centre remains unobstructed. Provide a reduced-flash variant using
only outline thickness and no bright centre.
```

#### P66 — Studio evolution

```text
Create a sixteen-frame 128x128 Studio evolution effect: small cyan nodes snap to
a precise grid, gold lines assemble a clean instrument silhouette, one aligned
ring confirms completion, then particles settle. Geometric, reliable and calm;
transparent background and no text.
```

#### P67 — Live evolution

```text
Create a sixteen-frame 128x128 Live evolution effect: magenta and orange notes
enter off-beat, spiral around the centre, improvise into a new instrument
silhouette, then burst into three uneven gold arcs. Energetic but readable;
transparent and no full-frame flash.
```

#### P68 — boss telegraph set

```text
Create four transparent eight-frame boss telegraphs: circular radial pulse,
60-degree cone, straight scanline and targeted floor marker. Each begins dark
purple, gains a gold timing edge, and turns magenta only on the final dangerous
frame. Include a colour-blind-safe variant using thicker edges and interior
hatching.
```

#### P69 — Static Baron attack VFX

```text
Create a transparent Static Baron VFX atlas: 32x32 static bolt with six frames,
tileable 64x64 broadcast beam middle segment with four frames, 96x96 radial
interference wedge with eight frames, and 64x64 falling-channel target impact
with ten frames. Jagged scanline shapes, magenta and cyan accents, hard pixels.
```

#### P70 — environment ambience

```text
Create four subtle transparent ambient loops: six-frame paper drift, four-frame
monitor flicker, eight-frame dust mote cluster and six-frame tiny note firefly.
Each fits 64x64, uses very low visual weight, and must not resemble a projectile
or pickup.
```

## 9. Acceptance criteria

### Visual

- Every ordinary enemy has a unique silhouette at 1× native scale.
- Standard enemy, elite, miniboss, and boss scale are obvious without labels.
- Each weapon’s projectile and impact can be identified in a still frame.
- Studio and Live evolutions remain visibly related to their base weapon but
  are distinguishable from each other.
- The player remains readable above the arena at all times.
- No gameplay-critical state relies only on hue.
- The arena has at least three navigational landmarks visible during a run.
- UI remains readable at 1280×720 and the target minimum text scale.

### Technical

- PNG with alpha; nearest-neighbour rendering.
- Exact documented cell dimensions and frame counts.
- No stray pixels outside cells.
- No semi-transparent edge pixels on opaque gameplay sprites.
- Pivots move by no more than one native pixel across a cycle.
- Animation loops do not pop at the final-to-first transition.
- Atlas dimensions stay within LÖVE/platform texture limits.
- A crowded test with 300 enemies and 150 projectiles remains readable and
  satisfies the game’s performance gate.
- Reduced-flash mode has approved alternatives for level-up, groove, evolution,
  damage, and boss telegraphs.

### Provenance

For every imported or generated asset, record:

- stable asset ID;
- filename and destination;
- source URL or generation service;
- author/vendor;
- license/terms URL and captured copy;
- download or generation date;
- original archive filename and SHA-256;
- whether commercial use, modification, attribution, and redistribution are
  permitted;
- prompt, model/tool version, seed, and reference inputs for generated work;
- human cleanup notes;
- approval state: reference, prototype, production candidate, approved, or
  rejected.

## 10. Phased visual roadmap

### Phase V0 — lock the visual contract

- Approve “after-hours office occult.”
- Approve palette, native sizes, perspective, outline, lighting, and animation
  rules.
- Decide whether Joe’s current visible proportions remain or are redrawn.
- Create the asset register before importing anything.

**Exit:** one approved style board and a crowded-screen readability mockup.

### Phase V1 — no-cost prototype

- Download only the approved CC0 shortlist.
- Preserve untouched originals and license evidence.
- Build one office arena composition.
- Replace enemy recolours with five temporary silhouettes.
- Add temporary music icons, card frames, input prompts, and three VFX families.

**Exit:** the running game looks intentionally composed even though signature
art remains temporary.

### Phase V2 — generated signature probe

- Run prompts P01–P03, P14, P16, P33, P49, P58, and P68 as a bounded test.
- Measure rejection rate, cleanup minutes per frame, directional consistency,
  and in-game readability.
- Choose the generation tool only after comparing actual cleaned outputs.

**Exit:** one approved Joe reference, two approved enemy cycles, one complete
weapon attack family, one tile, one card, and one telegraph.

### Phase V3 — current-content production pass

- Joe full animation and portraits.
- Monotone, Tempo Leech, Metronome Guardian, Static Baron.
- Four current weapons and both Kazoo evolutions.
- Three current passives, rewards, pickups.
- Core arena, HUD, level-up, title, results, and current combat VFX.

**Exit:** every implemented content ID has final or approved production-candidate
art; no shared enemy recolour remains.

### Phase V4 — vertical-slice variety

- Add Feedback Bee, Paper Jammer, Deadline Drummer.
- Add Noise Auditor and Syncopation Brute.
- Add Drone Tambourine and its two evolutions.
- Add remaining Studio/Live evolution families.
- Add Wizard narrative sprites and environmental landmarks.

**Exit:** five ordinary enemies, two elites, one miniboss, one boss, five base
weapons, five passives, and ten branch evolutions are visually complete.

### Phase V5 — polished demo

- Add reserve weapons, optional second boss, additional characters, meta shop,
  alternate stage, accessibility variants, and promotional/key art.
- Conduct a final asset-license audit.
- Remove all unapproved prototypes and donor art from the shipping package.

**Exit:** every shipped asset is approved, provenance-recorded, readable under
load, and consistent with the Groove Bound house style.

## 11. Approval gates

User approval is required before:

- downloading or importing external assets;
- generating any visual asset;
- training or fine-tuning on existing project art;
- approving new character/enemy/weapon names as game canon;
- replacing current first-party legacy art;
- using any asset with custom, attribution, share-alike, or unclear terms;
- publishing screenshots or builds containing prototype donor art.

