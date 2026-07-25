-- Stable-ID weapon inventory.
--
-- Slots are authoritative. UI and firing systems receive instances from this
-- inventory instead of maintaining their own weapon lists.

local class = require("src.core.class")

local WeaponInventory = class()

local function copy_instance(instance)
  if not instance then return nil end
  local result = {}
  for key, value in pairs(instance) do result[key] = value end
  return result
end

function WeaponInventory:init(content, opts)
  opts = opts or {}
  assert(content and content.weapons, "weapon content is required")
  self.content = content
  self.capacity = opts.capacity or 4
  self.slots = {}
  self.revision = 0
end

function WeaponInventory:count()
  return #self.slots
end

function WeaponInventory:find_slot(weapon_id)
  for slot, instance in ipairs(self.slots) do
    if instance.id == weapon_id then return slot end
  end
  return nil
end

function WeaponInventory:get(weapon_id)
  local slot = self:find_slot(weapon_id)
  return slot and self.slots[slot] or nil, slot
end

function WeaponInventory:get_slot(slot)
  return self.slots[slot]
end

function WeaponInventory:add(weapon_id, level)
  local definition = self.content.weapons[weapon_id]
  if not definition then return nil, "unknown_weapon" end
  if self:find_slot(weapon_id) then return nil, "already_owned" end
  if #self.slots >= self.capacity then return nil, "inventory_full" end

  level = level or 1
  if level < 1 or level > definition.max_level then
    return nil, "invalid_level"
  end

  local instance = {
    id = weapon_id,
    level = level,
  }
  self.slots[#self.slots + 1] = instance
  self.revision = self.revision + 1
  return instance, #self.slots
end

function WeaponInventory:level_up(weapon_id)
  local instance = self:get(weapon_id)
  if not instance then return nil, "not_owned" end
  local definition = self.content.weapons[weapon_id]
  if instance.level >= definition.max_level then return nil, "max_level" end
  instance.level = instance.level + 1
  self.revision = self.revision + 1
  return instance
end

function WeaponInventory:replace_at(slot, weapon_id, level, metadata)
  local current = self.slots[slot]
  if not current then return nil, "empty_slot" end

  local definition = self.content.weapons[weapon_id]
  if not definition then return nil, "unknown_weapon" end

  local existing_slot = self:find_slot(weapon_id)
  if existing_slot and existing_slot ~= slot then
    return nil, "already_owned"
  end

  level = level or 1
  if level < 1 or level > definition.max_level then
    return nil, "invalid_level"
  end

  local replacement = {
    id = weapon_id,
    level = level,
  }
  for key, value in pairs(metadata or {}) do replacement[key] = value end
  self.slots[slot] = replacement
  self.revision = self.revision + 1
  return replacement, copy_instance(current)
end

function WeaponInventory:snapshot()
  local result = {
    capacity = self.capacity,
    revision = self.revision,
    slots = {},
  }
  for slot, instance in ipairs(self.slots) do
    result.slots[slot] = copy_instance(instance)
  end
  return result
end

function WeaponInventory:restore(snapshot)
  assert(type(snapshot) == "table" and type(snapshot.slots) == "table", "invalid inventory snapshot")
  self.capacity = snapshot.capacity
  self.revision = snapshot.revision
  self.slots = {}
  for slot, instance in ipairs(snapshot.slots) do
    self.slots[slot] = copy_instance(instance)
  end
end

return WeaponInventory
