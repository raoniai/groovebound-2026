# Groove Bound — Cutscene Video Music Map

## Source of truth

Use the exact runtime OGG files in `assets/music/`. They are the locally
integrated, technically validated 48 kHz stereo, 32-beat edits used by the game.
Do not substitute the longer MP3 source candidates, generate a new composition,
or use the four files in `music/`, which are older theme exports rather than the
current cutscene routing.

The game's music router applies a `-4 dB` cutscene duck. For a finished video,
start at `-4 dB` and automate deeper ducking only where required for exact
dialogue intelligibility. Keep voices centred, retain stereo music, and place
foley around the dialogue rather than over it.

## Canonical cutscene routing

| Cutscene | Story beat | Cue ID | BPM | Catalog gain | Runtime file |
|---|---|---|---:|---:|---|
| Prologue, beat 1 | Backbeat alive | `prologue_city` | 92 | 0.62 | `assets/music/02_prologue_city.ogg` |
| Prologue, beat 2 | The Break | `prologue_break` | 100 | 0.60 | `assets/music/03_prologue_break.ogg` |
| Prologue, beats 3–4 | Emergency and resolve | `prologue_resolve` | 116 | 0.62 | `assets/music/04_prologue_resolve.ogg` |
| Joe intro | Joe character theme | `joe_intro` | 98 | 0.62 | `assets/music/06_joe_intro.ogg` |
| Lyra intro | Lyra character theme | `lyra_intro` | 142 | 0.62 | `assets/music/07_lyra_intro.ogg` |
| Stage 2 transition, beats 1–2 | First Press and map | `first_press` | 88 | 0.60 | `assets/music/13_first_press.ogg` |
| Stage 2 transition, beat 3 | Dead Line descent | `dead_line_recovery` | 90 | 0.58 | `assets/music/14_dead_line_recovery.ogg` |
| Ending | Grand Conductor teaser | `ending_teaser` | 96 | 0.58 | `assets/music/30_ending_teaser.ogg` |

All paths above are relative to the canonical runtime folder:
`/Users/raonilima/Documents/Groove Bound/groove-bound/`.

## Recommended cue edit map

| Cutscene | 15-second edit | 30-second edit |
|---|---|---|
| Prologue | 02: 0–4s → 03: 4–8s → 04: 8–15s | 02: 0–8s → 03: 8–15s → 04: 15–30s |
| Joe intro | 06 continuous for 15s | 06 continuous; loop only at its authored 32-beat boundary |
| Lyra intro | 07 continuous; its 32-beat loop repeats once | 07 continuous; repeat only at authored loop boundaries |
| Stage 2 transition | 13: 0–10s → 14: 10–15s | 13: 0–19s → 14: 19–30s |
| Ending | 30 continuous for 15s | 30 continuous; loop at its authored 32-beat boundary around 20s |

Use short equal-power crossfades only where the cue changes. Align the midpoint
of each crossfade to a visual cut and a musical beat. Never time-stretch a cue
to force a transition; trim on a beat or use its clean loop boundary.

## Upload mapping by generation

### Prologue

- `@Audio 1` → `assets/music/02_prologue_city.ogg`
- `@Audio 2` → `assets/music/03_prologue_break.ogg`
- `@Audio 3` → `assets/music/04_prologue_resolve.ogg`

### Joe intro

- `@Audio 1` → `assets/music/06_joe_intro.ogg`

### Lyra intro

- `@Audio 1` → `assets/music/07_lyra_intro.ogg`

### Stage 2 transition

- `@Audio 1` → `assets/music/13_first_press.ogg`
- `@Audio 2` → `assets/music/14_dead_line_recovery.ogg`

### Ending

- `@Audio 1` → `assets/music/30_ending_teaser.ogg`

## Voice and soundtrack separation

Seedance may treat uploaded audio as a style/rhythm reference rather than
preserving it sample-for-sample. For guaranteed soundtrack parity in the game,
the final delivery should contain separable audio if the interface provides it:

1. dialogue stem;
2. sound-effects and ambience stem;
3. music stem or a clean video without replacement music.

During final video preparation, lay the exact runtime OGG cue back under the
dialogue and effects according to the edit map above. Reject a generated video
if it invents a different melody, adds singing or vocal chops, audibly warps the
supplied cue, or bakes dialogue so unclearly that it cannot be remixed.

## Existing reusable game sound effects

These are optional spot effects, not music tracks. They may be layered during
final editing when their action occurs:

| Event | File |
|---|---|
| Kazoo/projectile release | `assets/legacy/sfx/projectile.ogg` |
| Robot destruction | `assets/legacy/sfx/enemy-death.ogg` |
| Resonance pickup | `assets/legacy/sfx/xp.ogg` |
| Power/evolution accent | `assets/legacy/sfx/level-up.ogg` |

The video prompts also call for scene-specific generated foley—trains, crowd,
radio static, cosmic tears, gates, rails, robot servos and debris—which does not
currently exist as discrete project audio. Preserve those effects as a separate
stem where possible so they can be balanced against the game soundtrack.

## Audio acceptance checks

- Correct cue file or sequence for the cutscene.
- No substituted music, vocals, choir, chanting, rap, vocal chops or lyrics.
- All current dialogue appears once, verbatim and intelligibly.
- Music ducking is smooth and returns naturally after each line.
- Impacts, footsteps, weapon sounds and environmental foley land on picture.
- No clipping, pumping, abrupt cue splice or audible loop seam.
- Final render is stereo and ready to replace the current visual background.
