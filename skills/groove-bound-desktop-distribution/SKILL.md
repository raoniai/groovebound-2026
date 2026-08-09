---
name: groove-bound-desktop-distribution
description: Prepare, audit, or verify Groove Bound desktop builds for Windows, macOS, and Linux from one canonical Lua/LÖVE source. Use for fused Windows executables, macOS app bundles, Linux LOVE or AppImage delivery, CI build matrices, clean-machine testing, platform save paths, filename portability, runtime licenses, signing, notarization, artifact manifests, or native controller and media verification.
---

# Groove Bound desktop distribution

Build platform artifacts from one verified `.love` package. Do not fork gameplay source by operating system.

## Workflow

1. Read `LATEST_VERSION_HANDOVER.md`, [references/platform-matrix.md](references/platform-matrix.md), and the current official LÖVE distribution instructions.
2. Freeze the exact source commit or explicitly label a dirty internal test artifact.
3. Run `$groove-bound-release-verification` and use the resulting `.love` as the common payload.
4. Run `scripts/portability_audit.py` before native packaging.
5. Build only the requested targets with a pinned official LÖVE runtime and required licenses.
6. Generate per-target manifest, checksum, runtime version, architecture, and signing state.
7. Run target-native boot, save/load, keyboard, controller, audio, video, fullscreen, resize, and exit checks.
8. Keep unsigned internal QA, signed candidate, notarized build, store submission, and public release distinct.
9. Update the handover with proven target states and remaining platform gaps.

## Approval gates

Require explicit authority for certificates, secrets, signing, notarization, store uploads, release publication, or replacing existing downloads.
