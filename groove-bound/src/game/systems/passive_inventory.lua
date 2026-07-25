-- Stable-ID passive inventory with a hard slot limit.

local class = require("src.core.class")

local PassiveInventory = class()

function PassiveInventory:init(content, opts)
  opts = opts or {}
  assert(content and content.passives, "passive content is required")
  self.content = content
  self.capacity = opts.capacity or 4
  self.slots = {}
end

function PassiveInventory:count()
  return #self.slots
end

function PassiveInventory:find_slot(id)
  for slot, passive in ipairs(self.slots) do
    if passive.id == id then return slot end
  end
  return nil
end

function PassiveInventory:get(id)
  local slot = self:find_slot(id)
  return slot and self.slots[slot] or nil, slot
end

function PassiveInventory:levels()
  local result = {}
  for _, passive in ipairs(self.slots) do result[passive.id] = passive.level end
  return result
end

function PassiveInventory:add(id, level)
  local definition = self.content.passives[id]
  if not definition then return nil, "unknown_passive" end
  if self:find_slot(id) then return nil, "already_owned" end
  if #self.slots >= self.capacity then return nil, "inventory_full" end
  level = level or 1
  if level < 1 or level > definition.max_level then return nil, "invalid_level" end
  local passive = { id = id, level = level }
  self.slots[#self.slots + 1] = passive
  return passive, #self.slots
end

function PassiveInventory:level_up(id)
  local passive = self:get(id)
  if not passive then return nil, "not_owned" end
  local definition = self.content.passives[id]
  if passive.level >= definition.max_level then return nil, "max_level" end
  passive.level = passive.level + 1
  return passive
end

function PassiveInventory:remove(id)
  local slot = self:find_slot(id)
  if not slot then return nil, "not_owned" end
  local removed = table.remove(self.slots, slot)
  return removed, slot
end

function PassiveInventory:snapshot()
  local result = { capacity = self.capacity, slots = {} }
  for slot, passive in ipairs(self.slots) do
    result.slots[slot] = { id = passive.id, level = passive.level }
  end
  return result
end

function PassiveInventory:restore(snapshot)
  assert(type(snapshot) == "table" and type(snapshot.slots) == "table",
    "invalid passive snapshot")
  self.capacity = snapshot.capacity
  self.slots = {}
  for slot, passive in ipairs(snapshot.slots) do
    self.slots[slot] = { id = passive.id, level = passive.level }
  end
end

return PassiveInventory
