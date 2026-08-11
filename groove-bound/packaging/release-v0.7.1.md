## Groove Bound v0.7.1

This release focuses on menu clarity, controller parity, cleaner upgrade
presentation, fairer World Tour starts, and the first native Windows package.

### Highlights

- Strong, unmistakable sprite-backed focus states across menus.
- True four-direction D-pad navigation instead of linear next-item traversal.
- Full controller navigation for Pause, Settings, Controls, and Admin.
- Concise sprite-backed Pause, Options, Admin, level-up, and evolution interfaces.
- Wider modular nine-slice upgrade cards with clearer, icon-led attribute gains and totals.
- Evolution guidance now shows only evolutions relevant to equipped weapons.
- Gradual free starter loadouts for harder World Tour worlds.
- Auto-selection still pauses for available weapon evolutions.
- Stable controller ownership across hot-plug events and centralized vibration.
- Validated migration from earlier Windows `.love` saves into the native executable.

### Desktop downloads

- **Windows x64:** download `Groove-Bound-Windows-x64.zip`, extract the complete
  **Groove Bound** folder, and launch `Groove Bound.exe`. Keep every DLL beside
  the executable. This preview is unsigned, so SmartScreen may require
  **More info → Run anyway** after you verify the checksum below.
- **macOS:** use `Groove-Bound-macOS.dmg` for normal installation. The app is a
  universal Apple Silicon and Intel build with the Groove Bound icon. It is
  ad-hoc signed but is not Apple-notarized.
- **Linux/development:** use `groove-bound.love` with LÖVE 11.5.

The Windows and Mac packages embed the same deterministic `.love` payload.
Desktop packaging source: `{{COMMIT}}`.

### Verification

- 353 automated tests pass; Luacheck reports zero findings across 172 files.
- Native Windows CI verifies tests, pinned runtimes, PE branding, fused payload
  integrity, packaged content bootstrap, ZIP integrity, and release manifests.
- The Mac build verifies its universal executable, icon, ad-hoc signature,
  property list, packaged bootstrap, and DMG checksum.
- Full graphical/audio play, physical controllers, SmartScreen behavior, and
  clean-machine save migration remain manual Windows hardware checks.

### SHA-256

- `Groove-Bound-Windows-x64.zip`: `{{WINDOWS_SHA256}}`
- `Groove-Bound-macOS.dmg`: `{{MAC_DMG_SHA256}}`
- `Groove-Bound-macOS.zip`: `{{MAC_ZIP_SHA256}}`
- `groove-bound.love`: `{{LOVE_SHA256}}`
- `Groove-Bound-Windows-x64.manifest.json`: `{{WINDOWS_MANIFEST_SHA256}}`
- `SHA256SUMS-Windows.txt`: `{{WINDOWS_SUMS_SHA256}}`
- `SHA256SUMS-Desktop.txt`: attached to this release.
