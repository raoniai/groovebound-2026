## Groove Bound v0.8.1

This release makes level-ups player-controlled. Earn points continuously,
spend them when the moment feels right, or restore automatic menu opening in
Settings or directly from the level-up screen.

### Highlights

- Level gains bank one spendable point each without interrupting combat.
- A compact sprite-backed CTA sits beneath the current build and shows the
  exact unspent balance.
- Open the paused level-up menu with `L`, the controller Triangle button, or a
  click; spend one point or several, then close and keep the rest.
- Every selection consumes exactly one point and immediately produces a new
  seeded three-card offer with the existing anti-repeat and legal-build rules.
- Automatic menu opening is a persistent Settings option and can also be
  toggled inside the level-up menu.
- D-pad, arrow-key, and WASD movement now obey strict rows: left/right never
  falls into a lower CTA at a row edge, while up/down stays spatially aligned.
- Gameplay notices share a compact right-side alert stack with relevant sprite
  icons, timed disappearance, individual dismissal, and Clear All.
- Menu CTAs, Settings, results, reward presentation, and focus treatment use a
  consistent accessible sprite-backed visual system.

### Desktop downloads

- **Windows x64:** download `Groove-Bound-Windows-x64.zip`, extract the complete
  **Groove Bound** folder, and launch `Groove Bound.exe`. Keep every DLL beside
  the executable. This preview is unsigned, so SmartScreen may require
  **More info -> Run anyway** after you verify the checksum below.
- **macOS:** use `Groove-Bound-macOS.dmg` for normal installation. The app is a
  universal Apple Silicon and Intel build with the Groove Bound icon. It is
  ad-hoc signed but is not Apple-notarized.
- **Linux/development:** use `groove-bound.love` with LÖVE 11.5.

The Windows and Mac packages embed the same deterministic `.love` payload.
Desktop packaging source: `{{COMMIT}}`.

### Verification

- 372 automated tests pass; Luacheck reports zero findings across 173 files.
- The common archive contains the new runtime CTA/alert atlas and excludes
  generated source candidates, tests, documentation, and source media.
- Windows and macOS jobs verify the shared payload, platform package integrity,
  application metadata, and packaged bootstrap marker.
- Physical Windows controller/audio/SmartScreen testing and a complete manual
  campaign playthrough remain separate hardware acceptance checks.

### SHA-256

- `Groove-Bound-Windows-x64.zip`: `{{WINDOWS_SHA256}}`
- `Groove-Bound-macOS.dmg`: `{{MAC_DMG_SHA256}}`
- `Groove-Bound-macOS.zip`: `{{MAC_ZIP_SHA256}}`
- `groove-bound.love`: `{{LOVE_SHA256}}`
- `Groove-Bound-Windows-x64.manifest.json`: `{{WINDOWS_MANIFEST_SHA256}}`
- `SHA256SUMS-Windows.txt`: `{{WINDOWS_SUMS_SHA256}}`
- `SHA256SUMS-Desktop.txt`: attached to this release.
