# Groove Bound — Latest Version Handover

**Role:** canonical project database and continuation record

**Authority:** live repository evidence plus explicitly approved product decisions

**Canonical runtime:** `groove-bound/`

**Update owner:** `$groove-bound-latest-handover`

This document answers four questions: what is authoritative, what the latest version contains, what is actually verified, and what the next person or agent can safely do. Live checks override stale counts or status prose. Product decisions remain human-owned.

## Live repository snapshot

<!-- LIVE-SNAPSHOT:START -->

_Generated from live repository evidence: 2026-08-11 20:30 AEST_

| Field | Live value |
|---|---|
| Branch | `codex/world-tour-v1` |
| Release source | `29c779d` — feat: ship World Tour v0.7.0 interface and release |
| Upstream | `origin/codex/world-tour-v1` includes the release source and this follow-up delivery record |
| Compared with `origin/main` | 25 ahead, 0 behind after the delivery-record commit |
| Working changes | Three protected root paths remain outside the release: the story/mechanics working handover, banner PSD, and `promo-assets/` source folder |
| Lua source/test files | 106 source, 51 test |
| Current `.love` artifact | 164,992,773 bytes; 254 valid entries |
| Test suite | passed: 329 tests, 0 failures |
| Lint | passed: 0 warnings / 0 errors in 159 files |
| Skill packages | 11 |

<!-- LIVE-SNAPSHOT:END -->

## Current product version

Groove Bound is a bright urban-supernatural survival roguelike built in Lua with LÖVE 11.5. Its current development preview follows:

**Title → Prologue → Character Selection → Character Intro → Backbeat Streets → The Orbit Line → World Tour → playable Funk, Soul, and Disco routes**

The player selects Joe or Lyra Vex, keeps one build across both stages, levels through seeded three-card offers, combines up to six weapons and four supports, and claims musical chests for reward reels and eligible fusions.

### Current content surface

- Two playable characters with differentiated stats, traits, weapons, logos,
  single-frame idle poses, and movement-speed-driven run animation.
- The complete two-stage Prologue plus six playable World Tour stages across
  Funk, Soul, and Disco; six later routes remain defined future scope.
- Sixteen base weapons, eight supports, and sixteen documented fusions.
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
| Chest rewards | Published in v0.7.0, tests passed, visually sampled, and package verified | Five large spinning chests converge without number cycling, flash the centre chest, reveal large sprite-backed rewards, and accept Esc/Circle animation skip; capped builds auto-apply the selected utility reward | Physical-controller timing and reward-feel playthrough with naturally dropped chests |
| Arena collision and navigation | Published in v0.7.0 and tests passed | Tall props now block 90% of their height and redraw their complete opaque sprite above actors; deterministic safe-drop and navigation tests remain green | Confirm every authored tall prop in a full playthrough |
| Enemy projectiles | Committed, pushed, and tests passed | Sprite mapping, attack tuning, content and entity tests | Confirm readability, rate, and boss pressure in play |
| Cutscene video | Six runtime videos published in v0.6.0 and package verified | Both new MP4s converted to packaged OGV; scene-ID discovery; Circle/`b` skip tests; global mute now drives video-source volume; skip/mute separation visually verified | Physical PlayStation controller check; listening check for mute during each video; full-video fade, pause, final-frame, fallback, and campaign-order playthrough |
| Music system | Implemented preview | Catalog, router, director, content, OGG assets and tests | BeatClock, latency calibration, groove scoring, and accessibility remain future work |
| Application icon | Published in the v0.6.0 macOS app; tests passed, package verified, and manual small-size QA verified | Commit `097c883`; Joe/Lyra adventure emblem at 512px RGBA; native `GrooveBound.icns` present and referenced in the verified app bundle | Confirm the rebuilt native app icon in the macOS Dock on another clean Mac |
| Generic controller and camera support | Published in v0.7.0 and tests passed | Released right-stick aim preserves direction while the world-space reticle follows the moving player; input abstraction, hints, deadzone, vibration and camera zoom remain covered | Physical PlayStation controller check; hot-plug identity, glyphs/remapping, wired/wireless matrix |
| Combat readability and HUD | Published in v0.6.0, tests passed, and visually sampled | Hit slide/pulse, camera shake, damage flash, HP-loss callout, concern below 20%, stronger critical state below 5%, transparent enlarged aim reticle, gameplay-only OS cursor hiding, compact right-side power-up notices, separate 50% panel shades, and tiled nine-slice slot frames with fixed corners | Full combat-feel pass with flash/reduced-flash options and physical controller |
| Character, upgrade, and results interface | Published in v0.7.0, tests passed, and visually sampled | Anton/Oswald typography, sprite-backed level-up and reward cards, complete sprite-only evolution guide, exact gain-to-total rows, generated NEW badge, pickup-art utility choices, and existing reroll/skip sprite CTAs | Manual defeat/victory results pass and final small-screen readability review |
| Save system | Version 2 profiles and slots | Save, migration, profile, export and World Tour session tests | Cross-platform clean-machine fixtures |
| Landing page and repository README | Committed and pushed at `29c779d`; public deployment not configured | Home, Catalog and Builder identify v0.7.0, keep the stable Latest DMG route, and state that Prologue/Funk/Soul/Disco ship in the download; 160 site sprites and the current trailer remain source-controlled | Physical-phone refresh, trailer audio check, explicit deployment destination, and `main` promotion |
| World Tour runtime atlases | Committed, pushed, source-runtime verified, and excluded from the package audit payload where appropriate | 147 transparent cells across 16 repaired atlases validate with zero edge crossings and no component reuse; runtime loader mappings remain stable | Focused physical-controller World Tour playthrough |
| Desktop distribution | v0.7.0 `.love`, universal macOS ZIP, and icon-bearing DMG published as GitHub Latest | Valid 254-entry `.love`; ad-hoc signed universal app; version, packaged boot, signature, icon resource, DMG checksum, GitHub asset digests, tag and public Latest redirects verified | Native Windows/Linux artifacts and test matrix; Apple notarization if required |
| Engine migration | Planned | Engine migration research and parity roadmap | Clean baseline and bounded target-engine spike |
| Groove Bound skills | Installed, committed, and pushed | Eleven installed packages match repository source; structural, package, and representative helper validation passed | Fresh-agent forward tests |

## Active working state

The v0.7.0 game, repaired runtime media, tests, documentation, repository README,
and landing-page source are committed and pushed on `codex/world-tour-v1` at
`29c779d`. Tag `v0.7.0` resolves to that source commit and its DMG, universal
Mac ZIP, and `.love` artifacts are public as GitHub Latest. The separate root
story/mechanics handover, banner PSD, and `promo-assets/` source folder remain
intentionally untouched and outside the release commit.

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
| Automated tests | 329 passed, 0 failed on 2026-08-11 | v0.7.0 controller aim, auto-pick progression, chest animation, collision, fresh-world assist, media, campaign and existing systems tested locally |
| Lint | 0 warnings and 0 errors across 159 files on 2026-08-11 | Current Lua source and tests statically checked |
| Package | Published v0.7.0 `.love`: 164,992,773 bytes, SHA-256 `0098c90ec018573fad0ccd6a9a320744f42ae7f4aa3e7e331e932a6046b3e4ce` | Valid ZIP with 254 entries; new fonts and UI sprites present; tests, docs, MP4s, source candidates and isolated audit derivatives excluded; GitHub digest matches local artifact |
| macOS artifacts | Published v0.7.0 universal ZIP and icon-bearing DMG | ZIP: 176,198,940 bytes, SHA-256 `8fec29dc1ba3becfbc1a74878d6acb62b61e659372a80bbecb01df74390f00a9`; DMG: 179,387,154 bytes, SHA-256 `7fd9c15be6b330e147d0d869f9bf125dc97a9efbee14d3f6f3f8ee4395c745e7`; GitHub digests match |
| Packaged boot | Verified on 2026-08-11 | v0.7.0 packaged app validated content and reached the title screen in LÖVE 11.5; universal architectures, app version, icon resource, ad-hoc signature and DMG checksum verified |
| Manual graphical QA | Focused v0.7.0 source captures verified | Level-up cards, all evolution sprite rows, generated NEW badge, reward-card scale, and right-side mechanic safe area visually inspected; full campaign, physical controller, audio and small-screen play-feel remain open |
| Source release commit | `29c779d` — feat: ship World Tour v0.7.0 interface and release | Tag `v0.7.0`, the pushed branch and public release all resolve to this commit |
| Feature-branch push | `origin/codex/world-tour-v1` contains `29c779d` | Feature branch is current; `main` remains independently unpromoted |
| Main promotion | Not current | Verify `origin/main` independently |
| Public release/download | v0.7.0 is published as GitHub Latest with DMG, ZIP, and `.love` assets | Release and tag verified public-live; GitHub digests match local SHA-256 values; stable `/releases/latest/download/` DMG and `.love` URLs returned HTTP 206 |
| Landing download link | v0.7.0 source committed and pushed on the feature branch | Home, Catalog and Builder use the stable Latest DMG route, which now resolves publicly to v0.7.0; visible badges link the exact v0.7.0 release |
| GitHub README presentation | Landing-styled rewrite committed and pushed at `f96acf9` | GitHub Markdown API rendered 21,124 bytes with 28 images, 50 links, and 3 tables; all 29 local references and 7 navigation anchors resolve; default-page visibility still depends on merging to `main` |
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
