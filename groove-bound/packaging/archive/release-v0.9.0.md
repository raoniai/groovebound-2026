## Groove Bound v0.9.0

This release rebuilds the playable World Tour mechanics, gives every second
stage its own animated visual identity, and turns all eight world bosses into
harder multi-pattern encounters.

### Highlights

- Funk, Soul, Disco, and Jazz now have distinct mechanic rules, rewards, HUD
  instructions, animation states, and faster Stage 2 variations.
- Successful mechanic chains boost the active build and lead to Encore, while
  mechanic mastery charges a temporary Break window against final bosses.
- Soul converts overhealing into Guard; Disco emphasizes continuous cadence;
  Funk rewards downbeat routing; Jazz rewards tighter adaptive phrasing.
- Every second stage has a new transparent eight-prop environment atlas with
  subtle animation and a reduced-motion route.
- Eight high-resolution production sheets, eight runtime atlases, and 32 named
  individual mechanic animation sprites are included.
- Final bosses have more health and range, 90–96 percent knockback resistance,
  displacement caps, attack-windup anchoring, three escalating health phases,
  and rotating pulse, fan, radial, and cross-wave patterns.
- Heavy hostile projectiles require three cancellation hits, and boss range
  warnings are calmer outlines instead of large flashing fills.
- The mechanic guide reserves space below the top-right Score and Combo devices,
  with alerts automatically flowing beneath it.

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
