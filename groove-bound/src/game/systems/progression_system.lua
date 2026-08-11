-- Generates and applies legal Vampire-Survivors-style level-up decisions.
-- Inventory/passive state is authoritative; impossible or capped cards never
-- enter the weighted pool. Legal weapon/support fusions are always offered
-- before ordinary upgrades.

local class = require("src.core.class")
local PassiveInventory = require("src.game.systems.passive_inventory")
local WeaponEvolution = require("src.game.systems.weapon_evolution")

local ProgressionSystem = class()

local function card(kind, id, title, description, priority)
  return {
    kind = kind,
    id = id,
    title = title,
    description = description,
    priority = priority or 10,
  }
end

local function card_key(choice)
  return choice.kind .. ":" .. choice.id
end

local AUTO_FALLBACKS = {
  heal = { "Second Wind", "Restore 30% maximum health.", 20 },
  coins = { "Tip Jar", "Bank 25 coins for the results.", 21 },
  guard = { "Sound Check", "Gain 25 temporary guard.", 22 },
}

local function fallback_card(kind)
  local definition = AUTO_FALLBACKS[kind]
  if not definition then return nil end
  return card(kind, kind, definition[1], definition[2], definition[3])
end

function ProgressionSystem:init(opts)
  self.content = assert(opts.content)
  self.inventory = assert(opts.inventory)
  self.weapon_runtime = assert(opts.weapon_runtime)
  self.player = assert(opts.player)
  self.rng = assert(opts.rng)
  self.passives = PassiveInventory(self.content, { capacity = 4 })
  self.evolution = WeaponEvolution(self.content)
  self.rerolls = 1
  self.evolutions = {}
  self.coins = 0
  self.offer_serial = 0
  self.last_offer = nil
  self.evolution_notice = 0
  self.evolution_notice_text = nil
  self.upgrade_notice = 0
  self.upgrade_notice_text = nil
  self.last_evolution_signature = ""
  self.chests_opened = 0
  self.chest_rewards_claimed = 0
  self.auto_fallback_kind = nil
end

function ProgressionSystem:passive_bonus(stat)
  local total = 0
  for _, passive in ipairs(self.passives.slots) do
    local definition = self.content.passives[passive.id]
    if definition.stat == stat then
      total = total + passive.level * definition.per_level
    end
  end
  return total
end

function ProgressionSystem:eligible_evolutions()
  return self.evolution:eligible(
    self.inventory,
    self.passives,
    "level_up",
    self.weapon_runtime)
end

function ProgressionSystem:evolution_progress()
  local result = {}
  for recipe_id, recipe in pairs(self.content.evolutions) do
    local weapon, slot = self.inventory:get(recipe.base_weapon)
    local evolved = self.inventory:get(recipe.result_weapon)
    if weapon and not evolved then
      local requirement = recipe.required_passives[1]
      local support = self.passives:get(requirement.id)
      local weapon_ready = weapon.level >= recipe.required_weapon_level
      local support_ready = support ~= nil
        and support.level >= requirement.min_level
      result[#result + 1] = {
        id = recipe_id,
        recipe = recipe,
        base = self.content.weapons[recipe.base_weapon],
        result = self.content.weapons[recipe.result_weapon],
        support = self.content.passives[requirement.id],
        slot = slot,
        weapon_level = weapon.level,
        required_weapon_level = recipe.required_weapon_level,
        support_level = support and support.level or 0,
        required_support_level = requirement.min_level,
        weapon_ready = weapon_ready,
        support_ready = support_ready,
        eligible = weapon_ready and support_ready,
      }
    end
  end
  table.sort(result, function(a, b)
    if a.eligible ~= b.eligible then return a.eligible end
    if a.weapon_ready ~= b.weapon_ready then return a.weapon_ready end
    if a.support_ready ~= b.support_ready then return a.support_ready end
    if a.weapon_level ~= b.weapon_level then
      return a.weapon_level > b.weapon_level
    end
    return a.result.name < b.result.name
  end)
  return result
end

function ProgressionSystem:update(dt)
  self.evolution_notice = math.max(0, self.evolution_notice - dt)
  self.upgrade_notice = math.max(0, self.upgrade_notice - dt)
  local eligible = self:eligible_evolutions()
  local signature = table.concat(eligible, "|")
  if signature ~= "" and signature ~= self.last_evolution_signature then
    local recipe = self.content.evolutions[eligible[1]]
    local result = self.content.weapons[recipe.result_weapon]
    self.evolution_notice = 5
    self.evolution_notice_text = "CHEST READY: EVOLVE INTO " .. result.name
  end
  self.last_evolution_signature = signature
end

function ProgressionSystem:_weapon_cards(out)
  for _, instance in ipairs(self.inventory.slots) do
    local definition = self.content.weapons[instance.id]
    if not definition.evolved and instance.level < definition.max_level then
      out[#out + 1] = card(
        "weapon_level",
        instance.id,
        definition.name .. "  R" .. (instance.level + 1),
        definition.description,
        1)
    end
  end

  if self.inventory:count() < self.inventory.capacity then
    for id, definition in pairs(self.content.weapons) do
      if not definition.evolved and not self.inventory:get(id) then
        out[#out + 1] = card(
          "weapon_add",
          id,
          definition.name,
          definition.description,
          4)
      end
    end
  end
end

function ProgressionSystem:_passive_cards(out)
  for id, definition in pairs(self.content.passives) do
    local owned = self.passives:get(id)
    if owned and owned.level < definition.max_level then
      out[#out + 1] = card(
        "passive_level",
        id,
        definition.name .. "  R" .. (owned.level + 1),
        definition.description,
        id == "breath_control" and 2 or 5)
    elseif not owned and self.passives:count() < self.passives.capacity then
      out[#out + 1] = card(
        "passive_add",
        id,
          definition.name,
        definition.description,
        id == "breath_control" and 2 or 5)
    end
  end
end

function ProgressionSystem:_evolution_cards(out)
  for _, evolution_id in ipairs(self:eligible_evolutions()) do
    local recipe = self.content.evolutions[evolution_id]
    local result = self.content.weapons[recipe.result_weapon]
    local base = self.content.weapons[recipe.base_weapon]
    local support = self.content.passives[recipe.required_passives[1].id]
    out[#out + 1] = card(
      "evolution",
      evolution_id,
      "EVOLVE NOW: " .. result.name,
      "READY: " .. base.name .. " R10 + " .. support.name
        .. ". Consumes both; support slot reopens.",
      0)
  end
end

function ProgressionSystem:_fallback_cards(out)
  out[#out + 1] = fallback_card("heal")
  out[#out + 1] = fallback_card("coins")
  out[#out + 1] = fallback_card("guard")
end

function ProgressionSystem:grant_starter_loadout(loadout)
  loadout = loadout or {}
  local granted = { weapons = {}, passives = {} }
  local seen_weapons, seen_passives = {}, {}
  for _, id in ipairs(loadout.weapons or {}) do
    local definition = self.content.weapons[id]
    if definition and not definition.evolved and not seen_weapons[id]
      and not self.inventory:get(id)
      and self.inventory:count() < self.inventory.capacity
    then
      self:apply({ kind = "weapon_add", id = id })
      granted.weapons[#granted.weapons + 1] = id
      seen_weapons[id] = true
    end
  end
  for _, id in ipairs(loadout.passives or {}) do
    local definition = self.content.passives[id]
    if definition and not seen_passives[id] and not self.passives:get(id)
      and self.passives:count() < self.passives.capacity
    then
      self:apply({ kind = "passive_add", id = id })
      granted.passives[#granted.passives + 1] = id
      seen_passives[id] = true
    end
  end
  return granted
end

function ProgressionSystem:is_auto_select_available()
  local pool = {}
  self:_evolution_cards(pool)
  self:_weapon_cards(pool)
  self:_passive_cards(pool)
  return #pool == 0
end

function ProgressionSystem:set_auto_fallback(kind)
  if not AUTO_FALLBACKS[kind] or not self:is_auto_select_available() then
    return false
  end
  self.auto_fallback_kind = kind
  return true
end

function ProgressionSystem:can_auto_select()
  return AUTO_FALLBACKS[self.auto_fallback_kind] ~= nil
    and self:is_auto_select_available()
end

function ProgressionSystem:auto_select()
  if not self:can_auto_select() then return nil end
  local choice = fallback_card(self.auto_fallback_kind)
  local result = self:apply(choice)
  self.upgrade_notice = 2.8
  self.upgrade_notice_text = "AUTO PICK  •  " .. choice.title
  return {
    kind = choice.kind,
    id = choice.id,
    title = choice.title,
    description = choice.description,
    result = result,
    auto_selected = true,
  }
end

local function sorted_candidates(source, predicate, selected, previous)
  local preferred, repeated = {}, {}
  for _, candidate in ipairs(source) do
    local key = card_key(candidate)
    if predicate(candidate) and not selected[key] then
      if previous[key] then
        repeated[#repeated + 1] = candidate
      else
        preferred[#preferred + 1] = candidate
      end
    end
  end
  local candidates = #preferred > 0 and preferred or repeated
  table.sort(candidates, function(a, b)
    return card_key(a) < card_key(b)
  end)
  return candidates
end

function ProgressionSystem:_draw_offer_card(
  pool, offer, selected, previous, predicate)
  local candidates = sorted_candidates(
    pool, predicate, selected, previous)
  if #candidates == 0 then return false end
  local candidate = candidates[self.rng:range(1, #candidates)]
  selected[card_key(candidate)] = true
  offer[#offer + 1] = candidate
  return true
end

function ProgressionSystem:create_offer()
  local pool = {}
  self:_weapon_cards(pool)
  self:_passive_cards(pool)
  self:_fallback_cards(pool)
  local previous = {}
  for _, choice in ipairs(self.last_offer or {}) do
    previous[card_key(choice)] = true
  end

  local offer = {}
  local selected = {}
  local function draw(predicate)
    if #offer >= 3 then return false end
    return self:_draw_offer_card(
      pool, offer, selected, previous, predicate)
  end
  local weapon_room = self.inventory:count() < self.inventory.capacity
  local support_room = self.passives:count() < self.passives.capacity

  -- While a weapon slot is free, surface one genuinely new weapon and rotate
  -- it away from the immediately previous offer whenever the pool permits.
  draw(function(choice) return choice.kind == "weapon_add" end)

  -- Keep progression represented, but vary across every owned weapon/support.
  draw(function(choice)
    return choice.kind == "weapon_level"
      or choice.kind == "passive_level"
  end)

  -- New supports are a distinct build decision, not a fixed Breath slot.
  draw(function(choice) return choice.kind == "passive_add" end)

  -- Once both inventories are full, guarantee another owned rank card. This
  -- prevents fallback rewards from stalling the route to rank-ten fusions.
  if not weapon_room and not support_room then
    draw(function(choice)
      return choice.kind == "weapon_level"
        or choice.kind == "passive_level"
    end)
  end

  -- Full/capped inventories fall through to any remaining legal wildcard.
  while #offer < 3 do
    local added = draw(function() return true end)
    if not added then break end
  end

  self.offer_serial = self.offer_serial + 1
  self.last_offer = offer
  return offer
end

function ProgressionSystem:_random_chest_card()
  local pool = {}
  self:_weapon_cards(pool)
  self:_passive_cards(pool)
  if #pool == 0 then self:_fallback_cards(pool) end
  table.sort(pool, function(a, b) return card_key(a) < card_key(b) end)
  return pool[self.rng:range(1, #pool)]
end

-- Chests resolve immediately. Ready evolutions always occupy reward slots
-- before ordinary legal weapon/passive rewards, and the pool is rebuilt after
-- every grant so a full or newly reopened inventory can never produce an
-- impossible duplicate.
function ProgressionSystem:claim_chest(reward_count)
  assert(reward_count == 1 or reward_count == 3 or reward_count == 5,
    "chest reward count must be 1, 3, or 5")
  local rewards = {}
  local evolution_pending = #self:eligible_evolutions() > 0
  local all_auto_selected = self:can_auto_select() and not evolution_pending
  local has_evolution = false
  for _ = 1, reward_count do
    local choice
    if self:can_auto_select() then
      choice = fallback_card(self.auto_fallback_kind)
    else
      all_auto_selected = false
      local evolutions = {}
      self:_evolution_cards(evolutions)
      if #evolutions > 0 then
        table.sort(evolutions, function(a, b) return card_key(a) < card_key(b) end)
        choice = evolutions[1]
      else
        choice = self:_random_chest_card()
      end
    end
    if not choice then break end
    local result = self:apply(choice)
    has_evolution = has_evolution or choice.kind == "evolution"
    rewards[#rewards + 1] = {
      kind = choice.kind,
      id = choice.id,
      title = choice.title,
      description = choice.description,
      result = result,
    }
  end
  self.chests_opened = self.chests_opened + 1
  self.chest_rewards_claimed = self.chest_rewards_claimed + #rewards
  rewards.auto_selected = all_auto_selected and #rewards > 0
  rewards.has_evolution = has_evolution
  if #rewards > 0 then
    local names = {}
    for _, reward in ipairs(rewards) do names[#names + 1] = reward.title end
    self.upgrade_notice = 6
    self.upgrade_notice_text = "CHEST ×" .. #rewards .. "  •  "
      .. table.concat(names, "  •  ")
  end
  return rewards
end

function ProgressionSystem:reroll()
  if self.rerolls <= 0 then return nil, "no_rerolls" end
  self.rerolls = self.rerolls - 1
  return self:create_offer()
end

function ProgressionSystem:_apply_passive_effects()
  local quickstep = self.passives:get("quickstep")
  self.player.passive_speed_multiplier = 1 + (quickstep and quickstep.level * 0.10 or 0)

  local encore = self.passives:get("encore")
  local next_max = math.floor(self.player.base_max_hp
    * (1 + (encore and encore.level * 0.15 or 0)) + 0.5)
  local gain = math.max(0, next_max - self.player.max_hp)
  self.player.max_hp = next_max
  self.player.hp = math.min(self.player.max_hp, self.player.hp + gain)

  local next_guard_capacity = self:passive_bonus("guard")
  local guard_gain = math.max(
    0, next_guard_capacity - (self.player.passive_guard_capacity or 0))
  self.player.passive_guard_capacity = next_guard_capacity
  self.player.guard = (self.player.guard or 0) + guard_gain

  self.weapon_runtime:set_passives(self.passives:levels())
  self.weapon_runtime:sync(self.inventory)
end

function ProgressionSystem:apply(choice)
  assert(choice and choice.kind, "progression choice required")
  local result
  if choice.kind == "weapon_level" then
    local before = self.inventory:get(choice.id).level
    result = assert(self.inventory:level_up(choice.id))
    self.weapon_runtime:sync(self.inventory)
    local definition = self.content.weapons[choice.id]
    local old_stats = definition.levels[before]
    local new_stats = definition.levels[result.level]
    local changes = {}
    if new_stats.damage ~= old_stats.damage then
      changes[#changes + 1] = string.format("%+d DMG", new_stats.damage - old_stats.damage)
    end
    if new_stats.cooldown ~= old_stats.cooldown then
      changes[#changes + 1] = string.format("%.2fs FASTER", old_stats.cooldown - new_stats.cooldown)
    end
    if (new_stats.count or 1) ~= (old_stats.count or 1) then
      changes[#changes + 1] = string.format("%+d PROJECTILE",
        (new_stats.count or 1) - (old_stats.count or 1))
    end
    if new_stats.speed ~= old_stats.speed then
      changes[#changes + 1] = string.format("%+d SPEED", new_stats.speed - old_stats.speed)
    end
    self.upgrade_notice = 3.5
    self.upgrade_notice_text = definition.name .. " R" .. result.level
      .. "  •  " .. table.concat(changes, "  •  ")
  elseif choice.kind == "weapon_add" then
    result = assert(self.inventory:add(choice.id, 1))
    self.weapon_runtime:sync(self.inventory)
    self.upgrade_notice = 3.5
    self.upgrade_notice_text = "NEW WEAPON  •  " .. self.content.weapons[choice.id].name
  elseif choice.kind == "passive_add" then
    result = assert(self.passives:add(choice.id, 1))
    self:_apply_passive_effects()
  elseif choice.kind == "passive_level" then
    result = assert(self.passives:level_up(choice.id))
    self:_apply_passive_effects()
  elseif choice.kind == "evolution" then
    result = assert(self.evolution:evolve(
      choice.id,
      self.inventory,
      self.passives,
      "level_up",
      self.weapon_runtime))
    self:_apply_passive_effects()
    self.last_evolution_signature = ""
    self.evolution_notice = 0
    self.upgrade_notice = 5
    self.upgrade_notice_text = "EVOLVED  •  "
      .. self.content.weapons[result.new_weapon_id].name
    self.evolutions[#self.evolutions + 1] = {
      id = choice.id,
      result_weapon = result.new_weapon_id,
      branch = result.branch,
    }
  elseif choice.kind == "heal" then
    self.player.hp = math.min(self.player.max_hp, self.player.hp + self.player.max_hp * 0.30)
    result = { healed = true }
  elseif choice.kind == "coins" then
    self.coins = self.coins + 25
    result = { coins = 25 }
  elseif choice.kind == "guard" then
    self.player.guard = (self.player.guard or 0) + 25
    result = { guard = 25 }
  else
    error("unknown progression choice: " .. tostring(choice.kind))
  end
  return result
end

function ProgressionSystem:skip()
  self.coins = self.coins + 5
  return 5
end

function ProgressionSystem:snapshot()
  local inventory = self.inventory:snapshot()
  local passives = self.passives:snapshot()
  return {
    inventory = inventory,
    weapons = inventory.slots,
    passive_inventory = passives,
    passives = passives.slots,
    rerolls = self.rerolls,
    coins = self.coins,
    evolutions = self.evolutions,
    chests_opened = self.chests_opened,
    chest_rewards_claimed = self.chest_rewards_claimed,
    auto_fallback_kind = self.auto_fallback_kind,
  }
end

function ProgressionSystem:restore(snapshot)
  assert(type(snapshot) == "table", "invalid progression snapshot")
  local inventory = snapshot.inventory or {
    capacity = math.max(4, #(snapshot.weapons or {})),
    revision = 0,
    slots = snapshot.weapons or {},
  }
  local passives = snapshot.passive_inventory or {
    capacity = math.max(4, #(snapshot.passives or {})),
    slots = snapshot.passives or {},
  }
  self.inventory:restore(inventory)
  self.passives:restore(passives)
  self.rerolls = snapshot.rerolls or 1
  self.coins = snapshot.coins or 0
  self.evolutions = snapshot.evolutions or {}
  self.chests_opened = snapshot.chests_opened or 0
  self.chest_rewards_claimed = snapshot.chest_rewards_claimed or 0
  self.auto_fallback_kind = AUTO_FALLBACKS[snapshot.auto_fallback_kind]
      and snapshot.auto_fallback_kind or nil
  self.weapon_runtime:sync(self.inventory)
  self:_apply_passive_effects()
  return self:snapshot()
end

return ProgressionSystem
