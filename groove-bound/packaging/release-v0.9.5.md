## Groove Bound v0.9.5

This release rebuilds every player projectile as a separate, readable
eight-frame animation while retaining the v0.9.4 enemy-state overhaul and the
established deterministic combat balance.

- Replaces all 32 five-frame projectile strips with separate 2048x1024 RGBA
  sheets containing eight distinct 512x512 animation frames per stable weapon
  or fusion ID.
- Gives beams, bombs, area attacks, waves, orbitals, deployables, and
  scenario-range lightning authored beginnings, peaks, breakups, and endings.
- Renders every effect at a uniform native-or-smaller scale and caps long beam
  visuals without shrinking their gameplay coverage or stretching their art.
- Adds subtle deterministic visual-only timing offsets to multi-shot and storm
  effects without consuming gameplay RNG or changing firing cadence.
- Preserves weapon cooldowns, bounded damage windows, collision, immutable
  firing snapshots, rank-based reach and radius growth, evolution paths, and
  save compatibility.
- Adds a tiny boxed `v0.9.5` tag only to the title and pause menus.
- Keeps prompts, chroma sources, keyed intermediates, rejected variants, and
  reproducible build sources out of the playable package.
