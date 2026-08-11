# World Tour website asset copies

These files are byte-identical presentation copies of canonical runtime art from
`groove-bound/assets/generated/campaign/`. The game-owned files remain the
authority; replace a website copy only after comparing its SHA-256 digest with
the matching runtime source.

## Playable world sets

- `funk-*`, `soul-*`, and `disco-*`: enemy, environment, and floor atlases used
  by the three currently playable World Tour worlds on the active local branch.

## World Tour systems

- `world-tour-ui-atlas.png`: world and grade emblems.
- `world-interface-atlas.png`: journey, record, reward, and mastery icons.
- `world-mechanics-atlas.png`: Funk Pocket and Disco spotlight states.
- `meta-perks-atlas.png`: the permanent perk database art.
- `menu-button-icons-atlas.png`: journey and protected reset actions.
- `evolved-weapon-icons-atlas-2.png`: the second eight-cell evolution roster;
  the site derives transparent Catalog sprites 9–16 from these strict cells.

## Chests, results, and progression

- `musical-chest-atlas.png`: standard eight-frame chest loop.
- `stage-clear-chest.png`: mandatory Encore Gate stage-clear chest.
- `chest-luck-reveal-atlas.png`: luck reels and reward reveal backplates.
- `completion-ui-atlas.png`: completion crests and result badges.
- `funk-pocket-pad-atlas.png`: five Funk timing-pad states.

Generated source candidates remain outside the site and are not runtime or
public presentation assets.

## Individual website sprites

The public site does not map atlas cells in CSS or JavaScript. Run
`python3 landing-page/scripts/extract-world-tour-sprites.py` from the repository
root to regenerate `sprites/` from the canonical runtime atlases.

The extractor:

- segments connected artwork across each complete transparent atlas;
- assigns every component to its nearest authored sprite instead of clipping it
  at the nominal grid line;
- recovers complete subjects that cross a cell boundary while preventing the
  same component from appearing in a neighboring output;
- discards isolated one-to-three-pixel alpha noise;
- removes residual chroma green from the affected generated sheets;
- clears hidden RGB under fully transparent pixels;
- trims every transparent edge to the exact non-zero alpha bounds;
- preserves native pixels without resizing; and
- records source-component assignments, authored cells, recovered extensions,
  alpha bounds, dimensions, and SHA-256 digests for all 160 derivatives in
  `sprites/manifest.json`.

Opaque floor cells still retain their exact grid dimensions because the visible
texture reaches every edge. Original atlases remain byte-identical website
copies and are retained only as provenance sources; live cards, inspectors,
floating elements, animation frames, and World Tour galleries use individual
PNGs.
