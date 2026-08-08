-- Spawn timeline for the run. Ordered by `at` (seconds since run start).
-- Each entry starts streams of enemies: `count` spawned one per `cadence` sec,
-- then repeated until the next wave. Boss entries opt out of repetition.

return {
  { at = 1, enemies = { { id = "monotone", count = 8, cadence = 1.2 } } },
  { at = 20, enemies = {
      { id = "monotone", count = 14, cadence = 0.9 },
      { id = "tempo_leech", count = 4, cadence = 3.0 },
      { id = "syncopation_skitter", count = 4, cadence = 2.4 },
  } },
  { at = 48, enemies = {
      { id = "monotone", count = 18, cadence = 0.75 },
      { id = "tempo_leech", count = 8, cadence = 2.2 },
      { id = "feedback_phantom", count = 3, cadence = 3.0 },
  } },
  { at = 72, enemies = {
      { id = "metronome_guardian", count = 1, cadence = 1.0, continuous = false },
      { id = "monotone", count = 14, cadence = 0.7 },
  } },
  { at = 90, enemies = {
      { id = "monotone", count = 24, cadence = 0.55 },
      { id = "tempo_leech", count = 12, cadence = 1.6 },
      { id = "syncopation_skitter", count = 10, cadence = 1.4 },
      { id = "noise_turret", count = 4, cadence = 3.2 },
  } },
  { at = 120, enemies = {
      { id = "monotone", count = 30, cadence = 0.45 },
      { id = "tempo_leech", count = 16, cadence = 1.3 },
      { id = "feedback_phantom", count = 8, cadence = 1.8 },
      { id = "bass_brute", count = 5, cadence = 3.0 },
  } },
  { at = 145, enemies = {
      { id = "static_baron", count = 1, cadence = 1.0, continuous = false },
      { id = "tempo_leech", count = 10, cadence = 1.5 },
      { id = "bass_brute", count = 4, cadence = 2.8 },
      { id = "noise_turret", count = 5, cadence = 2.2 },
  } },
}
