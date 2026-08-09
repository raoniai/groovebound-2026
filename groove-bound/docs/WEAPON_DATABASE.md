# Arsenal, Supports, and Fusion Database

The live database now projects three authoritative content families:

- 16 base weapons, each with ten ranks;
- 8 support enhancements;
- 8 fused evolution weapons.

Open **Arsenal Database** from the development-only Admin tab. It is no longer
exposed on the title or pause menu. Use
arrows/WASD or D-pad to navigate, Tab or controller shoulders to change
filters, and Escape/B to return. The Supports filter shows live support
ownership, rank, effect, level-up availability, and authored fusion pairings.

## Base weapons

| Weapon | Stable ID | Mechanic |
|---|---|---|
| Kazoo Pistol | `kazoo_pistol` | Balanced aimed starter |
| Bass Drop | `bass_drop` | Slow heavy piercer |
| Cymbal Slicer | `cymbal_slicer` | Fast aimed fan |
| Feedback Loop | `feedback_loop` | Accelerating focused fire |
| Drum Circle | `drum_circle` | 360-degree radial control |
| Trumpet Burst | `trumpet_burst` | Tight knockback cone |
| Vinyl Scratch | `vinyl_scratch` | Four cutting lanes |
| Synth Wave | `synth_wave` | Slow broad projectile wall |
| Triangle Tracer | `triangle_tracer` | Very fast precision piercer |
| Cello Lance | `cello_lance` | High-damage sniper thrust |
| Maraca Orbit | `maraca_orbit` | Rapid rotating spiral |
| Tuning Fork | `tuning_fork` | Front-and-back paired lanes |
| Keytar Chord | `keytar_chord` | Large advancing formation |
| Bell Tower | `bell_tower` | Slow heavy radial nova |
| Tape Repeater | `tape_repeater` | Alternating sideways lanes |
| Laser Harp | `laser_harp` | Fast close-range fan |

Damage, cooldown, amount, speed, size, lifetime, spread, pierce, knockback,
pattern, projectile color, atlas cell, role, and rarity are content data.
Admin multipliers and support bonuses are applied only when an immutable
projectile snapshot is created.

## Supports

| Support | Stable ID | Per-rank effect | Fusion pair |
|---|---|---|---|
| Quickstep | `quickstep` | +10% movement | Cymbal Slicer |
| Encore | `encore` | +15% maximum health | Drum Circle |
| Breath Control | `breath_control` | +8% cooldown stability | Kazoo Pistol |
| Power Amplifier | `power_amplifier` | +12% all damage | Bass Drop |
| Pickup Magnet | `pickup_magnet` | +20% attraction range | Vinyl Scratch |
| Overdrive Pedal | `overdrive_pedal` | +9% fire rate | Feedback Loop |
| Echo Chamber | `echo_chamber` | +1 projectile | Synth Wave |
| Safety Vest | `safety_vest` | +12 guard | Trumpet Burst |

Support bonuses remain live while the support is owned. A fusion consumes its
paired support, so that bonus is removed and the support slot immediately
reopens.

## Fusion evolutions

| Base + support | Result | Stable result ID |
|---|---|---|
| Kazoo Pistol R10 + Breath Control | Brass Barrage | `brass_barrage` |
| Bass Drop R10 + Power Amplifier | Subwoofer Supernova | `subwoofer_supernova` |
| Cymbal Slicer R10 + Quickstep | Orbital Ovation | `orbital_ovation` |
| Feedback Loop R10 + Overdrive Pedal | Improvised Solo | `improvised_solo` |
| Drum Circle R10 + Encore | Thunderhead Ensemble | `thunderhead_ensemble` |
| Trumpet Burst R10 + Safety Vest | Golden Fortissimo | `golden_fortissimo` |
| Vinyl Scratch R10 + Pickup Magnet | Gravity Groove | `gravity_groove` |
| Synth Wave R10 + Echo Chamber | Neon Crescendo | `neon_crescendo` |

When a recipe becomes legal, the HUD displays **CHEST READY**. The pause menu
illustrates base weapon + support = evolved result, rendering satisfied
requirements in full colour and missing requirements at reduced opacity. The
fusion is reserved for the next collected musical chest; ordinary level-up
offers cannot evolve weapons.

With Admin → Rewards → **Show evolution needs** enabled, every relevant
weapon/support card names its pairing and the bottom guide reports:

- current weapon rank versus rank 10;
- the exact paired support and whether it is owned;
- the evolved result;
- whether the fusion is ready.

A musical chest is required. Once the base weapon is rank 10 and the paired
support is owned, that fusion takes priority inside the chest's automatic
one-, three-, or five-reward roll. The paused chest luck screen visibly settles
each reel on its exact weapon, support, fusion, or utility result before combat
resumes.

Resolving it from the chest performs one atomic transaction:

1. verify rank, support, result uniqueness, and live emitter consistency;
2. replace the base weapon in its exact firing slot;
3. consume the exact paired support;
4. resynchronise all support modifiers;
5. grant one additional weapon-capacity slot, up to six active weapons;
6. expose the freed support slot and new weapon capacity to future cards;
7. roll inventory, support state, capacity, and runtime back on failure.

Existing projectiles retain their original source ID and stats.

## Offer rotation and full slots

Offers use the run's seeded loot stream, so they are randomized but
reproducible. A choice shown on the immediately previous offer is avoided when
another legal choice in the same category exists.

While weapon/support slots are open, new base items rotate through the cards.
When both inventories are full, at least two cards are drawn from owned weapon
or support rank-ups so the player can reach fusion requirements. Fusion
consumes its support, keeps the evolved weapon in the original firing slot,
raises weapon capacity by one up to six, and therefore reopens both inventories
for new base items.

## Visual assets

Base, support, and fused icons are separate 1024×512 RGBA atlases with 256×256
cells. Fused icons visibly combine both ingredients and use brighter legendary
materials while retaining the base silhouette. Full generation prompts,
mappings, and processing provenance are recorded in
`assets/generated/PROVENANCE.md`.
