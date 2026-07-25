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
  },

  encore = {
    id          = "encore",
    name        = "Encore",
    description = "Increase maximum health.",
    stat        = "max_hp",
    max_level   = 5,
    per_level   = 0.15,
  },

  breath_control = {
    id          = "breath_control",
    name        = "Breath Control",
    description = "Stabilise cooldowns and projectile accuracy.",
    stat        = "cooldown_stability",
    max_level   = 5,
    per_level   = 0.08,
  },
}
