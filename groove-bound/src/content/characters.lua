-- Playable Resonants. The six displayed attributes are normalized multipliers;
-- systems consume the same values shown on character selection.

return {
  joe = {
    id              = "joe",
    name            = "Joe",
    title           = "THE BACKBEAT",
    description     = "A steady street fighter who turns pressure into power.",
    starting_weapon = "kazoo_pistol",
    intro_scene     = "joe_intro",
    trait_name      = "Hold the Line",
    trait_text      = "Starts with 18 Guard and delivers heavier knockback.",
    stats = {
      vitality = 1.15,
      power = 1.12,
      speed = 1.00,
      defense = 1.12,
      tempo = 0.94,
      resonance = 1.00,
    },
    starting_guard = 18,
    knockback_mult = 1.20,
    portrait = { col = 1, row = 1 },
  },
  lyra = {
    id              = "lyra",
    name            = "Lyra Vex",
    title           = "THE LIVE WIRE",
    description     = "A cosmic rock explorer built for speed, tempo, and risky movement.",
    starting_weapon = "keytar_chord",
    intro_scene     = "lyra_intro",
    trait_name      = "Stage Dive",
    trait_text      = "Moves and fires faster, and earns 8% more Resonance XP.",
    stats = {
      vitality = 0.94,
      power = 0.96,
      speed = 1.16,
      defense = 0.92,
      tempo = 1.12,
      resonance = 1.08,
    },
    starting_guard = 0,
    knockback_mult = 0.92,
    portrait = { col = 2, row = 1 },
  },
}
