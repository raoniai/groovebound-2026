#!/usr/bin/env bash

set -euo pipefail

PYTHONPATH="${PYTHONPATH:-/tmp/groove_music_tools}"
export PYTHONPATH

build() {
  local number="$1"
  local bpm="$2"
  local source="$3"
  local output="$4"
  local beats="${5:-32}"

  echo "Building cue ${number}: ${output}"
  python3 scripts/audio/build_loop.py \
    --bpm "$bpm" \
    --beats "$beats" \
    "assets/generated/source-candidates/music/${source}" \
    "assets/music/${output}"
}

build 04 116 04-prologue-resolve-heroic-breakbeat-signal-alternate.mp3 04_prologue_resolve.ogg
build 05 120 05-character-selection-arcade-funk-showroom.mp3 05_character_select.ogg
build 06 98 06-joe-intro-heavy-street-funk.mp3 06_joe_intro.ogg
build 07 142 07-lyra-intro-electro-rock-keytar.mp3 07_lyra_intro.ogg
build 08 124 08-stage1-opening-urban-supernatural-funk.mp3 08_stage1_opening.ogg
build 09 138 09-stage1-pressure-breakbeat-escalation.mp3 09_stage1_pressure.ogg
build 10 136 10-metronome-guardian-clockwork-techno-duel.mp3 10_metronome_guardian.ogg
build 11 174 11-stage1-overload-drum-and-bass-street-siege.mp3 11_stage1_overload.ogg
build 12 110 12-static-baron-glitch-hop-broadcast-tyrant.mp3 12_static_baron.ogg
build 13 88 13-first-press-map-pretending-to-be-music.mp3 13_first_press.ogg
build 14 90 14-dead-line-recovery-ambient-beat-recovery.mp3 14_dead_line_recovery.ogg
build 15 126 15-orbit-line-arrival-cosmic-disco-pursuit.mp3 15_stage2_arrival.ogg
build 16 172 16-orbit-line-escalation-liquid-dnb-constellation.mp3 16_stage2_escalation.ogg
build 17 116 17-turntable-sentinel-turntablism-glitch-hop-duel.mp3 17_turntable_sentinel.ogg
build 18 176 18-orbit-line-overload-neurofunk-arcade-rush.mp3 18_stage2_overload.ogg
build 19 132 19-grand-orchestrator-phase1-mechanical-symphonic-electro.mp3 19_grand_orchestrator_p1.ogg
build 20 176 20-grand-orchestrator-final-full-city-backing-band.mp3 20_grand_orchestrator_final.ogg
build 21 120 21-level-up-resonance-reward-loop.mp3 21_level_up.ogg
build 22 140 22-weapon-evolution-resonance-transformation.mp3 22_evolution.ogg
build 23 132 23-low-health-pulse-tower-warning-stem.mp3 23_low_health.ogg
build 24 92 24-pause-filtered-city-groove.mp3 24_pause.ogg
build 25 114 25-arsenal-database-synth-funk-workshop.mp3 25_arsenal.ogg
build 26 120 26-admin-debug-diagnostic-minimal-techno.mp3 26_admin.ogg
build 27 124 27-stage-clear-street-victory-sting-loop.mp3 27_stage_clear.ogg
build 27-sting 124 27-stage-clear-street-victory-sting-loop.mp3 stage_clear_sting.ogg 8
build 28 118 28-victory-results-backbeat-survives.mp3 28_victory_results.ogg
build 29 84 29-defeat-results-broken-groove-ready-to-retry.mp3 29_defeat_results.ogg
build 30 96 30-ending-teaser-orchestra-still-assembling.mp3 30_ending_teaser.ogg
