-- Permanent World Tour perks. Definitions are immutable during a run.

local next_cell = 0
local function perk(id, name, max_rank, source, description, modifier, rarity)
  next_cell = next_cell + 1
  local prices = {}
  local bands = max_rank == 5 and { 250, 400, 575, 800 }
    or max_rank == 3 and { 500, 850 } or {}
  for rank = 2, max_rank do prices[rank] = bands[rank - 1] end
  return {
    id = id, name = name, description = description,
    rarity = rarity or (max_rank == 1 and "rare" or "common"),
    max_rank = max_rank, source = source,
    sprite = { atlas = "meta_perks", cell = next_cell },
    balance_revision = 1, prices = prices, modifiers = { modifier },
  }
end

local function world_source(world_id, grade)
  return { type = "world_grade", world_id = world_id, grade = grade }
end

return {
  open_ears = perk("open_ears", "Open Ears", 5,
    { type = "prologue_clear" }, "Increase pickup radius.",
    { key = "pickup.radius_multiplier", operation = "add", per_rank = 0.03, total_cap = 0.15 }),
  pocket_drive = perk("pocket_drive", "Pocket Drive", 5, world_source("funk", "C"),
    "Increase base damage by a small capped amount.",
    { key = "combat.base_damage_multiplier", operation = "add", per_rank = 0.02, total_cap = 0.10 }),
  breakstep = perk("breakstep", "Breakstep", 3, world_source("funk", "A"),
    "Increase movement speed.",
    { key = "movement.speed_multiplier", operation = "add", per_rank = 0.03, total_cap = 0.09 }, "uncommon"),
  warm_current = perk("warm_current", "Warm Current", 5, world_source("soul", "C"),
    "Increase maximum health.",
    { key = "survival.max_health_multiplier", operation = "add", per_rank = 0.03, total_cap = 0.15 }),
  velvet_guard = perk("velvet_guard", "Velvet Guard", 3, world_source("soul", "A"),
    "Reduce incoming damage.",
    { key = "survival.damage_reduction", operation = "add", per_rank = 0.025, total_cap = 0.075 }, "uncommon"),
  mirrorball_tips = perk("mirrorball_tips", "Mirrorball Tips", 5, world_source("disco", "C"),
    "Increase eligible in-run coin value within its cap.",
    { key = "economy.coin_value_multiplier", operation = "add", per_rank = 0.03, total_cap = 0.15 }),
  spotlight_spin = perk("spotlight_spin", "Spotlight Spin", 1, world_source("disco", "A"),
    "Grant one level-up reroll per run.",
    { key = "level_up.rerolls", operation = "grant_count", per_rank = 1, total_cap = 1 }),
  four_count = perk("four_count", "Four Count", 5, world_source("house", "C"),
    "Extend the positive Groove timing window.",
    { key = "groove.window_seconds", operation = "add", per_rank = 0.012, total_cap = 0.06 }),
  floor_control = perk("floor_control", "Floor Control", 3, world_source("house", "A"),
    "Reduce arena-hazard damage.",
    { key = "hazards.damage_reduction", operation = "add", per_rank = 0.05, total_cap = 0.15 }, "uncommon"),
  live_wire = perk("live_wire", "Live Wire", 5, world_source("electro", "C"),
    "Improve attack cooldown.",
    { key = "combat.cooldown_reduction", operation = "add", per_rank = 0.016, total_cap = 0.08 }),
  signal_boost = perk("signal_boost", "Signal Boost", 3, world_source("electro", "A"),
    "Increase XP gain.",
    { key = "progression.xp_multiplier", operation = "add", per_rank = 0.033, total_cap = 0.10 }, "uncommon"),
  precision_loop = perk("precision_loop", "Precision Loop", 5, world_source("techno", "C"),
    "Extend combo grace without changing damage.",
    { key = "combo.grace_seconds", operation = "add", per_rank = 0.08, total_cap = 0.40 }),
  hard_reset = perk("hard_reset", "Hard Reset", 1, world_source("techno", "A"),
    "Reduce the first damaging hit of each run.",
    { key = "survival.first_hit_reduction", operation = "replace_once", per_rank = 0.25, total_cap = 0.25 }),
  orbital_balance = perk("orbital_balance", "Orbital Balance", 3, world_source("cosmic_boogie", "C"),
    "Improve knockback resistance and recovery.",
    { key = "movement.knockback_resistance", operation = "add", per_rank = 0.08, total_cap = 0.24 }, "uncommon"),
  encore_spark = perk("encore_spark", "Encore Spark", 1, world_source("cosmic_boogie", "A"),
    "Add one reward choice after the first boss.",
    { key = "rewards.first_boss_choices", operation = "grant_count", per_rank = 1, total_cap = 1 }),
  deep_reserve = perk("deep_reserve", "Deep Reserve", 5, world_source("soulful_garage", "C"),
    "Increase healing effectiveness.",
    { key = "survival.healing_multiplier", operation = "add", per_rank = 0.03, total_cap = 0.15 }),
  afterglow = perk("afterglow", "Afterglow", 3, world_source("soulful_garage", "A"),
    "Extend post-hit protection duration.",
    { key = "survival.invulnerability_seconds", operation = "add", per_rank = 0.08, total_cap = 0.24 }, "uncommon"),
  neon_dividend = perk("neon_dividend", "Neon Dividend", 5, world_source("future_funk", "C"),
    "Increase capped Encore payout.",
    { key = "economy.encore_multiplier", operation = "add", per_rank = 0.03, total_cap = 0.15 }),
  first_drop = perk("first_drop", "First Drop", 1, world_source("future_funk", "A"),
    "Begin each run with a small fixed XP boost.",
    { key = "progression.starting_xp", operation = "grant_count", per_rank = 8, total_cap = 8 }),
}
