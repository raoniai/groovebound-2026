# World Tour V1 Music QA

## Delivery state

- Generated in the user's Groove Bound Suno workspace on 13 August 2026.
- Model and settings: Suno v5.5, Advanced, Instrumental, Auto duration,
  Weirdness 30%, Style influence 80%.
- Cost: 28 Create actions, 280 credits, two candidates per action.
- Promoted set: one neutral World Tour hub cue plus three unique cues for each
  of the nine worlds. No world shares another world's route, pressure, or
  finale asset.
- Source masters: 28 promoted 48 kHz stereo MP3 files under
  `assets/generated/source-candidates/music/world-tour-v1/` and excluded from
  release packages.
- Runtime: 28 48 kHz stereo OGG Vorbis files under `assets/music/`.
- Automated audio audit: all 59 soundtrack records passed; World Tour LUFS
  range -18.6 to -17.4, highest true peak -5.1 dBFS, highest decoded seam jump
  0.04254.
- Unit/regression suite: 358 tests, 0 failures after integration.
- Boogie Tank exception: the promoted first take is a validated 32-beat loop
  because neither generated candidate contained a safe 64-beat window. Both
  source candidates are preserved; no regeneration was used.
- Cue 55 exception: the source required a cue-specific -19.5 LUFS processing
  target to land at -18.1 LUFS within the shipped tolerance.
- Listening status: automated waveform, beat-grid, loudness, peak, edge, seam,
  and in-engine load checks are verified. Human creative listening and native
  Windows playback remain separate manual gates.

## Promoted Suno sources

| Cue | Source master | Duration | Suno song ID |
|---:|---|---:|---|
| 31 | `31-world-tour-hub-passport-to-the-pocket.mp3` | 185.613 s | `9364767f-bad4-4ea2-9566-a276020be51e` |
| 32 | `32-world-funk-route-hold-the-pocket.mp3` | 159.680 s | `41158b2e-1a47-441a-becb-d18bc687cad2` |
| 33 | `33-world-funk-boss-boogie-tank-lockdown.mp3` | 34.681 s | `3233f661-e28f-4d08-bdb9-20bea4012882` |
| 34 | `34-world-funk-finale-board-the-mothership.mp3` | 124.720 s | `ac7849be-a76a-421a-a12c-f3490453028b` |
| 35 | `35-world-soul-route-velvet-resonance.mp3` | 212.120 s | `07cea899-716c-4897-a5d7-52aaeadc77d3` |
| 36 | `36-world-soul-boss-organ-colossus.mp3` | 156.400 s | `42bc3bab-e0b9-457f-808c-6bf9b7284a2a` |
| 37 | `37-world-soul-finale-velvet-titan-rising.mp3` | 165.920 s | `3f5f97d2-c2b5-4ac6-b3b2-496f441020f1` |
| 38 | `38-world-disco-route-mirrorball-metro.mp3` | 149.680 s | `ac2bbb57-fb44-45d1-946c-537fdfebde7c` |
| 39 | `39-world-disco-boss-laser-conductor.mp3` | 162.320 s | `495ea0be-d31d-42cd-b544-a3495cc1c3cc` |
| 40 | `40-world-disco-finale-prism-monarch.mp3` | 189.280 s | `a2aaf11e-2ac0-4c02-bccc-b775aacde577` |
| 41 | `41-world-house-route-warehouse-909.mp3` | 156.920 s | `0d0419f7-e355-4972-a211-80d75c3d1253` |
| 42 | `42-world-house-pressure-floor-cycle-overdrive.mp3` | 127.160 s | `6f7206f5-116a-4f75-bc1a-1afd5da42166` |
| 43 | `43-world-house-finale-kickdrum-constructor.mp3` | 184.681 s | `7d8e066d-5616-4c44-91ac-42caadd1a8b3` |
| 44 | `44-world-electro-route-neon-circuit.mp3` | 161.120 s | `7b415fc1-cfda-4725-927c-c6619d82ba7f` |
| 45 | `45-world-electro-pressure-node-chain-surge.mp3` | 129.080 s | `a4e87287-a377-4ab4-88f4-3198c9e18c86` |
| 46 | `46-world-electro-finale-voltage-vandal.mp3` | 68.600 s | `66b5574e-6ca6-41f1-81cb-6987f0377fa3` |
| 47 | `47-world-techno-route-the-iron-loop.mp3` | 222.721 s | `eb59e93f-134c-4c5b-962a-541d8d9c1d19` |
| 48 | `48-world-techno-pressure-memory-loop-breach.mp3` | 88.040 s | `76b0b775-88b2-4983-add9-b4c7268d95d7` |
| 49 | `49-world-techno-finale-loop-architect.mp3` | 153.040 s | `8e1b3f3c-809e-4f65-9d7f-e45784c6e8da` |
| 50 | `50-world-cosmic-boogie-route-orbital-dance-deck.mp3` | 171.880 s | `0961f2fe-dea2-4603-a1e3-9c315df9d734` |
| 51 | `51-world-cosmic-boogie-pressure-zero-g-pocket.mp3` | 178.201 s | `22188ef8-22d1-4cb0-a682-fec705b81067` |
| 52 | `52-world-cosmic-boogie-finale-celestial-selector.mp3` | 193.840 s | `29dd7f2a-5338-4a06-90d9-255a5d01ef3b` |
| 53 | `53-world-soulful-garage-route-midnight-garage.mp3` | 208.600 s | `4841602b-c869-4a20-975f-4724b7092704` |
| 54 | `54-world-soulful-garage-pressure-resonance-gate.mp3` | 183.160 s | `84858042-ceda-4b31-ad3b-87ea33f9a0d8` |
| 55 | `55-world-soulful-garage-finale-night-shift-conductor.mp3` | 140.960 s | `1837fe71-1bdc-4fa4-a3ba-ae9d751bf903` |
| 56 | `56-world-future-funk-route-tomorrow-mall.mp3` | 192.200 s | `ab3d6161-10c2-4e30-b497-2e78f52170d5` |
| 57 | `57-world-future-funk-pressure-sample-memory-corrupt.mp3` | 158.521 s | `accca47b-3e86-4252-a7da-035c4820f675` |
| 58 | `58-world-future-funk-finale-the-recompiler.mp3` | 184.600 s | `d0e4867f-1e9e-4a7e-baf9-93875818ce8c` |

## Runtime audit

| Cue | Stable ID | BPM | Beats | Duration | LUFS | Peak dBFS | Seam | SHA-256 | Suno song ID |
|---:|---|---:|---:|---:|---:|---:|---:|---|---|
| 31 | `world_tour_hub` | 110 | 128 | 69.827 s | -18.4 | -6.5 | 0.00530 | `9d4ec679c885e6c1769b0c11840fa9f171c10597fb810d7ec0aaf90fa0b6909e` | `9364767f-bad4-4ea2-9566-a276020be51e` |
| 32 | `world_funk_route` | 112 | 128 | 68.567 s | -17.5 | -5.3 | 0.01176 | `2772248b2039cb49ebbb8102df1399ac4823e44296c20d278a73a855fab4c363` | `41158b2e-1a47-441a-becb-d18bc687cad2` |
| 33 | `world_funk_boogie_tank` | 118 | 32 | 16.264 s | -17.9 | -6.2 | 0.00419 | `c079f4ec56567550994183a1bba53943d33fbca83080c939e54521308cf4c7db` | `3233f661-e28f-4d08-bdb9-20bea4012882` |
| 34 | `world_funk_mothership` | 124 | 64 | 30.961 s | -17.8 | -7.1 | 0.00290 | `6c9babc16758c4b35ac751d18e7df69540d0b7d9bc69a56730137d590a5d4eb5` | `ac7849be-a76a-421a-a12c-f3490453028b` |
| 35 | `world_soul_route` | 92 | 128 | 83.480 s | -17.4 | -5.9 | 0.00192 | `448c7933b65eaa56bf276df9e15e8de0ba1c757cae63a291363d5fb587b9a593` | `07cea899-716c-4897-a5d7-52aaeadc77d3` |
| 36 | `world_soul_organ_colossus` | 100 | 64 | 38.396 s | -18.2 | -7.1 | 0.01169 | `795cf496a406e6d427538e0ee49f1df96c24d647c63e21bc701ef178c54b3b7c` | `42bc3bab-e0b9-457f-808c-6bf9b7284a2a` |
| 37 | `world_soul_velvet_titan` | 108 | 64 | 35.559 s | -18.0 | -7.0 | 0.00079 | `b003ec13c1fbc0196ff6f29be4c59761bddf1eb76b6f0946d2653819edaf2f7a` | `3f5f97d2-c2b5-4ac6-b3b2-496f441020f1` |
| 38 | `world_disco_route` | 122 | 128 | 62.943 s | -17.8 | -6.7 | 0.00292 | `5a5dc1f0e3973b9d30237f8260e9d74143bfdc6d26c20cb4ee658949f2869777` | `ac2bbb57-fb44-45d1-946c-537fdfebde7c` |
| 39 | `world_disco_laser_conductor` | 128 | 64 | 29.987 s | -17.7 | -8.1 | 0.00584 | `bc3bd808b7c84ca51bb8d59a678a2028b2bad9b5f64ef8135352cdb1f9e8bc3a` | `495ea0be-d31d-42cd-b544-a3495cc1c3cc` |
| 40 | `world_disco_prism_monarch` | 132 | 64 | 29.081 s | -18.1 | -8.0 | 0.00167 | `1b3c6def04e5cf3423a0117eb3a0083ef74a2533e8a281a9d3384eb841d20455` | `a2aaf11e-2ac0-4c02-bccc-b775aacde577` |
| 41 | `world_house_route` | 124 | 128 | 61.927 s | -18.5 | -7.7 | 0.00749 | `8ad7caffac1730775f799db2f03ea8a8541e39f50a955a36c313f44f53a677e2` | `0d0419f7-e355-4972-a211-80d75c3d1253` |
| 42 | `world_house_pressure` | 128 | 64 | 29.988 s | -18.0 | -8.7 | 0.00174 | `e777d8e024d69583dc569392b6369a423afcf9645dfdee3b1c9c09ed01dd07b9` | `6f7206f5-116a-4f75-bc1a-1afd5da42166` |
| 43 | `world_house_kickdrum_constructor` | 130 | 64 | 29.528 s | -17.8 | -6.9 | 0.00624 | `447939225d81eac806ac297a2bfa13204bb0f1a53d953ebb64ad6ac1ffd0722b` | `7d8e066d-5616-4c44-91ac-42caadd1a8b3` |
| 44 | `world_electro_route` | 118 | 128 | 65.072 s | -18.0 | -7.2 | 0.00609 | `3789e694383a90a82ce349b92569d86d1cf9c064ac915608028a33e7d5365840` | `7b415fc1-cfda-4725-927c-c6619d82ba7f` |
| 45 | `world_electro_pressure` | 126 | 64 | 30.464 s | -17.9 | -8.0 | 0.00162 | `da6078cc4c309484784d907b9b3ccd4d2419fd5aad8208bb6ff1af5c1e37b7fc` | `a4e87287-a377-4ab4-88f4-3198c9e18c86` |
| 46 | `world_electro_voltage_vandal` | 132 | 64 | 29.077 s | -17.6 | -6.0 | 0.00751 | `e9709a73c82810be0bdece8b83f24331c6fd36792285d886f51b6b1657178ee4` | `66b5574e-6ca6-41f1-81cb-6987f0377fa3` |
| 47 | `world_techno_route` | 132 | 128 | 58.171 s | -17.9 | -6.4 | 0.04253 | `7d490d3f45f21ac7ecb9e6437f8a4d45cae9b4619ed81f15e2501cab4a8c34c4` | `eb59e93f-134c-4c5b-962a-541d8d9c1d19` |
| 48 | `world_techno_pressure` | 138 | 64 | 27.816 s | -17.8 | -8.1 | 0.00077 | `2be091107d6c7da8e20ff0884e686b2a68c066fe00014bf9a63078b20f9e68a8` | `76b0b775-88b2-4983-add9-b4c7268d95d7` |
| 49 | `world_techno_loop_architect` | 144 | 64 | 26.659 s | -17.9 | -7.9 | 0.00400 | `0533943ea4adfc2c7b605f10abf92f5448225c1f8af319cab9b98fe087218049` | `8e1b3f3c-809e-4f65-9d7f-e45784c6e8da` |
| 50 | `world_cosmic_boogie_route` | 116 | 128 | 66.209 s | -17.8 | -6.0 | 0.00709 | `09f3d1193790440c9197e78a88c760d7fdd369acaefbddbb0c9c979f302ebb2b` | `0961f2fe-dea2-4603-a1e3-9c315df9d734` |
| 51 | `world_cosmic_boogie_pressure` | 124 | 64 | 30.957 s | -18.0 | -6.0 | 0.00498 | `7a94a1a55461fcb50902a26d91b72721e2f4a1a6670d9bd293e0bb4eb1037944` | `22188ef8-22d1-4cb0-a682-fec705b81067` |
| 52 | `world_cosmic_boogie_celestial_selector` | 130 | 64 | 29.527 s | -17.8 | -6.8 | 0.00120 | `4b33a2067f1874d8f5e294a8fc1f6672f816a2aa41eba7bf7151d4ed278a2a97` | `29dd7f2a-5338-4a06-90d9-255a5d01ef3b` |
| 53 | `world_soulful_garage_route` | 132 | 128 | 58.175 s | -18.1 | -7.4 | 0.00364 | `e4ce95f8d7ad88004249970f95a675c3335187406703f4414a891d845c11932f` | `4841602b-c869-4a20-975f-4724b7092704` |
| 54 | `world_soulful_garage_pressure` | 136 | 64 | 28.233 s | -18.6 | -7.9 | 0.00442 | `be0768f954e4eed0bb3031384123add15c05355eb305ad5f9e0661d7f3e1f9ec` | `84858042-ceda-4b31-ad3b-87ea33f9a0d8` |
| 55 | `world_soulful_garage_night_shift_conductor` | 140 | 64 | 27.424 s | -18.1 | -5.1 | 0.00035 | `c63ea1e43fd57cd1bd4adb094bf81d106c3beca0071ddeac518903a41fb02ff8` | `1837fe71-1bdc-4fa4-a3ba-ae9d751bf903` |
| 56 | `world_future_funk_route` | 116 | 128 | 66.195 s | -17.9 | -5.5 | 0.00572 | `a9d66cff430eaa4cd831abacaab2fdd9be39a7be30db6da184a1a2501a70ca60` | `ab3d6161-10c2-4e30-b497-2e78f52170d5` |
| 57 | `world_future_funk_pressure` | 124 | 64 | 30.957 s | -17.8 | -7.1 | 0.00602 | `d48cb67e1ac5cca45e5ca9392a011105acdda6624a80a9241539f9288c6a8465` | `accca47b-3e86-4252-a7da-035c4820f675` |
| 58 | `world_future_funk_recompiler` | 132 | 64 | 29.093 s | -17.7 | -6.5 | 0.00203 | `a36646435df4c6df448ad19b5d660f4dc147da7d913d72778961e0ff12a5a6ce` | `d0e4867f-1e9e-4a7e-baf9-93875818ce8c` |

## Routing acceptance map

- World Tour selector and loadout use `world_tour_hub` continuously so browsing
  does not chop between worlds.
- Funk, Soul, and Disco gameplay each route to their own route cue and both of
  their own boss cues.
- House, Electro, Techno, Cosmic Boogie, Soulful Garage, and Future Funk each
  have an independent route, pressure, and finale pack ready for their planned
  runtime stages; the selector does not describe them as currently playable.
- Pause, ordinary level-up, chest reward, Options, and Controls continue and
  duck the current audible cue. Evolution, stage clear, results, cutscenes,
  Arsenal, Perk Database, and Admin retain their authored global cues.

## Live packaged-game smoke

The packaged `.love` booted in LÖVE 11.5, validated content, entered the title,
opened the World Tour selector, launched the playable Funk route, and exercised
live combat plus repeated level-up overlays without an audio load error.

- [`title-world-tour-entry.jpg`](../screenshots/world-tour-music/title-world-tour-entry.jpg)
- [`world-tour-selector.jpg`](../screenshots/world-tour-music/world-tour-selector.jpg)
- [`funk-stage-start.jpg`](../screenshots/world-tour-music/funk-stage-start.jpg)
- [`funk-live-combat.jpg`](../screenshots/world-tour-music/funk-live-combat.jpg)
- [`funk-level-up-continuity.jpg`](../screenshots/world-tour-music/funk-level-up-continuity.jpg)
