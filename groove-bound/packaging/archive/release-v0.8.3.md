## Groove Bound v0.8.3

This release cleans up the live run interface, removes overlapping information,
and restores the capped-build utility loop while keeping every device readable
at the supported minimum canvas.

### Highlights

- HP, Guard, and Resonance XP now occupy separate sprite-segmented rows with
  tiny labels above each bar. The fixed end caps and repeated middle rails join
  cleanly without stretching or visible gaps.
- Low and critical health warnings are smaller and sit outside the HP rail.
  Critical HP pulses the bar itself, with a stable reduced-flash fallback.
- All six weapon slots stay inside the persistent build panel. Weapon, passive,
  player-level, point, and maximum ranks continue to use the shared circular
  sprite device.
- The level-point module is centred and cleaner, with separate clickable
  Triangle and keyboard-L tip devices beneath it.
- Fully capped builds remember the chosen HP, Tip, or Guard utility and repeat
  it for queued and future points even when Auto Menu is off. Repetition pauses
  as soon as a weapon, passive, or evolution choice becomes legal.
- Score and combo use dedicated sprite devices. The compact stage mechanic sits
  below them with reserved alert space, while Boss HP is tied directly beneath
  the central timing block.
- Completion results remove Final Setlist, Evolved, shots, and bosses copy;
  promote Level, Kills, and XP gain; keep six build slots aligned; and raise the
  primary actions.
- Perk Database cards and actions use the established sprite chrome with tighter
  unknown and rank treatment.
- Continuing into World Tour now asks which player to use after the world is
  selected and before the new run begins.

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

- 380 automated tests pass; Luacheck reports zero findings across 176 files.
- Focused coverage verifies six-slot containment, dual mouse-clickable level
  tips, capped utility repetition, right-rail separation, and player selection
  between World Tour and run start.
- The common archive contains the sprite-led interface assets and excludes
  source candidates, tests, documentation, scripts, and source media.
- Windows and macOS jobs verify shared-payload parity, package integrity,
  application metadata, and the packaged bootstrap marker.
- Physical Windows controller/audio/SmartScreen testing, current-screen visual
  capture, and a complete manual campaign playthrough remain separate hardware
  acceptance checks.

### SHA-256

- `Groove-Bound-Windows-x64.zip`: `{{WINDOWS_SHA256}}`
- `Groove-Bound-macOS.dmg`: `{{MAC_DMG_SHA256}}`
- `Groove-Bound-macOS.zip`: `{{MAC_ZIP_SHA256}}`
- `groove-bound.love`: `{{LOVE_SHA256}}`
- `Groove-Bound-Windows-x64.manifest.json`: `{{WINDOWS_MANIFEST_SHA256}}`
- `SHA256SUMS-Windows.txt`: `{{WINDOWS_SUMS_SHA256}}`
- `SHA256SUMS-Desktop.txt`: attached to this release.
