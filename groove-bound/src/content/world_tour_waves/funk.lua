-- Pocket District pacing authored against a ten-minute reference timeline.
return {
  { at = 1, enemies = {
    { id = "pocket_gremlin", count = 28, cadence = 0.58 },
  } },
  { at = 120, enemies = {
    { id = "slapback_hound", count = 20, cadence = 1.05 },
    { id = "funkadelic_wasp", count = 28, cadence = 0.72 },
  } },
  { at = 240, enemies = {
    { id = "groove_guard", count = 18, cadence = 1.55 },
    { id = "talkbox_oracle", count = 8, cadence = 3.35 },
  } },
  { at = 360, enemies = {
    { id = "pocket_gremlin", count = 38, cadence = 0.52 },
    { id = "slapback_hound", count = 24, cadence = 0.82 },
    { id = "groove_guard", count = 18, cadence = 1.25 },
  } },
  { at = 540, enemies = {
    { id = "boogie_tank", count = 1, cadence = 1, continuous = false },
    { id = "funkadelic_wasp", count = 42, cadence = 0.48 },
    { id = "pocket_gremlin", count = 36, cadence = 0.50 },
  } },
}
