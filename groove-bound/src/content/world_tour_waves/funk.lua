-- Catalog-ready Funk pacing authored against a ten-minute run.
return {
  { at = 1, enemies = { { id = "monotone", count = 24, cadence = 0.65 } } },
  { at = 120, enemies = {
    { id = "tempo_leech", count = 18, cadence = 1.25 },
    { id = "syncopation_skitter", count = 24, cadence = 0.90 },
  } },
  { at = 240, enemies = {
    { id = "bass_brute", count = 14, cadence = 1.80 },
    { id = "noise_turret", count = 6, cadence = 4.0 },
  } },
  { at = 360, enemies = {
    { id = "feedback_phantom", count = 28, cadence = 0.88 },
    { id = "bass_brute", count = 20, cadence = 1.45 },
  } },
  { at = 540, enemies = {
    { id = "static_baron", count = 1, cadence = 1, continuous = false },
    { id = "syncopation_skitter", count = 34, cadence = 0.62 },
  } },
}
