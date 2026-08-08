<p align="center">
  <img src="docs/assets/groove-bound-campaign-banner.png" alt="Groove Bound — Joe and Lyra defend Backbeat Streets and the cosmic Orbit Line from music-powered robot invaders" width="100%">
</p>

<p align="center">
  <strong>Restore rhythm to the universe.</strong><br>
  A bright urban-supernatural survival roguelike built with LÖVE.
</p>

<p align="center">
  <a href="https://github.com/raoniai/groovebound-2026/releases/latest/download/groove-bound.love">
    <img src="https://img.shields.io/badge/DOWNLOAD-LATEST%20BUILD-F2BF32?style=for-the-badge&logo=github&logoColor=111111" alt="Download the latest Groove Bound build">
  </a>
  <a href="https://github.com/raoniai/groovebound-2026/actions/workflows/ci.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/raoniai/groovebound-2026/ci.yml?branch=main&style=for-the-badge&label=BUILD" alt="Build status">
  </a>
  <img src="https://img.shields.io/badge/L%C3%96VE-11.5-EA316E?style=for-the-badge&logo=love&logoColor=white" alt="LÖVE 11.5">
  <img src="https://img.shields.io/badge/TESTS-241%20PASSING-19D3C5?style=for-the-badge" alt="241 tests passing">
</p>

<p align="center">
  <a href="#the-campaign">Campaign</a> ·
  <a href="#choose-your-resonant">Characters</a> ·
  <a href="#two-stages-one-build">Stages</a> ·
  <a href="#build-your-set">Arsenal</a> ·
  <a href="#download-and-play">Play</a> ·
  <a href="#development-reference">Development</a>
</p>

> [!IMPORTANT]
> This README describes the current **two-stage narrative campaign development
> preview**. The downloadable release may trail the source branch until the
> preview is merged and released. The platform-neutral
> `.love` package requires [LÖVE 11.5](https://love2d.org/).

---

## The campaign

Backbeat is a city where music is infrastructure. Rooftop venues, train lines,
street lights, and the defensive Pulse Tower all share a living network called
the Resonance.

Then the sky misses a beat.

A cosmic chord plays backwards through every connected speaker. Instrument
machines descend into the city, sampling its music and assembling an alien
orchestra. Joe and Lyra Vex answer the downbeat, break open the Static Baron,
and recover a strange record called the **First Press**. Its song is also a
map—one that leads beneath Backbeat to the abandoned Orbit Line.

<p align="center">
  <img src="groove-bound/assets/generated/cutscenes/prologue-atlas.png" alt="Four illustrated panels showing Backbeat before and during the Break" width="49%">
  <img src="groove-bound/assets/generated/cutscenes/campaign-atlas.png" alt="Four illustrated panels showing the First Press, Orbit Line, and Grand Conductor signal" width="49%">
</p>

The playable flow is now:

**Title → Prologue → Character Selection → Character Intro → Backbeat Streets
→ Inter-stage Cutscene → The Orbit Line → Campaign Ending**

The supplied prologue and Joe-intro videos now play directly in the campaign,
mapped by filename. Clicking a playing video pauses or resumes it; when it ends,
its final frame holds behind Next and Replay actions. Every video scene retains
its illustrated storyboard as an automatic fallback.

Read the complete [first-draft canon](groove-bound/docs/FIRST_DRAFT_CANON.md).

---

## Choose your Resonant

<p align="center">
  <img src="groove-bound/assets/generated/campaign/character-portraits-atlas.png" alt="Joe and Lyra Vex character-selection portraits" width="82%">
</p>

| | Joe — The Backbeat | Lyra Vex — The Live Wire |
|---|---|---|
| Style | Durable street guardian | Fast cosmic rock adventurer |
| Starting weapon | Kazoo Pistol | Keytar Chord |
| Signature trait | **Hold the Line** — starts with 18 Guard and stronger knockback | **Stage Dive** — moves and fires faster and earns more Resonance XP |
| Strengths | Vitality, power, defense | Speed, tempo, resonance |
| Trade-off | Slower firing tempo | Lower vitality and defense |

Both characters have four-direction idle, walk, high-speed run, and hurt/action
states. Walking now uses dedicated motion frames; sufficiently large speed
upgrades visibly switch the selected hero into their faster run cycle.

<p align="center">
  <img src="groove-bound/assets/generated/campaign/joe-action-sheet.png" alt="Joe directional idle, walk, run, and hurt animation sheet" width="49%">
  <img src="groove-bound/assets/generated/campaign/lyra-action-sheet.png" alt="Lyra directional idle, walk, run, and hurt animation sheet" width="49%">
</p>

---

## Two stages, one build

Your complete weapon and support build carries forward between stages. Clearing
Backbeat restores part of your health, grants temporary Guard, and moves
directly into the illustrated Orbit Line transition.

### Stage 1 — Backbeat Streets

A supernatural concert district grounded by a subtle urban-grime floor, filled
with speaker stacks, service equipment,
road cases, light trusses, and the original invasion horde. Survive the
Metronome Guardian and bring down the Static Baron to recover the First Press.

### Stage 2 — The Orbit Line

A distinct cosmic transit arena with cosmic dust and embedded crystal detail,
energy rails,
alien speaker pylons, sealed gates, turntable consoles, orbital structures,
and an escalating instrument-machine orchestra.

<p align="center">
  <img src="groove-bound/assets/generated/environment-atlas.png" alt="Backbeat Streets environment props" width="49%">
  <img src="groove-bound/assets/generated/campaign/stage2-environment-atlas.png" alt="Orbit Line alien transit environment props" width="49%">
</p>

### Face two enemy families

<p align="center">
  <img src="groove-bound/assets/generated/enemy-variants-atlas.png" alt="Backbeat Streets enemy roster including the Metronome Guardian and Static Baron" width="49%">
  <img src="groove-bound/assets/generated/campaign/stage2-enemies-atlas.png" alt="Orbit Line enemy roster including the Turntable Sentinel and Grand Orchestrator" width="49%">
</p>

The Orbit Line introduces four normal enemies, two elites, a midboss, and a
megazord-scale final boss:

- Vinyl Drone, Trumpet Ray, Drum Wheel, and Theremin Jelly;
- elite Amp Hound and Keyboard Centipede;
- Turntable Sentinel midboss;
- Grand Orchestrator final boss.

Enemy behaviours now include chase, zigzag, charge, orbit, ranged note bolts,
resonance pulses, attack windups, contact attacks, and boss pressure patterns.
Difficulty increases naturally within each stage and rises again in Stage 2.

Both stages default to three minutes. Admin controls can independently set either
stage from 60 to 1,200 seconds and scale the campaign difficulty ramp.

---

## Build your set

Movement is manual; equipped instruments auto-target and fire. Every run is a
compact build-crafting puzzle:

1. Move, dodge, and control space.
2. Collect XP gems and trigger paused level-up choices.
3. Add weapons, raise ranks, equip supports, or take recovery and currency.
4. Build up to six active weapons and four supports.
5. Find a rare musical chest to fuse a ready rank-10 weapon and support recipe.
6. Carry the completed build into the Orbit Line and finish the campaign.

### 16 base weapons

Brass bursts, bass shockwaves, cymbal blades, feedback loops, drum pulses,
trumpet cones, vinyl sparks, synth waves, triangle tracers, cello lances,
orbiting maracas, tuning forks, keytar chords, bells, cassette echoes, and
laser-harp beams span seven firing behaviours.

<p align="center">
  <img src="groove-bound/assets/generated/weapon-icons-atlas.png" alt="First eight Groove Bound base weapon icons" width="49%">
  <img src="groove-bound/assets/generated/weapon-icons-atlas-2.png" alt="Second eight Groove Bound base weapon icons" width="49%">
</p>

### 8 supports · 8 legendary fusions

Supports strengthen the live build and complete evolution recipes. Level-up
cards cannot evolve weapons: a rare musical chest rolls one, three, or five
automatic legal rewards and prioritizes any ready fusions. A fusion consumes
both ingredients, replaces the exact firing emitter, and reopens support and
weapon capacity.

<p align="center">
  <img src="groove-bound/assets/generated/support-icons-atlas.png" alt="Eight Groove Bound support item icons" width="49%">
  <img src="groove-bound/assets/generated/evolved-weapon-icons-atlas.png" alt="Eight legendary fused weapon icons" width="49%">
</p>

See the complete [Weapon Database](groove-bound/docs/WEAPON_DATABASE.md) and
[Evolution Guide](groove-bound/docs/WEAPON_EVOLUTION.md).

---

## Combat now reads like combat

Each base and evolved weapon now uses a related projectile silhouette rather
than sharing one recoloured bullet. Enemies flash when hit, receive directional
knockback, and burst into animated death effects. Contact attacks, note bolts,
and resonance pulses trigger player hurt frames, damage flashes, recoil,
screen shake, and optional controller vibration.

<p align="center">
  <img src="groove-bound/assets/generated/campaign/projectile-atlas.png" alt="Twenty-four weapon-specific Groove Bound projectile designs" width="59%">
  <img src="groove-bound/assets/generated/campaign/combat-fx-atlas.png" alt="Hit sparks, explosions, death flicker, and damage-response effects" width="39%">
</p>

The active HUD presents health, Guard, XP, stage progress, countdown, complete
weapon and support racks, boss health, score, combo, and campaign notices with a
larger, clearer information hierarchy. `Tab` hides or restores the debug
overlay at any time.

---

## Download and play

### 1. Install LÖVE

Download **LÖVE 11.5** for macOS, Windows, or Linux from
[love2d.org](https://love2d.org/).

### 2. Download Groove Bound

<p>
  <a href="https://github.com/raoniai/groovebound-2026/releases/latest/download/groove-bound.love">
    <img src="https://img.shields.io/badge/Download-groove--bound.love-19D3C5?style=for-the-badge" alt="Download groove-bound.love">
  </a>
  <a href="https://github.com/raoniai/groovebound-2026/releases/latest">
    <img src="https://img.shields.io/badge/View-release%20notes-6F42C1?style=for-the-badge" alt="View the latest release notes">
  </a>
</p>

### 3. Launch it

| Platform | How to launch |
|---|---|
| macOS | Open LÖVE, then drag `groove-bound.love` onto the LÖVE application. |
| Windows | Double-click `groove-bound.love`, or drag it onto `love.exe`. |
| Linux | Run `love groove-bound.love` from a terminal. |

### Controls

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | `WASD` or arrow keys | Left stick |
| Confirm / choose | `Enter` or `Space` | `A` |
| Pause / resume | `Esc` or `P` | `Start` |
| Back / cancel | `Esc` | `B` |
| Navigate menus | Arrow keys | D-pad |
| Open Admin Controls | `F1` | Available from title/pause menus |
| Toggle debug overlay | `Tab` | — |

The Options screen includes persistent volume, feedback, fullscreen, aim
assist, deadzone, and conflict-checked keyboard rebinding controls.

---

## Current preview

<p align="center">
  <img src="groove-bound/assets/generated/campaign/app-icon.png" alt="Groove Bound gold vinyl-speaker cosmic application icon" width="144">
</p>

| System | Current build |
|---|---|
| Campaign | Filename-mapped videos with illustrated fallbacks across the two-stage story |
| Run structure | Two three-minute stages with build carryover and partial recovery |
| Characters | Joe and Lyra Vex with different stats, traits, weapons, and animation states |
| Arsenal | 16 base weapons, seven firing patterns, six weapon slots |
| Build crafting | Eight supports, four support slots, eight rank-10 fusion recipes |
| Stage 2 roster | Four normal enemies, two elites, one midboss, and one final boss |
| Combat feedback | Unique projectiles, hit sparks, explosions, death flicker, knockback, hurt reactions |
| Progression | Four XP-gem tiers, magnetized consumables, randomized level-up cards, and chest-only fusions |
| Interface | Larger type, clearer hierarchy, campaign HUD, Arsenal Database, Admin dashboard |
| Input | Keyboard, mouse, and gamepad menus with persistent options |
| Validation | 241 headless tests, Luacheck, content validation, package checks, video playback smoke, and CI boot smoke |

### Admin testing controls

The segmented Admin dashboard includes:

- independent Stage 1 and Stage 2 duration;
- difficulty escalation, player speed, invincibility, damage, fire rate,
  knockback, enemy speed/damage/density, XP, and pickup tuning;
- Grant Level, Prepare Evolution, Spawn Boss, and Clear Stage tools;
- an explicit toggle-gated rank-1 evolution shortcut for testing only.

Normal progression still requires a rank-10 weapon and its matching support.
See the [Admin Controls guide](groove-bound/docs/ADMIN_CONTROLS.md).

---

## Development reference

Run from source:

```sh
git clone https://github.com/raoniai/groovebound-2026.git
cd groovebound-2026/groove-bound
make run
```

Verification:

```sh
make test
make lint
make package
```

Project code lives in [`groove-bound/`](groove-bound/). The
[gameplay README](groove-bound/README.md) documents runtime architecture,
developer controls, and implementation ground rules.

### Lore, systems, and visual provenance

- [First-Draft Canon](groove-bound/docs/FIRST_DRAFT_CANON.md)
- [Weapon Database](groove-bound/docs/WEAPON_DATABASE.md)
- [Weapon Evolution Guide](groove-bound/docs/WEAPON_EVOLUTION.md)
- [Admin Controls](groove-bound/docs/ADMIN_CONTROLS.md)
- [Generated Visual Asset Register](groove-bound/assets/generated/PROVENANCE.md)
- [Stage 2 Visual Prompt Set](groove-bound/docs/STAGE2_VISUAL_PROMPTS.md)
- [Legacy Asset Register](groove-bound/assets/legacy/PROVENANCE.md)
- [Visual Research and Generation Plan](VISUAL_ASSET_RESEARCH_AND_GENERATION_PLAN.md)
- [Remake Execution Plan](REMAKE_EXECUTION_PLAN.md)

The first-draft campaign is deliberately structured so supplied video and
proper source audio can replace the current placeholders without rewriting the
campaign state. The next planned layers are canon and balance refinement,
cinematic video/audio, and the BeatClock groove system.

Bug reports and build feedback can be filed through
[GitHub Issues](https://github.com/raoniai/groovebound-2026/issues).
