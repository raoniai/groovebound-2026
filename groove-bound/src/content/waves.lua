-- Spawn timeline for the run. Ordered by `at` (seconds since run start).
-- Each entry starts streams of enemies: `count` spawned one per `cadence` sec,
-- then repeated until the next wave. Boss entries opt out of repetition.

return {
  { at = 1, enemies = { { id = "monotone", count = 16, cadence = 0.72 } } },
  { at = 20, enemies = {
      { id = "monotone", count = 26, cadence = 0.58 },
      { id = "tempo_leech", count = 8, cadence = 1.85 },
      { id = "syncopation_skitter", count = 10, cadence = 1.45 },
  } },
  { at = 48, enemies = {
      { id = "monotone", count = 34, cadence = 0.46 },
      { id = "tempo_leech", count = 16, cadence = 1.25 },
      { id = "feedback_phantom", count = 10, cadence = 1.75 },
      { id = "noise_turret", count = 4, cadence = 3.0 },
  } },
  { at = 72, enemies = {
      { id = "metronome_guardian", count = 1, cadence = 1.0, continuous = false },
      { id = "monotone", count = 28, cadence = 0.42 },
      { id = "syncopation_skitter", count = 8, cadence = 1.25 },
      { id = "noise_turret", count = 4, cadence = 2.8 },
  } },
  { at = 90, enemies = {
      { id = "monotone", count = 45, cadence = 0.34 },
      { id = "tempo_leech", count = 24, cadence = 0.92 },
      { id = "syncopation_skitter", count = 22, cadence = 0.82 },
      { id = "noise_turret", count = 10, cadence = 1.8 },
  } },
  { at = 120, enemies = {
      { id = "monotone", count = 54, cadence = 0.28 },
      { id = "tempo_leech", count = 30, cadence = 0.78 },
      { id = "feedback_phantom", count = 18, cadence = 1.05 },
      { id = "bass_brute", count = 12, cadence = 1.9 },
      { id = "noise_turret", count = 12, cadence = 1.55 },
  } },
  { at = 145, enemies = {
      { id = "static_baron", count = 1, cadence = 1.0, continuous = false },
      { id = "tempo_leech", count = 20, cadence = 0.85 },
      { id = "bass_brute", count = 12, cadence = 1.65 },
      { id = "noise_turret", count = 14, cadence = 1.25 },
      { id = "feedback_phantom", count = 24, cadence = 0.95 },
  } },
}
