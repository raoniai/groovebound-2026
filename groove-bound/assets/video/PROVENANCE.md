# Cutscene video provenance

The MP4 files in this directory are user-supplied editable source media and are
excluded from the `.love` package. Runtime OGV files live in `runtime/`.

| Source | Runtime mapping | Technical transform |
|---|---|---|
| `cutscene-0-main_menu.mp4` | `runtime/cutscene-0-main_menu.ogv` | Existing title loop |
| `cutscene-1-prologue.mp4` | `runtime/cutscene-1-prologue.ogv` | Existing prologue |
| `cutscene-2-joe_intro.mp4` | `runtime/cutscene-2-joe_intro.ogv` | Existing Joe intro |
| `cutscene-3-lyra_intro.mp4` | `runtime/cutscene-3-lyra_intro.ogv` | Existing Lyra intro |
| `cutscene-4-stage2_transition.mp4` | `runtime/cutscene-4-stage2_transition.ogv` | Theora quality 7, Vorbis quality 1 |
| `cutscene-5-ending_v1.mp4` | `runtime/cutscene-5-ending.ogv` | Theora quality 7, Vorbis quality 1; runtime name normalized to scene ID `ending` |

The two new sources are 1280×720, 24 fps, approximately 30.08 seconds, with AAC
source audio. Their runtime files are 1280×720 Theora video with Vorbis audio.
The original MP4s are preserved without modification.
