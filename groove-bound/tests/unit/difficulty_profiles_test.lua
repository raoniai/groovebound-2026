local H = require("tests.helpers")
local DifficultyProfiles = require("src.config.difficulty_profiles")

local T = {}

local multiplier_keys = {
  "wave_pressure", "enemy_health", "enemy_damage", "enemy_speed",
  "enemy_amount", "enemy_attack_interval", "player_damage", "boss_health",
  "boss_attack_damage", "boss_speed", "boss_attack_interval",
  "boss_projectile_speed",
}

T["difficulty menu exposes five ordered complete multiplier profiles"] = function()
  H.eq(#DifficultyProfiles.order, 5)
  H.eq(DifficultyProfiles.label("very_easy"), "VERY EASY")
  H.eq(DifficultyProfiles.label("easy"), "EASY")
  H.eq(DifficultyProfiles.label("medium"), "MEDIUM")
  H.eq(DifficultyProfiles.label("hard"), "HARD")
  H.eq(DifficultyProfiles.label("super_hard"), "SUPER HARD")
  for _, id in ipairs(DifficultyProfiles.order) do
    local profile = DifficultyProfiles.get(id)
    for _, key in ipairs(multiplier_keys) do
      H.is_true(type(profile[key]) == "number" and profile[key] > 0,
        id .. " requires " .. key)
    end
  end
end

T["Medium is the authored baseline and invalid values safely resolve to it"] = function()
  local medium = DifficultyProfiles.get("medium")
  for _, key in ipairs(multiplier_keys) do H.eq(medium[key], 1) end
  H.eq(DifficultyProfiles.resolve("unknown"), "medium")
  H.eq(DifficultyProfiles.resolve(nil), "medium")
end

T["difficulty stepping is bounded at both ends"] = function()
  H.eq(DifficultyProfiles.step("very_easy", -1), "very_easy")
  H.eq(DifficultyProfiles.step("medium", -1), "easy")
  H.eq(DifficultyProfiles.step("medium", 1), "hard")
  H.eq(DifficultyProfiles.step("super_hard", 1), "super_hard")
end

T["higher tiers raise pressure while reducing player damage"] = function()
  local easy = DifficultyProfiles.get("very_easy")
  local hard = DifficultyProfiles.get("super_hard")
  H.is_true(hard.wave_pressure > easy.wave_pressure)
  H.is_true(hard.enemy_health > easy.enemy_health)
  H.is_true(hard.enemy_damage > easy.enemy_damage)
  H.is_true(hard.enemy_speed > easy.enemy_speed)
  H.is_true(hard.enemy_amount > easy.enemy_amount)
  H.is_true(hard.boss_health > easy.boss_health)
  H.is_true(hard.boss_attack_damage > easy.boss_attack_damage)
  H.is_true(hard.boss_projectile_speed > easy.boss_projectile_speed)
  H.is_true(hard.boss_attack_interval < easy.boss_attack_interval)
  H.is_true(hard.player_damage < easy.player_damage)
end

return T
