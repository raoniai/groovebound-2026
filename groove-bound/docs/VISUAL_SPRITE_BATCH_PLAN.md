# Groove Bound visual sprite batch plan

## Delivery boundary

This plan separates the implemented interface batch from the next enemy
animation batch. Runtime media lives under `assets/generated/campaign/`.
Editable image-generation outputs live under `assets/generated/source-candidates/`
and are excluded from release packages.

## Batch A — transparent interface chrome (implemented)

- `campaign/aim-reticle.png` is a square transparent marker drawn at its native
  aspect ratio. The system cursor is hidden only while the run itself is active.
- `campaign/hud-slot-frame.png` is transparent frame artwork. Runtime divides it
  into four fixed corners and repeatable top, bottom, left, and right strips.
  Wide or tall blocks extend by tiling strips rather than stretching pixels.
- Stat, warning, score, reroll, and skip symbols use the transparent code-drawn
  glyph family in `src/ui/icons.lua`.
- Top-left inventory, top-middle stage/time, top-right score, temporary buffs,
  and right-side power-up toasts place their background shade separately at
  approximately 50% opacity.
- Empty inventory slots contain no numbers or placeholder art: only the subtle
  shade and low-alpha tiled outline remain.

The initial opaque 6×4 atlas is reference-only under `source-candidates/` and is
excluded from the package. It is not loaded by the runtime.

Acceptance: no opaque tile backgrounds; no non-uniform sprite scaling; fixed
corner proportions; repeatable edge strips; readable at 32–64 pixels; concern
and critical states include text as well as colour; compact temporary notices
stay beneath the score block rather than covering the center of play.

## Batch B — character and game-over presentation (implemented)

- `campaign/joe-logo.png` and `campaign/lyra-vex-logo.png` are approved
  first-party copies from the separate landing-site asset set.
- `campaign/game-over-v2.png` is a full-screen defeat illustration with Joe and
  Lyra Vex, clean upper title space, and lower runtime-panel space.
- Character selection uses large portrait crops, logos, starting-weapon icons,
  stat icons, and a visual trait/weapon panel.
- Results use the new defeat art, icon-led run statistics, and a weapon rack.

## Batch C — three-frame enemies (production-ready plan, art pending)

The target is one three-frame loop for every stable enemy ID. Each enemy keeps
its current silhouette, palette, gameplay size, pivot, and threat readability.
The loop must feel alive without changing its collision radius.

| Stage | Enemy IDs | Frame intent |
|---|---|---|
| Backbeat | `monotone`, `tempo_leech`, `metronome_guardian`, `static_baron` | contact, compression, rebound |
| Backbeat | `syncopation_skitter`, `feedback_phantom`, `bass_brute`, `noise_turret` | contact, locomotion/charge, settle |
| Orbit | `vinyl_drone`, `trumpet_ray`, `drum_wheel`, `theremin_jelly` | hover/contact, active beat, recoil |
| Orbit | `amp_hound`, `keyboard_centipede`, `turntable_sentinel`, `grand_orchestrator` | contact, mechanical step, powered return |

### Proposed atlas contract

- Two atlases, one per stage, each 4 columns × 6 rows.
- Each enemy owns three vertically adjacent equal cells.
- Stage 1 mapping: columns 1–4 are the first four IDs, then columns 1–4 for the
  second four IDs; rows 1–3 and 4–6 hold their respective three-frame loops.
- Stage 2 uses the same mapping convention.
- Animation rates are data-driven per enemy, default 7 fps, scaled between
  0.8× and 1.25× by actual movement speed.
- Static attackers use an idle pulse until windup, then hold frame 2 and snap to
  frame 3 on release.
- Boss frames must keep the same feet/base pivot and never alter hit geometry.

### Enemy art acceptance

1. Exact equal cells, alpha edges, no bleed, no embedded floor shadow.
2. Frame-to-frame subject scale changes below 4%; feet/base pivot drift below
   two runtime pixels at authored draw size.
3. A three-frame contact sheet review at 32%, 50%, and 100% scale.
4. Runtime playback against normal speed, elite speed, overtime ×3, pause, and
   reduced-effects settings.
5. Collision/debug overlay confirms the sprite never changes hit geometry.
6. Package audit includes runtime atlases exactly once and excludes sources.

Until those atlases exist and pass the checks above, the current single-frame
enemy art remains authoritative. Code should not fabricate or duplicate frames
and call the art batch complete.
