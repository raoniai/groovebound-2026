-- Orbit Line wave timeline. Times are authored against the stage's
-- `wave_base_duration` and scaled when Admin changes the playable duration.

return {
  { at = 1, enemies = {
      { id = "vinyl_drone", count = 12, cadence = 1.15 },
  } },
  { at = 70, enemies = {
      { id = "vinyl_drone", count = 18, cadence = 0.82 },
      { id = "trumpet_ray", count = 6, cadence = 2.8 },
  } },
  { at = 140, enemies = {
      { id = "drum_wheel", count = 10, cadence = 1.9 },
      { id = "theremin_jelly", count = 7, cadence = 2.4 },
      { id = "vinyl_drone", count = 20, cadence = 0.72 },
  } },
  { at = 225, enemies = {
      { id = "amp_hound", count = 7, cadence = 3.2 },
      { id = "trumpet_ray", count = 10, cadence = 2.0 },
      { id = "drum_wheel", count = 12, cadence = 1.6 },
  } },
  { at = 315, enemies = {
      { id = "keyboard_centipede", count = 6, cadence = 3.4 },
      { id = "theremin_jelly", count = 12, cadence = 1.9 },
      { id = "vinyl_drone", count = 28, cadence = 0.58 },
  } },
  { at = 405, enemies = {
      { id = "turntable_sentinel", count = 1, cadence = 1.0 },
      { id = "amp_hound", count = 8, cadence = 2.6 },
      { id = "trumpet_ray", count = 12, cadence = 1.7 },
  } },
  { at = 480, enemies = {
      { id = "keyboard_centipede", count = 10, cadence = 2.4 },
      { id = "drum_wheel", count = 18, cadence = 1.15 },
      { id = "theremin_jelly", count = 14, cadence = 1.5 },
  } },
  { at = 545, enemies = {
      { id = "amp_hound", count = 12, cadence = 2.0 },
      { id = "keyboard_centipede", count = 12, cadence = 2.0 },
      { id = "vinyl_drone", count = 34, cadence = 0.48 },
  } },
  { at = 580, enemies = {
      { id = "grand_orchestrator", count = 1, cadence = 1.0 },
      { id = "trumpet_ray", count = 12, cadence = 1.4 },
      { id = "drum_wheel", count = 12, cadence = 1.3 },
  } },
}
