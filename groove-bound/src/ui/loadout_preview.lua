local LoadoutPreview = {}

local function copy_ids(source)
  local result = {}
  for _, id in ipairs(source or {}) do result[#result + 1] = id end
  return result
end

local function contains(source, id)
  for _, value in ipairs(source) do if value == id then return true end end
  return false
end

function LoadoutPreview.compute(content, character_id, weapons, passives, hovered)
  weapons, passives = copy_ids(weapons), copy_ids(passives)
  if hovered then
    local target = hovered.kind == "weapon" and weapons or passives
    if not contains(target, hovered.id) then target[#target + 1] = hovered.id end
  end
  local character = assert(content.characters[character_id])
  local all_weapons = { character.starting_weapon }
  for _, id in ipairs(weapons) do all_weapons[#all_weapons + 1] = id end
  local bonuses = { damage = 0, speed = 0, max_hp = 0, fire_rate = 0,
    cooldown_stability = 0, amount = 0, guard = 0 }
  for _, id in ipairs(passives) do
    local passive = content.passives[id]
    if passive then bonuses[passive.stat] = (bonuses[passive.stat] or 0) + passive.per_level end
  end
  local damage, projectiles = 0, 0
  for _, id in ipairs(all_weapons) do
    local level = content.weapons[id] and content.weapons[id].levels[1]
    if level then
      damage = damage + (level.damage or 0)
      projectiles = projectiles + (level.count or 1) + bonuses.amount
    end
  end
  return {
    power = character.stats.power * (1 + bonuses.damage),
    damage = damage * character.stats.power * (1 + bonuses.damage),
    projectiles = projectiles,
    max_hp = math.floor(100 * character.stats.vitality * (1 + bonuses.max_hp) + 0.5),
    guard = (character.starting_guard or 0) + bonuses.guard,
    speed = character.stats.speed * (1 + bonuses.speed),
    fire_rate = character.stats.tempo * (1 + bonuses.fire_rate + bonuses.cooldown_stability),
    weapon_count = #all_weapons,
    support_count = #passives,
  }
end

return LoadoutPreview
