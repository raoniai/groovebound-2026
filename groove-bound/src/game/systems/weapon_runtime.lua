-- Active weapon emitters, indexed by the authoritative inventory slot.
--
-- An emitter is the exact weapon/level currently firing. Evolution replaces
-- the emitter in the same slot. Projectile creation snapshots stats so
-- projectiles already in flight are not retroactively mutated.

local class = require("src.core.class")
local TestMode = require("src.game.test_mode")

local WeaponRuntime = class()

local function copy_table(source)
  local result = {}
  for key, value in pairs(source or {}) do result[key] = value end
  return result
end

function WeaponRuntime:init(content, tuning, opts)
  opts = opts or {}
  assert(content and content.weapons, "weapon content is required")
  self.content = content
  self.tuning = tuning
  self.character = opts.character or { stats = {} }
  self.passives = {}
  self.emitters = {}
  self.inventory_revision = -1
  self.temporary_damage_multiplier = 1
end

function WeaponRuntime:set_temporary_damage_multiplier(multiplier)
  self.temporary_damage_multiplier = multiplier or 1
end

function WeaponRuntime:set_passives(levels)
  self.passives = levels or {}
end

function WeaponRuntime:_value(id, fallback)
  if not self.tuning then return fallback end
  return self.tuning:get(id)
end

function WeaponRuntime:_passive_bonus(stat)
  local total = 0
  for id, level in pairs(self.passives) do
    local definition = self.content.passives and self.content.passives[id]
    if definition and definition.stat == stat then
      total = total + level * definition.per_level
    end
  end
  return total
end

function WeaponRuntime:_build_emitter(slot, instance, previous)
  local definition = assert(self.content.weapons[instance.id], "unknown weapon: " .. instance.id)
  local stats = assert(definition.levels[instance.level], "missing weapon level stats")
  local fire_rate = self:_value("combat.fire_rate_multiplier", 1)
  local tempo = (self.character.stats or {}).tempo or 1
  local stability = self:_passive_bonus("cooldown_stability")
  local overdrive = self:_passive_bonus("fire_rate")
  local cooldown = stats.cooldown
    * (1 - math.min(0.30, stability))
    / (fire_rate * tempo * (1 + overdrive))
  local cooldown_remaining = 0

  if previous and previous.cooldown > 0 then
    local remaining_ratio = math.max(0, math.min(1, previous.cooldown_remaining / previous.cooldown))
    cooldown_remaining = cooldown * remaining_ratio
  end

  return {
    slot = slot,
    weapon_id = instance.id,
    level = instance.level,
    cooldown = cooldown,
    cooldown_remaining = cooldown_remaining,
  }
end

function WeaponRuntime:sync(inventory)
  local next_emitters = {}
  for slot, instance in ipairs(inventory.slots) do
    next_emitters[slot] = self:_build_emitter(slot, instance, self.emitters[slot])
  end
  self.emitters = next_emitters
  self.inventory_revision = inventory.revision
  return self
end

function WeaponRuntime:replace_weapon(slot, instance, inventory_revision)
  self.emitters[slot] = self:_build_emitter(slot, instance, self.emitters[slot])
  self.inventory_revision = inventory_revision
  return self.emitters[slot]
end

function WeaponRuntime:get(slot)
  return self.emitters[slot]
end

function WeaponRuntime:assert_consistent(inventory)
  assert(#self.emitters == #inventory.slots, "weapon runtime slot count does not match inventory")
  for slot, instance in ipairs(inventory.slots) do
    local emitter = self.emitters[slot]
    assert(emitter, "missing emitter for weapon slot " .. slot)
    assert(emitter.slot == slot, "emitter slot mismatch at " .. slot)
    assert(emitter.weapon_id == instance.id, "emitter weapon mismatch at slot " .. slot)
    assert(emitter.level == instance.level, "emitter level mismatch at slot " .. slot)
  end
  assert(
    self.inventory_revision == inventory.revision,
    "weapon runtime revision does not match inventory")
  return true
end

function WeaponRuntime:projectile_snapshot(slot)
  local emitter = assert(self.emitters[slot], "no active emitter in slot " .. tostring(slot))
  local definition = self.content.weapons[emitter.weapon_id]
  local stats = definition.levels[emitter.level]
  return {
    source_weapon_id = emitter.weapon_id,
    source_weapon_level = emitter.level,
    damage = stats.damage
      * self:_value("combat.damage_multiplier", 1)
      * TestMode.factor(self.tuning)
      * ((self.character.stats or {}).power or 1)
      * (1 + self:_passive_bonus("damage"))
      * self.temporary_damage_multiplier,
    speed = (stats.speed or 0) * self:_value("projectiles.speed_multiplier", 1),
    count = math.max(1,
      (stats.count or 1)
      + self:_value("projectiles.per_shot_bonus", 0)
      + math.floor(self:_passive_bonus("amount"))),
    size = stats.size,
    lifetime = stats.lifetime,
    spread = (stats.spread or 0)
      * (1 - math.min(0.35, (self.passives.breath_control or 0) * 0.06)),
    pierce = stats.pierce or 0,
    knockback = stats.knockback or 8,
    pattern = definition.pattern or "aimed",
    color = definition.projectile_color,
  }
end

function WeaponRuntime:snapshot()
  local result = {
    inventory_revision = self.inventory_revision,
    emitters = {},
  }
  for slot, emitter in ipairs(self.emitters) do
    result.emitters[slot] = copy_table(emitter)
  end
  return result
end

function WeaponRuntime:restore(snapshot)
  self.inventory_revision = snapshot.inventory_revision
  self.emitters = {}
  for slot, emitter in ipairs(snapshot.emitters) do
    self.emitters[slot] = copy_table(emitter)
  end
end

return WeaponRuntime
