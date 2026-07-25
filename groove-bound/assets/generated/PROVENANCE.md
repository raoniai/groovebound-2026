# Generated Weapon Icon Atlas

**Created:** 26 July 2026  
**Generator:** OpenAI image generation available in Codex  
**Rights source:** Original generated artwork; no third-party source image was
used as an input.

## Files

- `weapon-icons-atlas-source.png` — untouched 1774×887 generator output with a
  chroma-key magenta background. It is retained as editable provenance and
  excluded from the packaged `.love`.
- `weapon-icons-atlas.png` — runtime 1024×512 RGBA atlas. Chroma key was
  removed with the bundled `remove_chroma_key.py` helper, then the result was
  resized with nearest-neighbour filtering.

## Final production prompt

> Create one strict 4-column by 2-row sprite atlas containing exactly eight
> separate square retro pixel-art weapon icons for a music-themed survival
> roguelike. Row 1 left to right: brass kazoo pistol, bass speaker emitting a
> shockwave, spinning golden cymbal blade, feedback microphone with electric
> loop. Row 2 left to right: marching drum with radial sticks, red trumpet
> firing a cone, purple vinyl record with scratch sparks, cyan synthesizer
> projecting a wave. Each object must be centered within its own equal cell,
> fully contained with generous transparent-safe padding, consistent
> three-quarter view, chunky 16-bit pixel clusters, bold dark outline, bright
> neon highlights, no text, no labels, no numbers, no frames, no UI panels, no
> overlap, no shadows crossing cells. Use a single flat chroma-key magenta
> background with no texture, gradients, glow, or magenta inside the objects.
> Canvas aspect ratio exactly 2:1.

## Stable mapping

| Cell | Stable weapon ID |
|---|---|
| Row 1, column 1 | `kazoo_pistol` |
| Row 1, column 2 | `bass_drop` |
| Row 1, column 3 | `cymbal_slicer` |
| Row 1, column 4 | `feedback_loop` |
| Row 2, column 1 | `drum_circle` |
| Row 2, column 2 | `trumpet_burst` |
| Row 2, column 3 | `vinyl_scratch` |
| Row 2, column 4 | `synth_wave` |

The two Kazoo evolutions intentionally inherit the base Kazoo silhouette with
distinct evolution tinting until their production illustrations are authored.

## Concurrent generated candidates captured with the repository snapshot

The following generated atlas pairs appeared in the shared project workspace on
26 July 2026 after the first repository snapshot was committed:

- `enemy-variants-atlas-source.png` and `enemy-variants-atlas.png`
- `environment-atlas-source.png` and `environment-atlas.png`
- `evolved-weapon-icons-atlas-source.png` and
  `evolved-weapon-icons-atlas.png`
- `player-v2-sheet-source.png` and `player-v2-sheet.png`
- `support-icons-atlas-source.png` and `support-icons-atlas.png`
- `weapon-icons-atlas-2-source.png` and `weapon-icons-atlas-2.png`

They are retained as **generated reference candidates**, not as
production-approved or runtime-integrated assets. Detailed prompts, generator
metadata, processing steps, stable cell mappings, and approval records were not
present alongside the files when this repository snapshot was taken. Those
details must be added before any of these candidates is promoted into the
runtime or a public build.
