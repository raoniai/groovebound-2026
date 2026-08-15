# Player attack animation source prompts

**Mode:** Codex built-in OpenAI image generation

**References:** the v0.9.1 projectile atlas for palette and finish; the combat
effects atlas as a density limit; the rejected shared attack atlas as a list of
abstract attack categories only.

Four accepted prompts each requested a five-column by eight-row pixel-art stage
board on flat chroma green. The rows map to eight stable weapon IDs and the
columns always map to anticipation/charge, formation/launch, full-power peak,
fracture/retraction, and fading remnant. Every cell had to be a separately
painted state rather than a transformed duplicate. The four boards cover the
first eight base attacks, second eight base attacks, first eight evolutions,
and second eight evolutions respectively.

The prompts assigned clean silhouettes to darts, bombs, crescents, lightning,
rings, waves, orbitals, deployables and beams; required generous cell padding,
controlled glow and restrained particles; and prohibited text, characters, UI,
background variation and cross-cell effects. Bomb rows explicitly move from
flight through detonation to aftermath. Long beam rows explicitly include an
origin, natural-length formed beam, full peak and end cap, fractured retraction,
and remnant, never a short sprite intended for non-uniform stretching.

The stage boards are never loaded by the game. The build script extracts them
into 32 separate 1920x128 runtime strips, each containing five genuine 384x128
authored frames. It verifies five distinct frame hashes within every atlas.
