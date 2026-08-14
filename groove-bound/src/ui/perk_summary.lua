local PerkSummary = {}

local labels = {
  ["pickup.radius_multiplier"] = "Pickup range",
  ["combat.base_damage_multiplier"] = "Base damage",
  ["movement.speed_multiplier"] = "Move speed",
  ["survival.max_health_multiplier"] = "Max HP",
  ["survival.damage_reduction"] = "Armor",
  ["economy.coin_value_multiplier"] = "Coin value",
  ["level_up.rerolls"] = "Rerolls",
  ["groove.window_seconds"] = "Groove window",
  ["hazards.damage_reduction"] = "Hazard armor",
  ["combat.cooldown_reduction"] = "Cooldown",
  ["progression.xp_multiplier"] = "XP gain",
  ["combo.grace_seconds"] = "Combo grace",
  ["survival.first_hit_reduction"] = "First-hit armor",
  ["movement.knockback_resistance"] = "Knockback resist",
  ["rewards.first_boss_choices"] = "Boss choices",
  ["survival.healing_multiplier"] = "Healing",
  ["survival.invulnerability_seconds"] = "Hit protection",
  ["economy.encore_multiplier"] = "Encore payout",
  ["progression.starting_xp"] = "Starting XP",
}

function PerkSummary.attribute(perk)
  local modifier = perk and perk.modifiers and perk.modifiers[1] or {}
  return labels[modifier.key] or "Permanent boost"
end

function PerkSummary.value(perk, rank)
  local modifier = perk and perk.modifiers and perk.modifiers[1] or {}
  local total = (modifier.per_rank or 0) * (rank or 0)
  if modifier.operation == "grant_count" then return "+" .. tostring(total) end
  if modifier.key and modifier.key:match("seconds$") then
    return string.format("+%.2fs", total)
  end
  return string.format("+%d%%", math.floor(total * 100 + 0.5))
end

function PerkSummary.collect(content, slot)
  local result = { owned = 0, ranks = 0, total = 0, entries = {} }
  for _ in pairs(content.meta_perks or {}) do result.total = result.total + 1 end
  for id, ownership in pairs(slot and slot.perks or {}) do
    local perk = content.meta_perks[id]
    if perk then
      result.owned = result.owned + 1
      result.ranks = result.ranks + (ownership.rank or 0)
      result.entries[#result.entries + 1] = {
        id = id, perk = perk, rank = ownership.rank or 0,
        label = PerkSummary.attribute(perk),
        value = PerkSummary.value(perk, ownership.rank or 0),
      }
    end
  end
  table.sort(result.entries, function(a, b)
    return a.perk.sprite.cell < b.perk.sprite.cell
  end)
  return result
end

return PerkSummary
