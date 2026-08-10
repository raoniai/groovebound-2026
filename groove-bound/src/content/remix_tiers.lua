-- Remix tiers never replace Standard and do not alter first-clear access.

return {
  standard = {
    id = "standard", order = 0, name = "Standard",
    unlock_grade = nil, enemy_health = 1, enemy_speed = 1,
    enemy_damage = 1, spawn_rate = 1, reward_band = 1,
  },
  remix_i = {
    id = "remix_i", order = 1, name = "Remix I",
    unlock_grade = "B", enemy_health = 1.12, enemy_speed = 1.06,
    enemy_damage = 1.08, spawn_rate = 1.10, reward_band = 1.15,
  },
  remix_ii = {
    id = "remix_ii", order = 2, name = "Remix II",
    unlock_grade = "S", enemy_health = 1.25, enemy_speed = 1.10,
    enemy_damage = 1.15, spawn_rate = 1.18, reward_band = 1.35,
  },
}
