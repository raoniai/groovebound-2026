-- Fail-loud content validation, run once at boot.
--
-- Every content table is checked against a declarative schema: required
-- fields, types, numeric ranges, and cross-file ID references. A typo'd
-- enemy id in a wave is a boot error with a precise message, never a silent
-- fallback to some default enemy.
--
--   local errors = Validate.check(content)  -- content = {weapons=..., enemies=..., ...}
--   Validate.assert_valid(content)          -- error()s listing every problem

local Validate = {}

-- ------------------------------------------------------------ field checks

local function check_field(errors, where, value, spec)
  if value == nil then
    if not spec.optional then
      errors[#errors + 1] = where .. ": missing required field"
    end
    return
  end

  if spec.type and type(value) ~= spec.type then
    errors[#errors + 1] = string.format(
      "%s: expected %s, got %s", where, spec.type, type(value))
    return
  end

  if spec.min and value < spec.min then
    errors[#errors + 1] = string.format("%s: %s is below minimum %s", where, value, spec.min)
  end
  if spec.max and value > spec.max then
    errors[#errors + 1] = string.format("%s: %s is above maximum %s", where, value, spec.max)
  end
  if spec.one_of then
    local ok = false
    for _, allowed in ipairs(spec.one_of) do
      if value == allowed then ok = true break end
    end
    if not ok then
      errors[#errors + 1] = string.format(
        "%s: %q is not one of {%s}", where, tostring(value), table.concat(spec.one_of, ", "))
    end
  end
end

-- ------------------------------------------------------------ schemas

-- Field specs per content kind. `ref` marks a field whose value must be a key
-- in another content table (checked in a second pass).
local schemas = {
  weapons = {
    name        = { type = "string" },
    description = { type = "string" },
    archetype   = { type = "string", one_of = { "projectile", "aoe_pulse", "orbital", "spread" } },
    max_level   = { type = "number", min = 1, max = 10 },
    levels      = { type = "table" },
  },
  enemies = {
    name   = { type = "string" },
    hp     = { type = "number", min = 1 },
    speed  = { type = "number", min = 0 },
    size   = { type = "number", min = 1 },
    damage = { type = "number", min = 0 },
    xp     = { type = "number", min = 0 },
    coins  = { type = "number", min = 0, optional = true },
    brain  = { type = "string", one_of = { "chase", "zigzag", "charger", "static" } },
  },
  passives = {
    name        = { type = "string" },
    description = { type = "string" },
    stat        = {
      type = "string",
      one_of = { "speed", "max_hp", "damage", "magnet", "luck", "cooldown_stability" },
    },
    max_level   = { type = "number", min = 1 },
    per_level   = { type = "number" },
  },
  evolutions = {
    name                  = { type = "string" },
    base_weapon           = { type = "string", ref = "weapons" },
    result_weapon         = { type = "string", ref = "weapons" },
    branch                = { type = "string", one_of = { "studio", "live" } },
    required_weapon_level = { type = "number", min = 1, max = 10 },
    required_passives     = { type = "table" },
    trigger               = {
      type = "string",
      one_of = { "resolve_reward", "boss_chest", "level_up", "admin" },
    },
    consume_passives      = { type = "boolean", optional = true },
  },
  characters = {
    name           = { type = "string" },
    starting_weapon = { type = "string", ref = "weapons" },
    speed_mult     = { type = "number", min = 0.1, optional = true },
    hp_mult        = { type = "number", min = 0.1, optional = true },
  },
  waves = {}, -- validated structurally below (timeline entries, not id-keyed)
}

-- ------------------------------------------------------------ validation

local function check_id_table(errors, kind, tbl, content)
  local schema = schemas[kind]
  for id, entry in pairs(tbl) do
    local where_base = kind .. "." .. tostring(id)

    if type(entry) ~= "table" then
      errors[#errors + 1] = where_base .. ": entry must be a table"
    else
      if entry.id ~= id then
        errors[#errors + 1] = string.format(
          "%s: id field %q must equal its table key", where_base, tostring(entry.id))
      end

      for field, spec in pairs(schema) do
        local where = where_base .. "." .. field
        check_field(errors, where, entry[field], spec)
        -- Cross-reference check.
        if spec.ref and entry[field] ~= nil and content[spec.ref] then
          if content[spec.ref][entry[field]] == nil then
            errors[#errors + 1] = string.format(
              "%s: references unknown %s id %q", where, spec.ref, tostring(entry[field]))
          end
        end
      end

      -- Weapon-specific: levels array must match max_level and carry damage/cooldown.
      if kind == "weapons" and type(entry.levels) == "table" then
        if entry.max_level and #entry.levels ~= entry.max_level then
          errors[#errors + 1] = string.format(
            "%s.levels: has %d rows but max_level is %d", where_base, #entry.levels, entry.max_level)
        end
        for i, row in ipairs(entry.levels) do
          local lw = string.format("%s.levels[%d]", where_base, i)
          check_field(errors, lw .. ".damage", row.damage, { type = "number", min = 0 })
          check_field(errors, lw .. ".cooldown", row.cooldown, { type = "number", min = 0.01 })
        end
      elseif kind == "evolutions" then
        if entry.base_weapon == entry.result_weapon and entry.base_weapon ~= nil then
          errors[#errors + 1] = where_base .. ": base and result weapons must differ"
        end

        local base = content.weapons and content.weapons[entry.base_weapon]
        if base
          and type(entry.required_weapon_level) == "number"
          and entry.required_weapon_level > base.max_level
        then
          errors[#errors + 1] = string.format(
            "%s.required_weapon_level: %d exceeds %s max level %d",
            where_base,
            entry.required_weapon_level,
            entry.base_weapon,
            base.max_level)
        end

        if type(entry.required_passives) == "table" then
          local seen = {}
          for i, requirement in ipairs(entry.required_passives) do
            local rw = string.format("%s.required_passives[%d]", where_base, i)
            check_field(errors, rw .. ".id", requirement.id, { type = "string" })
            check_field(errors, rw .. ".min_level", requirement.min_level, {
              type = "number",
              min = 1,
            })
            if requirement.id then
              if seen[requirement.id] then
                errors[#errors + 1] = rw .. ".id: duplicate passive requirement"
              end
              seen[requirement.id] = true
              local passive = content.passives and content.passives[requirement.id]
              if not passive then
                errors[#errors + 1] = string.format(
                  "%s.id: references unknown passive id %q",
                  rw,
                  tostring(requirement.id))
              elseif type(requirement.min_level) == "number"
                and requirement.min_level > passive.max_level
              then
                errors[#errors + 1] = string.format(
                  "%s.min_level: %d exceeds %s max level %d",
                  rw,
                  requirement.min_level,
                  requirement.id,
                  passive.max_level)
              end
            end
          end
        end
      end
    end
  end
end

local function check_waves(errors, waves, content)
  local last_at = -1
  for i, wave in ipairs(waves) do
    local where = string.format("waves[%d]", i)
    check_field(errors, where .. ".at", wave.at, { type = "number", min = 0 })

    if type(wave.at) == "number" then
      if wave.at < last_at then
        errors[#errors + 1] = where .. ".at: timeline must be in ascending order"
      end
      last_at = wave.at
    end

    if type(wave.enemies) ~= "table" or #wave.enemies == 0 then
      errors[#errors + 1] = where .. ".enemies: must be a non-empty array"
    else
      for j, spawn in ipairs(wave.enemies) do
        local sw = string.format("%s.enemies[%d]", where, j)
        check_field(errors, sw .. ".id", spawn.id, { type = "string" })
        check_field(errors, sw .. ".count", spawn.count, { type = "number", min = 1 })
        check_field(errors, sw .. ".cadence", spawn.cadence, { type = "number", min = 0.01 })
        if spawn.id and content.enemies and content.enemies[spawn.id] == nil then
          errors[#errors + 1] = string.format(
            "%s.id: references unknown enemy id %q", sw, tostring(spawn.id))
        end
      end
    end
  end
end

-- Check a full content bundle. Returns an array of error strings (empty = valid).
function Validate.check(content)
  local errors = {}
  for kind in pairs(schemas) do
    local tbl = content[kind]
    if tbl == nil then
      errors[#errors + 1] = "content." .. kind .. ": table is missing"
    elseif kind == "waves" then
      check_waves(errors, tbl, content)
    else
      check_id_table(errors, kind, tbl, content)
    end
  end
  return errors
end

function Validate.assert_valid(content)
  local errors = Validate.check(content)
  if #errors > 0 then
    error("content validation failed:\n  " .. table.concat(errors, "\n  "), 2)
  end
  return content
end

return Validate
