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
  self.last_evolution_signature = ""
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

function ProgressionSystem:update(dt)
  self.evolution_notice = math.max(0, self.evolution_notice - dt)
  local eligible = self:eligible_evolutions()
  local signature = table.concat(eligible, "|")
  if signature ~= "" and signature ~= self.last_evolution_signature then
    local recipe = self.content.evolutions[eligible[1]]
    local result = self.content.weapons[recipe.result_weapon]
    self.evolution_notice = 5
    self.evolution_notice_text = "YOU CAN EVOLVE NOW: " .. result.name
  end
  self.last_evolution_signature = signature
end

function ProgressionSystem:_weapon_cards(out)
  for slot, instance in ipairs(self.inventory.slots) do
    local definition = self.content.weapons[instance.id]
    if not definition.evolved and instance.level < definition.max_level then
      out[#out + 1] = card(
        "weapon_level",
        instance.id,
        definition.name .. "  R" .. (instance.level + 1),
        "Upgrade the weapon currently firing from slot " .. slot .. ".",
        1)
    end
  end

  if self.inventory:count() < self.inventory.capacity then
    for id, definition in pairs(self.content.weapons) do
      if not definition.evolved and not self.inventory:get(id) then
        out[#out + 1] = card(
          "weapon_add",
          id,
          "NEW: " .. definition.name,
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
        "SUPPORT: " .. definition.name,
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
      "FUSION: " .. result.name,
      base.name .. " + " .. support.name
        .. ". Consumes both and frees the support slot.",
      0)
  end
end

function ProgressionSystem:_fallback_cards(out)
  out[#out + 1] = card("heal", "heal", "Second Wind", "Restore 30% maximum health.", 20)
  out[#out + 1] = card("coins", "coins", "Tip Jar", "Bank 25 coins for the results.", 21)
  out[#out + 1] = card("guard", "guard", "Sound Check", "Gain 25 temporary guard.", 22)
end

local function sort_cards(a, b)
  if a.priority == b.priority then
    if a.kind == b.kind then return a.id < b.id end
    return a.kind < b.kind
  end
  return a.priority < b.priority
end

function ProgressionSystem:create_offer()
  local pool = {}
  self:_evolution_cards(pool)
  self:_weapon_cards(pool)
  self:_passive_cards(pool)
  self:_fallback_cards(pool)
  table.sort(pool, sort_cards)

  -- Preserve the deliberate first two synergy slots, then seed-shuffle the
  -- remainder so offers vary without becoming irreproducible.
  local offer = {}
  while #pool > 0 and #offer < 3 do
    local priority = pool[1].priority
    local group = {}
    while pool[1] and pool[1].priority == priority do
      group[#group + 1] = table.remove(pool, 1)
    end
    self.rng:shuffle(group)
    for _, candidate in ipairs(group) do
      if #offer < 3 then offer[#offer + 1] = candidate end
    end
  end

  self.offer_serial = self.offer_serial + 1
  self.last_offer = offer
  return offer
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
    result = assert(self.inventory:level_up(choice.id))
    self.weapon_runtime:sync(self.inventory)
  elseif choice.kind == "weapon_add" then
    result = assert(self.inventory:add(choice.id, 1))
    self.weapon_runtime:sync(self.inventory)
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
  return {
    weapons = self.inventory:snapshot().slots,
    passives = self.passives:snapshot().slots,
    rerolls = self.rerolls,
    coins = self.coins,
    evolutions = self.evolutions,
  }
end

return ProgressionSystem
