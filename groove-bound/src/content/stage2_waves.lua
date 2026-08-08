-- Orbit Line wave timeline. Times are authored against the stage's
-- `wave_base_duration` and scaled when Admin changes the playable duration.

return {
  { at = 1, enemies = {
      { id = "vinyl_drone", count = 22, cadence = 0.72 },
  } },
  { at = 70, enemies = {
      { id = "vinyl_drone", count = 34, cadence = 0.52 },
      { id = "trumpet_ray", count = 14, cadence = 1.55 },
  } },
  { at = 140, enemies = {
      { id = "drum_wheel", count = 20, cadence = 1.12 },
      { id = "theremin_jelly", count = 14, cadence = 1.45 },
      { id = "vinyl_drone", count = 38, cadence = 0.44 },
      { id = "trumpet_ray", count = 8, cadence = 1.7 },
  } },
  { at = 225, enemies = {
      { id = "amp_hound", count = 14, cadence = 1.9 },
      { id = "trumpet_ray", count = 18, cadence = 1.15 },
      { id = "drum_wheel", count = 22, cadence = 0.95 },
  } },
  { at = 315, enemies = {
      { id = "keyboard_centipede", count = 12, cadence = 2.0 },
      { id = "theremin_jelly", count = 20, cadence = 1.1 },
      { id = "vinyl_drone", count = 44, cadence = 0.36 },
      { id = "trumpet_ray", count = 12, cadence = 1.2 },
  } },
  { at = 405, enemies = {
      { id = "turntable_sentinel", count = 1, cadence = 1.0, continuous = false },
      { id = "amp_hound", count = 16, cadence = 1.55 },
      { id = "trumpet_ray", count = 24, cadence = 0.95 },
      { id = "keyboard_centipede", count = 10, cadence = 1.85 },
  } },
  { at = 480, enemies = {
      { id = "keyboard_centipede", count = 18, cadence = 1.35 },
      { id = "drum_wheel", count = 32, cadence = 0.72 },
      { id = "theremin_jelly", count = 26, cadence = 0.88 },
      { id = "trumpet_ray", count = 18, cadence = 0.9 },
  } },
  { at = 545, enemies = {
      { id = "amp_hound", count = 22, cadence = 1.18 },
      { id = "keyboard_centipede", count = 20, cadence = 1.15 },
      { id = "vinyl_drone", count = 55, cadence = 0.30 },
      { id = "trumpet_ray", count = 22, cadence = 0.78 },
  } },
  { at = 580, enemies = {
      { id = "grand_orchestrator", count = 1, cadence = 1.0, continuous = false },
      { id = "trumpet_ray", count = 24, cadence = 0.82 },
      { id = "drum_wheel", count = 24, cadence = 0.76 },
      { id = "keyboard_centipede", count = 18, cadence = 1.1 },
  } },
}
