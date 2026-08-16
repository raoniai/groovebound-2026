-- Player-facing difficulty profiles. Each tier changes several independent
-- pressure levers; Medium is the authored baseline and therefore stays at 1.0.

local DifficultyProfiles = {}

DifficultyProfiles.order = {
  "very_easy", "easy", "medium", "hard", "super_hard",
}

DifficultyProfiles.profiles = {
  very_easy = {
    label = "VERY EASY",
    wave_pressure = 0.65,
    enemy_health = 0.65,
    enemy_damage = 0.60,
    enemy_speed = 0.82,
    enemy_amount = 0.70,
    enemy_attack_interval = 1.18,
    player_damage = 1.35,
    boss_health = 0.60,
    boss_attack_damage = 0.55,
    boss_speed = 0.82,
    boss_attack_interval = 1.25,
    boss_projectile_speed = 0.85,
  },
  easy = {
    label = "EASY",
    wave_pressure = 0.82,
    enemy_health = 0.82,
    enemy_damage = 0.80,
    enemy_speed = 0.92,
    enemy_amount = 0.85,
    enemy_attack_interval = 1.10,
    player_damage = 1.15,
    boss_health = 0.80,
    boss_attack_damage = 0.75,
    boss_speed = 0.92,
    boss_attack_interval = 1.12,
    boss_projectile_speed = 0.92,
  },
  medium = {
    label = "MEDIUM",
    wave_pressure = 1.00,
    enemy_health = 1.00,
    enemy_damage = 1.00,
    enemy_speed = 1.00,
    enemy_amount = 1.00,
    enemy_attack_interval = 1.00,
    player_damage = 1.00,
    boss_health = 1.00,
    boss_attack_damage = 1.00,
    boss_speed = 1.00,
    boss_attack_interval = 1.00,
    boss_projectile_speed = 1.00,
  },
  hard = {
    label = "HARD",
    wave_pressure = 1.18,
    enemy_health = 1.18,
    enemy_damage = 1.15,
    enemy_speed = 1.08,
    enemy_amount = 1.18,
    enemy_attack_interval = 0.92,
    player_damage = 0.93,
    boss_health = 1.25,
    boss_attack_damage = 1.20,
    boss_speed = 1.08,
    boss_attack_interval = 0.92,
    boss_projectile_speed = 1.08,
  },
  super_hard = {
    label = "SUPER HARD",
    wave_pressure = 1.38,
    enemy_health = 1.42,
    enemy_damage = 1.30,
    enemy_speed = 1.16,
    enemy_amount = 1.38,
    enemy_attack_interval = 0.86,
    player_damage = 0.85,
    boss_health = 1.55,
    boss_attack_damage = 1.40,
    boss_speed = 1.16,
    boss_attack_interval = 0.84,
    boss_projectile_speed = 1.18,
  },
}

local index_by_id = {}
for index, id in ipairs(DifficultyProfiles.order) do
  index_by_id[id] = index
end

function DifficultyProfiles.resolve(id)
  return DifficultyProfiles.profiles[id] and id or "medium"
end

function DifficultyProfiles.get(id)
  return DifficultyProfiles.profiles[DifficultyProfiles.resolve(id)]
end

function DifficultyProfiles.label(id)
  return DifficultyProfiles.get(id).label
end

function DifficultyProfiles.step(id, direction)
  local index = index_by_id[DifficultyProfiles.resolve(id)]
  index = math.max(1, math.min(#DifficultyProfiles.order,
    index + (direction < 0 and -1 or 1)))
  return DifficultyProfiles.order[index]
end

return DifficultyProfiles
