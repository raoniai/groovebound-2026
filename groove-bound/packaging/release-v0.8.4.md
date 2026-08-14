## Groove Bound v0.8.4

This release opens Jazz as the fourth World Tour world and keeps the running
build identity synchronized across every public surface.

### Highlights

- Jazz opens two connected stages: Blue Note Borough and Midnight Changes.
- Eight Jazz enemies join the tour, ending with the Brass Regent and Midnight
  Maestro boss encounters.
- Blue-note improvisation windows reward readable movement with a temporary
  speed boost without interrupting play.
- New Jazz enemy, environment, floor, logo, route, wave, and soundtrack assets
  are included in the shared desktop payload.
- Source, `.love`, macOS, Windows, GitHub Latest, and landing-page versions are
  checked through one fail-closed workflow.

### Desktop downloads

- **Windows x64:** `Groove-Bound-Windows-x64.zip`
- **macOS:** `Groove-Bound-macOS.dmg`
- **Linux/development:** `groove-bound.love` with LÖVE 11.5

The Windows and Mac packages embed the same deterministic `.love` payload.
Desktop packaging source: `{{COMMIT}}`.

### Verification

- Automated tests and lint must pass before publication.
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
