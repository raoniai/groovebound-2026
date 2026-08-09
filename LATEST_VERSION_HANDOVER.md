# Groove Bound — Latest Version Handover

**Role:** canonical project database and continuation record

**Authority:** live repository evidence plus explicitly approved product decisions

**Canonical runtime:** `groove-bound/`

**Update owner:** `$groove-bound-latest-handover`

This document answers four questions: what is authoritative, what the latest version contains, what is actually verified, and what the next person or agent can safely do. Live checks override stale counts or status prose. Product decisions remain human-owned.

## Live repository snapshot

<!-- LIVE-SNAPSHOT:START -->

_Generated from live repository evidence: 2026-08-10 01:16 AEST_

| Field | Live value |
|---|---|
| Branch | `GPT/stage-2-cutscenes` |
| HEAD | `26c8910` — Publish v0.6.0 game and landing update |
| Upstream | `origin/GPT/stage-2-cutscenes` |
| Compared with `origin/main` | 15 ahead, 0 behind |
| Working changes | 1 files: 0 game, 0 site, 0 skills/package |
| Lua source/test files | 80 source, 41 test |
| Game tree excluding `dist/` | 387.6 MiB |
| Current `.love` artifact | 129.6 MiB |
| Test suite | passed: 269 tests, 0 failures |
| Lint | passed: 0 warnings / 0 errors in 123 files |
| Skill packages | 11 |

<!-- LIVE-SNAPSHOT:END -->

## Current product version

Groove Bound is a bright urban-supernatural survival roguelike built in Lua with LÖVE 11.5. Its current development preview follows:

**Title → Prologue → Character Selection → Character Intro → Backbeat Streets → Inter-stage Cutscene → The Orbit Line → Campaign Ending**

The player selects Joe or Lyra Vex, keeps one build across both stages, levels through seeded three-card offers, combines up to six weapons and four supports, and claims musical chests for reward reels and eligible fusions.

### Current content surface

- Two playable characters with differentiated stats, traits, weapons, logos,
  single-frame idle poses, and movement-speed-driven run animation.
- Two three-minute stages with independent Admin duration controls.
- Sixteen base weapons, eight supports, and eight documented fusions.
- Two enemy families with normal enemies, elites, midbosses, and stage bosses.
- Persistent options, keyboard/mouse/gamepad controls, rebindings, deadzone, aim assistance, four camera zoom levels, vibration, flash, shake, fullscreen, and volume controls.
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
| Chest rewards | Published in v0.6.0, tests passed, and package verified | Higher bounded drop chances; reachable-position search; five concealed reels that resolve to 1, 3, or 5; reward tests | Manual timing and reward-feel playthrough with naturally dropped chests |
| Arena collision and navigation | Published in v0.6.0 and tests passed | Blocking and navigation tests; trunk/base-only tall-object collision; deterministic safe-drop search; upper-layer redraw | Confirm tree, tower, and compound-obstacle layering in a full playthrough |
| Enemy projectiles | Committed, pushed, and tests passed | Sprite mapping, attack tuning, content and entity tests | Confirm readability, rate, and boss pressure in play |
| Cutscene video | Six runtime videos published in v0.6.0 and package verified | Both new MP4s converted to packaged OGV; scene-ID discovery; Circle/`b` skip tests; global mute now drives video-source volume; skip/mute separation visually verified | Physical PlayStation controller check; listening check for mute during each video; full-video fade, pause, final-frame, fallback, and campaign-order playthrough |
| Music system | Implemented preview | Catalog, router, director, content, OGG assets and tests | BeatClock, latency calibration, groove scoring, and accessibility remain future work |
| Application icon | Published in the v0.6.0 macOS app; tests passed, package verified, and manual small-size QA verified | Commit `097c883`; Joe/Lyra adventure emblem at 512px RGBA; native `GrooveBound.icns` present and referenced in the verified app bundle | Confirm the rebuilt native app icon in the macOS Dock on another clean Mac |
| Generic controller and camera support | Published in v0.6.0 and tests passed | Input abstraction, hints, deadzone, vibration, Circle/`b` cutscene skip mapping, persistent 75%/100%/125%/150% camera zoom with plus/minus controls and Settings slider | Physical PlayStation controller check; hot-plug identity, glyphs/remapping, wired/wireless matrix; small-screen zoom play-feel |
| Combat readability and HUD | Published in v0.6.0, tests passed, and visually sampled | Hit slide/pulse, camera shake, damage flash, HP-loss callout, concern below 20%, stronger critical state below 5%, transparent enlarged aim reticle, gameplay-only OS cursor hiding, compact right-side power-up notices, separate 50% panel shades, and tiled nine-slice slot frames with fixed corners | Full combat-feel pass with flash/reduced-flash options and physical controller |
| Character, upgrade, and results interface | Published in v0.6.0, tests passed, and visually sampled | Larger Joe/Lyra selection art and logos; weapon/stat icons; icon-led level-up CTAs; new generated game-over art and rebuilt results layout | Manual defeat/victory results pass and final small-screen readability review |
| Save system | Version 1 envelope | Save tests and injectable backend | Atomic target-engine import and cross-platform clean-machine fixtures |
| Landing page | v0.6.0 three-page source committed and pushed; integrated Home campaign locally browser-verified | Home, Catalog, Builder, 54 category-specific records, fusion cross-links, draggable First Press route, authentic ending video, simplified Resonant selector, desktop and 390x844 QA; DMG buttons use the verified stable GitHub Latest Download URL | Physical-phone refresh check; deployment destination and public-live verification |
| Desktop distribution | v0.6.0 `.love`, universal macOS ZIP, and icon-bearing DMG published as GitHub Latest | Valid `.love`; ad-hoc signed macOS app; verified app boot, signature, icon resource, DMG checksum, GitHub asset digests, and public Latest Download redirect | Native Windows/Linux artifacts and test matrix; Apple notarization if required |
| Engine migration | Planned | Engine migration research and parity roadmap | Clean baseline and bounded target-engine spike |
| Groove Bound skills | Installed, committed, and pushed | Eleven installed packages match repository source; structural, package, and representative helper validation passed | Fresh-agent forward tests |

## Active working state

The v0.6.0 gameplay, media, documentation, landing-page, icon, and macOS packaging batch is committed and pushed on `GPT/stage-2-cutscenes`. Release tag `v0.6.0` points to source commit `26c8910`, and its three verified artifacts are published as GitHub Latest. The only expected local change while this record is being refreshed is this handover file.

Current active themes include:

- The two supplied MP4 files remain reference/source media and are excluded from
  distribution; their OGV derivatives are packaged runtime media.
- Generated source candidates and the earlier opaque UI-chrome atlas remain
  reference-only and are excluded from distribution.
- `landing-page/` is committed source, but the repository has no configured
  public homepage and no deployment has been claimed.
- This handover remains the canonical delivery record after release work.

Do not infer `main` promotion or landing-page deployment from the feature-branch push and GitHub release.

## Verification and delivery ledger

| Layer | Latest state | Meaning |
|---|---|---|
| Automated tests | 269 passed, 0 failed on 2026-08-10 | Current source mechanics, camera zoom, video mute, cursor policy, and transparent UI media tested in the local environment |
| Lint | 0 warnings and 0 errors across 123 files | Current Lua source and tests statically checked |
| Package | Published v0.6.0 `.love`: 135,918,489 bytes, SHA-256 `2840f0612797e4a87622a53d2ae3ff69395c7618f6b43d1016e7926d429f5d1e` | Valid ZIP with 199 entries; both new OGV videos, transparent aim and tiled-slot art, character logos, and game-over art present; source candidates, opaque reference atlas, MP4s, tests, and docs excluded; GitHub digest matches local artifact |
| macOS artifacts | Published v0.6.0 universal ZIP and icon-bearing DMG | ZIP SHA-256 `d2e6e38e6b1fa95a08f43cb610516eae0221a47c2ae2102f153d7aaf6b750b1f`; DMG SHA-256 `6e0b1600b329708653b69805ca9317838a0185ed981b5bf27c4afdef78af87b7`; GitHub digests match |
| Packaged boot | Verified on 2026-08-10 | v0.6.0 packaged app validated content and reached the title screen in LÖVE 11.5; app version, icon resource, ad-hoc signature, and DMG checksum verified |
| Manual graphical QA | Partially verified for v0.6.0 source | Title shade removal, scaled title, character selection, level-up cards, transparent compact HUD, clean empty slots, tiled frames, enlarged aim, hidden gameplay cursor, zoomed view, compact right-side notices, and cutscene skip/mute spacing were visually sampled; audio listening, chest timing, low-HP feel, results, full campaign, and physical controller remain open |
| Source release commit | `26c8910` — Publish v0.6.0 game and landing update | Tag `v0.6.0` and the public release resolve to this source commit |
| Feature-branch push | `origin/GPT/stage-2-cutscenes` contains `26c8910` | Recheck after the handover-only follow-up commit and future work |
| Main promotion | Not current | Verify `origin/main` independently |
| Public release/download | v0.6.0 is published as GitHub Latest with DMG, ZIP, and `.love` assets | Release and tag verified public-live; GitHub digests match local SHA-256 values; stable `/releases/latest/download/` DMG and `.love` URLs returned HTTP 206 |
| Landing download link | Committed and pushed on the feature branch | Home, Catalog, and Builder DMG buttons use `https://github.com/raoniai/groovebound-2026/releases/latest/download/Groove-Bound-macOS.dmg`, verified against v0.6.0 |
| Landing deployment | Not performed or proven | GitHub reports no configured repository homepage; source publication is not a public-site deployment |

## Desktop and engine portability

The canonical Lua source should remain shared across Windows, macOS, and Linux. Build a common `.love`, then create native target artifacts and validate them on their target operating systems.

For an engine migration, keep LÖVE as the golden reference. The leading researched target is a pure C# deterministic domain with a Godot presentation shell, with MonoGame/C# as fallback. Revalidate current stable versions and export restrictions before starting. Do not combine parity work with new gameplay or visual redesign.

## Risks and approval gates

- Feature-branch release state can be mistaken for `main` promotion.
- Documentation, badges, package hashes, and status counts drift unless refreshed from live evidence.
- Automated checks do not prove the remaining visual, video, navigation, audio, controller, or game-feel criteria.
- Generated and legacy assets require maintained provenance and package separation.
- Website asset copies can drift from canonical runtime assets.
- Signing, notarization, credentials, store submission, public release, deployment, destructive migration, and engine cutover require explicit approval.

## Next safe actions

1. Manually listen to mute/unmute during every video, then verify natural chest
   drops, low/critical-health feel, tall-object layering, results, every video,
   and the full current-HEAD campaign.
2. Verify Circle skip on physical PlayStation hardware and cover hot-plug,
   remapping, wired, and wireless behavior.
3. Produce the two planned 4-by-6 enemy movement atlases and wire three-frame
   animation for all sixteen enemy definitions without changing deterministic
   movement or combat timing.
4. Promote the verified source to `main` only through a separately approved
   merge after reviewing the feature-branch delta and CI state.
5. Keep the stable GitHub Latest Download URL in future landing-page releases;
   Apple signing/notarization and site deployment remain separate approval gates.
6. Extend the desktop matrix with native Windows and Linux artifacts from the
   same verified `.love` candidate.
7. Freeze a clean migration baseline before any Godot or MonoGame spike.
8. Deploy the landing page only when its destination and public state are
   explicitly approved.

## Continuation history

### 2026-08-10 — v0.6.0 GitHub release and stable landing download

- Committed the verified game and three-page landing update as `26c8910` and
  pushed `GPT/stage-2-cutscenes` to GitHub.
- Built a universal macOS app at v0.6.0 with the Groove Bound icon, then created
  the DMG, ZIP, and platform-neutral `.love` package.
- Verified 269 tests, lint across 123 files, archive integrity, forbidden-file
  exclusions, app metadata, icon resource, ad-hoc signature, DMG checksum, and
  packaged boot through content validation to the title screen.
- Published `v0.6.0` as GitHub Latest with all three assets; GitHub-reported
  SHA-256 digests match the local artifacts and the tag resolves to `26c8910`.
- Updated Home, Catalog, and Builder DMG buttons to the stable GitHub
  `/releases/latest/download/Groove-Bound-macOS.dmg` URL and verified that the
  public redirect serves the new release.
- Delivery state: game and landing source committed and pushed; v0.6.0 release
  published and public-live verified. `main` is not promoted, the macOS app is
  not Apple-notarized, and no public landing-page deployment is configured or
  claimed. Full campaign, controller, and listening QA remain open.

### 2026-08-10 — Transparent HUD, camera zoom, and cutscene video mute refinement

- Routed global mute and master volume directly into the active cutscene video
  source, so video audio and background music follow the same control.
- Added persistent 75%, 100%, 125%, and 150% camera zoom through plus/minus
  keyboard controls and the Gameplay section in Settings.
- Replaced the opaque HUD atlas with transparent aim and slot-frame assets,
  separate 50% panel shades, and reusable fixed corners plus repeated top,
  bottom, left, and right strips so variable-size frames never stretch the art.
- Enlarged the aspect-correct aim reticle, hid the OS pointer only during active
  play, cleaned inactive weapon/support slots, and retained the pointer on pause
  and other menus.
- Moved ordinary power-up, upgrade, pickup, and evolution notices into compact
  stacked cards beneath the score block on the right.
- Verified 269 tests, zero lint findings, clean diff whitespace, transparent
  RGBA media, a zero-risk media audit, ZIP integrity, packaged boot, and live
  fullscreen samples of the refined HUD, zoom, cursor policy, and right notice.
- Delivery state: locally implemented, tests passed, package verified, and
  partially manual-QA verified; uncommitted and unpushed. Physical-controller
  validation and an audible cutscene mute/unmute playthrough remain open.

### 2026-08-10 — Home campaign consolidation and Resonant cleanup

- Removed the repeated epithets and oversized positioning headlines beneath
  Joe and Lyra's transparent logos while preserving their descriptions,
  attributes, weapon imagery, traits, and full-record actions.
- Audited the standalone Lore page against Home and Catalog, retained its
  unique Resonance origin, stage objectives, First Press route, Stage 2
  transition, and ending, and migrated them into one chronological Home story.
- Retired `landing-page/lore.html`, removed its shared navigation and footer
  links, and replaced the footer destination with the integrated Story anchor.
- Copied the provenance-recorded 1280 by 720 H.264/AAC ending source into the
  website media surface without modifying the canonical game source.
- Verified all three public pages, shared navigation and footer destinations,
  zero missing local references, zero missing images, zero horizontal overflow,
  the Joe/Lyra switch, a 404 for the retired Lore URL, and autoplay of the
  30.08-second ending at desktop and 390 by 844 mobile dimensions. The media
  audit reported zero risks.
- Delivery state: locally implemented and preview-verified; uncommitted,
  unpushed, and undeployed. Game tests and lint were not run for this site-only
  refresh because the canonical game tree contains separate active work.

### 2026-08-10 — Combat feedback, interface art, video, and arena pass

- Integrated both newly supplied videos as runtime OGV cutscenes while keeping
  their MP4 sources out of the package; added immediate Circle/`b` skip and
  separated the video skip control from the global mute control.
- Added hit slide/pulse, camera shake, HP-loss callouts, escalating below-20%
  concern and below-5% critical states, a minimal pointer aim sprite, corrected
  player sprite anchoring, and true one-frame idle poses.
- Rebuilt character selection around larger Joe/Lyra portraits and logos,
  starting-weapon imagery and icon stats; added icon-led HUD, live-data holders,
  level-up stat rows, and reroll/skip CTAs.
- Removed the title-screen central black panel, created and integrated new
  game-over artwork, and rebuilt the results presentation.
- Increased chest availability, constrained drops to reachable positions, and
  concealed 1/3/5 luck outcomes behind a more dynamic five-reel roll.
- Added base-only collision and upper-layer redraw for trees, towers, and other
  tall props so the player can pass behind their tops.
- Recorded the implemented UI sprite batch and a concrete two-atlas,
  three-frame plan for all sixteen enemies in `docs/VISUAL_SPRITE_BATCH_PLAN.md`.
- Verified 264 tests, zero lint findings, clean diff whitespace, media audit with
  no risks, ZIP integrity, packaged boot, and selected fullscreen interface
  views. Fixed package symlink traversal discovered during verification.
- Delivery state: locally implemented, tests passed, package verified, and
  partially manual-QA verified; uncommitted and unpushed. Full campaign,
  physical-controller, results, low-HP feel, natural chest, and enemy-animation
  implementation remain open.

### 2026-08-10 — Category-specific inspectors and connected Catalog

- Rebuilt the shared inspector with six category-specific presentations,
  larger copy, icon-led metrics, text-only color tags, and simplified gem data.
- Added bidirectional weapon, passive, and evolution relationships; linked
  Resonants to starting weapons and enemies to their runtime gem tier.
- Added a full-Catalog deep link to every record plus Catalog-only boss and
  miniboss tags.
- Verified all 54 records, every category count, relationship navigation,
  deep-link focus, focus return, zero missing images, zero console errors, and
  zero horizontal overflow at desktop and 390 by 844 mobile dimensions.
- Delivery state: locally implemented and preview-verified; uncommitted,
  unpushed, and undeployed. Game tests and lint were not run for this site-only
  refresh because the canonical game tree contains separate active work.

### 2026-08-10 — Simplified primary navigation

- Removed the Arsenal shortcut from the shared top bar on Home, Lore, Catalog,
  and Builder while preserving the Home Arsenal section and footer sitemap link.
- Verified the same four primary links on every page, correct current-page state,
  zero horizontal overflow, zero missing local references, and no browser errors.
- Delivery state: locally implemented and preview-verified; uncommitted,
  unpushed, and undeployed.

### 2026-08-10 — Catalog visibility regression fix

- Removed dynamically generated Catalog groups from the optional scroll-reveal
  lifecycle so records cannot remain transparent after the static observer scan.
- Bumped the shared script cache key to `v=20260810-11` across all four pages so
  phone previews fetch the corrected Catalog behavior.
- Verified 54 initial cards across six groups, immediate 16-card Weapons
  filtering at full opacity, Kazoo Pistol details and stat bars, a two-result
  `Keytar` search, zero horizontal overflow, zero missing local references, and
  no browser console errors.
- Delivery state: locally implemented and preview-verified; uncommitted,
  unpushed, and undeployed. A physical-phone refresh check remains open.

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
- Delivery state: installed in Codex, committed as `701ea77`, and pushed to `origin/GPT/stage-2-cutscenes`. All eleven installed copies match repository source and pass structural validation. Fresh-agent forward tests remain open.

## Handover protocol

After material work:

1. Refresh the live snapshot.
2. Update only the affected curated status rows.
3. Record automated and manual evidence separately.
4. Preserve open acceptance and unrelated work.
5. Add a concise continuation entry.
6. State the next safe action and any approval gate.
