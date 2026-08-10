-- Golden Afterparty pressure. The Mothership arrives with a dense supporting
-- ensemble; existing boss-pressure scaling keeps that crowd accelerating.
return {
  { at = 1, enemies = {
    { id = "pocket_phantom", count = 22, cadence = 0.72 },
    { id = "funkadelic_wasp", count = 24, cadence = 0.64 },
  } },
  { at = 90, enemies = {
    { id = "slapback_hound", count = 28, cadence = 0.76 },
    { id = "talkbox_oracle", count = 10, cadence = 2.8 },
  } },
  { at = 180, enemies = {
    { id = "groove_guard", count = 24, cadence = 1.20 },
    { id = "pocket_gremlin", count = 42, cadence = 0.46 },
  } },
  { at = 300, enemies = {
    { id = "pocket_phantom", count = 32, cadence = 0.62 },
    { id = "funkadelic_wasp", count = 40, cadence = 0.48 },
    { id = "talkbox_oracle", count = 12, cadence = 2.45 },
  } },
  { at = 420, enemies = {
    { id = "groove_guard", count = 30, cadence = 1.0 },
    { id = "slapback_hound", count = 36, cadence = 0.62 },
    { id = "pocket_phantom", count = 30, cadence = 0.56 },
  } },
  { at = 540, enemies = {
    { id = "mothership_of_funk", count = 1, cadence = 1, continuous = false },
    { id = "pocket_gremlin", count = 52, cadence = 0.38 },
    { id = "funkadelic_wasp", count = 48, cadence = 0.40 },
    { id = "groove_guard", count = 32, cadence = 0.88 },
  } },
}
