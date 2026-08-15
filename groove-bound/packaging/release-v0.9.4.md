## Groove Bound v0.9.4

This release replaces the single enemy movement loop with an individual,
state-aware animation set for every enemy while preserving combat behavior,
balance, collision, rewards, and deterministic simulation.

- Ships 170 individual RGBA sprite strips and 600 authored frames across all
  49 enemy identities.
- Gives every enemy a three- or four-frame walk, hit reaction, and four-frame
  death sequence.
- Gives all 23 projectile enemies a four-frame weapon-specific attack sequence
  synchronized to their existing wind-up and recovery.
- Replaces the former Breakbeat Bruiser visual alias with a distinct
  orange-and-black drum-machine brawler and complete four-state animation set.
- Keeps animation clocks visual-only so no state transition consumes gameplay
  RNG or changes attack timing.
- Preserves the previous movement-atlas fallback while excluding prompts,
  source boards, extracted authoring frames, and review sheets from packages.
