## Groove Bound v0.9.1

This hotfix repairs the v0.9.0 desktop package startup failure caused by a
runtime World Tour lock sprite being omitted from the common `.love` payload.

### Fixes

- Restores `locked-world.png`, which the World Tour asset loader requires at
  startup, to the macOS, Windows, and standalone LÖVE packages.
- Adds a release gate that discovers complete asset paths referenced by runtime
  Lua and fails packaging if any referenced file is absent from the archive.
- Retains the complete v0.9.0 World Tour mechanics, second-stage artwork, boss
  overhaul, HUD clearance, and accessibility behavior without balance changes.

### Desktop downloads

- **Windows x64:** `Groove-Bound-Windows-x64.zip`
- **macOS:** `Groove-Bound-macOS.dmg`
- **Linux/development:** `groove-bound.love` with LÖVE 11.5

The Windows and Mac packages embed the same deterministic `.love` payload.
Desktop packaging source: `{{COMMIT}}`.

### Verification

- Automated tests, lint, media, portability, package, runtime-asset, and
  version gates must pass before publication.
- The packaged archive must contain every complete runtime asset path found in
  `main.lua`, `conf.lua`, and `src/**/*.lua`.
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
