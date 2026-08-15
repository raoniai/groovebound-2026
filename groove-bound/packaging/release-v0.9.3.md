## Groove Bound v0.9.3

This release gives every enemy an authored movement loop while preserving the
existing combat, balance, collision, and deterministic simulation.

- Animates all 49 enemy definitions across Backbeat, Orbit, Funk, Soul,
  Disco, and Jazz, covering 48 unique established visuals.
- Adds three-frame loops for Backbeat through Disco and four-frame loops for
  every Jazz enemy.
- Matches motion to each silhouette, including walking, hovering, wingbeats,
  planted pulses, recoil, heavy marching, and mechanical leg cycles.
- Uses deterministic per-enemy visual phase offsets without consuming gameplay
  RNG or changing enemy mechanics.
- Preserves left-facing sprite flips, tint/flash/windup rendering, pooling,
  static-enemy positions, and the existing static-sprite fallback.
- Ships only six optimized runtime atlases; prompts, build sources, manifests,
  individual frames, and review GIFs remain package-excluded.
