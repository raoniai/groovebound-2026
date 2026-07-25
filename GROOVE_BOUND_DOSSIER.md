# Groove Bound — Full Project Dossier

**Status date:** 26 July 2026 (Australia/Sydney)  
**Scope searched:** local workspace, connected GitHub account, connected Dropbox, live Groove Bound web page and downloadable build  
**Project language/runtime:** Lua on LÖVE (Love2D)  
**Assessment type:** source-grounded project reconstruction and current-state audit  

---

## 1. Executive assessment

Groove Bound is a musically themed survival roguelike/top-down shooter that has passed through three distinct implementation eras:

1. **The original playable game** in `raoniai/004_GrooveBound`, developed rapidly in April 2025 and publicly distributed as a macOS app.
2. **Two experimental rewrites** collected in `raoniai/Groove-Bound-Prototype-1`, developed from late April to early May 2025.
3. **A clean architectural remake**, started in a draft pull request in July 2026. This is the newest and strongest engineering direction, but it currently implements only foundation and player movement—not a complete game.

The most important conclusion is:

> **Groove Bound has a playable but obsolete public build, an original source tree with broader gameplay but unresolved bugs, and a much cleaner 2026 remake that is only at the movement-slice stage and has not been merged.**

There is no single canonical working copy today:

- The local workspace is empty.
- The original repository contains the broadest playable feature set.
- The prototype repository's `main` branch contains abandoned/experimental rewrites.
- The newest remake exists only inside draft PR #2 on a remote feature branch.
- Dropbox is the richest source-art and working-audio archive, but not a code repository.
- The public download is three original-repository commits behind the original source HEAD and roughly fourteen months behind the remake effort.

### Current status at a glance

| Area | Evidence-backed status | Assessment |
|---|---|---|
| Local workspace | Empty Git repository; no commits, files, or remote | **Not usable** |
| Original game source | 59 commits; broad playable systems; last commit 27 Apr 2025 | **Legacy playable source** |
| Original public build | Live and downloadable; exact game content matches commit `365e774` | **Public-live but obsolete** |
| Public devlog | Live; exactly matches repository HTML; stops at `6d1e538` | **Stale/incomplete** |
| Prototype 1 | Large dependency-based rewrite with duplicated legacy tree | **Reference only** |
| Prototype 2 | Dependency-free rewrite with known correctness and lifecycle bugs | **Abandoned/reference only** |
| 2025 visual-fix PR | Draft PR #1 against Prototype 2 | **Obsolete unless old prototype is revived** |
| 2026 clean remake | Draft PR #2; foundation + movement; 100 unit tests in passing CI | **Best canonical candidate, not merged** |
| Combat in clean remake | Not implemented | **Phase 2 pending** |
| Full run/progression | Not implemented in clean remake | **Phase 3 pending** |
| Musical/groove layer | Not implemented in clean remake or proven in legacy build | **Phase 4 pending** |
| Dropbox art/audio | 270 entries, ~274 MiB; editable art, sprite pack, Audition sessions | **Valuable source archive; needs provenance and curation** |
| Release engineering | Old unsigned/generic macOS bundle; no current releases/tags | **Not release-ready** |

### Overall project health

| Dimension | Rating | Why |
|---|---:|---|
| Concept and identity | Strong | Clear musical-survivor premise, distinctive Joe/wizard/pixel-art identity |
| Existing gameplay proof | Moderate | Original project demonstrates many systems, but quality and correctness are uneven |
| Current architecture | Promising | Clean remake directly addresses prior lifecycle, determinism, data, and scale failures |
| Current playable completeness | Low | Clean remake has movement only |
| Test maturity | Moderate for foundation | 100 unit tests and green CI, but lint is advisory and there is no automated LÖVE boot test |
| Content readiness | Early | Starter content schemas exist; production content and balancing remain ahead |
| Musical differentiator | Very early | Core promise is designed but not implemented |
| Asset readiness | Mixed | Many source assets exist, but licensing/provenance and integration status are unclear |
| Release readiness | Low | No current tagged build, unsigned obsolete public app, no current packaging pipeline |
| Canonical-source clarity | Low | Four competing representations and no populated local working tree |

---

## 2. Source inventory and authority

### 2.1 Local workspace

**Path:** `/Users/raonilima/Documents/Groove Bound`

The directory was an initialized but completely empty Git repository:

- Branch: `main`
- Commits: none
- Tracked project files: none
- Configured project remote: none found
- Size: approximately 88 KiB, consisting only of `.git`

This means the local directory is a placeholder, not a clone or authoritative source. No current code was available locally before this dossier was written.

### 2.2 GitHub repositories

Two matching repositories were found in the connected `raoniai` GitHub account:

1. [`raoniai/004_GrooveBound`](https://github.com/raoniai/004_GrooveBound)
2. [`raoniai/Groove-Bound-Prototype-1`](https://github.com/raoniai/Groove-Bound-Prototype-1)

Both are public and unarchived. Neither has a formal GitHub release or tag. Neither has an explicit license file.

### 2.3 Dropbox project archive

**Folder:** `RAOLATRO/GAMES/004 GrooveBound`  
**Open:** [Groove Bound in Dropbox](https://www.dropbox.com/home/RAOLATRO/GAMES/004%20GrooveBound)

The Dropbox folder is primarily an editable art, generated/reference visual, test, and working-audio archive. It contains no Lua source tree and is not a replacement for the Git repositories.

### 2.4 Public web distribution

- [Live Groove Bound devlog](https://raoni.studio/games/groovebound/)
- [Live downloadable ZIP](https://raoni.studio/games/groovebound/download/GrooveBound.zip)

Both endpoints returned successfully during this audit. Their presence proves a public legacy artifact exists, but does not establish current development status.

### 2.5 Recommended source classification

| Source | Recommended classification |
|---|---|
| PR #2 branch, `groove-bound/` directory | **Canonical candidate** |
| `Groove-Bound-Prototype-1` main, Prototype 1 | Reference/obsolete prototype |
| `Groove-Bound-Prototype-1` main, Prototype 2 | Reference/obsolete prototype |
| Draft PR #1 | Reference-only patch for obsolete Prototype 2 |
| `004_GrooveBound` source | Legacy playable reference |
| Live downloadable app | Frozen public legacy artifact |
| Dropbox editable art/audio | Source-material archive |
| Dropbox imported/generated packs | Reference/licensing-review material |
| Empty local Git repository | Placeholder |

No source should be declared canonical merely because it is public or on `main`. The newest intended architecture is currently off-main in draft PR #2.

---

## 3. Project identity and creative proposition

### 3.1 Genre

Groove Bound is designed as a:

- Vampire Survivors-style survival roguelike;
- top-down arena shooter;
- auto-fire and movement-driven action game;
- musical/rhythm-inflected combat experience;
- run-based progression game built in Lua with LÖVE.

The original project sometimes describes itself more generally as a rhythm-based top-down shooter. The remake plan sharpens the product category into a survival roguelike with musical systems layered into combat, enemy choreography, rewards, and presentation.

### 3.2 Premise

The remake plan frames the protagonist as **Joe**, a burned-out office worker chosen by the **Wizard of Groove** to restore rhythm across a universe whose musical energy has been disrupted.

This premise is already reflected in surviving visual assets:

- Joe appears as a pixel-art office worker.
- The game icon is a purple wizard hat with gold musical notes.
- The game-over art depicts the office-worker hero with a guitar and the line: “GAME OVER! You do not have the GROOVE!”
- Floor assets establish a dark, littered, urban/office-adjacent arena tone.

The combination of ordinary office-worker protagonist, magical musical calling, and deliberately playful pixel-art language is one of the clearest pieces of distinctive project identity.

### 3.3 Intended player fantasy

The intended fantasy is not simply “shoot enemies to music.” It is:

- regain momentum and personal groove;
- become increasingly expressive and powerful during a run;
- use music-themed weapons and passive upgrades;
- time or sustain actions in relation to a beat;
- survive choreographed waves;
- confront personifications of monotony, static, and discord;
- leave a run with visible progression, results, and future meta rewards.

### 3.4 Intended core loop

The documented target loop is:

1. Select a character.
2. Enter an arena.
3. Move and position while weapons fire automatically.
4. Survive escalating enemy waves.
5. Collect XP gems and coins.
6. Level up and choose one of three cards.
7. Add or improve weapons and passives.
8. Build synergies across a limited loadout.
9. Face a timed boss.
10. Win or lose the run.
11. Review results and rewards.
12. Spend future meta currency or unlock characters/content.

The clean remake currently implements only the title-to-arena transition, movement, aim direction, pause, camera, and a minimal HUD. It does not yet execute the larger loop.

### 3.5 Musical differentiator

The planned differentiator includes:

- beat-synchronised weapon behavior;
- on-beat bonuses;
- a groove meter;
- arena and UI pulses;
- beat-choreographed enemies;
- musically structured bosses;
- reactive sound and feedback;
- potentially evolving musical intensity as the run develops.

This is central to the concept but remains a design promise. The original README explicitly describes a beat-sync bonus as not working. The clean remake schedules the formal groove layer for Phase 4.

---

## 4. Full development chronology

### Era A — Original game, April 2025

Repository: [`004_GrooveBound`](https://github.com/raoniai/004_GrooveBound)

The original game was built in an intense six-day period:

### 22 April 2025 — Foundation

- Clean project start.
- Initial LÖVE configuration.
- Early beat-checking experiment.
- Core settings and bootstrap work.

### 23 April 2025 — First playable combat

- Player movement.
- Mouse aim and shooting.
- Auto-fire behavior.
- Scoring and combo concepts.
- Health/hearts.
- Game-over flow.
- Loot.
- Enemy waves and miniboss logic.
- HUD and inventory.
- Multiple weapon forms, including drones and area effects.

### 24 April 2025 — Run progression and presentation

- Pause menu.
- Dynamic weapon levels.
- Popup/notification system.
- Loot pickup behavior.
- Arena/scenario and floor treatment.
- XP and level-up mechanics.
- Camera and art improvements.
- Custom cursor and projectile sprites.

### 25 April 2025 — Shop, sprites, and scaling

- Expanded sprite use.
- Shop system.
- Loot scaling.
- Enemy health bars.
- Multiple loot drops.
- Additional balancing and UI work.

### 26 April 2025 — Audio and refactoring

- SFX integration.
- Shop and level-up refactors.
- Shared menu-template direction.
- Power-up data and UI work.
- Boss-stat rebalancing.
- Several commit messages still describe bugs or incomplete adjustments.

### 27 April 2025 — Last original source commit

Final commit:

`2525c4d` — “Weapons correctly added to inventory after purchase. Game working, need to install the new power up logic (next task)”

The commit message is important. It says the game was working at that moment, but it also explicitly records the next unresolved implementation: the new power-up logic.

The previous commit stated:

`670de92` — “Reposition menu UI elements and enable projectile sounds. Still buggy and needs adjustments.”

Therefore the original branch ended as a broad, playable experiment—not a finished, verified release.

### Era B — Prototype rewrites, April–May 2025

Repository: [`Groove-Bound-Prototype-1`](https://github.com/raoniai/Groove-Bound-Prototype-1)

Development resumed on 29 April 2025 with a more structured rewrite.

### Prototype 1

Prototype 1 used common Lua/LÖVE libraries:

- HUMP;
- windfield;
- anim8.

It explored:

- movement and arena bounds;
- hit areas and debug rendering;
- aim/control configuration;
- weapon and level UI;
- enemies and XP;
- damage and game-over;
- gamepad focus;
- shop and level-up systems.

The codebase grew large and accumulated duplication. A complete `src_legacy` copy remains beside the active source tree.

### Prototype 2

Prototype 2 moved toward a dependency-free architecture. Its commit history describes a staged framework and playable combat attempt, with recurring notes such as:

- XP “buggy”;
- game-over bugs;
- shop bugs;
- level-up refactor bugs;
- combat bugs.

It contains some useful structural ideas, but the later 2026 audit identifies nineteen specific correctness bugs and approximately twenty-five structural issues. It should not be resumed unchanged.

The last `main` commit is:

`de3d5b8`, dated 5 May 2025.

There was then no recorded GitHub development in these repositories until draft pull requests appeared later.

### Era C — Visual patch for old Prototype 2, June 2025

Draft PR: [#1 — Enhance visuals & responsive UI](https://github.com/raoniai/Groove-Bound-Prototype-1/pull/1)

Created 21 June 2025, this patch:

- makes bullets circular;
- represents the player as a triangle;
- corrects the inverted weapon-inventory limit condition;
- improves the level-up modal's responsiveness.

It contains 65 additions and 32 deletions across a small set of old Prototype 2 files.

It remains open and draft. It has no substantive automated test evidence. If the clean remake is adopted, this PR should be closed or explicitly labelled reference-only because it patches an architecture the remake intends to replace.

### Era D — Clean remake, July 2026

Draft PR: [#2 — Remake: audit + plan, Phase 0 (core plumbing), Phase 1 (movement slice)](https://github.com/raoniai/Groove-Bound-Prototype-1/pull/2)

The remake branch contains three commits:

1. `ea52d98` — audit and remake plan;
2. `a364ce0` — Phase 0 clean scaffold and 59 tests;
3. `fe79d6f` — Phase 1 movement slice and 41 additional tests.

The branch was last updated 3 July 2026. As of 26 July 2026:

- the PR is still open;
- the PR is still a draft;
- it is reported mergeable;
- no reviewer is assigned;
- it is not merged into `main`;
- no later Git commit was found;
- Git activity has therefore been idle for 23 days.

This is the newest known work and the best candidate for the future game, but its status is **reviewable development branch**, not **current released game**.

---

## 5. Original game repository dossier

### 5.1 Repository metrics

| Metric | Value |
|---|---:|
| Commits | 59 |
| Active branches | 1 (`main`) |
| Tags | 0 |
| GitHub releases | 0 |
| Pull requests | 0 |
| Issues | 0 |
| Tracked files | 121 |
| Lua files | 32 |
| Approximate Lua lines | 7,253 |
| Repository working-tree size | ~7.8 MiB |
| Development period | 22–27 Apr 2025 |

### 5.2 Runtime and entry points

- `main.lua` — application bootstrap and principal update/draw flow.
- `conf.lua` — LÖVE configuration.
- `settings.lua` — game-wide settings and tuning.
- `paths.lua` — path constants and asset routing.

### 5.3 Principal modules

The `scripts/` directory contains modules covering:

- player;
- enemies;
- weapons;
- beat checking;
- camera;
- collision;
- debug display;
- game-over state;
- gamepad handling;
- HUD;
- inventory;
- level statistics;
- level-up menu;
- loot;
- shared menu templates;
- pause menu;
- popups;
- power-ups;
- scenario/arena;
- scoring;
- sound effects;
- shop;
- sprites;
- sprite registry.

Data files include:

- `data/items.lua`;
- `data/powerups.lua`.

This is a modular file layout around a still fairly procedural, tightly coupled game loop. It represents rapid feature construction rather than a stable production architecture.

### 5.4 Configured behavior

The surviving configuration includes:

- window resolution settings;
- BPM and beat-check parameters;
- player speed and hit points;
- thirty XP levels;
- loot and boss scaling;
- power-up rarity weights;
- weapons and progression behavior.

Some settings and historical commit notes disagree—for example, the repository includes a 1920×1080 setting while prior commits refer to a fixed 1280×720 window. This is evidence of configuration drift, not multiple supported release profiles.

### 5.5 Implemented or attempted systems

The original game contains or attempts:

- player movement and aiming;
- mouse and gamepad handling;
- manual/automatic projectile firing;
- projectile sound;
- scoring and combo behavior;
- health and heart display;
- enemy waves;
- minibosses;
- wave/boss announcements;
- multiple weapon types;
- drones and orbiting weapon behavior;
- area attacks;
- weapon levelling;
- inventory;
- loot drops and pickup;
- pickup radius options;
- XP and level-up;
- shop purchasing;
- power-up data and menus;
- popup notifications;
- pause menu;
- game-over state;
- scenario/floor rendering;
- custom cursor;
- sprite registration;
- sound effects.

The existence of code for a feature does not mean it is production-complete. Several of these systems were still being refactored or described as buggy in the last commits.

### 5.6 Original README claims versus evidence

The README presents:

- WASD/arrow movement;
- mouse aim;
- click or automatic fire;
- pause via Escape;
- combo and scoring;
- health;
- waves and minibosses;
- weapon variety;
- loot and XP;
- game-over state;
- visual and audio assets;
- dynamic settings;
- beat-sync bonus.

The README itself notes that the beat-sync bonus is not working. This matters because musical interaction is the product's defining promise.

### 5.7 Technical-debt indicators

- No test suite.
- No CI workflow.
- No license.
- No `.gitignore`.
- `.DS_Store` files are committed.
- `powerup.lua.bak` is committed.
- A packaged `.love` file was once committed and later deleted.
- No release tags.
- No release notes.
- HTML page calls the game `v1.0.0` without a corresponding version tag.
- Commit messages disclose unresolved menu, popup, and power-up problems.
- Broad systems were added faster than they were isolated and verified.

### 5.8 What should be retained from it

The original repository is valuable as:

- a playable proof that the concept can be embodied in LÖVE;
- a behavioral reference for weapon feel;
- a source for pixel art and exported SFX;
- a catalog of UX ideas;
- a source of tuning experiments;
- a regression reference when rebuilding features.

It should not be used as the production foundation without a costly stabilization effort that would duplicate much of the clean remake's purpose.

---

## 6. Prototype repository dossier

### 6.1 Repository structure

The repository contains two materially different games:

```text
Groove-Bound-Prototype-1/
├── PROTOTYPE 1/
│   ├── source using HUMP, windfield and anim8
│   └── duplicated src_legacy tree
├── PROTOTYPE 2/
│   ├── groovebound/
│   └── committed love.app runtime
└── later branches and pull requests
```

This structure makes the `main` branch an archive of experiments, not a clean current project.

### 6.2 Approximate code size

| Area | Approximate Lua size |
|---|---:|
| Prototype 1 active source, excluding vendored libraries and legacy duplicate | 10,818 lines / 38 files |
| Prototype 1 `src` | 10,067 lines |
| Prototype 1 `src_legacy` duplicate | 9,611 lines |
| Vendored libraries | 4,741 lines |
| Prototype 2 | 6,018 lines / 36 files |

Prototype 1 is larger than the original game but size reflects dependencies, duplication, and experimentation—not proportional product maturity.

### 6.3 Repository hygiene issues

- No `.gitignore` on `main`.
- Committed `.DS_Store`.
- A 24 MiB `love.app` runtime committed under Prototype 2.
- Spaces and nested product versions in paths.
- `debug_output.txt` records `love command not found`.
- No test suite on `main`.
- No CI on `main`.
- No license.
- No tagged builds or releases.
- Documentation overstates some system readiness.
- Two prototypes remain side by side without an authoritative selection.

### 6.4 Prototype 1 assessment

Prototype 1 demonstrates serious exploration of:

- library-backed state and physics;
- collisions;
- animation;
- weapons;
- input;
- UI;
- XP/progression.

Its main weaknesses are:

- unnecessary physics complexity for survivor-scale combat;
- large dependency surface;
- duplicated source;
- unclear ownership;
- difficult restart and lifecycle behavior;
- poor suitability for hundreds of lightweight entities.

The remake plan recommends retaining patterns and knowledge, not the implementation.

### 6.5 Prototype 2 assessment

Prototype 2 was a more focused dependency-free rewrite. It contributes useful ideas:

- state organization;
- event usage;
- settings separation;
- grid concepts;
- debug tools;
- data-driven weapons/waves/passives.

However, its actual content loading, listener lifecycle, progression ownership, and combat correctness are not reliable. It is best treated as a source of requirements and regression cases.

---

## 7. Legacy Prototype 2 bug register

The 2026 audit identifies nineteen specific defects. They are central to understanding why a clean remake was chosen.

| ID | Defect | Consequence |
|---|---|---|
| B1 | Weapon inventory condition is inverted | Valid additions can be rejected while invalid/full states may be allowed |
| B2 | Enemy emits `xpValue` but run reads `xp` | XP gems fall back to value 1 |
| B3 | Two XP-award paths exist | XP may be applied twice |
| B4 | Two separate level-up triggers exist | Multiple level-up modals can open |
| B5 | Code calls nonexistent `getAvailableUpgrades`; implementation is `getUpgradeOptions` | Runtime failure in upgrade flow |
| B6 | Event listeners are registered every run and never removed | Restart leaks and duplicate behavior |
| B7 | Upgrade matching uses display-name substrings; “Speed Up” does nothing | Fragile, incorrect progression |
| B8 | Hard-coded modal options bypass offer, rarity, and slot logic | Data model and actual game diverge |
| B9 | Enemy, wave, and passive data files are never required | Authored content is dead data |
| B10 | Enemy constructor ignores enemy type | All enemies behave as the same basic type |
| B11 | Spawner ends after 60 seconds with no boss/end transition | Runs cannot resolve correctly |
| B12 | Misleading iframe-related comment | Documentation obscures actual behavior |
| B13 | Duplicate/dead knockback calculation | Confusing and potentially inconsistent damage behavior |
| B14 | Fonts are constructed during every draw | Avoidable per-frame allocation and performance cost |
| B15 | Input pause flag is unreachable | Intended pause logic cannot execute |
| B16 | Competing/invalid error handlers exist | Unreliable crash reporting and failure behavior |
| B17 | `math.random` is called with floats | Runtime-crash risk |
| B18 | State stacks and listeners leak when quitting to title | Repeated runs accumulate stale state |
| B19 | XP only crosses one threshold while configurations disagree | Multi-level gains and progression become incorrect |

### Structural issues behind the bugs

The audit also records broader failure patterns:

- no stable content IDs;
- ownership split across player, run, UI, and singleton modules;
- ambient global/singleton state;
- module tables reused as state instances;
- no event-listener scope or cleanup model;
- hard-coded upgrade UI;
- authored data not loaded;
- dead and duplicate code;
- potentially quadratic collision work;
- per-frame allocations;
- inconsistent `require` paths that can instantiate a module twice;
- debug `print` spam;
- multiple pause booleans;
- old LÖVE runtime assumptions;
- no seeded randomness policy;
- documentation drift.

The clean remake's architecture maps directly to these failure modes.

---

## 8. Clean remake: intended architecture

### 8.1 Guiding principles

The remake plan specifies:

- stable IDs instead of display-name matching;
- a per-run `RunContext`;
- explicit system ownership;
- instance-based states;
- lifecycle-scoped event subscriptions;
- object pooling;
- uniform-grid spatial hashing;
- deterministic seeded random streams;
- fail-loud content validation;
- separated content and tuning settings;
- no ambient globals;
- no hidden cross-system side effects;
- automated regression coverage for previously observed bugs.

### 8.2 Intended runtime structure

The architecture separates:

- app/bootstrap;
- state stack;
- run lifetime;
- world/entities;
- gameplay systems;
- content registry;
- presentation/UI;
- save/config;
- debugging/logging;
- tests.

Conceptually:

```text
Application
├── State machine
│   ├── Title
│   ├── Run
│   ├── Pause
│   └── Results
├── RunContext
│   ├── deterministic clocks
│   ├── named RNG streams
│   ├── scoped event bus
│   ├── world
│   └── run statistics
├── World
│   ├── entity pools
│   ├── spatial hash
│   ├── collision/damage
│   ├── enemies and spawner
│   ├── weapons/projectiles
│   └── pickups
├── Content
│   ├── characters
│   ├── weapons
│   ├── enemies
│   ├── passives
│   └── waves
└── Platform
    ├── input
    ├── save/migrations
    ├── logging
    └── automated checks
```

### 8.3 Why this direction is credible

The remake is not only a theoretical plan. Foundation classes and tests already exist for the most important lifecycle concerns:

- event listener removal;
- once-only listeners;
- state transitions;
- scheduler behavior;
- deterministic random streams;
- corrupted-save fallback;
- save migration;
- content cross-reference validation;
- object-pool reuse;
- spatial lookup;
- camera bounds and shake;
- input dead zones;
- pause-safe run time;
- run-context reset.

This provides a credible base. It does not yet prove combat feel, musical feel, survivor-scale performance, or complete-run stability.

---

## 9. Clean remake: what is actually implemented

### 9.1 Code and test metrics

| Metric | Value |
|---|---:|
| Directory | `groove-bound/` |
| Total Lua files | 52 |
| Approximate production source, excluding tests/libraries | 2,302 lines |
| Approximate tests | 1,284 lines |
| Total code/docs/Makefile footprint | ~3,860 lines |
| Test functions | 100 |
| CI result | Passed |
| Merge status | Open, draft, mergeable |

### 9.2 Phase 0 — Foundation

Implemented:

- small class helper;
- scoped event bus with `on`, `off`, and `once`;
- instance-based stack state machine;
- scheduler;
- seeded named random-number streams;
- ring-buffer logger;
- JSON encoding/decoding;
- save loading and writing;
- save-version migration support;
- invalid/corrupt-save fallback;
- content-schema validation;
- cross-reference validation;
- title screen;
- Makefile;
- `.gitignore`;
- GitHub Actions workflow;
- 59 foundation tests.

### 9.3 Phase 1 — Movement slice

Implemented:

- object pool;
- uniform-grid spatial hash;
- `RunContext`;
- world container;
- arena bounds;
- camera with clamping, smoothing, and trauma-based shake;
- keyboard input;
- mouse input;
- gamepad input and dead zones;
- movement-only player;
- player aim indicator;
- title-to-run transition;
- pause modal;
- return-to-title behavior;
- minimal HUD;
- debug hitboxes on F3;
- 41 additional tests.

### 9.4 Current playable flow

The current remake flow is:

1. Launch.
2. See title screen.
3. Select Play.
4. Enter arena.
5. Move the player.
6. Aim.
7. Observe camera and HUD.
8. Pause/resume.
9. Quit to title.

The player is represented as a circle with an aim indicator. The HUD exposes HP, run time, and debug information such as FPS, entity count, and seed.

### 9.5 What is not implemented

The clean remake currently has no:

- enemy behavior;
- enemy spawning;
- projectile combat;
- weapon firing;
- damage system in active play;
- player death;
- XP drops;
- XP levelling;
- coins;
- level-up cards;
- weapon slots;
- passive slots;
- upgrade choices;
- loot collection;
- boss;
- win state;
- loss/results state;
- run rewards;
- save-driven options UI;
- audio;
- music;
- beat clock;
- groove meter;
- musical bonuses;
- production sprites;
- particle/VFX pass;
- meta progression;
- release packaging.

This is why “movement slice” is the correct current-stage description.

### 9.6 Authored but inactive content

The branch already contains validated content definitions for:

- Joe as a character;
- starter weapon `kazoo_pistol`, with three levels;
- enemy `Monotone`;
- enemy `Tempo Leech`;
- passive `Quickstep`;
- passive `Encore`;
- four wave entries extending to 45 seconds.

These definitions prove the content schema and validation path, but the gameplay systems do not yet consume them. They are not currently playable content.

### 9.7 Test breakdown

| Test family | Tests |
|---|---:|
| Class helper | 3 |
| Event bus | 7 |
| State machine | 7 |
| Scheduler | 5 |
| RNG | 8 |
| Save behavior | 6 |
| JSON | 7 |
| Logger | 5 |
| Content validation | 11 |
| Object pool | 3 |
| Spatial hash | 10 |
| Arena | 4 |
| Camera | 7 |
| Input | 11 |
| RunContext | 6 |
| **Total** | **100** |

### 9.8 Verification limits

The GitHub Actions run completed successfully. That is solid evidence that the test command passed in CI.

However:

- the workflow runs `luacheck` with `|| true`, so lint failures do not fail CI;
- green CI therefore does not prove lint cleanliness;
- the workflow does not boot LÖVE automatically;
- the PR body reports a manual LÖVE 11.5 boot, but that was not independently reproduced in this audit;
- the current Codex environment had no `lua`, `luajit`, `love`, or `luacheck` executable;
- the 100 tests could be counted and inspected but not rerun locally;
- no automated rendering, resize, or controller smoke test exists;
- no performance capture demonstrates the Phase 1 feel/performance exit criteria.

The correct status is **unit CI passed; runtime acceptance only partially evidenced**.

### 9.9 Phase 1 acceptance gaps

The plan's broader definition of done asks for:

- clean lint;
- repeatable run lifecycle;
- no inline gameplay tunables;
- event registry;
- regression tests;
- architecture/design documentation;
- tagged build;
- playtest notes.

Not all of those are present.

Specific remaining gaps include:

- draft/unmerged PR;
- advisory lint;
- no LÖVE boot smoke test in CI;
- no tagged Phase 1 build;
- no license;
- no `.editorconfig`;
- no `docs/design.md`;
- no `docs/architecture.md`;
- no content-authoring guide;
- no event registry document;
- no automated simulation tests;
- no recorded performance benchmark;
- no current playtest note;
- some inline UI layout constants;
- no resize handler on the run screen, although title/pause perform relayout.

---

## 10. Planned content and gameplay systems

### 10.1 Launch weapon concepts

The remake plan proposes:

| Weapon | Intended role |
|---|---|
| Kazoo Pistol | Starter sidearm |
| Power Chord | Straight-line attack |
| Bass Drop | Area-of-effect attack |
| Drone Tambourine | Orbiting weapon |
| Snare Scatter | Spread attack |

The target is four active weapon slots and up to ten weapon levels.

### 10.2 Enemy concepts

Early enemy concepts include:

- Static Sprites / Monotones;
- Feedback Bees / Tempo Leeches;
- additional music-disruption archetypes;
- boss candidates such as Feedback Fiend or Static Baron.

The clean remake data currently includes Monotone and Tempo Leech, but no enemy behavior is connected.

### 10.3 Progression

Planned run progression includes:

- XP gems;
- coins;
- three-card level-up choices;
- weapons;
- weapon upgrades;
- passives;
- reroll;
- skip;
- limited slots;
- future evolutions/synergies;
- results and currency persistence;
- future meta shop and additional characters.

### 10.4 Boss and narrative direction

An older master concept referenced recognizable musicians such as Bob Marley, Snoop Dogg, Michael Jackson, and Jimi Hendrix, as well as an “Eternal Stratocaster.”

The remake plan correctly flags:

- right-of-publicity risk;
- trademark risk;
- music-licensing risk;
- dependence on celebrity resemblance or association.

It proposes original antagonists and mythology instead, including names such as:

- Static Baron;
- Maestro Monotone;
- DJ Discord.

This original-IP direction should be treated as the production path unless explicit legal clearance is obtained.

---

## 11. Planned roadmap and actual stage

The remake plan estimates twelve to fifteen working weeks from a clean start to a polished demo. This is a planning estimate written on 3 July 2026, not a verified schedule.

### Phase 0 — Foundation

**Plan estimate:** ~1 week  
**Current implementation:** substantially built in draft PR #2  
**Status:** **Code complete enough for review; not merged; definition-of-done gaps remain**

Deliverables:

- app/state foundation;
- event lifecycle;
- scheduler;
- deterministic RNG;
- logging;
- save/migration;
- validation;
- tests and CI.

### Phase 1 — Movement slice

**Plan estimate:** ~1 week  
**Current implementation:** substantially built in draft PR #2  
**Status:** **Development complete in branch; runtime acceptance incomplete; not merged**

Deliverables:

- movement;
- input parity;
- arena;
- camera;
- pause;
- HUD;
- pooling and spatial hash;
- debug tools.

### Phase 2 — Combat

**Plan estimate:** 1–2 weeks  
**Current implementation:** not started in clean remake  
**Status:** **Next planned development phase**

Planned deliverables:

- weapon runtime;
- projectile pools;
- enemy runtime;
- spawn director;
- collision;
- damage;
- death;
- XP drops;
- survivor-scale performance.

### Phase 3 — Progression and full-run vertical slice

**Plan estimate:** ~2 weeks  
**Current implementation:** not started  
**Status:** **Pending**

Planned deliverables:

- XP and coins;
- level-up cards;
- passives;
- four weapons;
- boss;
- win/lose/results;
- save and options;
- complete repeatable run.

The plan estimates a vertical slice around four to five working weeks from a clean start. Since development stopped after Phase 1 and no verified velocity exists, this should not be converted into a calendar commitment without replanning.

### Phase 4 — Groove layer

**Plan estimate:** ~2 weeks  
**Current implementation:** not started  
**Status:** **Pending and concept-critical**

Planned deliverables:

- BeatClock;
- track integration;
- on-beat effects;
- groove meter;
- reactive arena/UI;
- musical enemy and boss behavior.

This is the phase where Groove Bound becomes meaningfully different from a generic survivor clone.

### Phase 5 — Content and balance

**Plan estimate:** 2–3 weeks  
**Current implementation:** not started  
**Status:** **Pending**

Targets:

- eight enemies;
- eight weapons;
- ten-minute run;
- second boss;
- evolutions;
- tuning and balance.

### Phase 6 — Meta progression and polish

**Plan estimate:** 2–3 weeks  
**Current implementation:** not started  
**Status:** **Pending**

Targets:

- meta shop;
- additional characters;
- effects;
- accessibility;
- quality and usability polish.

### Phase 7 — Release engineering

**Plan estimate:** 1–2 weeks  
**Current implementation:** not started  
**Status:** **Pending**

Targets:

- multi-platform CI bundles;
- crash reporting;
- final performance pass;
- legal review;
- packaged version `0.1.0` demo.

---

## 12. Art and visual production dossier

### 12.1 Established visual language

The original game uses:

- low-resolution pixel-art characters;
- dark, textured floor tiles;
- playful music-related icons and effects;
- high-contrast projectiles;
- cartoonish fantasy elements;
- an office-worker hero;
- a purple wizard/music-note brand icon.

This is a viable visual foundation. The identity is clearer when it combines drab office life with exaggerated musical fantasy than when it resembles a generic neon rhythm game.

### 12.2 Dropbox inventory

The project Dropbox folder contains:

| Measure | Value |
|---|---:|
| Total entries | 270 |
| Files | 245 |
| Folders | 25 |
| Total size | 287,678,027 bytes (~274.35 MiB) |

Top-level groups:

| Group | Files | Approximate size | Date span |
|---|---:|---:|---|
| `Graphics` | 204 | 78,037,506 bytes | Apr 2024–Apr 2025 |
| `_Tests` | 22 | 186,083,757 bytes | Apr 22–28 2025 |
| `SFX Working` | 19 | 23,556,764 bytes | Apr–Sep 2025 |

### 12.3 File types

| Extension | Count | Bytes | Likely use |
|---|---:|---:|---|
| PNG | 196 | 50,366,127 | Sprites, effects, tests, exports |
| GIF | 16 | 9,495,838 | Animation previews |
| SESX | 15 | 1,326,268 | Adobe Audition sessions/backups |
| PSD | 7 | 48,581,229 | Editable source art |
| JPG | 4 | 352,176 | Tests/reference |
| WAV | 3 | 177,069,004 | Raw/working audio |
| PKF | 2 | 471,572 | Audition peak files |
| WEBP | 1 | 8,690 | Image asset |
| ASEPRITE | 1 | 7,123 | Editable Joe sprite |

### 12.4 Editable graphics

Notable editable files:

- `weapons-sprite.psd` — 2,442,780 bytes;
- `floor-tiles1.psd` — 5,188,645 bytes;
- `drone1-sprite.psd` — 140,862 bytes;
- `Joe-v1.aseprite` — 7,123 bytes;
- `target-projectile.psd` — 48,611 bytes;
- `hp.psd` — 1,002,724 bytes;
- `gameover.psd` — 12,948,455 bytes;
- `man1-sprite.psd` — 26,809,152 bytes.

These are valuable because they preserve editability beyond the exported PNGs committed to Git.

### 12.5 Effects sprite collection

`Explosions and Powers Sprites` contains:

- 196 files;
- approximately 29,449,154 bytes;
- Parts 1–15;
- each part has twelve PNG frames and one GIF preview;
- a root-level `Free Preview All.gif`.

The structure and “Free Preview” naming suggest an imported third-party effects pack. No license or provenance file was found in the project folder. Before any public release, the team should record:

- source URL;
- author/vendor;
- purchased/free tier;
- permitted commercial use;
- redistribution rules;
- attribution requirements;
- whether the actual production frames—not only previews—are licensed.

Until resolved, these assets should be classified as **license-review required**, not assumed production-safe.

### 12.6 Test and generated visual material

The `_Tests` folder includes:

- screenshots and visual experiments;
- photo/reference tests;
- two long prompt-named generated images of a “boring office guy”;
- a very large raw audio file despite the folder name.

Generated and reference material should be separated from approved production art. Prompt-named images are useful provenance evidence but should not be mistaken for final authored sprites.

---

## 13. Audio dossier

### 13.1 Original repository exports

The original Git repository contains nineteen OGG SFX exports, including:

- seven coin sounds;
- four death sounds;
- three projectile sounds;
- level-up sound;
- weapon pickup/upgrade sounds.

The music directory has no actual music track—only placeholder/system files. Therefore the original game has SFX work but no source-grounded evidence of an integrated soundtrack.

### 13.2 Dropbox Audition work

#### GrooveBound SFX session

- 13 files;
- 21,784,572 bytes;
- Adobe Audition 25.2;
- created/worked on around 26 April 2025;
- Track 1–6, Mix, session backups;
- source file `POD00020 44100 1.wav`, approximately 20.3 MiB.

This aligns closely with the SFX integration commits in the original repository.

#### Untitled Session 1

- 6 files;
- 1,772,192 bytes;
- Adobe Audition 25.3;
- last activity 4 September 2025;
- Track 1–6, Mix, Metronome;
- source `PatGPT second Read Trim-esv2-60p-bg-0p 44100 1.wav`, approximately 1.435 MiB.

This is the latest project-related artifact found in Dropbox, several months after code development stopped in 2025. There is no evidence that this session was exported into a Git build. Its purpose and production status should be confirmed before it is treated as game content.

### 13.3 Audio gaps

- No integrated music track found.
- No documented BPM/track-authoring pipeline.
- No BeatClock-linked audio implementation in the clean remake.
- No audio licensing register.
- No source-to-export naming map.
- No loudness/format specification.
- No evidence of platform audio QA.
- No proof that the September 2025 session belongs in the final game.

---

## 14. Public build and website audit

### 14.1 Availability

The live page and ZIP download both returned HTTP 200 during the audit.

Downloaded ZIP:

- size: **14,006,467 bytes**;
- SHA-256: `33db7168efdee3cf0c440766c84c5b19a506ac00f333bc0ac2f993be14fbd883`;
- contains `GrooveBound 0_0_14.app`;
- embedded `.love` payload: 2,121,027 bytes.

### 14.2 Exact source version

The embedded game content was compared against Git history. It matches:

`365e774` — 26 April 2025, “Rebalance boss stats and improve UI for shop/level up menus”

It does **not** match the original repository's final commit.

The public build is three commits behind original-source HEAD:

1. `48ab21f`;
2. `670de92`;
3. `2525c4d`.

Those later commits contain approximately:

- 1,903 insertions;
- 966 deletions;
- shared menu-template work;
- major shop/level-up/power-up changes;
- new blaster/weapon-power-up art;
- the inventory purchase correction.

Therefore the public app predates the final inventory fix and the last round of menu/power-up work.

### 14.3 Packaging quality

The app bundle:

- is a universal x86_64 + arm64 macOS executable;
- includes LÖVE 11.5a;
- retains generic product metadata:
  - bundle name `LÖVE`;
  - identifier `org.love2d.love`;
- does not present a verified signed/notarized Groove Bound distribution identity;
- failed bundle code-sign verification because content was not signed;
- has no verified Team Identifier.

This is appropriate for an internal prototype package, not a polished public macOS release.

### 14.4 Devlog drift

The live devlog HTML is byte-for-byte identical to the `index.html` in the original repository.

It contains 35 commit entries and ends at:

`6d1e538` — “Add game over screen update logic and halt gameplay when game over is active”

The original repository has 59 commits, so the devlog omits the final 24 commits.

The page presents `v1.0.0`, but:

- there is no `v1.0.0` Git tag;
- there is no GitHub release;
- the app filename says `0_0_14`;
- the app packages neither the final original source nor the clean remake;
- core power-up and beat features were unfinished.

The version label should be treated as inaccurate historical presentation rather than a release-management fact.

---

## 15. Quality, testing, and operational maturity

### 15.1 Testing by era

| Era | Automated tests | CI | Runtime proof |
|---|---:|---:|---|
| Original game | None | None | Historical public macOS build |
| Prototype 1 | None | None | Historical development code |
| Prototype 2 main | None | None | Historical development code |
| Draft PR #1 | No meaningful suite | No evidence of run | Patch only |
| Clean remake PR #2 | 100 unit tests | Passing | PR-reported manual LÖVE boot |

### 15.2 What the clean tests meaningfully protect

The test suite directly addresses prior failure classes:

- duplicate/leaked listeners;
- stale state across runs;
- pause-time clock behavior;
- deterministic random sequences;
- corrupt saves;
- save migrations;
- invalid content references;
- pool reset/reuse;
- spatial-grid queries;
- camera bounds and shake;
- controller dead zones;
- run-context reset.

This is a material improvement in engineering quality.

### 15.3 What the tests do not yet prove

- Combat correctness.
- Player damage and invulnerability timing.
- XP/drop correctness.
- Weapon slot rules.
- Level-up offer behavior.
- Boss/run completion.
- Musical synchronization.
- 300+ enemies and 150+ projectiles at target frame rate.
- LÖVE boot on every supported OS.
- rendering correctness;
- responsive layout;
- audio integration;
- packaged-build health;
- repeated full-run memory/lifecycle behavior.

### 15.4 No formal release discipline yet

Across the project there is no current:

- semantic versioning policy;
- changelog;
- tag strategy;
- GitHub release;
- signed artifact pipeline;
- automated package manifest;
- crash-reporting path;
- supported-platform matrix;
- minimum hardware profile;
- reproducible-build record;
- dependency/license manifest.

---

## 16. Key contradictions and ambiguity register

### 16.1 “Current game”

There are at least four possible meanings:

- public original app;
- final original source;
- Prototype 2 on `main`;
- clean remake in PR #2.

Recommendation: reserve **current development** for the clean remake branch and call the others **legacy original**, **old prototypes**, and **public legacy build**.

### 16.2 “Version 1.0.0”

The website uses `v1.0.0`, but version-control and packaging evidence do not support a true 1.0 release. The actual public artifact is named `0_0_14`.

### 16.3 “Game working”

The last original commit says the game is working, but adjacent commits describe bugs and unfinished power-up logic. This should mean “locally playable at that commit,” not “feature-complete or release-verified.”

### 16.4 “Phase 3 complete”

The old Prototype 2 status document describes substantial phase completion, but later code audit shows data is disconnected and essential boss/end/progression paths are broken or absent.

### 16.5 “CI green”

PR #2 unit tests passed, but lint is allowed to fail and the game is not booted in CI. “Green” means test command success, not full production readiness.

### 16.6 “Music game”

The project has a musical theme and some beat-check experimentation, but no current implementation of the groove system and no integrated soundtrack was found.

---

## 17. Risk register

| Priority | Risk | Current evidence | Response |
|---|---|---|---|
| Critical | No canonical source | Empty local workspace; remake only in draft PR | Make an explicit canonical decision before more implementation |
| Critical | Core differentiator is unbuilt | Groove layer deferred to Phase 4 | Prototype BeatClock/groove feel early enough to validate the premise |
| High | Remake never merged | PR open/draft since 3 Jul 2026 | Review and either merge/harden or explicitly reject |
| High | Scope creep and restart cycle | Original + two prototypes + new remake | Freeze architecture and phase exit criteria |
| High | IP/publicity/music risk | Older concept names real musicians | Use original characters/bosses unless legally cleared |
| High | Asset license uncertainty | Imported “Free Preview” effects pack, no license record | Complete provenance register before production use |
| High | Survivor-scale performance | Prior broad collision architecture; no combat benchmark yet | Treat 300 enemies/150 projectiles at target FPS as Phase 2 gate |
| High | Public artifact misrepresents status | `v1.0.0`, old unsigned build, stale devlog | Re-label as legacy prototype or replace after a verified vertical slice |
| Medium | CI overstates cleanliness | `luacheck ... || true` | Make lint blocking after resolving baseline |
| Medium | No runtime smoke CI | Unit-only workflow | Add headless/boot smoke and packaged-build checks |
| Medium | Documentation drift | Old phase claims and incomplete devlog | Generate status from canonical milestones and tags |
| Medium | Audio pipeline unclear | Sessions and exports lack mapping | Create audio source/export/license manifest |
| Medium | Local recovery risk | Working directory has no code | Clone the approved canonical branch after decision |
| Medium | No license | Both public repositories lack LICENSE | Decide code and asset licensing |
| Medium | Bus factor/AI-wiring errors | Prior lifecycle defects, no assigned review | Require human code review at phase gates |
| Low | Repository bloat | committed app runtime, duplicate legacy trees | Archive old prototypes and remove runtimes from future history |

---

## 18. Recommended canonical decision

### Recommendation

Adopt the **clean remake in draft PR #2** as the canonical development direction, subject to a short hardening review before merge.

Why:

- It is the newest intentional work.
- It directly addresses the identified architecture failures.
- It has a coherent staged plan.
- It has real automated unit coverage.
- It has deterministic and lifecycle foundations suitable for run-based gameplay.
- It avoids carrying forward the most expensive legacy coupling.

This does not mean merging blindly. The branch should first meet an explicit Phase 0/1 integration gate.

### Alternatives and trade-offs

#### Continue the original game

Benefit:

- broadest playable feature set;
- fastest route to a visibly content-rich build.

Cost:

- no tests;
- unfinished power-up/beat logic;
- tightly coupled systems;
- likely expensive stabilization;
- reproduces issues the remake already set out to solve.

#### Continue Prototype 2

Benefit:

- dependency-free;
- more structured than original.

Cost:

- nineteen known correctness bugs;
- lifecycle leaks;
- dead content data;
- wrong ownership;
- no tests on `main`.

This is the least attractive option.

#### Start over again

Benefit:

- theoretical cleanliness.

Cost:

- would create a fourth restart;
- discards the remake's tested foundation;
- reinforces the project's largest delivery risk.

There is no current evidence that another restart is justified.

---

## 19. Immediate recovery and continuation plan

### Stage 1 — Canonicalise

1. Review PR #2 as the canonical candidate.
2. Decide whether its `groove-bound/` directory should:
   - become the root of the existing repository; or
   - move into a new clean `GrooveBound` repository.
3. Mark the original repository as legacy.
4. Mark Prototype 1 and Prototype 2 as archived/reference.
5. Close or supersede PR #1 if the clean remake is accepted.
6. Populate the local workspace from the approved branch.

**Exit criteria:**

- one canonical Git URL;
- one default branch;
- one root game directory;
- local clone present;
- protected legacy sources clearly labelled;
- no ambiguous “current” code.

### Stage 2 — Harden Phase 0/1

Before merging:

- make `luacheck` blocking or document a temporary baseline;
- add automated LÖVE boot smoke;
- confirm LÖVE 11.5 runtime;
- verify keyboard/mouse/gamepad movement;
- verify pause and repeated title/run transitions;
- test window resize in run state;
- move UI layout constants into presentation settings;
- add `LICENSE`;
- add architecture/design/content-authoring documents;
- record event ownership/lifetimes;
- add a short manual playtest note;
- tag a Phase 1 development build after merge.

**Exit criteria:**

- CI must fail on test or lint errors;
- automated boot succeeds;
- two consecutive run/pause/title loops show no stale state;
- supported input methods pass;
- resize-safe HUD verified;
- tagged internal build exists.

### Stage 3 — Build Phase 2 combat

Recommended implementation order:

1. Enemy entity and pool.
2. Spawn director consuming wave data.
3. Weapon interface with stable IDs.
4. Kazoo Pistol projectile pool.
5. Spatial collision queries.
6. Damage/invulnerability/death events.
7. XP gem drop and pickup.
8. Debug counters and deterministic combat replay seed.
9. Performance scenario.

**Combat exit criteria:**

- one complete weapon works from content data;
- two enemy types behave differently;
- XP value is correct and awarded once;
- no listener leaks across restart;
- 300 enemies and 150 projectiles maintain the agreed target FPS on reference hardware;
- no per-frame font/object allocation in hot paths;
- deterministic test seed reproduces spawn and drop outcomes;
- prior B1–B19 relevant failures have regression coverage.

### Stage 4 — Reach a full-run vertical slice

Build:

- XP/levels;
- three-card offer;
- slot and rarity rules;
- passives;
- four weapons;
- boss;
- death/victory;
- results;
- coin/save path;
- options.

**Vertical-slice exit criteria:**

- ten consecutive complete runs without state corruption;
- win and loss both resolve;
- pause does not advance run time;
- restart does not duplicate listeners;
- save survives restart and corrupt-save fallback works;
- build is packaged and shared with a playtest note.

### Stage 5 — Validate the groove promise

Do not postpone the product-risk question indefinitely. A focused groove prototype should test:

- whether beat alignment is readable during dense combat;
- whether on-beat rewards feel empowering rather than punitive;
- whether timing survives frame variation;
- whether music and weapon feedback remain legible;
- whether players can enjoy the game without musical expertise;
- accessibility options for timing windows, flashes, and vibration.

The musical layer should add expressive upside. Missing a beat should not make the baseline game feel broken.

### Stage 6 — Curate assets and IP

Create an asset register with:

- stable asset ID;
- file path;
- editable source;
- export path;
- creator;
- origin;
- license;
- commercial-use permission;
- attribution;
- approval state;
- in-game consumer.

Separate Dropbox into:

- `source-art`;
- `production-exports`;
- `audio-working`;
- `licensed-third-party`;
- `generated-reference`;
- `tests`;
- `obsolete`.

### Stage 7 — Replace the public legacy artifact

Only after a verified vertical slice:

- correct the public version language;
- publish accurate stage/release notes;
- package the correct commit;
- brand the app bundle as Groove Bound;
- use an owned bundle identifier;
- sign and notarize macOS distribution;
- include licenses;
- publish checksums;
- link the release to a Git tag;
- verify download and launch on clean machines.

Until then, the current public page should be labelled as an early legacy prototype rather than `v1.0.0`.

---

## 20. Definition of “where we are now”

As of 26 July 2026:

### Product

- The premise and high-level loop are defined.
- The visual identity has credible early assets.
- The musical differentiator is not yet validated in the current architecture.

### Engineering

- The latest architecture has foundation and movement.
- Unit CI is passing.
- The latest work is unmerged and draft.
- Combat is the next major phase.

### Content

- A starter character, weapon, two enemies, two passives, and wave data exist as validated definitions.
- They are not connected to gameplay.
- The old projects contain more playable content but are legacy/reference.

### Art/audio

- Substantial editable art and SFX work exists.
- Asset provenance is incomplete.
- No integrated current soundtrack exists.
- Later audio work has unclear game integration.

### Distribution

- A legacy macOS prototype is public and downloadable.
- It is not the latest original code.
- It is not the remake.
- It is generically packaged and unsigned.
- The devlog and version presentation are stale.

### Delivery state

The accurate delivery label is:

> **Remake Phase 1 drafted and unit-tested on an unmerged branch; Phase 2 combat not started; public legacy prototype still live.**

It would be inaccurate to call the project:

- finished;
- at v1.0;
- release-ready;
- in content production;
- rhythm-system complete;
- locally restored.

---

## 21. Highest-value next decision

The next decision is not “which weapon should we add?” It is:

> **Do we formally adopt and merge the clean 2026 remake as the one canonical Groove Bound codebase?**

Once that is answered, the next executable milestone is a deterministic combat slice:

- Joe;
- Kazoo Pistol;
- Monotones and Tempo Leeches;
- wave data;
- damage;
- XP gems;
- stable 300-enemy performance;
- automated regression tests;
- a tagged internal build.

That milestone will convert the current architectural promise into a playable proof without reopening the entire project scope.

---

## 22. Evidence links

### GitHub

- [Original Groove Bound repository](https://github.com/raoniai/004_GrooveBound)
- [Prototype/rewrite repository](https://github.com/raoniai/Groove-Bound-Prototype-1)
- [Draft PR #1 — old Prototype 2 visual/responsive patch](https://github.com/raoniai/Groove-Bound-Prototype-1/pull/1)
- [Draft PR #2 — clean remake audit, Phase 0 and Phase 1](https://github.com/raoniai/Groove-Bound-Prototype-1/pull/2)

### Dropbox

- [Groove Bound source-art and audio folder](https://www.dropbox.com/home/RAOLATRO/GAMES/004%20GrooveBound)

### Public site

- [Live legacy devlog](https://raoni.studio/games/groovebound/)
- [Live legacy build ZIP](https://raoni.studio/games/groovebound/download/GrooveBound.zip)

---

## 23. Audit caveats

- “Everything” means all matching sources exposed through the connected GitHub and Dropbox accounts, the current local workspace, and the linked public site at the time of the audit.
- Deleted private repositories, unshared Dropbox locations, other accounts, local machines, unpushed branches, and external design tools cannot be ruled out.
- Repository content and connector metadata were inspected read-only.
- No GitHub branches were merged or altered.
- No Dropbox files were changed.
- No public deployment was changed.
- The public ZIP was downloaded only for forensic comparison.
- The latest Lua tests were not rerun locally because the current environment lacked Lua/LuaJIT/LÖVE; their passing status comes from the successful GitHub Actions run.
- Schedule estimates are taken from the remake plan and should be recalibrated after the canonical decision and a Phase 2 spike.
