-- Passive upgrade definitions. `stat` maps into the StatSheet buckets;
-- `per_level` is the additive bonus per level (0.10 = +10%).

return {
  quickstep = {
    id          = "quickstep",
    name        = "Quickstep",
    description = "Move faster.",
    stat        = "speed",
    max_level   = 5,
    per_level   = 0.10,
    icon        = { col = 1, row = 1 },
  },

  encore = {
    id          = "encore",
    name        = "Encore",
    description = "Increase maximum health.",
    stat        = "max_hp",
    max_level   = 5,
    per_level   = 0.15,
    icon        = { col = 2, row = 1 },
  },

  breath_control = {
    id          = "breath_control",
    name        = "Breath Control",
    description = "Shorten cooldowns and tighten projectile spread.",
    stat        = "cooldown_stability",
    max_level   = 5,
    per_level   = 0.08,
    icon        = { col = 3, row = 1 },
  },

  power_amplifier = {
    id = "power_amplifier",
    name = "Power Amplifier",
    description = "Increase all weapon damage.",
    stat = "damage",
    max_level = 5,
    per_level = 0.12,
    icon = { col = 4, row = 1 },
  },

  pickup_magnet = {
    id = "pickup_magnet",
    name = "Pickup Magnet",
    description = "Increase gem attraction range.",
    stat = "magnet",
    max_level = 5,
    per_level = 0.20,
    icon = { col = 1, row = 2 },
  },

  overdrive_pedal = {
    id = "overdrive_pedal",
    name = "Overdrive Pedal",
    description = "Increase weapon activation speed.",
    stat = "fire_rate",
    max_level = 5,
    per_level = 0.09,
    icon = { col = 2, row = 2 },
  },

  echo_chamber = {
    id = "echo_chamber",
    name = "Echo Chamber",
    description = "Add another projectile to every activation.",
    stat = "amount",
    max_level = 3,
    per_level = 1,
    icon = { col = 3, row = 2 },
  },

  safety_vest = {
    id = "safety_vest",
    name = "Safety Vest",
    description = "Gain a reserve of temporary guard.",
    stat = "guard",
    max_level = 5,
    per_level = 12,
    icon = { col = 4, row = 2 },
  },
}
