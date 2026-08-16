# Provenance

- **Created:** 2026-08-15
- **Generator:** Codex built-in OpenAI image generation
- **Use:** editable/generated source for the Groove Bound v0.9.5 projectile
  readability integration
- **Runtime status:** promoted to `assets/generated/projectiles/`; locally
  integrated, not released
- **Reference inputs:** v0.9.3 projectile sheets were visually inspected for
  palette continuity and specifically rejected as the density/scale target
- **Generation background:** a uniform `#00ff00` chroma field was used because
  two transparent-output pilots returned an RGB checkerboard instead of real
  alpha. Those pilots were rejected and are not part of this candidate set.
- **Transformation:** each stable projectile ID was generated independently,
  keyed with the bundled soft-matte/despill media utility, then split and
  normalized into one transparent eight-frame 4 x 2 sheet. Generated pixels
  were never enlarged during normalization.
- **Rejected output retained:** the first `neon_crescendo` attempt had empty
  bookend frames after keying; both its chroma source and keyed result are kept
  under `rejected/`. The accepted replacement has eight populated frames.
- **Rights:** first-party generated project media for Groove Bound
- **Integration baseline:** v0.9.4 source commit `28fa8e5`, merged into `main`
  at `4d8758d`
- **Remaining gates:** media, full tests, package, boot, and manual gameplay
  verification before release

The prompt set is recorded in `PROMPTS.md`. Generated image hashes and measured
dimensions/alpha statistics are recorded in `MANIFEST.md`.
