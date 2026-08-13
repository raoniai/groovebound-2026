#!/usr/bin/env bash

set -euo pipefail

PYTHONPATH="/tmp/groove_music_tools${PYTHONPATH:+:${PYTHONPATH}}"
export PYTHONPATH

build() {
  local number="$1"
  local bpm="$2"
  local source="$3"
  local output="$4"
  local beats="$5"
  local target_lufs="${6:--18}"

  if [[ -n "${START_CUE:-}" ]] && ((10#${number} < 10#${START_CUE})); then
    return
  fi

  echo "Building World Tour cue ${number}: ${output}"
  python3 scripts/audio/build_loop.py \
    --bpm "$bpm" \
    --beats "$beats" \
    --target-lufs "$target_lufs" \
    "assets/generated/source-candidates/music/world-tour-v1/${source}" \
    "assets/music/${output}"
}

build 31 110 31-world-tour-hub-passport-to-the-pocket.mp3 31_world_tour_hub.ogg 128
build 32 112 32-world-funk-route-hold-the-pocket.mp3 32_world_funk_route.ogg 128
build 33 118 33-world-funk-boss-boogie-tank-lockdown.mp3 33_world_funk_boogie_tank.ogg 32
build 34 124 34-world-funk-finale-board-the-mothership.mp3 34_world_funk_mothership.ogg 64
build 35 92 35-world-soul-route-velvet-resonance.mp3 35_world_soul_route.ogg 128
build 36 100 36-world-soul-boss-organ-colossus.mp3 36_world_soul_organ_colossus.ogg 64
build 37 108 37-world-soul-finale-velvet-titan-rising.mp3 37_world_soul_velvet_titan.ogg 64
build 38 122 38-world-disco-route-mirrorball-metro.mp3 38_world_disco_route.ogg 128
build 39 128 39-world-disco-boss-laser-conductor.mp3 39_world_disco_laser_conductor.ogg 64
build 40 132 40-world-disco-finale-prism-monarch.mp3 40_world_disco_prism_monarch.ogg 64
build 41 124 41-world-house-route-warehouse-909.mp3 41_world_house_route.ogg 128
build 42 128 42-world-house-pressure-floor-cycle-overdrive.mp3 42_world_house_pressure.ogg 64
build 43 130 43-world-house-finale-kickdrum-constructor.mp3 43_world_house_kickdrum_constructor.ogg 64
build 44 118 44-world-electro-route-neon-circuit.mp3 44_world_electro_route.ogg 128
build 45 126 45-world-electro-pressure-node-chain-surge.mp3 45_world_electro_pressure.ogg 64
build 46 132 46-world-electro-finale-voltage-vandal.mp3 46_world_electro_voltage_vandal.ogg 64
build 47 132 47-world-techno-route-the-iron-loop.mp3 47_world_techno_route.ogg 128
build 48 138 48-world-techno-pressure-memory-loop-breach.mp3 48_world_techno_pressure.ogg 64
build 49 144 49-world-techno-finale-loop-architect.mp3 49_world_techno_loop_architect.ogg 64
build 50 116 50-world-cosmic-boogie-route-orbital-dance-deck.mp3 50_world_cosmic_boogie_route.ogg 128
build 51 124 51-world-cosmic-boogie-pressure-zero-g-pocket.mp3 51_world_cosmic_boogie_pressure.ogg 64
build 52 130 52-world-cosmic-boogie-finale-celestial-selector.mp3 52_world_cosmic_boogie_celestial_selector.ogg 64
build 53 132 53-world-soulful-garage-route-midnight-garage.mp3 53_world_soulful_garage_route.ogg 128
build 54 136 54-world-soulful-garage-pressure-resonance-gate.mp3 54_world_soulful_garage_pressure.ogg 64
build 55 140 55-world-soulful-garage-finale-night-shift-conductor.mp3 55_world_soulful_garage_night_shift_conductor.ogg 64 -19.5
build 56 116 56-world-future-funk-route-tomorrow-mall.mp3 56_world_future_funk_route.ogg 128
build 57 124 57-world-future-funk-pressure-sample-memory-corrupt.mp3 57_world_future_funk_pressure.ogg 64
build 58 132 58-world-future-funk-finale-the-recompiler.mp3 58_world_future_funk_recompiler.ogg 64
