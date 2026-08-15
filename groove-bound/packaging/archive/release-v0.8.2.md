## Groove Bound v0.8.2

This release polishes the live gameplay interface around the information that
matters during a run: timing, mechanics, build ranks, health, experience, and
level-point spending.

### Highlights

- The pause menu is shorter and cleaner: Run Seed, supporting body copy, the
  pause subhead, and the bottom control footer are removed.
- Mute/unmute is now part of the pause menu during gameplay, while the corner
  control remains available across title, cutscene, and non-combat menus.
- World mechanic guidance moves out of the crowded top-right stack into a
  dedicated sprite-framed card directly beneath the central timer.
- The timing panel keeps the large clock centred and places the stage name and
  remaining time together on one line beneath it.
- HP and Resonance XP use repeatable sprite segments instead of prototype
  shapes, and persistent HUD panels use the established sprite-backed chrome.
- Scores use thousands separators for faster reading.
- Weapon, passive, player-level, and spendable-point ranks share a clear
  top-right circular badge; capped items use a matching highlighted MAX icon.
- The level-point triangle is green and mouse-clickable as well as available
  from keyboard and controller input.
- Gameplay control hints at the bottom centre are removed so the playfield
  stays clear.

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

- 376 automated tests pass; Luacheck reports zero findings across 176 files.
- The interface was visually checked at the reference desktop size and the
  supported 800 x 600 minimum, including active World Tour mechanics, pause,
  level-up, results, title, and settings states.
- The common archive contains the new runtime HUD sprites and excludes source
  candidates, tests, documentation, scripts, and source media.
- Windows and macOS jobs verify shared-payload parity, package integrity,
  application metadata, and the packaged bootstrap marker.
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
