# Projectile readability candidate manifest

Generated and audited on 2026-08-15, then integrated into the v0.9.5 candidate
based on Groove Bound v0.9.4.

## Validation summary

- 32 accepted PNGs exactly match the 32 stable runtime projectile IDs.
- Every accepted file is 2048 x 1024 RGBA in a 4 x 2 grid of 512 x 512 cells.
- Every sheet has eight populated, byte-distinct frames and no cell-edge bleed.
- Every sheet contains real transparent and partial-alpha pixels.
- Transparent area ranges from 90.22% to 99.21%; opaque area never exceeds
  5.48% of a sheet.
- All 32 accepted file hashes are unique.
- The media audit reports no risks.
- `source-candidates/` is explicitly excluded by `scripts/package_love.py`.
- v0.9.5 package verification must confirm all runtime sheets are present and
  no source-candidate paths are included.

## Accepted sheets

All paths below are relative to `sheets/`.

| File | SHA-256 |
|---|---|
| `aurora_harp.png` | `c1eaba818e7d7b0c71ff02172e3fad5e10e368727a45c3d4478c5f116ab9b518` |
| `bass_drop.png` | `632978173b229a21df32120b4184448fa5b43b6b7dcaa286a8f4f9b2162c659f` |
| `bell_tower.png` | `736ef4eeb1c8402e34234bf975fc32bb2fb271c15321eba9bc559cb76730c4aa` |
| `brass_barrage.png` | `d3d9ef01a7914854263fe852c36ae181b498a49c9eca4a002a8930287c999387` |
| `carnival_superorbit.png` | `d1961b8a4ab93642964907fbf707df25614db1e25c61cfc4b51f923bb14bd857` |
| `cathedral_overdrive.png` | `6e1bafefcbb17cd0698c72ea5b1d19145cb8365fb78287eeeb8621b9c44b5aef` |
| `cello_lance.png` | `03b501e42cd15c7392b64d8ad960f198ed35ccd6cc1997405b9a88e904ec393e` |
| `cymbal_slicer.png` | `e74d6887b85b239630ab28425a7cbe90a70f223e281e25f1b12e677757499bac` |
| `drum_circle.png` | `d2dc8f59be355a58e0fa67280eeaab42369c6879e3a76c5f100327d274781a85` |
| `feedback_loop.png` | `56747636f4632b7c5d48fe6e8d1ca217e5edc7bf5d92f31eb3d00b5306f5450b` |
| `golden_fortissimo.png` | `1cfebc73ee57034948983a1a6f1f64c5dce5eb114108dd0831b8149dd6a04590` |
| `gravity_groove.png` | `34f020387ceeeb1387becfabd6551003764e7dabea2624217d9ea9aeaac26c65` |
| `improvised_solo.png` | `db6e7a4ba43f8c06b487b53169475796b863f361c0e11bd48543fa43525ec0c0` |
| `infinite_mixtape.png` | `b37142cea450fb92c9e8b27db6e171a37d216702332fa82e7b36cad137544692` |
| `kazoo_pistol.png` | `4b59acaf2dd38ba802229f0b5a566b6e2ef6f63ef77b9de8fc1b4d79c70dfcb8` |
| `keytar_chord.png` | `cd47b1290bb33494b0ac4629b9be689965493f157126c86bdffcdc8d48d23c42` |
| `laser_harp.png` | `e4bdc7dc3062b1423869bdfc36fcf99e14f76ec5019099f247da4eb8d4c38317` |
| `maraca_orbit.png` | `427308149fee799246480e5f297ccb64b761c0abad7926000f93cedd0d7df488` |
| `neon_crescendo.png` | `d66d796a0d0d53cb6d3d425cd25b33ee3439657d94b7ccd887f88051919fc8ff` |
| `orbital_ovation.png` | `3d775c57f9e9c6047bb84c582899b49f5cc99ad2e4253fff343847533db159b5` |
| `prismatic_triangle.png` | `6e2c13051d5551dac65f12762c86dacca0c0d2290c4c9faf821c5791591c6f39` |
| `resonance_rupture.png` | `b76804468a45ea940098b428e181ff6065dff997d8cff37df5b36db449feda6f` |
| `stadium_keytar.png` | `236ca6c5371c96f149b381e48e5ef2d64e8a1cd555aca5b015c95e34d33ee6cb` |
| `subwoofer_supernova.png` | `2306c59defc027bbd138c281bb197d9c8f639fe09080f4c4224434dc56805daa` |
| `synth_wave.png` | `3f11932006c10e39a9dc68fd3190c7397dc8fbaf150b8ed7959072f84aca9d69` |
| `tape_repeater.png` | `7e1a8d16fbb7576e1e7117e866a0e698d4331f8b11b6af25d38efa7c5d62261e` |
| `thunderhead_ensemble.png` | `0105010f5c4fe6b864dff15954270e8343611e7ba3abd3ad7c9ab73faaf4a817` |
| `triangle_tracer.png` | `4bfce0efe3c70449957417c25f4c16b55b9dd7b43f8799764f24ce0b4cfc207f` |
| `trumpet_burst.png` | `7dda67691bf07d7e2d7ebf2436d4ab08d749bc1dc54d422ab78691bdf552f99f` |
| `tuning_fork.png` | `b5e818d443dbaa474d895596c776fb7502bb04fc7bce4c657904fe93e2e77494` |
| `velvet_impaler.png` | `79ebb82eef4ac41db6c032eb756dd3a3677102c432ea1b277d3d6c7d1b7f2b0b` |
| `vinyl_scratch.png` | `5f00a7f169b5631abfa5c0b9b28b84430f182d85fc0015b39455da282f1d6b81` |
