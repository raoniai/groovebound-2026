-- Read-only projection of weapon content plus live run state. This is the
-- single database used by the Arsenal screen, level-up cards, and admin.

local class = require("src.core.class")

local WeaponCatalog = class()

function WeaponCatalog:init(content)
  assert(content and content.weapons and content.evolutions, "weapon content required")
  self.content = content
  self.recipe_by_result = {}
  for id, recipe in pairs(content.evolutions) do
    self.recipe_by_result[recipe.result_weapon] = {
      id = id,
      recipe = recipe,
    }
  end
end

local function status_for(entry)
  if entry.active then return "ACTIVE" end
  if entry.owned then return "OWNED" end
  if entry.evolution_eligible then return "EVOLVE NOW" end
  if entry.available_to_offer then return "LEVEL-UP POOL" end
  if entry.definition.evolved then return "EVOLUTION ONLY" end
  return "SLOTS FULL"
end

function WeaponCatalog:entry(id, run)
  local definition = assert(self.content.weapons[id], "unknown weapon " .. tostring(id))
  local inventory = run and run.combat and run.combat.inventory
  local runtime = run and run.combat and run.combat.weapon_runtime
  local progression = run and run.combat and run.combat.progression
  local instance, slot
  if inventory then instance, slot = inventory:get(id) end
  local recipe_record = self.recipe_by_result[id]
  local evolution_eligible = false

  if recipe_record and progression then
    evolution_eligible = progression.evolution:can_evolve(
      recipe_record.id,
      inventory,
      progression.passives,
      "level_up",
      runtime) == true
  end

  local active = instance ~= nil
    and runtime ~= nil
    and runtime:get(slot) ~= nil
    and runtime:get(slot).weapon_id == id
  local available_to_offer = not definition.evolved
    and not instance
    and (not inventory or inventory:count() < inventory.capacity)
  local upgradeable = instance ~= nil and instance.level < definition.max_level
  local entry = {
    id = id,
    definition = definition,
    icon = definition.icon,
    owned = instance ~= nil,
    active = active,
    slot = slot,
    level = instance and instance.level or nil,
    upgradeable = upgradeable,
    available_to_offer = available_to_offer,
    evolution_eligible = evolution_eligible,
    in_level_pool = available_to_offer or upgradeable or evolution_eligible,
    recipe = recipe_record and recipe_record.recipe or nil,
    first = definition.levels[1],
    maximum = definition.levels[definition.max_level],
  }
  entry.status = status_for(entry)
  return entry
end

function WeaponCatalog:list(run, filter)
  if filter == "supports" then return self:list_supports(run) end
  filter = filter or "all"
  local result = {}
  for id in pairs(self.content.weapons) do
    local entry = self:entry(id, run)
    local include = filter == "all"
      or (filter == "base" and not entry.definition.evolved)
      or (filter == "evolved" and entry.definition.evolved)
      or (filter == "owned" and entry.owned)
      or (filter == "level_up" and entry.in_level_pool)
    if include then result[#result + 1] = entry end
  end
  table.sort(result, function(a, b)
    if a.definition.evolved ~= b.definition.evolved then
      return not a.definition.evolved
    end
    return a.definition.name < b.definition.name
  end)
  return result
end

function WeaponCatalog:support_entry(id, run)
  local definition = assert(self.content.passives[id], "unknown support " .. tostring(id))
  local progression = run and run.combat and run.combat.progression
  local inventory = progression and progression.passives
  local instance, slot
  if inventory then instance, slot = inventory:get(id) end
  local upgradeable = instance ~= nil and instance.level < definition.max_level
  local available_to_offer = not instance
    and (not inventory or inventory:count() < inventory.capacity)
  local recipes = {}
  for recipe_id, recipe in pairs(self.content.evolutions) do
    for _, requirement in ipairs(recipe.required_passives) do
      if requirement.id == id then
        recipes[#recipes + 1] = {
          id = recipe_id,
          recipe = recipe,
          result = self.content.weapons[recipe.result_weapon],
          base = self.content.weapons[recipe.base_weapon],
        }
      end
    end
  end
  table.sort(recipes, function(a, b) return a.result.name < b.result.name end)
  local status
  if instance and upgradeable then status = "OWNED R" .. instance.level
  elseif instance then status = "MAX RANK"
  elseif available_to_offer then status = "LEVEL-UP POOL"
  else status = "SLOTS FULL" end
  return {
    kind = "support",
    id = id,
    definition = definition,
    icon = definition.icon,
    owned = instance ~= nil,
    slot = slot,
    level = instance and instance.level or nil,
    upgradeable = upgradeable,
    available_to_offer = available_to_offer,
    in_level_pool = available_to_offer or upgradeable,
    recipes = recipes,
    status = status,
  }
end

function WeaponCatalog:list_supports(run)
  local result = {}
  for id in pairs(self.content.passives) do
    result[#result + 1] = self:support_entry(id, run)
  end
  table.sort(result, function(a, b)
    return a.definition.name < b.definition.name
  end)
  return result
end

function WeaponCatalog:counts(run)
  local all = self:list(run, "all")
  local counts = {
    all = #all,
    base = 0,
    evolved = 0,
    owned = 0,
    level_up = 0,
    supports = #self:list_supports(run),
  }
  for _, entry in ipairs(all) do
    if entry.definition.evolved then counts.evolved = counts.evolved + 1
    else counts.base = counts.base + 1 end
    if entry.owned then counts.owned = counts.owned + 1 end
    if entry.in_level_pool then counts.level_up = counts.level_up + 1 end
  end
  return counts
end

return WeaponCatalog
