## Groove Bound v0.8.5

This release completes a focused catalog and menu-polish pass while keeping the
shared desktop build identity synchronized across every public surface.

### Highlights

- The title menu is cleaner, with a dedicated bright-red campaign reset action.
- The Perk Catalog adds readable perk summaries, rank-safe cards, disabled max
  states, side-by-side actions, and an aggregate owned-perk/stat panel.
- World Tour adds themed route emblems, lock identities for unavailable worlds,
  shadowed sprite-backed grades, weighted performance scoring, a clearer rank
  guide, and a larger two-thirds route grid.
- HP, Guard, XP, boss, character-stat, and World Tour bars share the same
  mirrored sprite caps; character selection now uses the same sprite panels.
- The global menu mute control is smaller and anchored to the lower left.
- Starting-loadout selection now previews current-versus-selected combat stats
  and the exact evolution combination for the hovered gear.
- Remaining player actions use the shared sprite-backed CTA presentation.

### Desktop downloads

- **Windows x64:** `Groove-Bound-Windows-x64.zip`
- **macOS:** `Groove-Bound-macOS.dmg`
- **Linux/development:** `groove-bound.love` with LÖVE 11.5

The Windows and Mac packages embed the same deterministic `.love` payload.
Desktop packaging source: `{{COMMIT}}`.

### Verification

- Automated tests, lint, media, portability, package, and version gates must
  pass before publication.
- The cross-surface version gate must pass before and after GitHub and landing
  publication.
- Physical Windows, controller, audio, full-campaign, and unlocked-Mac visual
  checks remain separate acceptance items until directly verified.

### SHA-256

- `Groove-Bound-Windows-x64.zip`: `{{WINDOWS_SHA256}}`
- `Groove-Bound-macOS.dmg`: `{{MAC_DMG_SHA256}}`
- `Groove-Bound-macOS.zip`: `{{MAC_ZIP_SHA256}}`
- `groove-bound.love`: `{{LOVE_SHA256}}`
- `Groove-Bound-Windows-x64.manifest.json`: `{{WINDOWS_MANIFEST_SHA256}}`
- `SHA256SUMS-Windows.txt`: `{{WINDOWS_SUMS_SHA256}}`
- `SHA256SUMS-Desktop.txt`: attached to this release.
