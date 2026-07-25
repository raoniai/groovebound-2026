-- Atomic weapon evolution transactions.
--
-- Eligibility is derived from the authoritative inventory and passive levels.
-- Before and after replacement, the active firing runtime must exactly match
-- the inventory. Any failure rolls inventory, passives, and runtime back.

local class = require("src.core.class")

local WeaponEvolution = class()

local function passive_level(passives, passive_id)
  local value = passives[passive_id]
  if type(value) == "table" then return value.level or 0 end
  return value or 0
end

local function snapshot_passives(passives)
  local result = {}
  for id, value in pairs(passives) do
    if type(value) == "table" then
      local copy = {}
      for key, nested in pairs(value) do copy[key] = nested end
      result[id] = copy
    else
      result[id] = value
    end
  end
  return result
end

local function restore_passives(passives, snapshot)
  for id in pairs(passives) do passives[id] = nil end
  for id, value in pairs(snapshot) do passives[id] = value end
end

function WeaponEvolution:init(content)
  assert(content and content.weapons and content.evolutions, "weapon and evolution content are required")
  self.content = content
end

function WeaponEvolution:can_evolve(recipe_id, inventory, passives, trigger, runtime)
  local recipe = self.content.evolutions[recipe_id]
  if not recipe then return false, "unknown_recipe" end
  if recipe.trigger ~= trigger then return false, "wrong_trigger" end
  if inventory:find_slot(recipe.result_weapon) then return false, "result_already_owned" end

  local weapon, slot = inventory:get(recipe.base_weapon)
  if not weapon then return false, "base_weapon_not_owned" end
  if weapon.level < recipe.required_weapon_level then return false, "base_weapon_level_too_low" end

  for _, requirement in ipairs(recipe.required_passives) do
    if passive_level(passives, requirement.id) < requirement.min_level then
      return false, "missing_passive:" .. requirement.id
    end
  end

  if runtime then
    local ok = pcall(function() runtime:assert_consistent(inventory) end)
    if not ok then return false, "runtime_out_of_sync" end
  end

  return true, {
    recipe = recipe,
    slot = slot,
    weapon = weapon,
  }
end

function WeaponEvolution:eligible(inventory, passives, trigger, runtime)
  local result = {}
  for recipe_id in pairs(self.content.evolutions) do
    local ok = self:can_evolve(recipe_id, inventory, passives, trigger, runtime)
    if ok then result[#result + 1] = recipe_id end
  end
  table.sort(result)
  return result
end

function WeaponEvolution:evolve(recipe_id, inventory, passives, trigger, runtime)
  local eligible, context = self:can_evolve(recipe_id, inventory, passives, trigger, runtime)
  if not eligible then return nil, context end

  local recipe = context.recipe
  local inventory_before = inventory:snapshot()
  local passives_before = snapshot_passives(passives)
  local runtime_before = runtime and runtime:snapshot() or nil

  local ok, result = pcall(function()
    local replacement, old_weapon = inventory:replace_at(
      context.slot,
      recipe.result_weapon,
      1,
      {
        evolved_from = recipe.base_weapon,
        evolution_id = recipe.id,
        evolution_branch = recipe.branch,
      })
    assert(replacement, old_weapon)

    if recipe.consume_passives then
      for _, requirement in ipairs(recipe.required_passives) do
        passives[requirement.id] = nil
      end
    end

    if runtime then
      runtime:replace_weapon(context.slot, replacement, inventory.revision)
      runtime:assert_consistent(inventory)
    end

    return {
      recipe_id = recipe.id,
      branch = recipe.branch,
      slot = context.slot,
      old_weapon_id = old_weapon.id,
      new_weapon_id = replacement.id,
      instance = replacement,
    }
  end)

  if not ok then
    inventory:restore(inventory_before)
    restore_passives(passives, passives_before)
    if runtime and runtime_before then runtime:restore(runtime_before) end
    return nil, "evolution_transaction_failed:" .. tostring(result)
  end

  return result
end

return WeaponEvolution
