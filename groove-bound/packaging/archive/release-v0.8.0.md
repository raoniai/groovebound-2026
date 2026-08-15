## Groove Bound v0.8.0

This release gives World Tour its own complete musical identity: one continuous
hub theme and a distinct three-cue soundtrack pack for every world.

### Highlights

- Nine coherent, world-specific packs for Funk, Soul, Disco, House, Electro,
  Techno, Cosmic Boogie, Soulful Garage, and Future Funk.
- A continuous World Tour hub cue across the selector and loadout flow, avoiding
  unnecessary restarts between connected menus.
- Unique route, pressure or boss, and finale cues for every world rather than a
  shared World Tour soundtrack.
- Funk, Soul, and Disco gameplay now route to their own stage and boss music.
- Future-world packs are integrated and ready for their stages without changing
  the capped World Tour V1 progression scope.
- Menu overlays preserve and duck the current musical context instead of
  interrupting the groove.

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

- 358 automated tests pass; Luacheck reports zero findings across 172 files.
- All 28 World Tour runtime cues pass format, loudness, true-peak, duration,
  musical-grid, and loop-seam checks.
- The common release archive excludes Suno source masters and contains all 28
  optimized OGG runtime cues.
- The macOS package was launched and exercised through the title, World Tour
  selector, Funk stage, live combat, and level-up overlay.
- Native Windows graphical/audio/controller play and final human creative
  listening remain manual hardware and taste checks.

### SHA-256

- `Groove-Bound-Windows-x64.zip`: `{{WINDOWS_SHA256}}`
- `Groove-Bound-macOS.dmg`: `{{MAC_DMG_SHA256}}`
- `Groove-Bound-macOS.zip`: `{{MAC_ZIP_SHA256}}`
- `groove-bound.love`: `{{LOVE_SHA256}}`
- `Groove-Bound-Windows-x64.manifest.json`: `{{WINDOWS_MANIFEST_SHA256}}`
- `SHA256SUMS-Windows.txt`: `{{WINDOWS_SUMS_SHA256}}`
- `SHA256SUMS-Desktop.txt`: attached to this release.
