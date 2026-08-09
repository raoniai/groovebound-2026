# Groove Bound — Latest Version Handover

**Role:** canonical project database and continuation record

**Authority:** live repository evidence plus explicitly approved product decisions

**Canonical runtime:** `groove-bound/`

**Update owner:** `$groove-bound-latest-handover`

This document answers four questions: what is authoritative, what the latest version contains, what is actually verified, and what the next person or agent can safely do. Live checks override stale counts or status prose. Product decisions remain human-owned.

## Live repository snapshot

<!-- LIVE-SNAPSHOT:START -->

_Generated from live repository evidence: 2026-08-09 23:35 AEST_

| Field | Live value |
|---|---|
| Branch | `GPT/stage-2-cutscenes` |
| HEAD | `097c883` — Redesign Groove Bound app icon |
| Upstream | `origin/GPT/stage-2-cutscenes` |
| Compared with `origin/main` | 12 ahead, 0 behind |
| Working changes | 65 files: 1 game, 22 site, 41 skills/package |
| Lua source/test files | 78 source, 39 test |
| Game tree excluding `dist/` | 320.5 MiB |
| Current `.love` artifact | 90.1 MiB |
| Test suite | passed: 253 tests, 0 failures |
| Lint | passed: 0 warnings / 0 errors in 119 files |
| Skill packages | 11 |

<!-- LIVE-SNAPSHOT:END -->

## Current product version

Groove Bound is a bright urban-supernatural survival roguelike built in Lua with LÖVE 11.5. Its current development preview follows:

**Title → Prologue → Character Selection → Character Intro → Backbeat Streets → Inter-stage Cutscene → The Orbit Line → Campaign Ending**

The player selects Joe or Lyra Vex, keeps one build across both stages, levels through seeded three-card offers, combines up to six weapons and four supports, and claims musical chests for reward reels and eligible fusions.

### Current content surface

- Two playable characters with differentiated stats, traits, weapons, and animation states.
- Two three-minute stages with independent Admin duration controls.
- Sixteen base weapons, eight supports, and eight documented fusions.
- Two enemy families with normal enemies, elites, midbosses, and stage bosses.
- Persistent options, keyboard/mouse/gamepad controls, rebindings, deadzone, aim assistance, vibration, flash, shake, fullscreen, and volume controls.
- Adaptive music routing, runtime OGG music, runtime OGV cutscenes, and storyboard fallbacks.
- Arsenal, Admin, results, level-up, pause, options, character selection, cutscene, run, and chest-reward screens.

The public landing site is a separate static presentation under `landing-page/`. It is not authoritative for gameplay or release state.

## Canonical source map

| Area | Authority | Classification |
|---|---|---|
| Runtime | `groove-bound/` | Canonical executable source |
| Core and gameplay | `groove-bound/src/core/`, `src/game/` | Canonical systems |
| Content | `groove-bound/src/content/` | Canonical IDs and definitions |
| Interface | `groove-bound/src/ui/` | Canonical player-facing application flow |
| Audio | `groove-bound/src/audio/`, `assets/music/` | Canonical runtime routing and media |
| Tests | `groove-bound/tests/` | Canonical automated verification |
| Generated runtime art | `groove-bound/assets/generated/` | Runtime when referenced and packaged |
| Generated sources | `*-source.png`, `source-candidates/` | Editable/reference; exclude from package |
| Legacy art and SFX | `groove-bound/assets/legacy/` | First-party legacy with provenance |
| Runtime video | `groove-bound/assets/video/runtime/` | Packaged OGV media |
| Source video | `groove-bound/assets/video/*.mp4` | Reference/source; exclude from package |
| Public site | `landing-page/` | Separate product surface |
| Research and plans | Root dossiers and plans | Reference-only unless explicitly adopted |
| Skill package | `skills/` | Canonical project-specific agent workflows |
| Distribution output | `groove-bound/dist/` | Generated; never hand-edit |

## System status database

| System | Current state | Evidence | Open acceptance |
|---|---|---|---|
| Campaign flow | Committed and pushed preview on `GPT/stage-2-cutscenes` | Source, campaign tests, upstream branch | Full current-HEAD campaign playthrough |
| Deterministic simulation | Tests passed | Named RNG streams and seeded full-run tests | Replay-file format for engine differential testing |
| Progression and fusion | Tests passed | Seeded offers, anti-repeat, capacity and evolution tests | Ongoing balance/play-feel evidence |
| Chest rewards | Committed, pushed, and tests passed | Queued reveals, capped fallbacks, reel and pointer tests | Manual animation/readability playthrough at current HEAD |
| Arena collision and navigation | Committed, pushed, and tests passed | Blocking, movement resolution, and navigation tests | Confirm intentional detouring around compound obstacles in play |
| Enemy projectiles | Committed, pushed, and tests passed | Sprite mapping, attack tuning, content and entity tests | Confirm readability, rate, and boss pressure in play |
| Cutscene video | Four runtime videos committed; one new source video untracked | MP4 sources, OGV runtime files, screen and tests | Convert/map Stage 2 transition if approved; verify fade, pause, final frame, fallback, and all videos manually |
| Music system | Implemented preview | Catalog, router, director, content, OGG assets and tests | BeatClock, latency calibration, groove scoring, and accessibility remain future work |
| Application icon | Committed and pushed; tests passed, package verified, and manual small-size QA verified | Commit `097c883`; Joe/Lyra adventure emblem at 512px RGBA; GB musical alternate; generated sources, prompts, and provenance recorded | Confirm the rebuilt native app icon in the macOS Dock after the next full desktop package build |
| Generic controller support | Implemented preview | Input abstraction, hints, deadzone, vibration, tests | Hot-plug identity, PlayStation glyphs/remapping, wired/wireless matrix |
| Save system | Version 1 envelope | Save tests and injectable backend | Atomic target-engine import and cross-platform clean-machine fixtures |
| Landing page | Committed/pushed baseline plus active uncommitted updates | Home, Lore, Builder, status updater, and current working changes | Review current update scope; deployment and public-live verification |
| Desktop distribution | Local `.love`, universal macOS ZIP, and DMG built | Valid `.love`; ad-hoc signed macOS build script and local artifacts | Upload v0.5.0 draft assets; native Windows/Linux artifacts and test matrix; notarization if required |
| Engine migration | Planned | Engine migration research and parity roadmap | Clean baseline and bounded target-engine spike |
| Groove Bound skills | Locally validated | Eleven packages, official structural validation, package validation, and representative helper execution | Fresh-agent forward tests and optional Codex installation |

## Active working state

The feature branch continues to advance through the HEAD shown in the live snapshot. Earlier gameplay, media, documentation, landing-page, icon, and macOS build work is committed and pushed. A separate landing-page update and the Stage 2 transition MP4 remain active working material. Treat them as protected user work.

Current active themes include:

- `groove-bound/assets/video/cutscene-4-stage2_transition.mp4`, currently an untracked source asset with no recorded runtime OGV integration in this handover.
- Modified and untracked `landing-page/` files for a separate public-site update.
- `LATEST_VERSION_HANDOVER.md` and the repository-owned `skills/` package created by this task.

Do not stage, revert, rename, move, or absorb these files into another task without first resolving the exact scope.

## Verification and delivery ledger

| Layer | Latest state | Meaning |
|---|---|---|
| Automated tests | Refresh in live snapshot | Current source mechanics tested in the local environment |
| Lint | Refresh in live snapshot | Current Lua source and tests statically checked |
| Package | Verified local `.love`: 94,477,855 bytes, SHA-256 `24d0599f9df8d919bc5fa3ded3eab43b0ebf53405f8ef7acb69863d51f1b9680` | Valid ZIP with 190 entries; new app icon present exactly once; GB alternate and generated sources excluded; no forbidden source/docs/test media detected |
| macOS artifacts | Local universal ZIP and DMG built at v0.5.0 | ZIP SHA-256 `a4ec24a59953bbf60d079b97e42a078dc61875b4770ba26f2da27f5d732e5928`; DMG SHA-256 `b87123efb8c4c55d73ee3061ab7e8392b419180d8856899d03917eda4dbeb8e4` |
| Packaged boot | Previously demonstrated; not repeated during skill-package creation | Re-run for the final uploaded candidate in a display-capable context |
| Manual graphical QA | Not complete for the current dirty state | Visual, video, navigation, controller, and feel criteria remain open |
| Local commit | HEAD shown in live snapshot | Recheck exact commit contents; active landing-page work and the untracked Stage 2 MP4 remain outside the skills scope |
| Feature-branch push | Upstream matches local HEAD at the latest refresh | Recheck after future commits |
| Main promotion | Not current | Verify `origin/main` independently |
| Public release/download | Public latest is v0.4.0 with `groove-bound.love` only | Verified through GitHub release data on 2026-08-09; it targets `c4d2699` and trails the feature branch |
| v0.5.0 macOS release | Draft, not published, zero uploaded assets | GitHub draft exists; local ZIP/DMG do not establish public availability |
| Landing deployment | Not proven | Committed/pushed site and local preview do not establish deployment |

## Desktop and engine portability

The canonical Lua source should remain shared across Windows, macOS, and Linux. Build a common `.love`, then create native target artifacts and validate them on their target operating systems.

For an engine migration, keep LÖVE as the golden reference. The leading researched target is a pure C# deterministic domain with a Godot presentation shell, with MonoGame/C# as fallback. Revalidate current stable versions and export restrictions before starting. Do not combine parity work with new gameplay or visual redesign.

## Risks and approval gates

- Current dirty work can be mixed accidentally into a later task.
- Documentation, badges, package hashes, and status counts drift unless refreshed from live evidence.
- Automated checks do not prove the remaining visual, video, navigation, audio, controller, or game-feel criteria.
- Generated and legacy assets require maintained provenance and package separation.
- Website asset copies can drift from canonical runtime assets.
- Signing, notarization, credentials, store submission, public release, deployment, destructive migration, and engine cutover require explicit approval.

## Next safe actions

1. Manually verify navigation, projectile, cutscene, chest-reward, and current-HEAD campaign acceptance criteria.
2. Decide whether the untracked Stage 2 transition MP4 belongs in the next cutscene-media change; do not absorb it into the skill-package commit accidentally.
3. Forward-test the validated local skill package with fresh agents when delegation is explicitly requested; install it into Codex discovery only after choosing the installation method.
4. Decide whether to attach the verified local v0.5.0 artifacts to the existing draft release; publication remains an approval gate.
5. Extend the desktop matrix with native Windows and Linux artifacts from the same verified `.love` candidate.
6. Freeze a clean migration baseline before any Godot or MonoGame spike.
7. Deploy the landing page only when its destination and public state are explicitly approved.

## Continuation history

### 2026-08-09 — Joe and Lyra application icon redesign

- Replaced the runtime application icon with a paired Joe/Lyra adventure
  emblem in the established gold, purple, cyan, and pixel-cosmic language.
- Added a separate `GB` musical monogram alternate with vinyl, waveform,
  speaker, and keytar references as documentation-only artwork.
- Preserved both 1254px generated sources, updated normalized prompts and
  provenance, and kept the alternate/source files outside the runtime package.
- Verified 32px and 64px readability, 512px RGBA structure, media audit, 253
  tests, zero lint warnings/errors, ZIP integrity, package exclusions, macOS
  ICNS conversion, and packaged boot through the title screen.
- Delivery state: committed and pushed to `origin/GPT/stage-2-cutscenes` at
  `097c883`; `origin/main`, release publication, and deployment are unchanged.

### 2026-08-09 — Groove Bound Studio skill package

- Added a repository-owned package of eleven Groove Bound skills.
- Added deterministic project, media, release, portability, and handover helpers.
- Added this canonical latest-version handover database.
- Preserved all pre-existing game and landing-page changes.
- Delivery state: locally validated; all eleven skills passed structural validation, package validation passed, and representative helper scripts executed successfully. Fresh-agent forward tests and global installation remain open.

## Handover protocol

After material work:

1. Refresh the live snapshot.
2. Update only the affected curated status rows.
3. Record automated and manual evidence separately.
4. Preserve open acceptance and unrelated work.
5. Add a concise continuation entry.
6. State the next safe action and any approval gate.
