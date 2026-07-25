# Groove Bound — Engine and Language Migration Research and Plan

**Research date:** 26 July 2026
**Canonical baseline inspected:** `groove-bound/`
**Decision status:** Recommendation and migration design complete; no migration implemented
**Recommended target:** Godot 4.7.1 .NET, C# 12, engine-independent C# simulation core
**Fallback target:** MonoGame 3.8.4.1, C#
**Current targets to preserve:** Windows, macOS, Linux

## 1. Executive decision

Groove Bound can be migrated away from Lua and LÖVE without losing its current
gameplay, but changing the language alone will not make it stable. The reduction
in bugs must come from preserving the current ownership rules, deterministic
simulation, validation, tests, and release gates while adding stronger compile-
time checks and better engine tooling.

The best-fit direction is:

> **Godot 4.7.1 .NET + C# 12, with all deterministic gameplay in a plain .NET
> library and Godot used as the platform, presentation, UI, input, asset, audio,
> and export layer.**

This is preferable to a direct scene-by-scene rewrite. The game should not make
every enemy, projectile, or pickup an independent physics-driven Godot object.
The current data-oriented world, pools, spatial hash, fixed update order, stable
IDs, and deterministic RNG should remain authoritative in the C# domain layer.
Godot nodes should present that state.

### Why this is the leading choice

- C# adds compile-time type checking, nullable-reference analysis, enums,
  records, analyzers, refactoring, and a mature test ecosystem.
- Godot has a dedicated 2D renderer and tools for sprites, animation, tile maps,
  particles, cameras, UI, input mapping, audio buses, localization, profiling,
  and command-line exports.
- Godot is MIT-licensed, open source, and has no revenue fee.
- Windows, macOS, and Linux are first-class export targets.
- The existing architecture maps cleanly into a pure C# domain library.
- The current assets—PNG, JPG, OGG, and TTF—are directly usable.
- The migration can be proven tick-by-tick against the Lua version.

### Important limitations

- Godot 4 C# projects currently cannot export to the web.
- Godot C# mobile support exists but remains less mature than desktop support.
- Consoles require approved developer access and third-party/private export
  middleware.
- Godot's rhythm-audio synchronization helpers need to be verified in a real
  Stage 5 spike; the official synchronization guide itself warns about audio
  buffers, display latency, and long-term drift.
- C# support in Godot still has some editor workflow differences and known
  issues. Gameplay code should therefore avoid depending deeply on Godot APIs.

If browser deployment becomes a firm requirement, revisit the language choice
before porting. The strongest alternatives would then be Godot with statically
typed GDScript, Unity C#, or a web-first TypeScript engine, depending on whether
browser or native desktop is the primary product.

## 2. Should the game migrate now?

### Recommendation

Run the bounded Godot/C# feasibility and parity spike now, before Stage 5.
Authorize the full port only if the spike passes every gate in section 11.

This is the least disruptive decision point because:

- Stages 1–4 form a complete and testable three-minute vertical slice.
- The BeatClock, soundtrack, audio-latency calibration, and groove system have
  not yet been implemented.
- Those Stage 5 systems are the features most affected by engine audio timing.
- Porting after Stage 5 would mean implementing and calibrating the most
  engine-sensitive system twice.
- The runtime is still small enough to port with controlled parity.

Do not start a full rewrite merely because another engine has more features.
If the spike cannot reproduce the exact seeded run, input behavior, rendering
fidelity, and audio timing, continue in LÖVE and finish the vertical slice.

## 3. Verified current baseline

### Repository state

- The Git branch is `main`.
- The repository has no commits.
- All current files are untracked.
- The status documents describe upstream head `fe79d6f`, but that provenance is
  not represented in the local Git history.
- The working tree is therefore the only current local implementation and must
  be snapshotted before migration work.
- Existing generated and legacy material must retain its current canonical,
  provenance, and reference-only classifications.

### Code and coupling

| Measure | Current value |
|---|---:|
| Lua files | 84 |
| Total Lua lines | 8,840 |
| Runtime Lua lines | 6,536 |
| Test Lua lines | 2,304 |
| Runtime Lua files | 58 |
| Files directly using a `love.*` API | 27 |
| Direct `love.*` references | 351 |
| `love.graphics` references | 324 |
| Headless tests | 158 |
| Binary assets | 18 |
| Asset directory size | approximately 2.8 MiB |

Most engine coupling is in rendering and UI. The core, content, scheduler, event
bus, RNG, pools, spatial hash, inventory, progression, and large parts of combat
are already structurally portable.

### Current behavior that must survive

- keyboard, mouse, and gamepad play;
- persistent options and keyboard rebinding;
- conflict detection for bindings;
- pause-safe run time;
- deterministic named RNG streams;
- timed waves and edge spawning;
- chase, zigzag, charge, and static enemy behavior;
- four base weapons, automatic targeting, and automatic firing;
- pooled enemies, projectiles, and XP gems;
- spatial-hash collision queries;
- damage, invulnerability, knockback, death, and drops;
- lossless multi-threshold XP;
- paused three-card choices, reroll, skip, and legal filtering;
- four weapon slots and four passive slots;
- stable-ID upgrades and atomic evolution;
- immutable projectile stat snapshots;
- Resolve-gated Studio/Live evolution;
- miniboss, final boss, victory, defeat, results, and replay;
- score, combo, guard, healing, coins, and combat telemetry;
- admin tuning controls in development builds only;
- source and packaged boot checks;
- seeded complete-run simulation.

### Current verification result

- `make test`: **158 tests, 0 failures**.
- `make lint`: **1 warning, 0 errors** in 83 files.
- The warning is `W221`, `slot` potentially never set, in
  `src/game/systems/weapon_catalog.lua:33`.
- LÖVE 11.5 is installed.
- The source boot smoke could not initialize SDL video in the current restricted
  desktop execution environment. This is an environment-level display failure,
  so boot is not newly confirmed or disproved by this research run.

The current status document says lint has zero findings. That statement has
drifted from the executable result and must be corrected during baseline freeze.

### Assets

The current binary assets are:

- 12 PNG images;
- 1 JPG floor sheet;
- 4 OGG Vorbis SFX;
- 1 TTF pixel font.

There is no integrated music track. Stage 5 still needs track metadata, a
BeatClock, loop handling, latency calibration, and the groove system.

## 4. What improves—and what does not

### Improvements expected from Godot + C#

| Area | Expected improvement |
|---|---|
| Type safety | IDs, slots, outcomes, card kinds, triggers, and content schemas become explicit types |
| Null safety | Nullable analysis catches missing owners and optional runtime state |
| Refactoring | IDE-supported symbol renaming replaces string and table-shape guesswork |
| Tests | Fast pure .NET tests plus engine-level Godot smoke and integration tests |
| Content | JSON schema plus typed deserialization and boot validation |
| UI | Layout containers, anchors, focus navigation, themes, localization, accessibility |
| Rendering | Dedicated 2D sprites, atlas regions, particles, shaders, camera tools |
| Audio | Audio buses, effects, playback-position APIs, latency queries, mixer controls |
| Input | Named actions, gamepad mappings, hot-plug handling, remapping |
| Profiling | CPU/GPU profiler, monitors, debugger, remote inspection |
| Packaging | Preset-based and command-line desktop exports |
| Operations | Reproducible engine pin, export presets, artifact manifests, CI matrix |

### Things an engine change will not fix automatically

- unclear feature ownership;
- duplicated state;
- listener leaks;
- nondeterministic update order;
- invalid content;
- unlicensed assets;
- bad balance;
- inadequate acceptance tests;
- missing clean-machine verification;
- documentation drift;
- scope creep or another restart cycle.

The target architecture must continue the current non-negotiable rules: stable
IDs, single ownership, run-scoped teardown, deterministic streams, validated
content, immutable projectile snapshots, atomic evolution, and release-only
gates.

## 5. Language possibilities

This is the practical programming-language landscape for this game, rather than
an unbounded list of every language with a graphics binding.

| Language | Typical engine/framework | Fit | Decision |
|---|---|---:|---|
| C# | Godot .NET, Unity, MonoGame | Excellent | **Recommended** |
| GDScript | Godot | Good | Browser-capable Godot alternative |
| C++ | Unreal, SDL3, raylib | Moderate | Too much ownership/build risk for this scope |
| Rust | Bevy, macroquad, SDL bindings | Promising | Not for the stability-first port |
| Java | libGDX | Good | Mature fallback, weaker rhythm/mobile audio story |
| Kotlin | libGDX | Good | Ergonomic JVM option; web support is reduced |
| GML | GameMaker | Moderate | Excellent 2D tools, but proprietary and dynamically typed |
| TypeScript | Phaser and web engines | Moderate | Choose only for browser-first distribution |
| Haxe | Heaps, HaxeFlixel | Moderate | Capable but smaller ecosystem and bus factor |
| Swift | SpriteKit | Narrow | Apple-only |
| C/C#/Rust bindings | SDL3 or raylib | Moderate | Framework construction burden, not a feature upgrade |

### Language conclusion

C# is the best balance of safety, productivity, performance, tooling, testability,
and engine choice. Rust offers stronger memory guarantees, but Bevy explicitly
warns that it is still experimental, has missing features, sparse documentation,
and breaking releases roughly every three months. C++ offers maximum control but
also adds manual lifetime, build, and platform complexity that conflicts with the
goal of fewer bugs. GDScript is productive and optionally typed, but a C# domain
library provides stronger long-term contracts and can move between Godot,
MonoGame, or Unity if necessary.

## 6. Engine comparison

Scores are specific to Groove Bound's current 2D, deterministic, desktop-first,
rhythm-aware design. Five is best. They are decision aids, not universal engine
rankings.

| Candidate | Parity safety | Stability | 2D/audio tools | Testing/tooling | Platform reach | Operational cost | Overall |
|---|---:|---:|---:|---:|---:|---:|---:|
| **Godot + C#** | 4.5 | 4.0 | 4.5 | 4.5 | 4.0 | 4.5 | **4.3** |
| **MonoGame + C#** | 5.0 | 4.5 | 2.8 | 4.5 | 4.5 | 4.0 | **4.2** |
| Unity 6.3 LTS + C# | 4.0 | 4.5 | 4.5 | 4.5 | 5.0 | 2.5 | **4.1** |
| Godot + typed GDScript | 4.0 | 4.0 | 4.5 | 3.5 | 4.3 | 4.7 | **4.0** |
| GameMaker LTS + GML | 3.0 | 3.5 | 4.7 | 3.2 | 4.3 | 3.0 | **3.6** |
| libGDX + Java/Kotlin | 4.2 | 4.2 | 3.0 | 4.2 | 4.0 | 3.8 | **3.9** |
| SDL3/raylib + C++ | 4.0 | 4.5 | 2.0 | 3.5 | 4.5 | 2.0 | **3.5** |
| Bevy + Rust | 3.0 | 2.0 | 3.2 | 4.0 | 3.5 | 3.0 | **3.1** |
| Unreal + C++/Blueprint | 2.5 | 4.5 | 3.0 | 4.5 | 5.0 | 1.5 | **3.3** |
| Phaser + TypeScript | 2.8 | 4.0 | 3.5 | 4.3 | 2.5 native / 5 web | 3.5 | **3.5** |

### Godot 4.7.1 .NET

**Best overall fit.**

Use Godot for presentation and platform services, not as the owner of the
simulation. The main risk is C# platform reach: no Godot 4 web export and
less mature mobile support. This is acceptable for the current
Windows/macOS/Linux target.

Pin exactly `4.7.1-stable` during the port. Do not develop on Godot 4.8 dev
builds. Upgrade only between parity checkpoints after reading release notes and
running the full matrix.

### MonoGame

**Best low-risk technical fallback.**

MonoGame is a framework rather than an editor-driven engine. Its XNA-style
update/draw model is closest to LÖVE, so the port would be straightforward and
the pure C# architecture would be excellent. It supports Windows, macOS, Linux,
mobile, and privately documented console backends for approved developers.

It does not provide the same scene, UI, animation, particle, or audio-authoring
features as Godot. Choosing it would improve language/tooling and packaging, but
would not provide the requested step-change in engine features.

### Unity 6.3 LTS

**Best if console support and a large commercial ecosystem become primary.**

Unity 6.3 is the current LTS and is supported for two years. It has mature 2D,
UI, profiling, testing, packaging, and audio DSP timing. It also has the widest
mainstream platform and asset ecosystem in this shortlist.

For Groove Bound it brings a heavier editor/runtime, greater package and
dependency complexity, and commercial licensing exposure. In 2026 Unity
Personal is free only up to USD 200,000 in revenue and funding; Unity Pro is
then required. It is viable, but not the best default for this small,
code-oriented 2D project.

### GameMaker LTS 2026

**Strong 2D authoring, weaker long-term code contracts.**

GameMaker LTS 2026 added UI layers, particle editing, audio buses/effects, a
better debugger, and stronger runtime handles. However, GML remains a
proprietary language, the next-generation GMRT runtime is still beta, and the
old runtime enters maintenance-only support through the LTS cycle. A commercial
license is required to monetize, and console export requires Enterprise.

It would be fast for a new 2D game, but less attractive for preserving this
tested, code-first architecture.

### libGDX

**Mature code-first Java/Kotlin alternative.**

libGDX 1.14.2 is current and supports desktop, Android, iOS, and web with
platform-specific restrictions. It has strong Gradle/JVM tooling. The official
audio documentation warns that the default Android audio path is not recommended
for latency-sensitive rhythm games and points to third-party Oboe or miniaudio
backends. Kotlin also reduces HTML target compatibility.

### Bevy

**Do not choose for this migration.**

Bevy 0.19 is attractive for data-oriented performance and Rust safety, but the
project's own documentation recommends Godot for teams seeking a more complete
and stable engine. Bevy still publishes breaking changes on a roughly quarterly
cadence. That directly conflicts with the objective of fewer bugs and a smooth,
low-breakage port.

### Unreal Engine

**Technically capable but disproportionate.**

Paper 2D can build this game, and Unreal has extensive C++, Blueprint, audio,
testing, profiler, and platform tooling. It is optimized around much larger 3D
production needs, has high workstation/build overhead, and introduces a 5%
royalty above USD 1 million in lifetime attributable product revenue under the
standard game license. It is not justified for this 2D project.

### SDL3, raylib, and custom C++/Rust stacks

**Maximum control, minimum feature leverage.**

SDL3 officially provides low-level video, audio, input, gamepad, haptic, and
cross-platform support. It would require Groove Bound to own the UI framework,
asset pipeline, animation tools, content tooling, packaging, and many platform
details. This replaces one lightweight framework with another rather than
delivering the requested feature improvement.

### Other considered routes

- **Defold:** stays with Lua, so it does not satisfy the requested language
  change.
- **Solar2D:** also Lua-based.
- **HaxeFlixel/Heaps:** capable and cross-platform, but smaller tooling and
  support ecosystems than the leading choices.
- **Cocos Creator:** viable TypeScript option, but less natural for the current
  code-first deterministic core than C#.
- **Phaser:** excellent for browser-first games, but desktop distribution adds
  a web wrapper and is not the current target.
- **Native SpriteKit/Android engines:** would create separate platform
  implementations and double QA.

## 7. Target architecture

```text
GrooveBound.sln
├── GrooveBound.Domain
│   ├── Core
│   │   ├── DeterministicRng
│   │   ├── Scheduler
│   │   ├── EventBus and SubscriptionScope
│   │   ├── ObjectPool
│   │   └── SpatialHash
│   ├── Content
│   │   ├── typed definitions
│   │   ├── JSON loading
│   │   ├── schema validation
│   │   └── stable ID value types
│   ├── Simulation
│   │   ├── RunContext
│   │   ├── World
│   │   ├── Combat
│   │   ├── SpawnDirector
│   │   ├── XP and progression
│   │   ├── inventories
│   │   └── weapon evolution
│   ├── Save
│   │   ├── versioned DTOs
│   │   └── migrations
│   └── Replay
│       ├── input commands
│       ├── tick snapshots
│       └── deterministic hashes
├── GrooveBound.Godot
│   ├── Bootstrap and state routing
│   ├── Platform adapters
│   │   ├── input
│   │   ├── save paths
│   │   ├── clipboard
│   │   ├── audio
│   │   ├── haptics
│   │   └── logging
│   ├── Presentation
│   │   ├── entity view pools
│   │   ├── sprite animation
│   │   ├── camera
│   │   └── effects
│   ├── UI scenes
│   └── Development-only admin tools
└── GrooveBound.Tests
    ├── unit tests
    ├── parity fixtures
    ├── seeded simulations
    ├── save compatibility
    └── performance tests
```

### Architectural rules

1. `GrooveBound.Domain` must compile and test without Godot installed.
2. No `Godot.*` type may appear in the domain project.
3. The domain uses its own `Vector2` value type or `System.Numerics.Vector2`.
4. The domain owns run time, update order, collision, damage, XP, inventory,
   offers, evolution, outcome, and statistics.
5. Godot owns actual input devices, windows, drawing, audio output, haptics,
   OS paths, and exports.
6. Presentation objects observe entity IDs and snapshots; they do not become
   authoritative gameplay entities.
7. UI sends typed commands into the domain; it does not mutate inventories or
   progression directly.
8. All randomness continues through the four named streams: `loot`, `spawn`,
   `combat`, and `vfx`.
9. `unchecked uint` operations must reproduce the Lua xorshift implementation
   exactly.
10. Simulation time uses a fixed tick. Rendering interpolates and may run at a
    different rate.

## 8. Module-by-module migration map

| Lua source | C# destination | Migration treatment |
|---|---|---|
| `src/core/rng.lua` | `Domain/Core/DeterministicRng.cs` | Exact uint32 port; golden sequences |
| `event_bus.lua` | `Domain/Core/EventBus.cs` | Typed events and disposable scopes |
| `scheduler.lua` | `Domain/Core/Scheduler.cs` | Preserve callback ordering and catch-up rules |
| `pool.lua` | `Domain/Core/ObjectPool.cs` | Generic typed pool with reset contract |
| `spatial_hash.lua` | `Domain/Core/SpatialHash.cs` | Preserve cell math and query semantics |
| `state_machine.lua` | Godot router or app state service | Keep stack/modal semantics |
| `save.lua` | `Domain/Save` + Godot path adapter | Preserve version-1 JSON envelope |
| `src/content/*.lua` | versioned JSON + typed records | One canonical data source |
| `content/validate.lua` | JSON Schema + domain validation | Boot fails with aggregated errors |
| `src/config/*.lua` | JSON/config records + project settings | Separate gameplay from feel/platform |
| `run_context.lua` | `Domain/Simulation/RunContext.cs` | Preserve scoped teardown and pause clock |
| `world.lua` | `Domain/Simulation/World.cs` | Keep arrays, IDs, spatial hash, sweep |
| entities | domain structs/classes + Godot views | Separate state from rendering |
| combat system | `Domain/Simulation/CombatSystem.cs` | Port in narrow, test-backed slices |
| weapon systems | typed domain services | Preserve slot authority and transactions |
| progression/XP | typed domain services | Preserve legal filtering and pending choices |
| `game/input.lua` | Godot InputMap adapter | Emit abstract actions only |
| arena/camera | domain bounds + Godot Camera2D | Compare transform and shake fixtures |
| `assets.lua` | Godot resources/import settings | Explicit manifest and atlas regions |
| UI screens/HUD | Godot Control scenes + C# presenters | Match focus, modal, and resize behavior |
| admin/debug | dev-only Godot overlay | Compile or export out of release builds |
| `main.lua/conf.lua` | `project.godot` + bootstrap scene | Minimal composition root |

## 9. Compatibility contracts

### Determinism

Create a versioned replay fixture:

```json
{
  "format": 1,
  "seed": 424242,
  "tick_hz": 60,
  "commands": [
    {"tick": 1, "action": "move", "x": 1, "y": 0},
    {"tick": 120, "action": "admin_prepare_evolution"}
  ],
  "checkpoints": [
    {"tick": 600, "state_hash": "..."}
  ]
}
```

Both Lua and C# runners consume the same commands. At defined ticks they emit a
canonical, sorted state snapshot containing:

- clock and pause state;
- all RNG stream states;
- player position, health, guard, and invulnerability;
- entity IDs, kinds, positions, health, and projectile snapshots;
- pools and active counts;
- wave cursor and scheduler state;
- XP, level, pending choices, inventory, passives, and Resolve;
- offers shown and selection;
- outcome and complete statistics.

Float fields receive an explicit tolerance only where bit-exact parity is not
possible. IDs, counts, choices, outcomes, and RNG states must be exact.

### Save compatibility

The current save format is already versioned JSON:

```json
{"version":1,"data":{...}}
```

The first Godot build must:

1. Read the same envelope and preserve unknown future-safe fields where
   practical.
2. Search the prior LÖVE identity directory `groove-bound` on each desktop OS.
3. If a valid legacy save exists and no Godot save exists, copy and import it.
4. Write the migrated save atomically to a temporary file, flush it, and rename.
5. Keep the original LÖVE file unchanged.
6. Record an import marker and source checksum to prevent repeated imports.
7. Test default, valid, corrupt, truncated, read-only, and future-version files.

Do not introduce save schema version 2 until parity is complete.

### Content compatibility

- Export the Lua content tables into stable, sorted JSON fixtures.
- Define a JSON Schema with required fields, ranges, enums, and references.
- Make JSON the single source during the dual-runtime period.
- Have both Lua and C# load the same files, or generate both runtime forms from
  the same canonical JSON.
- Preserve every current stable ID exactly.
- Never use display text for game logic.
- Hash the canonical content bundle and include the hash in replays and builds.

### Asset compatibility

For each asset, record:

- source and output path;
- checksum;
- dimensions, color mode, and audio sample rate;
- license and provenance;
- Godot import settings;
- pixel-filtering mode;
- atlas cell size and region definitions;
- loop points and track metadata where applicable.

Disable texture filtering for pixel assets unless an asset is explicitly meant
to scale smoothly. Verify sprite frame order, pivots, alpha, atlas regions,
color space, OGG looping, font metrics, and fallback glyphs.

### Input compatibility

- Preserve abstract actions: movement, aim, confirm, cancel, and pause.
- Preserve keyboard defaults and conflict detection.
- Preserve controller dead-zone behavior.
- Add controller hot-plug and device-prompt switching.
- Test keyboard-only, mouse/keyboard, and gamepad-only navigation.
- Record action-level input in replays, never raw device events.

### Timing compatibility

- Use a 60 Hz fixed simulation tick.
- Accumulate real frame time and cap catch-up work to prevent a spiral.
- Never drive gameplay directly from variable `_Process(delta)`.
- Pause must freeze the domain clock, scheduler, weapons, enemies, pickups, and
  BeatClock state.
- Rendering, effects, and UI may use unscaled time where explicitly intended.

### Audio and groove compatibility

Stage 5 must begin as a separate audio proof before integration:

- authored track metadata: BPM, offset, time signature, subdivisions, loop
  start/end, sample rate, and checksum;
- audio-clock-derived playback position;
- output-latency compensation;
- long-loop drift measurement;
- pause/resume and device-change behavior;
- visual beat and input timestamp comparison;
- persisted user calibration;
- an optional external audio middleware fallback if native timing fails.

The audio proof must run for at least 30 minutes without cumulative beat drift
outside the agreed grace window. Exact thresholds should be set after measuring
the candidate track and supported hardware.

## 10. Test strategy

### Layer 1 — pure domain tests

Port all 158 Lua tests to xUnit or NUnit. Add nullable warnings as errors,
Roslyn analyzers, formatting, and deterministic culture/time-zone settings.

Required categories:

- class/value construction;
- event subscription, once semantics, and scoped teardown;
- scheduler ordering and cancellation;
- xorshift sequences and named-stream independence;
- pool reset and reuse;
- spatial-hash insertion, movement, queries, and removal;
- content schema and cross-reference failures;
- save loading, corruption fallback, and migrations;
- input normalization and conflicts;
- camera bounds and trauma;
- XP multi-threshold behavior;
- inventory and passive limits;
- offers, rerolls, skip, and legal filtering;
- evolution eligibility, atomicity, rollback, and projectile snapshots;
- full seeded victory and deterministic defeat;
- duplicate boss reward prevention;
- 300-enemy/150-projectile simulation budget.

### Layer 2 — Lua/C# differential tests

For each golden replay:

1. Run Lua headlessly.
2. Run the C# domain headlessly.
3. Compare canonical snapshots.
4. Stop on the first divergent tick.
5. Print the smallest differing path and both values.

Golden scenarios must include:

- idle timeout;
- player death;
- complete victory;
- level-up crossing multiple thresholds;
- full inventory;
- Studio evolution;
- Live evolution;
- pause/resume;
- restart twice with zero stale listeners;
- resize and device changes at the presentation layer.

### Layer 3 — Godot integration tests

- project imports without errors;
- bootstrap reaches title;
- every scene instantiates;
- assets load;
- inputs reach typed commands;
- run/pause/level-up/results stack behaves correctly;
- save import and persistence work;
- admin controls are present only in development exports;
- audio buses and calibration persist;
- no orphan nodes or subscriptions after repeated runs.

### Layer 4 — visual regression

Capture the same deterministic scenes at 1280×720 and resized aspect ratios:

- title;
- options and controls;
- active combat;
- level-up cards;
- both evolution branches;
- boss HUD;
- pause;
- results;
- admin panel in development.

Use image comparisons with bounded tolerance, plus human review for layout and
animation. Pixel-perfect parity is the initial gate; improvements happen only
after parity is signed off.

### Layer 5 — performance and soak

- 300 enemies plus 150 projectiles at 60 Hz;
- target and minimum hardware profiles;
- 1%, 0.1%, and worst frame-time metrics;
- allocation count and managed-heap growth;
- entity, view-pool, particle, and audio-voice peaks;
- 30-minute gameplay soak;
- 100 automated full runs;
- 20 title/run/title loops;
- controller disconnect/reconnect;
- audio device change where the OS supports it.

### Layer 6 — package and clean-machine checks

For Windows, macOS, and Linux:

- build from a pinned clean checkout;
- import and export from command line;
- verify artifact manifest and checksums;
- install/launch on a clean machine;
- create/read save;
- verify input and audio;
- verify no admin/test/private/unlicensed files;
- sign and notarize macOS;
- confirm version matches tag, executable, results metadata, and website.

## 11. Migration phases and gates

### Phase 0 — Freeze the truth

**Estimated effort:** 2–4 focused days.

Deliverables:

- create the first canonical Git commit;
- record upstream provenance in Git notes or repository documentation;
- fix the current lint warning;
- rerun tests, lint, source smoke, package smoke, and ZIP integrity;
- record package checksum;
- capture golden screenshots and a complete live run;
- export content, save, RNG, and deterministic replay fixtures;
- record asset checksums and import expectations;
- update status documents to match executable evidence.

Gate:

- no unclassified source;
- zero test failures;
- zero lint findings;
- repeatable baseline package;
- approved parity manifest.

No port begins before this gate passes.

### Phase 1 — Godot/C# feasibility spike

**Estimated effort:** 5–8 focused days.

Build only:

- pinned Godot 4.7.1 .NET project;
- pure C# domain test project;
- exact RNG port;
- content JSON load and validation;
- a fixed-tick world with player movement;
- 300 enemies and 150 projectiles rendered from domain state;
- keyboard/gamepad input adapter;
- OGG playback and a provisional BeatClock;
- Windows/macOS/Linux command-line export proof.

Measure:

- compile/test time;
- frame time and allocations;
- sprite fidelity;
- input latency;
- audio playback-position accuracy and drift;
- package sizes and clean launch.

Go gate:

- exact RNG and content parity;
- fixed simulation matches reference fixtures;
- scale target maintains the agreed frame budget;
- no blocking export issue on any desktop target;
- audio timing is viable or has an approved middleware fallback;
- the team accepts the C# and Godot workflow.

If any hard gate fails, stop and run the same bounded spike in MonoGame C#.

### Phase 2 — Portable domain port

**Estimated effort:** 2–3 weeks.

Port in this order:

1. IDs, value types, settings, and content records.
2. RNG, event scopes, scheduler, pool, and spatial hash.
3. world and entities without rendering.
4. weapon inventory/runtime and immutable snapshots.
5. spawn director and combat.
6. XP and progression.
7. passives and evolution transaction.
8. outcome, stats, and full-run simulation.
9. save envelope and migrations.

Gate:

- all 158 behavioral tests represented and passing in C#;
- every golden replay matches;
- no Godot dependency in the domain assembly;
- nullable and analyzer warnings are zero;
- seeded full-run and scale gates pass.

### Phase 3 — Godot presentation shell

**Estimated effort:** 2–4 weeks.

Implement:

- bootstrap and state/modal routing;
- asset manifest and imports;
- arena and floor;
- pooled entity views;
- sprite animation;
- camera follow, bounds, trauma, and shake;
- projectiles, XP gems, health bars, and effects;
- HUD and combat counters.

Gate:

- deterministic screenshots pass;
- all current combat entities are visible and synchronized;
- no view object can change domain state directly;
- view pools return to baseline after each run;
- no sustained allocation or node-count growth.

### Phase 4 — UI, input, save, and platform parity

**Estimated effort:** 2–3 weeks.

Implement:

- title, options, controls, arsenal, run, level-up, pause, admin, and results;
- keyboard/mouse/gamepad focus;
- rebinding and conflict feedback;
- fullscreen, resize, volumes, shake, flash, vibration, aim assist, and dead zone;
- clipboard seed copy;
- LÖVE save discovery and non-destructive import;
- development/release feature flags.

Gate:

- all current navigation routes pass with each input mode;
- two consecutive run/title loops have no stale state;
- save compatibility fixtures pass on all desktop OSes;
- required controls remain reachable at supported window sizes;
- release export contains no admin surface.

### Phase 5 — Stage 5 audio and groove proof

**Estimated effort:** 1–2 weeks for the proof, then normal feature development.

Implement the BeatClock only after the engine clock experiment is accepted.
Keep the music clock authoritative and simulation events derived from track
metadata. Add calibration, grace window, metronome, beat pulse, and the initial
groove meter behind feature flags.

Gate:

- stable across pause, resume, and loop boundaries;
- no cumulative drift in the long-duration test;
- calibration persists;
- baseline combat never depends on hitting a beat;
- reduced-flash and non-audio cues work.

### Phase 6 — Parity release candidate

**Estimated effort:** 1–2 weeks.

- freeze new gameplay;
- run the complete regression, soak, performance, and package matrix;
- conduct side-by-side human QA;
- sign and notarize;
- create a private release candidate;
- keep the LÖVE build available as rollback;
- collect crash and performance evidence before public cutover.

Gate:

- no unresolved severity-1 or severity-2 parity defects;
- accepted frame-time, memory, input, and audio results;
- Windows/macOS/Linux clean-machine passes;
- save import verified with backups;
- artifact traceable to a commit and exact engine version;
- human approval for public replacement.

### Phase 7 — Cutover and stabilization

**Estimated effort:** 1–2 weeks of monitored stabilization.

- publish the approved Godot build;
- do not delete the LÖVE source or old player saves;
- label the LÖVE branch/tag as the frozen parity baseline;
- monitor crash, save-import, device, and performance issues;
- allow rollback to the last LÖVE public build;
- only begin visual or gameplay improvements after the stability window.

## 12. Improvement plan after parity

No item in this section should be mixed into the parity port.

### Reliability

- deterministic replay files attachable to bug reports;
- crash logging with build, engine, OS, GPU, content hash, and last replay tick;
- atomic saves with rolling backup;
- content schema versioning;
- dependency and license lockfiles;
- automated status generation from CI and release metadata;
- engine upgrade checklist and rollback branch.

### Performance

- fixed-step simulation and interpolated rendering;
- structure-of-arrays or packed hot-path collections where profiling proves it;
- pooled presentation objects;
- batched sprite rendering for high-count entities;
- hard particle, projectile, enemy, and audio-voice budgets;
- allocation-free combat update;
- release profiler captures on minimum hardware.

### Player-facing features

- proper UI scaling and text-size settings;
- localization-ready strings and pseudolocalization;
- glyph-safe font fallback;
- controller hot-plug prompts;
- richer particles, shaders, lighting, and screen effects within accessibility
  caps;
- audio buses, compressor/limiter policy, and per-category controls;
- Steam integration only after the desktop build is release-stable;
- mod/DLC content packs only after content schema security is designed.

### Development tools

- content browser and validator;
- wave timeline preview;
- weapon DPS and projectile-budget simulator;
- beat-grid and loop-point inspector;
- live performance graphs;
- deterministic replay viewer with step, rewind-by-reload, and state diff;
- automated asset provenance report.

## 13. Risk register

| Risk | Probability | Impact | Control |
|---|---|---|---|
| Another restart cycle | High | Critical | Spike first; full port needs gate approval |
| Baseline is lost | High until commit | Critical | Phase 0 canonical commit and artifacts |
| Hidden behavioral drift | High | High | Differential tick snapshots |
| C# web limitation becomes important | Medium | High | Decide platform contract before Phase 2 |
| Audio drift undermines groove | Medium | Critical | Stage 1 audio spike and long-loop gate |
| Godot node count hurts scale | Medium | High | Domain arrays and pooled/batched views |
| Save path change loses progress | Medium | Critical | Non-destructive import and fixtures |
| Asset import changes pixel fidelity | Medium | Medium | Manifest, pinned import settings, screenshots |
| Engine update breaks project | Medium | High | Exact pin and checkpoint-only upgrades |
| Status claims drift again | High | Medium | Generate reports from CI artifacts |
| Console goal appears late | Medium | High | Platform decision gate; Unity alternative |
| Mobile goal appears late | Medium | High | Prototype early or choose different target |
| Port adds features before parity | High | High | Separate parity and improvement backlogs |
| Licensing remains incomplete | High | High | Provenance gate before release |

## 14. Decision rules for changing the recommendation

Choose **Unity 6.3 LTS + C#** instead if:

- PlayStation/Xbox/Switch is a near-term funded target;
- commercial middleware and console support outweigh cost and engine weight;
- a larger multidisciplinary team needs the Unity ecosystem;
- the audio spike proves Unity DSP timing materially better for the design.

Choose **MonoGame + C#** instead if:

- the Godot spike fails performance, export, or audio gates;
- code-first development is preferred over visual tooling;
- maximum behavioral similarity to LÖVE is more important than richer tools;
- the team is willing to build or integrate UI, particle, and audio tooling.

Choose **Godot + typed GDScript** instead if:

- browser export is mandatory;
- native desktop remains primary enough for Godot;
- the team accepts weaker compile-time contracts;
- the domain/replay architecture is still kept separate and fully tested.

Stay on **Lua + LÖVE** if:

- the goal is only to finish the current desktop prototype quickly;
- the Godot and MonoGame spikes fail their gates;
- no editor, localization, advanced UI, console, or production tooling need
  justifies the migration;
- the team cannot fund the parity and clean-machine QA period.

## 15. Estimated total effort

For one experienced engineer working full time, the safe parity migration is
approximately **8–14 weeks**, including the feasibility spike, verification,
and desktop release candidate. This is a planning range, not a delivery promise.
Audio findings, visual polish expectations, platform access, and undocumented
behavior can move it.

Part-time solo development should plan by available focused hours rather than
calendar weeks. A second engineer or QA partner helps most during differential
testing, visual parity, platform packaging, and soak—not by porting the same
systems in parallel without shared fixtures.

## 16. Required approvals

Human approval is required before:

- creating the canonical first commit if its exact provenance is disputed;
- authorizing the full port after the spike;
- changing supported platforms;
- choosing paid middleware or a commercial engine plan;
- changing gameplay, balance, UI, or art during the parity phase;
- migrating or deleting real user data;
- publishing or replacing the public build;
- removing the LÖVE rollback artifact.

## 17. Immediate next actions

1. Accept or reject the recommended target:
   **Godot 4.7.1 .NET + C# 12**.
2. Complete Phase 0 and create a real canonical baseline commit.
3. Fix the one lint warning and reconcile `STAGE_STATUS.md`.
4. Add replay/state snapshot export to the Lua baseline.
5. Capture content, save, RNG, screenshots, performance, and package fixtures.
6. Run the 5–8 day Godot feasibility spike.
7. Review the spike report and explicitly authorize or reject the full port.

Until step 7, the correct delivery status is:

> **Migration researched and planned; implementation not started.**

## 18. Official sources

### Godot

- [Godot 4.7.1 official archive](https://godotengine.org/download/archive/)
- [Godot feature and platform list](https://docs.godotengine.org/en/stable/about/list_of_features.html)
- [Godot release policy](https://docs.godotengine.org/en/stable/about/release_policy.html)
- [Godot dedicated 2D features](https://docs.godotengine.org/en/stable/tutorials/2d/index.html)
- [Godot C# basics and limitations](https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/c_sharp_basics.html)
- [Godot audio/gameplay synchronization](https://docs.godotengine.org/en/stable/tutorials/audio/sync_with_audio.html)
- [Godot web export and C# limitation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)
- [Godot command-line and headless operation](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)
- [Godot project export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html)
- [Godot data paths](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html)
- [Godot console support](https://godotengine.org/consoles/)

### C# framework and commercial alternatives

- [MonoGame supported platforms](https://docs.monogame.net/articles/getting_started/platforms.html)
- [MonoGame code-first model](https://docs.monogame.net/articles/tutorials/building_2d_games/02_getting_started/)
- [MonoGame roadmap](https://docs.monogame.net/roadmap/)
- [Unity 6 release support](https://unity.com/releases/unity-6/support)
- [Unity 2026 pricing](https://unity.com/products/pricing-updates)
- [Unity 2D workflow](https://docs.unity3d.com/6000.1/Documentation/Manual/2d-game-creation-wokflow.html)

### Other evaluated engines

- [GameMaker LTS 2026 release and lifecycle](https://gamemaker.io/en/blog/lts-2026-release)
- [GameMaker platform preferences](https://manual.gamemaker.io/lts/en/Setting_Up_And_Version_Information/Platform_Preferences.htm)
- [libGDX 1.14.2 release](https://libgdx.com/news/2026/05/gdx-1-14-1)
- [libGDX project and platform setup](https://libgdx.com/wiki/start/project-generation)
- [libGDX audio limitations](https://libgdx.com/wiki/audio/audio)
- [Bevy stability warning](https://bevy.org/learn/quick-start/introduction/)
- [Bevy release process](https://bevy.org/learn/contribute/project-information/release-process/)
- [Unreal Paper 2D](https://dev.epicgames.com/documentation/unreal-engine/paper-2d-overview-in-unreal-engine)
- [Unreal licensing](https://www.unrealengine.com/license)
- [SDL3 overview and language bindings](https://wiki.libsdl.org/SDL3/FrontPage)
- [SDL3 supported platforms](https://wiki.libsdl.org/SDL3/README-platforms)

### Current engine baseline

- [LÖVE 11.5 changes](https://love2d.org/wiki/11.5)
- [LÖVE distribution model](https://love2d.org/wiki/Game_Distribution)
- [LÖVE filesystem and save locations](https://www.love2d.org/wiki/love.filesystem)
