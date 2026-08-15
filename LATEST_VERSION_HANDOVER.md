# Groove Bound — Latest Version Handover

**Role:** canonical project database and continuation record

**Authority:** live repository evidence plus explicitly approved product decisions

**Canonical runtime:** `groove-bound/`

**Update owner:** `$groove-bound-latest-handover`

This document answers four questions: what is authoritative, what the latest version contains, what is actually verified, and what the next person or agent can safely do. Live checks override stale counts or status prose. Product decisions remain human-owned.

## Live repository snapshot

<!-- LIVE-SNAPSHOT:START -->

_Generated from live repository evidence: 2026-08-15 23:34 AEST_

| Field | Live value |
|---|---|
| Branch | `codex/enemy-state-animation-v094` |
| HEAD | `28fa8e5` — release: publish desktop v0.9.4 |
| Upstream | `origin/codex/enemy-state-animation-v094` |
| Compared with `origin/main` | 0 ahead, 2 behind |
| Working changes | 0 files: 0 game, 0 site, 0 skills/package |
| Lua source/test files | 121 source, 67 test |
| Game tree excluding `dist/` | 882.4 MiB |
| Current `.love` artifact | 261.5 MiB |
| Test suite | passed: 416 tests, 0 failures |
| Lint | passed: 0 warnings / 0 errors in 190 files |
| Skill packages | 12 |

<!-- LIVE-SNAPSHOT:END -->

## Current product version

Groove Bound is a bright urban-supernatural survival roguelike built in Lua with LÖVE 11.5. Its current development preview follows:

The canonical source and desktop release are now **v0.9.4**. Loose-folder play
displays `v0.9.4-dev`; packaged builds display `v0.9.4`. GitHub Latest exposes
seven synchronized v0.9.4 assets built from clean release commit `28fa8e5`.
The 421-file v0.9.4 public-site bundle is deployed and public-live verified;
Home, Catalog, Builder, shared files, representative assets, and both stable
desktop download routes passed exact HTTPS checks.

**Title → Prologue → Character Selection → Character Intro → Backbeat Streets → The Orbit Line → World Tour → playable Funk, Soul, Disco, and Jazz routes**

The player selects Joe or Lyra Vex, keeps one build across both stages, banks level-up points for seeded three-card offers, combines up to six weapons and four supports, and claims musical chests for reward reels and eligible fusions.

### Current content surface

- Two playable characters with differentiated stats, traits, weapons, logos,
  single-frame idle poses, and movement-speed-driven run animation.
- The complete two-stage Prologue plus eight playable World Tour stages across
  Funk, Soul, Disco, and Jazz; five later routes remain defined future scope.
- Sixteen base weapons, eight supports, and sixteen documented fusions.
- Six authored enemy families across the Prologue and playable World Tour;
  all 49 identities have individual walk, hit, and death sequences, and all 23
  projectile enemies have attack sequences.
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
| Progression and fusion | Published in v0.8.2 and tests passed | Level gains bank spendable points without interrupting play by default; the green Triangle level-point CTA shows its balance in the shared rank badge and is mouse-clickable; every spend advances to a new seeded offer; seeded offers, anti-repeat, capacity and evolution tests remain green | Ongoing balance/play-feel evidence and a full physical-controller run |
| Chest rewards | Published in v0.7.1, tests passed, visually sampled, and package verified | Five large spinning chests converge without number cycling, flash the centre chest, reveal large sprite-backed rewards, and accept Esc/Circle animation skip; capped builds auto-apply the selected utility reward unless an eligible evolution must be shown | Physical-controller timing and reward-feel playthrough with naturally dropped chests |
| Arena collision and navigation | Published in v0.7.0 and tests passed | Tall props now block 90% of their height and redraw their complete opaque sprite above actors; deterministic safe-drop and navigation tests remain green | Confirm every authored tall prop in a full playthrough |
| Enemy projectiles | Committed, pushed, and tests passed | Sprite mapping, attack tuning, content and entity tests | Confirm readability, rate, and boss pressure in play |
| Enemy animation | Published in v0.9.4; automated, strip, real-engine gallery, package, and native boot checks passed | 170 individual runtime strips and 600 frames animate 49 distinct identities across walk, attack where applicable, hit, and death without consuming gameplay RNG; static enemies retain position and facing | Full crowded-combat and boss-scale play-feel pass on physical Windows hardware |
| World-specific mechanics | Released in v0.9.0 and correctly repackaged in v0.9.1; tests, art audit, package boot, and public delivery passed | Funk timing/relay, Soul charge/call-response with Guard overflow, Disco flow/prism relay, Jazz phrase/changes, shared chain/Encore rewards, and boss Break all retain stable IDs; eight animated mechanic states per world are packaged | Full two-stage play-feel pass with both characters and physical controller |
| World bosses | Released in v0.9.0; phase, knockback, projectile, and Break regression tests passed | Eight bosses have increased health/range, 90–96% knockback resistance, wind-up anchoring, three escalating phases, rotating pulse/fan/radial/cross patterns, and heavy multi-hit projectiles; range warnings use calmer outlines | Prolonged high-power-build balance pass and physical-device projectile-readability QA |
| Cutscene video | Six runtime videos published in v0.6.0 and package verified | Both new MP4s converted to packaged OGV; scene-ID discovery; Circle/`b` skip tests; global mute now drives video-source volume; skip/mute separation visually verified | Physical PlayStation controller check; listening check for mute during each video; full-video fade, pause, final-frame, fallback, and campaign-order playthrough |
| Music system | Published in v0.8.0; tests and release media checks passed | One continuous World Tour hub theme, nine world-specific soundtrack packs, and 28 optimized route, pressure or boss, and finale cues; connected menu overlays preserve or duck the current musical context | Final creative listening pass across all cues; BeatClock, latency calibration, groove scoring, and accessibility remain future work |
| Application icon | Published in the v0.6.0 macOS app; tests passed, package verified, and manual small-size QA verified | Commit `097c883`; Joe/Lyra adventure emblem at 512px RGBA; native `GrooveBound.icns` present and referenced in the verified app bundle | Confirm the rebuilt native app icon in the macOS Dock on another clean Mac |
| Generic controller and camera support | Published in v0.8.1 and tests passed | Level-up navigation uses strict spatial rows for D-pad, arrow keys, and WASD: left/right never wrap into another row, while up/down selects the nearest aligned item; existing right-stick aim and controller parity remain intact | Physical PlayStation controller check; hot-plug identity, glyphs/remapping, wired/wireless matrix |
| Combat readability and HUD | v0.9.2 projectile candidate tested; earlier interface states manually verified | Every player weapon owns a separate five-stage atlas; high-power effects have longer recovery windows; beams preserve authored proportions; rank increases protective geometry | Fresh unlocked graphical pass at minimum and reference sizes plus prolonged combat feel with flash/reduced-flash options |
| Character, upgrade, and results interface | Published in v0.7.1, tests passed, and visually sampled | Anton/Oswald typography, modular nine-slice upgrade cards, relevant-equipped evolution rows only, exact icon-led gain-to-total attributes, generated NEW badge, pickup-art utility choices, existing reroll/skip sprite CTAs, and bright sprite-backed menu focus | Manual defeat/victory results pass and final small-screen readability review |
| Save system | Version 2 profiles and slots | Save, migration, profile, export and World Tour session tests | Cross-platform clean-machine fixtures |
| Landing page and repository README | v0.9.4 bundle deployed and public-live verified | Home, Catalog, and Builder show v0.9.4, match local bytes, expose the 213-record Catalog, and retain stable Latest desktop URLs | Complete physical-phone refresh; `main` promotion remains separate |
| World Tour runtime atlases | v0.9.1 package verified after the v0.9.0 lock-sprite omission | Four Stage 2 environment atlases, four eight-state mechanic atlases, 32 individual mechanic sprites, and the directly loaded World Tour lock sprite pass source, archive, RGBA, transparency, grid, and packaged-reference checks | Full in-motion readability and collision/layering pass in all eight World Tour stages |
| Desktop distribution | v0.9.4 published as GitHub Latest | One clean common payload feeds the universal macOS ZIP/DMG and branded Windows x64 ZIP; all seven public assets expose SHA-256 digests and both packages passed native bootstrap | Physical Windows play, prolonged unlocked-Mac combat play, Apple signing, and notarization remain open |
| Engine migration | Planned | Engine migration research and parity roadmap | Clean baseline and bounded target-engine spike |
| Groove Bound skills | Twelve repository skills validated; version-sync skill committed and pushed | The fail-closed checker is wired into source, local/candidate, GitHub, landing, and public phases; repository package validation passes 12 of 12 | Unlocked-Mac visual forward test remains open |

## Active working state

The v0.9.4 release is on `codex/enemy-state-animation-v094` and the canonical
release branch `codex/world-overhaul-v090`. Feature commit `4224db8` and release
commit `28fa8e5` are pushed to both branches; `main` remains separately gated.
GitHub release `v0.9.4` is Latest and targets `28fa8e5`. Release workflow
`31887077955` completed source verification, the 416-test suite, common
packaging, macOS and Windows native packaging, candidate parity, boot markers,
publication, and GitHub Latest verification. CI `31887077883` also passed; the
standalone Windows push run was superseded by the successful Windows job inside
the release workflow. The 421-file site was deployed over FTPS with rollback
`20260815-233221-v0.9.4` and passed byte-for-byte public verification. The
original protected workspace and its unrelated dirty material were not changed.

The v0.9.0 startup failure was a package-manifest defect: `src/assets.lua`
directly loaded `world-tour-sprites/ui/world-tour/locked-world.png`, while a
blanket package exclusion removed that directory. v0.9.1 includes that required
file and adds a release gate which scans complete runtime asset paths in Lua and
rejects any archive that omits one. The old v0.9.0 release remains traceable but
is no longer Latest.

Current active themes include:

- The two supplied MP4 files remain reference/source media and are excluded from
  distribution; their OGV derivatives are packaged runtime media.
- Generated source candidates and the earlier opaque UI-chrome atlas remain
  reference-only and are excluded from distribution.
- `landing-page/` is the canonical public-site source. The server supports FTPS
  and the confirmed remote root is `/public_html/raoni.ai/groovebound`. The
  dedicated `groove-bound-ftp` credential is stored in macOS Keychain; no secret
  is stored in the repository.
- The campaign identity, Builder redesign, Round 2 Home refinements, transparent
  Prologue and World Tour marks, stage wordmarks, and Jazz public route are
  committed, pushed, and deployed. The Orbit logo remains exactly `ORBIT LINE`.
  All three public pages display v0.9.4 and retain stable Latest download URLs.
- The Catalog has 213 rendered records across 10 focused categories. Category
  filters combine independently and clear together; search is compact and
  magnifier-led; section headings are text-only; record counts and the
  pointer-following Inspect cue are removed; every card uses a category-colored
  outline. Six unlocked and future World cards use their canonical emblem art.
  Scenario Backgrounds contains 88 authentic
  environment, expansion, floor, and background assets across both Prologue
  stages and Funk, Soul, Disco, and Jazz. The durable site-sync rule now requires
  this catalog and FTPS loop for every future playable world or game/playable
  asset unless deployment is explicitly withheld.
- This handover remains the canonical delivery record after release work.

Do not infer `main` promotion from the feature-branch push, GitHub release, or landing deployment.

## Verification and delivery ledger

| Layer | Latest state | Meaning |
|---|---|---|
| Automated tests | v0.9.4 release: 416 passed, 0 failed in three local runs plus Linux and Windows release workflows on 2026-08-15 | State selection, death VFX, asset inventory, deterministic campaign completion, and existing systems are covered |
| Lint | 0 warnings and 0 errors across 190 files on 2026-08-15 | Current Lua source and tests statically checked |
| Common package | Published v0.9.4 `.love`, 274,166,402 bytes, SHA-256 `cdd9d24d181aa0d1c80152249b0b344c080c55088001802edd61c027247ad922` | Clean release marker, all 170 runtime strips, source-candidate exclusion, and identical embedding in both native packages |
| macOS artifacts | Published universal ZIP SHA-256 `79e31124bf41d4b02d00cb4aa0319e664f85cad58b760c61330c37d612ff858c`; DMG SHA-256 `1516536b3be5b4d977b3186c5286c76b475b691c9add15ec7968d453789b9afc` | Archive integrity, bundle v0.9.4, ad-hoc signature structure, DMG checksum, common payload, and packaged boot passed; not notarized |
| Windows artifact | Published branded x64 ZIP SHA-256 `9d66894e074652ed6b4efd0d06a778c40905ab65add666e61d2388300da76014` | Pinned official LÖVE 11.5 runtime, v0.9.4 icon/version metadata, common-payload equality, archive integrity, and native packaged boot passed; unsigned |
| Packaged boot | Verified in Windows and macOS release jobs; the local packaged Mac app also rendered the v0.9.4 title screen | Both packages reached `boot-complete`; this proves startup integrity, not a full physical-hardware combat run |
| Manual graphical QA | All 49 enemies and 170 strips inspected in a real-engine seven-page LÖVE gallery; packaged Mac title rendered v0.9.4 | Multiple time samples confirmed live frame progression; six full contact sheets verified every authored frame; physical Windows and prolonged crowded-combat feel remain open |
| Source release commit | `28fa8e5` — release: publish desktop v0.9.4 | Tag `v0.9.4` targets full commit `28fa8e5255138e63a159c5dc502f0795f1f34543` |
| Feature-branch push | `origin/codex/enemy-state-animation-v094` and `origin/codex/world-overhaul-v090` contain the release commit | `main` remains independently unpromoted; original local dirty work is preserved |
| Main promotion | Not current | Verify `origin/main` independently |
| Public release/download | v0.9.4 is published as GitHub Latest with seven synchronized desktop assets | GitHub API and the fail-closed version gate confirm every required asset and SHA-256 digest; stable Latest routes resolve to v0.9.4 |
| Landing download links | Public Home, Catalog, and Builder display v0.9.4 and reference stable macOS/Windows Latest routes | HTTPS bytes match local source; routes resolve to the expected 288,548,660-byte Mac DMG and 278,882,106-byte Windows ZIP |
| GitHub README presentation | Landing-styled rewrite committed and pushed at `f96acf9` | GitHub Markdown API rendered 21,124 bytes with 28 images, 50 links, and 3 tables; all 29 local references and 7 navigation anchors resolve; default-page visibility still depends on merging to `main` |
| Landing deployment | v0.9.4 421-file bundle deployed and public-live verified | Rollback captured at `20260815-233221-v0.9.4`; six core files, directory index, representative assets, badges, GitHub Latest, and stable desktop routes pass public parity |

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
2. Play both Jazz stages with Joe and Lyra; verify enemy/boss readability,
   blue-note mechanic timing, prop collision/layering, floor contrast and the
   temporary Electro-derived music fallback before commissioning Jazz audio.
3. Verify Circle skip on physical PlayStation hardware and cover hot-plug,
   remapping, wired, and wireless behavior.
4. Perform a crowded-combat animation feel pass across all six enemy families
   on physical Mac and Windows hardware.
5. Promote the verified source to `main` only through a separately approved
   merge after reviewing the feature-branch delta and CI state.
6. Keep the stable GitHub Latest Download URL in future landing-page releases;
   run the dry-run and public-verification commands around each approved FTPS
   deployment. Apple signing/notarization remains a separate approval gate.
7. Complete native Windows 10/11 acceptance for the published x64 ZIP, and
   extend the desktop matrix with a native Linux artifact from the same verified
   `.love` candidate.
8. Freeze a clean migration baseline before any Godot or MonoGame spike.
9. Reconcile the original protected workspace with the released branch only in
   a separate, reviewed pass; do not overwrite its unrelated dirty material.

## Continuation history

### 2026-08-15 — v0.9.4 individual enemy state animation release

- Added 170 individual runtime strips and 600 frames: walk, hit, and death for
  all 49 enemies plus attack sequences for all 23 projectile enemies.
- Replaced the Breakbeat Bruiser alias with a distinct orange-and-black
  drum-machine brawler and complete four-state animation set.
- Passed six roster contact-sheet reviews, a seven-page live LÖVE gallery with
  repeated frame-progression samples, three local 416-test runs, zero lint
  findings, media and portability audits, clean package verification, and a
  local packaged-Mac title-screen check.
- Published v0.9.4 from `28fa8e5`; CI `31887077883` and desktop release
  `31887077955` passed, including branded Windows and universal macOS native
  builds, both bootstrap markers, candidate parity, and GitHub Latest checks.
- Deployed the 421-file site with rollback `20260815-233221-v0.9.4`; exact
  public bytes, the 213-record Catalog, version badges, and both stable desktop
  routes passed public verification.

### 2026-08-15 — v0.9.3 complete enemy animation release

- Added six runtime animation atlases covering all 49 definitions and 48
  unique visuals with three-frame loops for Backbeat through Disco and
  four-frame loops for Jazz.
- Preserved enemy mechanics, balance, collision, attacks, pooling, facing,
  static positions, and deterministic gameplay RNG; visual phase is derived
  independently from stable identity and spawn coordinates.
- Passed 415 tests, zero lint findings across 189 files, zero-risk media audit,
  full-resolution atlas inspection, loose and packaged LÖVE boot, and local
  source/native payload parity.
- Published v0.9.3 from `ded61e1`; CI `31867133775`, standalone Windows
  `31867133809`, and desktop release `31867133836` all passed. Both native
  packages reached `boot-complete`, and the exact seven public assets are
  mirrored locally with checksum and candidate parity checks passing.
- Deployed the 420-file site with rollback `20260815-153846-v0.9.3`; six core
  files, directory index, representative assets, badges, GitHub Latest, and
  both stable desktop routes passed public HTTPS parity.

### 2026-08-15 — v0.9.2 projectile release

- Promoted the canonical source version to v0.9.2 and synchronized loose-source
  and local landing-page labels while retaining stable Latest download routes.
- Moved historical release notes to `packaging/archive/` and preserved active
  v0.8.4 local binaries under `dist/archive/v0.8.4-original-workspace/` rather
  than deleting them.
- Passed 410 tests, zero lint findings across 187 files, clean diff whitespace,
  zero-risk media audit, portability audit, World Overhaul art verification,
  and source plus landing version gates.
- Published release commit `eeadf67` to both the projectile feature branch and
  canonical World Overhaul release branch; tagged v0.9.2 is GitHub Latest.
- Passed all three GitHub workflows: CI `31853004637`, standalone Windows
  `31853004643`, and desktop release `31853004722`.
- Mirrored the exact seven published assets locally, passed checksum, archive,
  candidate/local version, Mac signature/DMG, embedded-payload, and packaged
  Mac boot checks. The game was opened locally from the published Mac bundle.
- Delivery state: committed, pushed, packaged locally for Mac and Windows, and
  public-live verified on GitHub. Public-site v0.9.2 deployment and physical
  Windows play remain separate approval/QA gates.

### 2026-08-14 — separate animated projectile-system candidate

- Created the work only in an isolated branch from verified World Overhaul
  v0.9.1 head `50c16f6`; the original protected 0.8.4 workspace and its earlier
  mistaken shared-atlas implementation remain untouched as recovery material.
- Replaced player attacks with nine deterministic families and 32 unique
  five-frame RGBA strips under `assets/generated/projectiles/`. The old runtime
  projectile atlas is removed, while source candidates and prompt provenance
  remain package-excluded.
- Added rank-scaled coverage, blast radius, area radius, orbit distance, beam
  length/width, storm reach/target count and wave width. Rank-one protective
  ranges and evolved scenario-wide storms have focused regression coverage.
- Passed 410 tests, zero lint findings across 187 files, World Overhaul art
  verification, media audit with zero risks, clean diff whitespace and package
  inspection. The dirty candidate package contained all 32 separate strips,
  no source candidates and no retired atlas; the release verifier correctly
  rejected only its dirty marker.
- Replaced the earlier single-concept procedural animation with four retained
  source boards and 160 distinct authored frames. All 32 independent runtime
  atlases are 1920x128 RGBA, contain five unique frame hashes, and preserve
  beam proportions with uniform runtime scaling.
- Delivery state: locally implemented, booted and ready for a new manual pass.
  Commit, push, release,
  deployment and manual in-motion approval remain open.

### 2026-08-14 — v0.9.1 desktop startup package hotfix

- Reproduced the public v0.9.0 DMG crash and proved that the source lock sprite
  existed while the common `.love` archive omitted it. The cause was a blanket
  exclusion for the individual World Tour sprite directory conflicting with a
  direct startup load in `src/assets.lua`.
- Added the lock sprite to the release payload and extended package verification
  to scan complete runtime asset paths in Lua; the old v0.9.0 archive fails this
  gate and the clean v0.9.1 archive reports 74 references with zero missing.
- Passed 398 tests, clean lint across 186 files, world-overhaul art checks,
  source/local/candidate/GitHub/landing/public version gates, macOS DMG
  validation, and macOS plus Windows packaged `boot-complete` markers.
- Published seven digest-bearing v0.9.1 GitHub assets from commit `ed092b9` in
  workflow `31783132056`; CI `31783131840` and Windows workflow `31783131924`
  also passed. Cleared generated `dist/` and repopulated its `.love`, DMG, app,
  Windows package, manifest, checksums, and extracted EXE from the exact public
  release, then verified both embedded payloads identify v0.9.1 and contain the
  lock sprite.
- Deployed the 420-file site by FTPS with rollback
  `20260814-182535-v0.9.1`; core pages, representative assets, badge identity,
  GitHub Latest, and stable Mac/Windows routes are public-live verified.
- Delivery state: committed, pushed, released, deployed, and public-live
  verified. `main` promotion, Apple notarization, and physical graphical QA on
  another Mac and Windows machine remain separate.

### 2026-08-14 — Jazz Home selector emblem correction

- Corrected the Home World Tour selector so Jazz uses the canonical 512px
  transparent emblem in its icon slot and retains the existing Jazz wordmark in
  its logo slot, matching the established Funk, Soul, and Disco presentation.
- Confirmed the website emblem is byte-identical to the canonical runtime
  emblem, rendered all four playable-world pairings in a headless visual fixture,
  and kept the Jazz wordmark as the accessible label.
- Verified JavaScript syntax, clean diff whitespace, the 420-file v0.8.5 site
  package, landing-version parity, byte-identical public Home source, explicit
  live emblem-plus-logo paths, and the complete public version gate without
  opening the game.
- Committed and pushed the correction at `17d135f`, deployed it by FTPS with
  rollback `20260814-155453-v0.8.5`, and public-live verified the result.
- Delivery state: committed, pushed, deployed, and public-live verified. A
  physical-phone refresh and `main` promotion remain separate.

### 2026-08-14 — Compact combinable Catalog filters and canonical world emblems

- Removed decorative icons and record counts from Catalog section headings and
  removed the global pointer-following Inspect cue while retaining semantic
  keyboard and click inspection behavior.
- Rebuilt category filtering as a compact multi-select union with independent
  pressed states, a magnifier-led search field, and one X Clear filters control.
  Empty selection restores the full ten-category, 212-record Catalog.
- Added persistent category-colored outlines to every asset card and replaced
  the six World card graphics with byte-identical copies of the canonical 512px
  transparent runtime emblems.
- Verified JavaScript syntax, clean diff whitespace, 420 allowlisted public
  files, 229 rendered local image references with zero missing files, 212 cards,
  ten text-only section headings, zero Inspect cues, multi-filter/clear behavior,
  responsive width, and zero media-pipeline risks without opening the game.
- Committed the Catalog change at `377edb0`, pushed it to
  `origin/codex/world-tour-v1`, deployed the 420-file v0.8.5 site by FTPS with
  final status-sync rollback `20260814-143926-v0.8.5`, and passed byte/public version checks for
  all core pages, scripts, representative assets, both stable desktop routes,
  and GitHub Latest v0.8.5.
- Delivery state: committed, pushed, deployed, and public-live verified. `main`
  promotion and physical-phone review remain separate.

### 2026-08-14 — Jazz Catalog emblem and complete scenario inventory

- Generated a text-free Jazz World emblem with OpenAI image generation,
  preserved the untouched source candidate, removed chroma with the project
  media helper, and recorded prompt, dimensions, alpha bounds, and SHA-256.
- Expanded the Catalog to 137 live records with one General emblem block and 12
  Jazz scenario records: eight environment sprites and four floor/background
  surfaces. The existing eight Jazz enemies remain fully represented.
- Verified 137 rendered cards, 11 category groups, responsive General styling,
  all local asset requests, JavaScript syntax, 375 public references, zero media
  risks, 386 tests, zero lint findings, and clean package integrity. The emblem
  is site-only, so the published Mac/Windows v0.8.4 payload was not changed.
- Committed and pushed source at `59ca969`, deployed 375 files by FTPS with
  final parity rollback `20260814-132629-v0.8.4`, and passed public byte checks for all core
  pages plus the new emblem and representative Jazz environment/floor assets.
- Added the standing project rule that every future playable world or game asset
  must update the Catalog and complete the approved FTPS/public verification
  loop unless the user explicitly withholds deployment.
- Delivery state: committed, pushed, deployed, and public-live verified. `main`
  promotion and physical-phone review remain separate.

### 2026-08-14 — v0.8.4 Jazz desktop and landing release

- Created clean release commit `b62d1d0` from the current canonical game and
  site surfaces while preserving unrelated archives, promo assets, PSD work,
  generated screenshot folders, and the original dirty workspace.
- Published Jazz as the fourth playable World Tour route with Blue Note Borough,
  Midnight Changes, eight enemies, two bosses, canonical runtime atlases, and
  matching isolated website sprites.
- Release workflow `31763025903` passed 386 tests, clean lint, portability,
  deterministic common-payload parity, native Windows regression and branding,
  Mac and Windows boot markers, complete candidate checks, and GitHub Latest.
- Published seven digest-bearing v0.8.4 GitHub assets. The common payload is
  209,627,657 bytes with SHA-256
  `b21a780913773bb906378ff368ac12920ccfddb89bfb26422ae3886a692005fc`.
- Deployed the 374-file landing bundle to the configured FTPS destination after
  capturing a rollback. Home, Catalog, Builder, core scripts, representative
  assets, public badges, and stable Mac/Windows routes are public-live verified.
- Delivery state: committed, pushed, released, deployed, and public-live
  verified. `main` promotion, code signing/notarization, physical Windows and
  controller QA, and manual Jazz visual/audio/play-feel acceptance remain open.

### 2026-08-13 — Jazz World local activation and runtime art suite

- Activated Jazz as the fourth core route after Disco, with House following it,
  while preserving the nine-world cap and the existing 19-perk economy. Added
  Blue Note Borough and Midnight Changes, eight stable enemy IDs, two bosses,
  two deterministic wave sets and the `jazz_improvisation` blue-note mechanic.
- Generated and integrated exact runtime enemy, environment and floor atlases;
  promoted the existing project-owned Jazz identity mark; preserved generator
  sources outside the package; and recorded prompts, mappings, transforms and
  hashes in generated-asset provenance.
- Verified 386 tests including three seeded Jazz routes, zero lint findings in
  180 files, clean diff whitespace, zero media-audit risks, content validation,
  common archive integrity and exact Jazz package inclusion. Rebuilt `.love`:
  209,627,657 bytes, SHA-256
  `910005215c3ffca01783233314d2cc7f762d096c4cb05a9f5c55b4054a389071`.
- The game was deliberately not launched because the user was using the
  computer. Manual visual, audio, controller and play-feel acceptance remains
  open. Jazz temporarily routes through the existing Electro soundtrack pack;
  dedicated Jazz music remains a creative follow-up.
- Delivery state: locally implemented, tests passed, media audited and common
  package verified; uncommitted, unpushed, unreleased and undeployed.

### 2026-08-13 — v0.8.4 visible build identity and version-sync gate

- Reconciled the tracked game folder to the published v0.8.3 source line, then
  established `groove-bound/VERSION` as the single v0.8.4 candidate source.
  Loose source displays `v0.8.4-dev`; release payloads display `v0.8.4`.
- Added tiny build text to the title-screen lower corner and pause-panel corner,
  plus unit coverage for source, packaged, and mismatch states.
- Rebuilt the common `.love`, universal macOS ZIP, and DMG from one payload.
  The local gate passes archive integrity, marker/version parity, Mac bundle
  metadata, control-character exclusions, and embedded-payload hash parity.
- Added and installed `$groove-bound-version-sync`; wired it into release CI,
  desktop packaging, and the landing publisher before and after public changes.
  Removed hard-coded release defaults and stale landing download digests.
- Verified 383 tests, zero lint findings across 178 files, portability, the
  12-skill package, a 354-file site dry run, and local v0.8.3 badge parity.
  Manual title/pause inspection remains unverified because the Mac was locked.
- GitHub Latest v0.8.3 is healthy, but all three live landing badges remain at
  v0.8.2. Local source is corrected; deployment and any v0.8.4 publication are
  explicit approval gates.

### 2026-08-13 — v0.8.2 gameplay interface and synchronized desktop release

- Reworked the live run HUD and pause/level-up presentation: removed Run Seed,
  supporting menu copy, pause subhead, and bottom gameplay controls; moved
  gameplay mute into Pause; centred the sprite-framed World Tour mechanic card
  below the timer; consolidated stage/remaining timing; formatted score groups;
  and introduced shared sprite rank, level-point, MAX, HP, and XP devices.
- Manual QA covered title, settings, active campaign and World Tour runs, pause,
  level-up, results, and the supported 800 x 600 minimum. The release integration
  passes 376 tests, zero Luacheck findings across 176 files, Linux CI, native
  Windows packaging tests, both packaged boot smokes, and payload parity.
- Published GitHub Latest v0.8.2 from clean commit `693885a` with seven
  digest-matched assets. The common payload SHA-256 is `73b5e4ad…fd07`; Windows
  ZIP is `5fee0bfc…e360`; Mac DMG is `0233c053…30e9`.
- Deployed the v0.8.2 landing badge over FTPS and verified all 354 public files,
  representative assets, directory index, and both stable Latest downloads
  byte-for-byte. Rollback: `20260813-142316-v0.8.2`.
- Remaining acceptance is physical Windows/PlayStation/audio/SmartScreen and a
  complete long-form campaign run. Windows is unsigned; macOS is ad-hoc signed
  and not notarized. `main` remains unpromoted, and dirty site/reference work in
  the active workspace remains uncommitted.

### 2026-08-13 — Evergreen public-facing landing presentation

- Kept v0.8.1 only in the top navigation badge on Home, Catalog, and Builder.
  Removed the footer version and release-notes links plus build-difference,
  development-status, and update-summary copy from visible and interactive
  public content.
- Reframed the Prologue, World Tour, screenshots, Catalog, download scenes, and
  Builder page around characters, musical combat, progression, worlds, and
  player experience. Locked worlds now use coming-soon and secret-route teasers.
- Rebuilt and uploaded 354 allowlisted files totalling 246,537,891 bytes through
  FTPS. Home, Catalog, Builder, shared code, directory index, representative
  logos, and both digest-matched GitHub Latest routes passed public verification.
- A live 1280-pixel browser audit found no broken images or horizontal overflow,
  no version outside the header, and no remaining Public build or Release notes
  copy. Physical-phone refresh and audio listening remain open. Delivery state:
  deployed and public-live verified; source remains uncommitted and unpushed.

### 2026-08-13 — v0.8.1 synchronized desktop release and landing deployment

- Published player-controlled banked level-up points, strict directional
  navigation, persistent automatic/manual preference, the sprite-backed point
  CTA, and the compact dismissible alert stack from clean commit `66b58bb`.
- Verified 372 tests, zero lint findings across 173 files, portability, common
  archive exclusions, payload parity, native Windows packaging, universal Mac
  packaging, and boot-complete markers on both platform runners.
- Published GitHub Latest v0.8.1 with seven digest-matched assets. Full public
  downloads of the 217,229,739-byte DMG and 207,443,365-byte Windows ZIP match
  GitHub's SHA-256 values and both embed `version=0.8.1`, commit `66b58bb678ae`,
  and `dirty=false`.
- Updated and deployed the 354-file landing site over FTPS. Home, Catalog,
  Builder, shared code, representative assets, visible v0.8.1 labels, and both
  stable Latest routes are public-live verified. The active local workspace was
  preserved on its divergent dirty branch and was not force-updated.
- Physical Windows graphical/audio/controller/SmartScreen/save-migration QA,
  Windows signing, Apple notarization, full campaign play, and `main` promotion
  remain open.

### 2026-08-13 — Transparent game icon refresh

- Preserved the two supplied 512-by-512 RGBA promo sources and replaced the
  flattened website identity with their transparent derivatives. The GB
  monogram now serves navigation, footer, catalog filter, and favicon use; the
  Joe and Lyra Vex artwork serves the desktop download scene and touch icon.
- Added cache-versioned references across Home, Catalog, and Builder, then
  recorded exact source-to-website mappings and hashes in promo provenance.
- Built and uploaded 354 allowlisted public files totaling 246,537,439 bytes.
  Public Home, Catalog, Builder, shared code, directory index, and both stable
  v0.8.0 downloads passed automated verification.
- Downloaded all three public icon derivatives after deployment; their SHA-256
  hashes match the approved local website copies. Delivery state: public-live
  verified; source remains uncommitted and unpushed. The rollback bundle is at
  `landing-page/.deployment/rollbacks/20260813-132514-v0.8.0`.

### 2026-08-13 — Automated FTPS publisher and public v0.8.0 deployment

- Implemented a clean release builder, dedicated macOS Keychain setup, FTPS
  connection helper, dry-run manifest, read-only remote inspection, rollback
  capture, atomic dependency-ordered uploader, and verification-only mode.
- Confirmed encrypted FTPS and the exact remote root
  `/public_html/raoni.ai/groovebound`; copied the existing host credential into
  the dedicated `groove-bound-ftp` Keychain service without exposing it.
- Built and uploaded 353 allowlisted public files totaling 245,956,798 bytes.
  Source candidates, research, scripts, notes, credentials, and development
  files were excluded. Existing unrelated remote entries were not deleted.
- Public verification matched Home, Catalog, Builder, CSS, JavaScript, status
  data, the directory index, and representative campaign assets byte-for-byte.
  GitHub Latest still resolves to the exact v0.8.0 DMG and Windows ZIP.
- Browser checks at 1440 by 1000 and 390 by 844 found no failed images or
  horizontal overflow. Home shows four paired platform CTAs; Catalog and Builder
  each show three, with the v0.8.0 music copy present throughout.
- Delivery state: deployment public-live verified; automation locally
  implemented and Keychain-configured; source uncommitted and unpushed. The
  rollback bundle is stored under ignored `landing-page/.deployment/`.

### 2026-08-13 — v0.8.0 landing sync and FTP automation plan

- Updated Home, Catalog, and Builder to the exact public v0.8.0 release and
  added the continuous World Tour hub theme, nine world soundtrack packs, and
  28-cue music story without changing the established module order.
- Triple-checked both stable GitHub Latest downloads against the public v0.8.0
  assets: the DMG returns HTTP 200 and 214,798,572 bytes; the Windows x64 ZIP
  returns HTTP 200 and 204,991,519 bytes.
- Resolved every local HTML and JavaScript asset reference, restored the missing
  World Tour header logo and other archived public assets, confirmed Home,
  Catalog, and Builder return HTTP 200, and passed JavaScript syntax, diff
  whitespace, 355 game tests, and Lua lint.
- Added an approval-gated FTP plan with an allowlisted release package, macOS
  Keychain credential storage, dry-run manifest, asset-first/HTML-last upload,
  rollback bundle, no-delete default, and post-upload HTTPS verification. The
  first connection must confirm FTPS support and the remote root read-only.
- Delivery state: locally implemented and FTP-ready; uncommitted, unpushed, and
  not uploaded. The public raoni.ai page still shows v0.7.1. Current rendered-
  browser regression was blocked by the app's local-URL safety policy and
  remains open with physical-phone and listening checks.

### 2026-08-12 — Direct World Tour-to-screenshots flow

- Removed the complete Home World Tour mechanics presentation: gameplay sprites,
  selection and grade menus, World Tour interface, menu controls, extra evolution
  and perk galleries, and the musical/Encore chest subsection.
- Moved the screenshot section directly after World Tour in the source HTML and
  retained the same adjacency in the enhanced module order. Tightened the visual
  handoff to 158 pixels at 1440 by 1000 and 104 pixels at 390 by 844.
- Browser checks confirm zero removed blocks, four current-build screenshots,
  exact World Tour-to-screenshots adjacency, and zero horizontal overflow at both
  breakpoints. JavaScript syntax, 227 local references, `git diff --check`, 350
  game tests, and Lua lint pass.
- Delivery state: locally implemented and responsive-browser verified;
  uncommitted, unpushed, and undeployed. Physical-phone refresh and any commit,
  push, main promotion, or deployment remain separate actions.

### 2026-08-12 — Simplified Home hero actions

- Removed the secondary `Start with the Prologue` hero link and its unused CSS.
  The hero now ends with the macOS, Windows, and repository actions; the primary
  navigation continues to provide the direct Prologue route.
- Browser checks confirmed three remaining actions, no stale CTA text, no
  horizontal overflow at 1440 by 1000 or 390 by 844, and equal 343-pixel mobile
  action widths. JavaScript syntax, local references, `git diff --check`, and the
  refreshed 350-test handover snapshot pass.
- Delivery state: locally implemented and responsive-browser verified;
  uncommitted, unpushed, and undeployed.

### 2026-08-12 — Inspectable campaign enemy rosters

- Connected the ten pictured Backbeat and Orbit enemies and bosses plus all 24
  pictured Funk, Soul, and Disco enemies and bosses to their existing inspector
  and Catalog records. The figures now expose an Inspect cue, pointer cursor,
  visible focus treatment, semantic button role, and descriptive accessible name.
- Verified click, Enter, and Space activation; the shared detail dialog returns
  focus to the originating figure when closed. Its View in full catalog action
  routes to and focuses the exact record. World enemy inspectors additionally
  expose the matching World and Resonance-drop records; the Catalog continues to
  contain all 40 enemy records.
- Browser checks passed at 1440 by 1000 and 390 by 844 with 34 unique focusable
  roster controls, zero page overflow, and zero mobile dialog overflow. JavaScript
  syntax, local references, `git diff --check`, and the refreshed 350-test handover
  snapshot pass.
- Delivery state: locally implemented and responsive-browser verified;
  uncommitted, unpushed, and undeployed. Physical-phone interaction remains open.

### 2026-08-12 — Equal evolution selector aspect ratios

- Fixed intrinsic tall evolution sprites stretching individual recipe controls.
  All sixteen buttons now use one enforced square box with the artwork removed
  from grid sizing and contained inside a consistent inset; the existing balanced
  desktop row offsets and mobile four-column order remain unchanged.
- Before the fix, buttons 10, 14, and 16 measured at approximately 0.808, 0.823,
  and 0.896 width-to-height. Browser verification now reports a 1.000 ratio for
  every control: 70 by 70 pixels at the desktop check and approximately 79 by 79
  pixels at 390 by 844, with zero horizontal overflow at both breakpoints.
- JavaScript syntax, local references, `git diff --check`, and the refreshed 350-
  test handover snapshot pass. Delivery remains locally implemented and responsive-
  browser verified; uncommitted, unpushed, and undeployed.

### 2026-08-12 — Horizontal Prologue stage wordmarks

- Created one transparent, wide, font-led wordmark variation for each Prologue
  stage while preserving the existing circular emblems. Backbeat Streets uses
  distressed stencil lettering, speaker hardware, waveform graffiti, road-case
  metal, and hazard accents grounded in its street-defense play. Orbit Line uses
  exactly two words with no `THE`, plus vinyl grooves, broadcast rails, orbital
  signals, purple energy, cyan, magenta, and brass grounded in Stage 2.
- Preserved both chroma generation sources and recorded prompt summaries and
  SHA-256 provenance. The final PNGs are RGBA, have zero-alpha corners and full
  opaque interiors, and are integrated into both selector cards and panel headers.
- Browser verification confirmed equal 190-pixel desktop cards and 158-pixel
  mobile cards, matching logo sizes, correct Orbit tab switching, complete natural
  image dimensions, and zero horizontal overflow at 1440 by 1000 and 390 by 844.
  JavaScript syntax, local references, `git diff --check`, and the refreshed 350-
  test handover snapshot pass.
- Delivery state: locally implemented and responsive-browser verified;
  uncommitted, unpushed, and undeployed. A physical-phone refresh and any commit,
  push, main promotion, or deployment remain separate actions.

### 2026-08-12 — Prologue stage video players

- Added a native-control 16:9 player to each selectable Prologue stage panel:
  `assets/video/prologue.mp4` for Backbeat Streets and
  `assets/video/stage2-transition.mp4` for The Orbit Line.
- Verified both website MP4s are byte-identical to canonical source files. The
  Prologue is 1280 by 720 H.264/AAC at 30.04 seconds; the Stage 2 transition is
  1280 by 720 H.264/AAC at 30.08 seconds.
- Kept both players manual rather than intersection-autoplayed, and pause videos
  when their stage panel is hidden. Browser verification confirmed correct
  source mapping, native controls, loaded metadata, tab switching, 16:9 sizing,
  and zero horizontal overflow at 1440 by 1000 and 390 by 844.
- Delivery state: locally implemented and responsive-browser verified;
  uncommitted, unpushed, and undeployed. A manual listening/playback pass remains
  open; unrelated game and campaign-source changes remain protected.

### 2026-08-12 — Windows download CTA parity

- Verified the existing public v0.7.1 Windows x64 portable ZIP, release manifest,
  checksum file, 173,654,466-byte size, GitHub SHA-256 digest, and stable Latest-
  release redirect against the live GitHub release. No asset was uploaded or
  replaced during this pass.
- Added Windows beside every active macOS download CTA across Home, Catalog,
  Builder, shared headers, shared footers, and the repository README. Replaced
  obsolete Mac-only language with macOS-universal and Windows-x64 availability.
- Added a CSS Windows mark and balanced three-action desktop groups; verified
  equal Mac/Windows link counts, one-row desktop actions, stacked phone actions,
  and zero horizontal overflow across all three pages at 1440 by 1000 and 390 by
  844. JavaScript syntax, local references, and `git diff --check` pass.
- Delivery state: site and README changes are locally implemented and responsive-
  browser verified; uncommitted, unpushed, and undeployed. The Windows release
  asset itself was already public before this task; native Windows acceptance
  remains a separate platform check.

### 2026-08-12 — Landing-page refinements round 2

- Reordered Home after the hero to trailer, character selection, one fluid
  two-stage Prologue, World Tour, current game captures, weapon evolution,
  Arsenal, and the remaining catalog modules.
- Replaced flattened campaign art with transparent Prologue and first-option
  World Tour festival marks, then isolated Backbeat Streets and The Orbit Line
  emblems for both the Prologue selector and stage headers. Recorded source,
  prompt, transformation, and SHA-256 provenance for each derivative.
- Removed the World Tour number-stat row and public-tour version disclaimer;
  tightened the six world cards, removed lock sprites, and added a small CSS
  padlock beside the three `In development` labels.
- Renamed the fusion chapter to `Evolve Your Weapons`, enlarged its sixteen
  selectors into balanced desktop rows of 5, 5, and 6, shortened the fusion loop
  to 4.8 seconds, and added converging pulses plus rapid white collision flashes.
- Verified Home at 1440 by 1000 and 390 by 844 with zero horizontal overflow,
  keyboard Prologue selection, the requested module order, deep-link alignment,
  compact world cards, and transparent logos in context. Home, Catalog, and
  Builder report zero missing static local references; JavaScript syntax,
  `git diff --check`, 347 game tests, and Lua lint pass.
- Delivery state: locally implemented and responsive-browser verified;
  uncommitted, unpushed, and undeployed. Existing unrelated game, root-document,
  campaign-source, and promotional changes remain protected.

### 2026-08-11 — v0.7.1 menu, controller, and World Tour release

- Added generated menu-category and focus-frame sprites plus modular nine-slice
  upgrade-card and attribute-icon assets, with source candidates, reproducible
  build scripts, and provenance.
- Reworked selection visibility and spatial navigation so D-pad input follows
  the actual four-direction layout across level-up, World Tour, starter-loadout,
  results, title, Pause, Options, Controls, and Admin surfaces.
- Rebuilt Pause, Options, Controls, and Admin with concise sprite-backed panels,
  category art, action blocks, and complete controller access.
- Filtered evolution guidance to equipped weapons, clarified icon-led gains and
  totals, added gradual free starter loadouts for harder worlds, and preserved
  chest presentation whenever an eligible evolution exists.
- Verified 342 tests, zero lint warnings, focused 1280-by-720 menu captures,
  valid package archives, universal architectures, ad-hoc signature, app icon,
  v0.7.1 metadata, packaged boot, and DMG checksum.
- Committed and pushed source as `a6d8132`; published tag and GitHub Latest
  release `v0.7.1` with digest-matched DMG, ZIP, and `.love` assets. The stable
  Latest DMG link now resolves publicly to v0.7.1.
- Delivery state: source committed and pushed on `codex/world-tour-v1`; release
  public-live verified. `main` promotion, landing deployment, Apple notarization,
  and a physical-controller hardware pass remain open. The separate uncommitted
  campaign-identity/Builder redesign and protected root assets remain untouched.

### 2026-08-11 — World Tour campaign identity and Builder refocus

- Added a reusable landing-page campaign lockup plus generated transparent
  wordmarks for World Tour, Funk, Soul, Disco, Jazz, House, and Techno. House was
  explicitly regenerated as a communal dancefloor mark; Techno was regenerated
  with a darker underground modular-club identity.
- Rebuilt the Home World Tour chapter around the ordered six-world route, a
  keyboard-accessible large-icon selector for playable Funk, Soul, and Disco,
  authentic floor-tile backgrounds, individual enemy sprites, and larger boss
  presentations. Multi-frame atlas presentations now use representative open
  states.
- Stripped Builder to a short Groove Bound-first creator introduction, current
  game captures, authentic RAOVERSE and Subjekt artwork, and two optimized
  first-party RAOVERSE films. Removed the curriculum-style professional profile
  and external experiment-project cards. Restored the supplied AI Raoni V2
  portrait beneath the creator name using its uncropped square composition.
- Added source, prompt, transform, and hash provenance for the new campaign
  marks and web video derivatives.
- Delivery state: locally implemented and responsive-browser verified;
  uncommitted, unpushed, and undeployed.

### 2026-08-11 — World Tour game-atlas isolation repair

- Kept the existing LÖVE atlas loader and every stable row/column mapping, then
  applied the landing-page component-isolation method to all 147 transparent
  World Tour cells used by the game across 16 enemy, environment, chest,
  mechanic, interface, perk, menu, and expansion-evolution atlases.
- Rebuilt each runtime sheet with one assigned subject per cell, uniform scaling,
  centred visible bounds, and at least eight pixels of transparent safe gutter.
  No component is reused across outputs and no final subject crosses a cell edge.
- Normalised `musical-chest-atlas.png` from a malformed 1256×1256 4×2 canvas
  with 314×628 cells to a 1600×800 4×2 canvas with eight square 400×400 cells,
  correcting the animation proportions without changing its frame order or
  runtime consumer.
- Added a reusable repair/check script, 147 tightly cropped backend audit PNGs,
  a hash and mapping manifest, expanded atlas-dimension regression coverage, and
  package exclusion for the 28 MiB duplicate audit derivatives. Removed the
  internal V1 label from the remaining player-visible game assertion.
- Verified the manifest and all atlas gutters, a labeled 16-atlas contact sheet,
  zero live loader changes, 323 tests, zero lint findings across 159 files, clean
  diff whitespace, a zero-risk media audit, a clean LÖVE 11.5 source boot, World
  Tour/run screen transitions, and a non-destructive 246-entry temporary package
  containing all repaired atlases and no audit/source/test payload.
- Delivery state: locally implemented and source-runtime verified; uncommitted,
  unpushed, unpublished, and not released. Focused physical-controller playthrough
  remains open before any release decision.

### 2026-08-11 — Cross-cell sprite isolation repair

- Re-audited all 160 individual World Tour derivatives in four labeled contact
  sheets and confirmed that some generated subjects and particles crossed their
  nominal atlas cells, causing pieces of neighbors to appear at output edges.
- Replaced independent grid-cell cropping for transparent atlases with global
  connected-component segmentation. Components are assigned once to the nearest
  authored sprite, so neighboring bodies, props, signals, badges, particles, and
  completion-frame details cannot be duplicated into another output.
- Recovered 36 complete sprites across nominal cell lines rather than clipping
  them, retained exact opaque floor cells, discarded isolated one-to-three-pixel
  alpha noise, and preserved the canonical runtime atlases unchanged.
- Visual contact sheets and live Home Funk, Soul, Disco, systems, and chest
  galleries show clean isolated silhouettes. Home and Catalog load all assets
  without failures or live atlas consumers, Catalog retains 116 records, there
  is no desktop overflow, and the chest displays one changing frame at a time.
  All 160 alpha bounds and hashes, unique source-component assignment, local
  references, JavaScript syntax, diff whitespace, canonical media audit, 322
  tests, and lint across 159 files pass.
- Delivery state: locally implemented and browser-verified; uncommitted,
  unpushed, undeployed, and not public-live.

### 2026-08-11 — Individual World Tour sprite extraction

- Added a repeatable website-media extractor that reads the canonical runtime
  atlases without modifying them and emits 160 individual PNG derivatives into
  system-specific enemy, environment, floor, mechanic, interface, evolution,
  perk, and chest folders.
- Cropped every atlas cell to its exact non-transparent alpha bounds without
  resizing, cleared hidden RGB, and removed residual chroma green from affected
  generated sheets. Recorded source hashes, cell coordinates, crop bounds,
  output dimensions, and output hashes in a machine-readable manifest.
- Replaced all live World Tour atlas-cell mappings across Home, Catalog, Builder,
  inspectors, draggable elements, fusion routes, galleries, and the chest
  animation. The animated chest now cycles through eight independent frames,
  and floating art keeps its natural aspect ratio instead of being forced into
  a square.
- Verified 160 outputs with zero transparent-border failures and zero residual
  strong-green pixels; zero live atlas consumers; no failed browser images or
  desktop horizontal overflow across Home, Catalog, and Builder; and direct PNG
  rendering for World Tour cards and draggable artwork. The chest cycles through
  exactly one of its eight independent frames at a time. JavaScript syntax,
  local static references, all manifest outputs, diff whitespace, the canonical
  media audit, 322 tests, and lint across 159 files all pass.
- Delivery state: locally implemented and browser-verified; uncommitted,
  unpushed, undeployed, and not public-live. Original runtime and site-copy
  atlases remain preserved as provenance sources.

### 2026-08-11 — Direct copy and complete World Tour catalog

- Rewrote the full Home presentation and Catalog entry copy in Raoni's direct,
  practical voice, with shorter headings and simpler explanations.
- Moved the complete Prologue presentation before World Tour in Home, shared
  navigation, and footers. Removed the internal V1 label from public website
  copy and the in-game World Tour screen while preserving internal branch and
  organization tags.
- Expanded the Catalog from 62 to 116 records: 24 World Tour enemies, nine
  worlds, 19 permanent perks, and two chest systems, all grounded in canonical
  runtime content and site-copied World Tour art.
- Added draggable World Tour enemies, perks, and chests to Home, Catalog, and
  Builder. Slowed and widened all floating-token and remix-field motion, kept
  keyboard movement and inspection, and preserved reduced-motion states.
- Corrected the musical chest animation from a stretched square cell to the
  source atlas cell's 1:2 geometry without changing the source image.
- Verified 116 Catalog records and exact category counts; inspect and keyboard
  drag behavior; changing long-loop sprite positions; zero desktop horizontal
  overflow across all three pages; 200 resolved local references; JavaScript
  syntax; clean diff whitespace; 322 tests; and zero lint findings across 159
  files.
- Delivery state: locally implemented and browser-verified; uncommitted,
  unpushed, undeployed, and not public-live. Physical-phone refresh and trailer
  audio remain open; deployment and publication still require approval.

### 2026-08-11 — World Tour V1 landing-page sync

- Added a dedicated Home chapter for World Tour V1 while keeping the public
  v0.6.0 Prologue build and the local active-branch preview explicitly separate.
- Mapped all six core and three secret World slots, then presented the playable
  Funk, Soul, and Disco two-stage routes with their canonical stage names,
  bosses, mechanics, enemy atlases, environment atlases, and floor atlases.
- Copied 20 runtime PNG atlases byte-for-byte into the website asset surface,
  covering world UI, interfaces, mechanics, nineteen permanent perks, both
  evolution sets, menu controls, musical and Encore Gate chests, luck reels,
  completion crests, and the Funk Pocket sequence. Kept source candidates out.
- Expanded the interactive Catalog from 54 to 62 records with all sixteen
  evolution definitions, authentic icons, recipes, relations, and fusion-picker
  routes. Added a bounded extractor for strict cells 9–16 from the second
  evolution atlas.
- Added a direct World Tour route to all three page headers and footers,
  keyboard-operable playable-world tabs, responsive layouts, an animated chest,
  and a static reduced-motion state.
- Verified JavaScript syntax, 191 local HTML/CSS references, 20/20 website-to-
  runtime atlas parity, 322 tests, zero lint findings across 159 files, clean
  diff whitespace, 62 Catalog records, sixteen evolution cards and picker
  routes, world-tab click and arrow-key behavior, and no failed images, browser
  warnings, or horizontal overflow on Home, Catalog, or Builder at 390, 1024,
  and 1440 pixel widths. Screenshot cards retain their source ratios.
- Delivery state: locally implemented and browser-verified; uncommitted,
  unpushed, undeployed, and not public-live. Physical-phone refresh and trailer
  audio remain open; deployment and publication still require approval.

### 2026-08-10 — Compact archive and Home trailer

- Rebuilt the Catalog into a six-column desktop and two-column phone archive
  with smaller equal-height records, name-only summaries, and a consistent plus
  affordance for opening details.
- Enlarged the seven category filters and icons, moved them to a full-width
  wrapping grid, and removed the previous horizontal-scrolling behavior.
- Widened section headings and removed low-value experiment labels from the
  Builder cards while preserving meaningful story-stage labels.
- Added the supplied Groove Bound trailer immediately after the Home hero as a
  centered 16:9 native player with its original promotional thumbnail and no
  surrounding filler copy. The website video and poster are byte-identical to
  their promotional sources.
- Verified 54 Catalog cards, six columns across populated desktop groups, two
  columns on a 390px phone viewport, all seven filters visible, filter and search
  interactions, record inspection, native 1280x720 trailer metadata, 30.083-second
  duration, no failed local references, no missing images, no horizontal overflow,
  no browser warnings or errors, and a zero-risk canonical media audit.
- Delivery state: locally implemented and preview-verified; uncommitted,
  unpushed, and undeployed. Game tests and lint were not rerun for this static
  site and promotional-media pass.

### 2026-08-10 — Viewport-centred primary navigation

- Anchored the Home, Catalog, and Builder desktop menu to the true horizontal
  centre of the page rather than the flexible space between the GB identity and
  release-action blocks.
- Kept the left logo, right release/GitHub/Mac actions, and compact phone menu
  independent from the desktop centring rule.
- Verified exact zero-pixel centre offset at 821, 1024, and 1440px page widths,
  positive clearance from both side blocks, zero horizontal overflow, no failed
  images, and no browser errors across all three pages. The 390px menu opens
  normally with the existing three links.
- Delivery state: locally implemented and preview-verified; uncommitted,
  unpushed, and undeployed. Game tests and lint were not rerun for this CSS-only
  site adjustment.

### 2026-08-10 — GitHub README aligned with the landing-page identity

- Rebuilt the root README around the current landing-page visual and narrative
  system: campaign banner, gold title identity, cyan/magenta/gold palette,
  Resonant logos and portraits, Backbeat-to-Orbit story, arsenal atlases, current
  gameplay captures, stable download path, and v0.6.0 release state.
- Removed stale preview claims and corrected the validation total, current video
  flow, camera zoom, controls, native-package status, and remaining manual QA.
- Verified all 29 local references, all 7 section-navigation anchors, whitespace,
  and landing JavaScript syntax. GitHub's Markdown API rendered 28 images, 50
  links, and 3 tables successfully.
- Delivery state: README committed as `f96acf9` and pushed to
  `origin/GPT/stage-2-cutscenes`. The default GitHub README on `main` is unchanged
  until the existing draft PR is reviewed and merged.

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
