# Groove Bound Music QA Log

## 2026-08-08 — Runtime soundtrack implementation

- **Source decision:** The user approved continuing with the saved Suno takes and
  explicitly waived the unavailable 48 kHz, 24-bit WAV-master requirement. The
  original Suno MP3 downloads remain source candidates and are excluded from the
  release package.
- **Selection:** Saved first takes were used except Cue 04. Its first take failed
  the safe tempo-correction gate, so the already-generated second take
  (Suno ID d512e59c-13ed-42b4-95d2-bbb640eff936) was used and passed.
- **Processing:** Each looping cue was cut on a detected beat grid, corrected to
  its declared BPM within the safe 0.80–1.25 ratio, normalized near -18 LUFS,
  exported as 48 kHz stereo OGG Vorbis, and checked at the decoded loop seam.
- **Derivative:** stage_clear_sting.ogg is an approved 8-beat derivative of
  Cue 27. The full 32-beat Cue 27 loop remains archived in runtime assets.
- **Low-health safety:** Cue 23 is rhythmic at 132 BPM, so routing restricts it to
  the tempo-matched Grand Orchestrator phase-one cue and seeks it to the current
  playback phase. It does not layer over incompatible stage or boss tempos.
- **Automated status:** All 31 promoted files passed codec, 48 kHz
  stereo, decoded duration, loudness, true-peak, audible-edge, and seam checks.
- **Manual status:** Creative listening, vocal-texture review, three-loop runtime
  listening, dialogue/SFX masking checks, and full campaign playthrough remain
  **not manually verified**.

| Cue | Runtime file | Beats | Duration | LUFS | Peak dBFS | Seam jump | SHA-256 | Result |
|---:|---|---:|---:|---:|---:|---:|---|---|
| 01 | 01_title.ogg | 32 | 17.153 s | -17.9 | -6.4 | 0.00213 | 0bffaeab53cc300b20be8bd6a45033fde23a5de87f251489b756169453402864 | Passed |
| 02 | 02_prologue_city.ogg | 32 | 20.884 s | -17.7 | -6.2 | 0.00012 | 9c83c23aad976f7957e9b0a23ae062cf4bc47db634b3cfffa6d915fc5a616122 | Passed |
| 03 | 03_prologue_break.ogg | 32 | 19.200 s | -18.5 | -9.1 | 0.00296 | 2922e5eb384f4efe4c16c5e6c2b576dc49a732ea97f4e0e0ef8dd9a18b860e22 | Passed |
| 04 | 04_prologue_resolve.ogg | 32 | 16.543 s | -17.8 | -7.5 | 0.00761 | e4f38ccef7452f2f5bf769e569eeaffac5aad86c4df610195035e2db5f2c0c46 | Passed |
| 05 | 05_character_select.ogg | 32 | 15.996 s | -17.9 | -6.6 | 0.00361 | 3dbbc6e0873988280af9da45784f318394238dc4d6a96a2a8305752f5bbf9cb9 | Passed |
| 06 | 06_joe_intro.ogg | 32 | 19.600 s | -17.5 | -5.9 | 0.00209 | 6724db0ed8daf129821a8a52b2da3f3e76f0d9b2a385d7b27d442b0c64abe5c5 | Passed |
| 07 | 07_lyra_intro.ogg | 32 | 13.515 s | -17.6 | -7.1 | 0.00578 | b40e9ae279b9d13d17ebf65b6e78d2923d2a82af671edf9567d35eeaa56b2588 | Passed |
| 08 | 08_stage1_opening.ogg | 32 | 15.473 s | -17.9 | -7.9 | 0.00519 | d5ec557554ebc35b4af5946adf0af50f58c90ab9e73a74166cc016a7b71cbae2 | Passed |
| 09 | 09_stage1_pressure.ogg | 32 | 13.907 s | -17.6 | -7.0 | 0.00556 | 41aced126d310fcda5afde226b99eb355a4ac37e61a3ffd75deff6a42a13cc64 | Passed |
| 10 | 10_metronome_guardian.ogg | 32 | 14.125 s | -17.9 | -9.1 | 0.00310 | 65ffe7afe59deb41043443e96bc9b85ef87e9afbc7b1fe70e975341e2888eabe | Passed |
| 11 | 11_stage1_overload.ogg | 32 | 11.021 s | -17.9 | -6.9 | 0.00297 | 6f4acdbb6fe5acae80c141828035307e6b43d20aaedba31b852b7bf5ca4f5db5 | Passed |
| 12 | 12_static_baron.ogg | 32 | 17.463 s | -17.5 | -7.7 | 0.00316 | 46183a925488df2d6a78a491d637eb33d013891aa1b9a003c3c7799d3e7e78cd | Passed |
| 13 | 13_first_press.ogg | 32 | 21.809 s | -17.8 | -6.0 | 0.00349 | b1bb54626cc06fcdc8594e39b65eda2c4f04a08de958b27b5c10f637a669e5ea | Passed |
| 14 | 14_dead_line_recovery.ogg | 32 | 21.325 s | -17.8 | -7.9 | 0.00211 | 36bcd32e21acaa45366a4d29e74104b9361bd285b2bc8ea65ddb8055e26bd9fe | Passed |
| 15 | 15_stage2_arrival.ogg | 32 | 15.232 s | -17.8 | -8.2 | 0.00336 | e63c6e677d49c7cfe24a78b09585f12b69a314ee70c5f0e17181ab59c911c561 | Passed |
| 16 | 16_stage2_escalation.ogg | 32 | 11.152 s | -17.9 | -8.6 | 0.00612 | acd1423443581d8230d34540c4a851c3e0a08c6d8ccf0727450b038c0c1843fe | Passed |
| 17 | 17_turntable_sentinel.ogg | 32 | 16.561 s | -17.6 | -6.9 | 0.00204 | 3befbcc187aedc16924c8b9c1400df0bf7c1f695ff31809248aecd51a51908f6 | Passed |
| 18 | 18_stage2_overload.ogg | 32 | 10.911 s | -17.7 | -5.8 | 0.00821 | daaf5ede6bf6522c278db96f69c602d02aff74fc726bca4d170583bce29275f1 | Passed |
| 19 | 19_grand_orchestrator_p1.ogg | 32 | 14.535 s | -17.9 | -8.1 | 0.00193 | 005c4412915034b444aaebce46e02870fba0103f56d9e7ab2ed27c2bfb18644c | Passed |
| 20 | 20_grand_orchestrator_final.ogg | 32 | 10.901 s | -18.0 | -8.4 | 0.00599 | 673c2b5830bfbe6906bae8004d66a80bc1e0c4212db24023c714f7e2d7fea57d | Passed |
| 21 | 21_level_up.ogg | 32 | 15.987 s | -17.5 | -4.8 | 0.00338 | a9950a9fa16eedd92e7ef9bcc581b5e5560bc99c3aff8d0ca5801c9113190c10 | Passed |
| 22 | 22_evolution.ogg | 32 | 13.699 s | -17.8 | -8.0 | 0.00209 | 89f0be62c3462543669ae0fd76362c988093e2a61464f6be63e8711aaf80838e | Passed |
| 23 | 23_low_health.ogg | 32 | 14.535 s | -18.5 | -6.8 | 0.02635 | 4bdce4a8a7845173e9b6f44b7985f2454244e0b0c0afd75b8e900d0b40e3fc0c | Passed |
| 24 | 24_pause.ogg | 32 | 20.871 s | -17.9 | -5.1 | 0.01090 | f074c7d3966a40995d5e4344e0f32926d49e4979ca6028e58d86343a1dfdfcb6 | Passed |
| 25 | 25_arsenal.ogg | 32 | 16.845 s | -17.7 | -6.6 | 0.00187 | 60c746b0a2fb80a26880337876190ab7c05098b5d6086befe4cd1db38aa7c86a | Passed |
| 26 | 26_admin.ogg | 32 | 15.991 s | -17.9 | -7.9 | 0.00424 | 6721081f771f47978489697862825f9eb296332fa1971c5171ebfd8b31ae4f3c | Passed |
| 27 | 27_stage_clear.ogg | 32 | 15.481 s | -18.9 | -4.2 | 0.00281 | abf3e4278f8aa8a91af75465b741384d03628e7cc4723a9a4985a9c39d86010e | Passed |
| 27-sting | stage_clear_sting.ogg | 8 | 3.861 s | -17.7 | -1.8 | 0.00250 | ff9bade0ccc4e2bf938449ac3149ffbbeb6556beba7f7d98947a5175912160f1 | Passed |
| 28 | 28_victory_results.ogg | 32 | 16.263 s | -17.8 | -7.1 | 0.00798 | dc3b83d1afce90b12a713243988ab38a12a846ab8ad7a421eef1ff4e6286f9e6 | Passed |
| 29 | 29_defeat_results.ogg | 32 | 22.844 s | -17.5 | -6.2 | 0.00804 | 7c33d1b9e23ecc948216257830c4605240573fbbe90c95bf7a1ee2a6499dd714 | Passed |
| 30 | 30_ending_teaser.ogg | 32 | 20.009 s | -18.0 | -7.6 | 0.00032 | 2706bd2447bccc11dc45d7aa3fc148c23bb2c8958cbbff68218027435aed7f98 | Passed |

Re-run the independent audit with:

PYTHONPATH=/tmp/groove_music_tools:scripts/audio python3 scripts/audio/audit_music.py

## Implementation verification

- **Automated tests:** 222 passed, 0 failed.
- **Lint:** 0 warnings, 0 errors across 106 Lua files.
- **Boot smoke:** LÖVE reached content validation, Title entry, and Boot complete.
- **Package:** `dist/groove-bound.love` contains all 31 runtime OGG files.
- **Package exclusions:** no Suno MP3/WAV candidates, `source-candidates/`, root
  `music/`, or audio build scripts are present in the archive.
- **Delivery state:** **Packaged** and **locally integrated**; not committed,
  pushed, merged, manually listened, or campaign-playthrough verified.
