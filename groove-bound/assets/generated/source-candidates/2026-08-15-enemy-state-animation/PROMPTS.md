# Enemy state animation generation prompts

## Shared specification

- Use case: `stylized-concept`; non-runtime game sprite source boards.
- Use only the supplied first-party Groove Bound enemy artwork as identity
  reference. Preserve each silhouette, palette, materials, proportions,
  three-quarter camera, dark outlines, and detailed retro pixel-art finish.
- Keep a fixed scale and baseline within each row. Use a removable solid chroma
  field with no text, labels, borders, grid lines, shadows, scenery, watermark,
  extra characters, detached fragments, cropping, or cross-cell effects.
- Hit sequences contain three readable beats: brace, impact flash/recoil, and
  recovery. Jazz uses four beats to match its existing four-frame cadence.
- Death sequences contain four non-looping beats: stable pose, collapse,
  breakdown, and final inert/remnant pose.
- Attack sequences are generated only for enemies whose canonical definition
  has a projectile attack, with four beats: aim/charge, peak charge, release,
  and recovery.

## Roster state boards

Backbeat, Orbit, Funk, Soul, Disco, and Jazz each use their canonical campaign
atlas as reference. The requested movement character for every enemy follows
the motion recorded in the earlier walk-set prompt at
`../2026-08-14-enemy-animation/PROMPTS.md`.

- Hit: one enemy per row, three columns for Backbeat, Orbit, Funk, Soul, and
  Disco; four columns for Jazz. Impact light remains localized to frame 2.
- Death: one enemy per row, four columns, preserving identifiable parts through
  the final pose rather than substituting a generic explosion.
- Attack: one canonical projectile enemy per row, four columns. The actual
  weapon organ (speaker, horn, laser, keyboard, dish, staff, or magical focus)
  drives the motion and release flash.

Orbit, Soul, and Disco hit boards were regenerated when the first boards did
not yield one complete authored row per enemy. The selected regenerated boards
are the files currently named `*-hit-atlas-chroma-source.png`.

## Breakbeat Bruiser

Create a distinct orange-and-black drum-machine brawler with a subwoofer chest,
large speaker fists, piston legs, and heavy plated shoulders. Do not reuse the
Turntable Sentinel. Produce a strict 4x4 board: walk, attack, hit, death from top
to bottom, four frames left to right, on solid green chroma.
