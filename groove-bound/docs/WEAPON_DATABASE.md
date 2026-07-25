# Weapon Database

The playable database contains eight base weapons and two evolved weapons.
`src/content/weapons.lua` is the authored source of truth. The in-game Arsenal
Database is a read-only projection of that content plus the current run's
authoritative inventory, active emitters, passive requirements, available
slots, and Resolve state.

Open the Arsenal Database from the title menu, pause menu, or Admin dashboard.
In the database, use arrows/WASD or the D-pad to navigate, Tab or controller
shoulders to change filter, and Escape/B to return.

## Base roster

| Weapon | Stable ID | Role | Pattern | Rank-1 profile | Rank-10 profile |
|---|---|---|---|---|---|
| Kazoo Pistol | `kazoo_pistol` | Balanced starter | Aimed | 10 damage, 0.80s, ×1 | 28 damage, 0.43s, ×3 |
| Bass Drop | `bass_drop` | Heavy piercer | Aimed | 20 damage, 1.20s, ×1 | 72 damage, 0.65s, ×3 |
| Cymbal Slicer | `cymbal_slicer` | Wide spread | Aimed fan | 7 damage, 0.52s, ×2 | 23 damage, 0.25s, ×5 |
| Feedback Loop | `feedback_loop` | Rapid focus | Aimed | 9 damage, 0.68s, ×1 | 30 damage, 0.26s, ×4 |
| Drum Circle | `drum_circle` | Radial control | 360-degree ring | 7 damage, 1.45s, ×6 | 24 damage, 0.72s, ×14 |
| Trumpet Burst | `trumpet_burst` | Close burst | Tight aimed cone | 11 damage, 0.92s, ×3 | 38 damage, 0.42s, ×8 |
| Vinyl Scratch | `vinyl_scratch` | Lane cutter | Cross lanes | 13 damage, 0.88s, ×2 | 45 damage, 0.37s, ×6 |
| Synth Wave | `synth_wave` | Area wall | Wide aimed wall | 16 damage, 1.30s, ×3 | 56 damage, 0.60s, ×8 |

Every base weapon has ten explicit, boot-validated rank rows. Unowned base
weapons are eligible for normal level-up cards only while a weapon slot is
free. Owned weapons return as rank-up cards until rank 10. The level-up
generator excludes duplicates, capped weapons, evolved results, and
slot-invalid additions before seeded selection.

## Evolutions

| Result | Stable ID | Branch | Recipe | Profile |
|---|---|---|---|---|
| Brass Barrage | `brass_barrage` | Studio | Kazoo Pistol R10 + Breath Control R1 + Resolve | 42 damage, 0.36s, ×3, pierce 3 |
| Improvised Solo | `improvised_solo` | Live | Kazoo Pistol R10 + Breath Control R1 + Resolve | 34 damage, 0.28s, ×2, cross lanes, pierce 2 |

Resolve is granted by the Metronome Guardian miniboss. When both branches are
legal, both evolution cards are placed ahead of normal rank and acquisition
cards. Selecting a branch atomically replaces the exact Kazoo inventory slot
and the exact emitter currently firing from it. Existing projectiles retain
their original weapon snapshots.

## Database status meanings

| Status | Meaning |
|---|---|
| `ACTIVE` | Owned and cross-checked against the emitter firing from the same slot |
| `OWNED` | Present in inventory, but the runtime emitter does not currently match |
| `EVOLVE NOW` | All recipe requirements and a Resolve token are present |
| `LEVEL-UP POOL` | Legally purchasable as a new weapon or owned rank upgrade |
| `EVOLUTION ONLY` | Cannot appear as a normal weapon acquisition |
| `SLOTS FULL` | Base weapon is unowned and no weapon slot is free |

The `OWNED` but not `ACTIVE` distinction is deliberate: it makes an inventory
and firing-runtime desynchronisation visible rather than silently reporting
the weapon as healthy.

## Visual atlas

All eight base icons come from
`assets/generated/weapon-icons-atlas.png`, a 1024×512 RGBA 4×2 atlas with
256×256 cells. Provenance, production prompt, source file, processing steps,
and stable cell mapping are recorded in
`assets/generated/PROVENANCE.md`.
