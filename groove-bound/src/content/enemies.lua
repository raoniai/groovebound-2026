-- Enemy definitions. All rhythmless creatures, no real-world references.

return {
  monotone = {
    id     = "monotone",
    name   = "Monotone",
    hp     = 20,
    speed  = 60,
    size   = 12,
    damage = 10,
    xp     = 10,
    coins  = 1,
    brain  = "chase",
    color  = { 0.85, 0.25, 0.25, 1 },
  },

  tempo_leech = {
    id     = "tempo_leech",
    name   = "Tempo Leech",
    hp     = 45,
    speed  = 95,
    size   = 18,
    damage = 15,
    xp     = 20,
    coins  = 2,
    brain  = "zigzag",
    color  = { 0.95, 0.55, 0.2, 1 },
  },

  metronome_guardian = {
    id = "metronome_guardian",
    name = "Metronome Guardian",
    hp = 900,
    speed = 72,
    size = 30,
    damage = 22,
    xp = 140,
    coins = 75,
    brain = "charger",
    boss_type = "miniboss",
    color = { 0.72, 0.35, 1.0, 1 },
  },

  static_baron = {
    id = "static_baron",
    name = "Static Baron",
    hp = 3200,
    speed = 0,
    size = 46,
    damage = 18,
    xp = 500,
    coins = 250,
    brain = "static",
    boss_type = "final",
    attack_interval = 1.4,
    attack_range = 520,
    color = { 1.0, 0.18, 0.62, 1 },
  },
}
