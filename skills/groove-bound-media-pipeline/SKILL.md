---
name: groove-bound-media-pipeline
description: Create, convert, integrate, audit, or replace Groove Bound visual and audio media. Use for sprites, atlases, portraits, environments, projectiles, VFX, icons, screenshots, generated images, legacy assets, music, sound effects, MP4 source video, OGV runtime video, cutscene storyboards, codec conversion, package inclusion, licensing, or provenance.
---

# Groove Bound media pipeline

Preserve authentic project identity, runtime efficiency, fallback behavior, and asset provenance from source through package.

## Workflow

1. Read `LATEST_VERSION_HANDOVER.md`, [references/media-contracts.md](references/media-contracts.md), and the relevant provenance register.
2. Classify each input as runtime, editable source, source candidate, legacy first-party, documentation-only, website copy, or unverified third-party.
3. Confirm the runtime consumer, stable mapping, dimensions, cell grid, anchor, alpha behavior, codec, duration, loop, and fallback before editing.
4. Use the image-generation skill for image creation or editing and the media workflow for audio/video operations.
5. Preserve source material separately. Produce optimized runtime files without overwriting provenance inputs.
6. Update asset loading, mappings, provenance, prompt records, tests, and package rules together.
7. Run `scripts/audit_media.py`, relevant source tests, full tests, lint, package integrity, and manual playback/visual checks.
8. Route UI layout or gameplay behavior changes to their owning skills.

## Block release when

- Rights or provenance are unresolved.
- The runtime asset has no stable mapping or fallback.
- A source candidate is accidentally included in the package.
- Case, path, atlas, alpha, codec, duration, or loop behavior is unverified.
- The source build works but the packaged build has not loaded the media.
