# Groove Bound landing-page change log

This file is the local implementation record. Add a new entry at the top after every material site pass.

## 2026-08-11 | SITE-025 | v0.7.1 menu and controller release

Updated the visible public-build links and version copy to v0.7.1 while
preserving the stable GitHub Latest asset routes. The release adds clear
sprite-backed menu focus, true four-direction controller navigation, complete
controller access through Pause, Settings, Controls and Admin, the cleaner
level-up/evolution presentation, evolution-aware capped-build chest handling,
and gradual free starter loadouts for harder World Tour routes.

## 2026-08-11 | SITE-024 | Windows x64 public download

Added a parallel Windows x64 download route to Home, Catalog, Builder, shared
headers, hero and closing calls to action, and every footer. Updated the public
build to v0.7.1, retained the stable Mac DMG route, replaced Mac-only wording,
and added responsive cyan Windows controls without changing the site's cinematic
identity or reduced-motion behavior.

## 2026-08-11 | SITE-023 | v0.7.0 public World Tour release

Updated Home, Catalog, Builder, the shared release badge, footer release-note
links, and World Tour record copy for the v0.7.0 Mac distribution. The stable
GitHub Latest DMG route remains unchanged, while public-facing copy now states
that the Prologue plus Funk, Soul, and Disco are included in the download and
keeps the six later World Tour routes clearly marked as future work.

## 2026-08-11 | SITE-022 | Cross-cell sprite isolation repair

Re-audited all 160 World Tour derivatives as labeled contact sheets and replaced fixed-cell extraction with atlas-wide connected-component segmentation. Each transparent sprite now receives only the artwork assigned to its authored identity, while complete subjects that cross nominal grid lines are recovered instead of clipped. This removed neighboring enemy, prop, badge, interface, perk, chest, and completion-frame fragments from corners and edges; recovered 36 sprites beyond their original cell bounds; discarded isolated pixel noise; and retained exact alpha trimming, native resolution, source hashes, and the original atlases unchanged.

## 2026-08-11 | SITE-021 | Individual World Tour sprite extraction

Replaced every live World Tour atlas-cell consumer with one of 160 individually extracted transparent PNGs organized by enemies, environments, floors, mechanics, interface, evolutions, perks, and chest systems. Added a reusable source-preserving extractor and SHA-256 manifest, trimmed every derivative to its exact visible alpha bounds without resizing, cleared hidden RGB and residual chroma green, rebuilt the chest animation from eight independent frames, and removed forced square proportions so floating and gallery artwork remains centered without stretching. The original runtime and website atlas copies remain untouched as provenance sources only.

## 2026-08-11 | SITE-020 | Direct copy, Prologue-first flow, and complete World Tour catalog

Rewrote the Home and Catalog copy in Raoni's direct voice, placed the complete Prologue experience before World Tour, and removed the internal V1 label from public-facing website and game interface text. Expanded the Catalog from 62 to 116 records with 24 World Tour enemies, nine worlds, 19 permanent perks, and two chests. Mixed World Tour enemies, perks, and chests into the draggable Home, Catalog, and Builder compositions; replaced short fixed hovering with slow multi-direction roaming while preserving drag and keyboard control plus reduced-motion behavior; and corrected the musical chest animation to use the source atlas cell's 1:2 proportions without stretching.

## 2026-08-11 | SITE-019 | World Tour V1 visual sync

Added a full World Tour V1 chapter to Home from canonical active-branch content and byte-identical runtime art. The new presentation separates the public v0.6.0 Prologue build from the local World Tour preview; maps all six core and three secret world slots; presents the playable Funk, Soul, and Disco two-stage routes with their enemy, environment, and floor atlases; and exposes the complete current World Tour interface, mechanics, perk, chest, completion, progression, and second evolution graphic set. Expanded the Catalog from 54 to 62 records with all sixteen authentic fusion icons and recipes. Added keyboard-accessible world tabs, an animated musical chest with a reduced-motion state, responsive layouts, a direct World Tour navigation route on all three pages, and a source-parity note beside the copied site assets.

## 2026-08-10 | SITE-018 | Compact archive and Home trailer

Rebuilt the Catalog as a denser six-column desktop archive with smaller equal-size records, larger icon-led filters that wrap without horizontal scrolling, name-only cards, and a consistent plus affordance for opening full details. Widened section headings and removed low-value experiment labels to reduce unnecessary line breaks and visual noise. Added the authentic 30-second Groove Bound trailer immediately below the Home hero as a large centered 16:9 player with its original promotional thumbnail.

## 2026-08-10 | SITE-017 | Viewport-centred primary navigation

Anchored the desktop Home, Catalog, and Builder menu to the true horizontal centre of the viewport instead of centring it inside the remaining space between the GB icon and release actions. The left identity and right CTA blocks now remain independent, while the existing compact mobile menu is unchanged.

## 2026-08-10 | SITE-016 | v0.6.0 release synchronisation

Updated Home, Catalog, and Builder to identify public build v0.6.0, link its release notes, and send every Mac download action through GitHub's stable Latest-release DMG route so future package replacements do not strand older page links.

## 2026-08-10 | SITE-015 | Lore consolidated into Home

Audited the standalone Lore page against Home and Catalog, migrated its unique Resonance origin, Backbeat and Orbit Line objectives, draggable First Press route, Stage 2 transition, and ending reveal into one chronological Home campaign sequence, then retired the redundant Lore page. Removed Lore from the shared primary navigation, replaced footer links with the integrated Story anchor, connected the finale to the authentic current ending video, and preserved detailed characters, enemies, weapons, supports, evolutions, and gems in their stronger existing Home and Catalog presentations.

## 2026-08-10 | SITE-014 | Simplified Resonant presentation

Removed the repeated character epithets and oversized positioning headlines beneath Joe and Lyra's transparent logos on the Home selector. The shorter module now moves directly from each character logo into their concise description, visual attributes, and full-details action.

## 2026-08-10 | SITE-013 | Category-specific inspectors and connected Catalog

Rebuilt the shared record inspector with larger category-specific layouts, icon-led numeric metrics, simplified guaranteed-drop gem summaries, cleaner text-only category tags, and a full-Catalog action on every record. Added bidirectional links between base weapons, required passives, and evolutions; linked Resonants to starting weapons and enemies to their runtime Resonance tier; added deep-linked Catalog highlighting and Catalog-only boss and miniboss tags.

## 2026-08-10 | SITE-012 | Simplified primary navigation

Removed the Arsenal shortcut from the shared top navigation across Home, Lore, Catalog, and Builder while preserving the Arsenal section itself and its footer sitemap link.

## 2026-08-10 | SITE-011 | Catalog visibility regression fix

Removed dynamically generated Catalog category groups from the optional scroll-reveal lifecycle so all 54 cards remain visible beneath the filters and every newly selected category appears immediately. Bumped the shared script cache key to force phones and existing previews to load the corrected lifecycle code.

## 2026-08-09 | SITE-010 | Shared release navigation and Resonance Archive

Unified all four pages around the GB navigation icon, Home link, larger menu, exact public v0.5.0 release badge, GitHub action, and version-pinned Mac download. Added balanced draggable hero elements, cinematic lower-page video backdrops, a consistent expanded sitemap footer, and a 54-record interactive Catalog with category filters, search, equal cards, and full inspector details. Verified all local assets resolve, every page has zero desktop horizontal overflow, catalog filtering and search return correct counts, inspector statistics open correctly, and the shared footer matches across every page.

## 2026-08-09 | SITE-008 | Cursor inspection and cinematic media pass

Removed hover category icons and made the Inspect prompt follow the mouse, added the authentic Groove Bound favicon, replaced sound graphics with white outline speaker controls, expanded prologue, character, and Stage 2 video chapters to full-viewport scenes, added current Stage 2 captures, upgraded Resonant logos and lore labels, equalised system cards, replaced the Builder portrait, added a verified artwork and experiment archive, renamed Dog vs Cats, and removed the public landing-page Status section.

## 2026-08-09 | SITE-007 | Native Mac release download

Replaced every Mac call to action with the self-contained Groove Bound DMG, preserving the platform-neutral LÖVE archive as the Windows and Linux fallback. Added a repeatable universal-app release build with the real Groove Bound application icon, Applications shortcut, package validation, and checksum output.

## 2026-08-09 | SITE-006 | Subtle inspection, seamless signals, and Builder experiments

Replaced persistent category labels with hover and inspector icons, removed category-colour hover outlines, branded the sound control with the First Press, rebuilt the game-stat strip as a seamless draggable loop, aligned matching Mac download and GitHub repository CTAs, limited the Home gallery to the latest gameplay captures, and refocused the Builder page around Raoni's current practice, verified public experiments, and authentic RAOVERSE Subjekt artworks.

## 2026-08-09 | SITE-005 | Complete sprite-boundary and extraction QA

Re-extracted every Backbeat enemy, Orbit Line enemy, and Resonance gem from alpha-connected source artwork instead of fixed atlas cells, removing adjacent-sprite fragments and restoring complete silhouettes. Added a reusable source-preserving extractor and visually audited the remaining weapons, supports, evolutions, character poses, and talking portraits for clean transparent edges.

## 2026-08-09 | SITE-004 | Character identity, fusion, media, and current build QA

Added isolated Joe and Lyra Vex nameplates, rebuilt the Resonant selector around character-specific visual attributes, corrected the fusion collision and held evolution reveal, replaced audio meters with speaker controls, enforced uncropped 16:9 video modules, added fresh live gameplay captures, clarified Mac availability, diversified Builder photography, and enlarged the Status ledger typography.

## 2026-08-09 | SITE-003 | Interactive lore, builder, categories, and status

Rebuilt the lore as a linear two-stage story, added every enemy as an inspectable field card, introduced category-coded detail cues, replaced the builder page with Raoni's authentic photography and full professional profile, preserved screenshot ratios, removed repeated video, and added this generated status ledger.

## 2026-08-09 | SITE-002 | Full interaction and media QA

Added static transparent character crops, mute controls, current game screenshots, fusion loops, drag interactions, detailed inspector cards, and responsive QA fixes across Home, Lore, and Builder.

## 2026-08-09 | SITE-001 | Landing-page foundation

Created the three-page cinematic Groove Bound site with current game assets, playable-build CTAs, video backgrounds, weapon and enemy catalogs, and mobile preview support.
