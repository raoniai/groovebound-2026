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
    attack_family = {
      type = "string",
      one_of = {
        "linear", "boomerang", "lobbed_bomb", "area_effect",
        "orbital", "beam", "storm", "wave", "deployable",
      },
    },
    visual_id   = { type = "string" },
    sprite_path = { type = "string" },
    animation_frames = { type = "number", min = 5 },
    animation_mode = { type = "string", one_of = { "one_shot" } },
    animation_fps = { type = "number", min = 1 },
    coverage = { type = "number", min = 1 },
    effect_radius = { type = "number", min = 1 },
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
    brain  = {
      type = "string",
      one_of = { "chase", "zigzag", "charger", "static", "ranged", "orbit", "pulse" },
    },
  },
  passives = {
    name        = { type = "string" },
    description = { type = "string" },
    stat        = {
      type = "string",
      one_of = {
        "speed", "max_hp", "damage", "magnet", "luck",
        "cooldown_stability", "fire_rate", "amount", "guard",
      },
    },
    max_level   = { type = "number", min = 1 },
    per_level   = { type = "number" },
  },
  evolutions = {
    name                  = { type = "string" },
    base_weapon           = { type = "string", ref = "weapons" },
    result_weapon         = { type = "string", ref = "weapons" },
    branch                = { type = "string", one_of = { "studio", "live", "fusion" } },
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
    title          = { type = "string", optional = true },
    description    = { type = "string", optional = true },
    intro_scene    = { type = "string", optional = true },
    trait_name     = { type = "string", optional = true },
    trait_text     = { type = "string", optional = true },
    stats          = { type = "table", optional = true },
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

local function check_stages(errors, stages, content)
  if type(stages) ~= "table" or #stages < 2 then
    errors[#errors + 1] = "content.stages: expected at least two campaign stages"
    return
  end
  local seen = {}
  for index, stage in ipairs(stages) do
    local where = string.format("stages[%d]", index)
    check_field(errors, where .. ".id", stage.id, { type = "string" })
    check_field(errors, where .. ".name", stage.name, { type = "string" })
    check_field(errors, where .. ".base_duration", stage.base_duration, {
      type = "number", min = 10,
    })
    check_field(errors, where .. ".wave_base_duration", stage.wave_base_duration, {
      type = "number", min = 10,
    })
    check_field(errors, where .. ".duration_tuning", stage.duration_tuning, {
      type = "string",
    })
    if stage.id then
      if seen[stage.id] then errors[#errors + 1] = where .. ".id: duplicate stage id" end
      seen[stage.id] = true
    end
    if not content.enemies[stage.final_boss] then
      errors[#errors + 1] = where .. ".final_boss: unknown enemy id"
    end
    check_waves(errors, stage.waves or {}, content)
  end
end

local function check_world_stages(errors, stage_catalog, content)
  if type(stage_catalog) ~= "table" then
    errors[#errors + 1] = "content.world_stages: table is missing"
    return
  end
  local seen = {}
  for world_id, stages in pairs(stage_catalog) do
    local world_where = "world_stages." .. tostring(world_id)
    if not content.world_tour or not content.world_tour[world_id] then
      errors[#errors + 1] = world_where .. ": unknown World Tour id"
    end
    if type(stages) ~= "table" or #stages == 0 then
      errors[#errors + 1] = world_where .. ": expected a non-empty stage array"
    else
      for index, stage in ipairs(stages) do
        local where = string.format("%s[%d]", world_where, index)
        check_field(errors, where .. ".id", stage.id, { type = "string" })
        check_field(errors, where .. ".world_id", stage.world_id, {
          type = "string",
        })
        check_field(errors, where .. ".name", stage.name, { type = "string" })
        check_field(errors, where .. ".base_duration", stage.base_duration, {
          type = "number", min = 10,
        })
        check_field(
          errors, where .. ".wave_base_duration", stage.wave_base_duration,
          { type = "number", min = 10 })
        if stage.world_id and stage.world_id ~= world_id then
          errors[#errors + 1] = where .. ".world_id: must match catalog key"
        end
        if stage.id then
          if seen[stage.id] then
            errors[#errors + 1] = where .. ".id: duplicate stage id"
          end
          seen[stage.id] = true
        end
        if not content.enemies[stage.final_boss] then
          errors[#errors + 1] = where .. ".final_boss: unknown enemy id"
        elseif content.enemies[stage.final_boss].boss_type ~= "final" then
          errors[#errors + 1] = where .. ".final_boss: enemy must be final"
        end
        check_waves(errors, stage.waves or {}, content)
        if type(stage.mechanic) ~= "table" then
          errors[#errors + 1] = where .. ".mechanic: table is required"
        else
          check_field(errors, where .. ".mechanic.id", stage.mechanic.id, {
            type = "string",
          })
          check_field(errors, where .. ".mechanic.stage_variant",
            stage.mechanic.stage_variant, { type = "string" })
          check_field(errors, where .. ".mechanic.kind", stage.mechanic.kind, {
            type = "string",
            one_of = { "timed_zone", "relay", "charge", "call_response",
              "flow", "prism_relay", "phrase", "changes" },
          })
          check_field(errors, where .. ".mechanic.encore_threshold",
            stage.mechanic.encore_threshold, { type = "number", min = 2, max = 8 })
          check_field(
            errors, where .. ".mechanic.cycle_seconds",
            stage.mechanic.cycle_seconds, { type = "number", min = 0.2 })
          if type(stage.mechanic.pads) ~= "table"
            or #stage.mechanic.pads < 3
          then
            errors[#errors + 1] = where
              .. ".mechanic.pads: expected at least three pads"
          end
          if stage.mechanic.stage_variant ~= stage.id then
            errors[#errors + 1] = where
              .. ".mechanic.stage_variant: must match stage id"
          end
        end
      end
    end
  end
end

local function check_narrative(errors, narrative)
  if type(narrative) ~= "table" then
    errors[#errors + 1] = "content.narrative: table is missing"
    return
  end
  for id, scene in pairs(narrative) do
    local where = "narrative." .. id
    if scene.id ~= id then errors[#errors + 1] = where .. ".id: must match key" end
    if type(scene.slides) ~= "table" or #scene.slides == 0 then
      errors[#errors + 1] = where .. ".slides: must be a non-empty array"
    else
      for index, slide in ipairs(scene.slides) do
        local sw = string.format("%s.slides[%d]", where, index)
        check_field(errors, sw .. ".atlas", slide.atlas, { type = "string" })
        check_field(errors, sw .. ".col", slide.col, { type = "number", min = 1, max = 2 })
        check_field(errors, sw .. ".row", slide.row, { type = "number", min = 1, max = 2 })
        check_field(errors, sw .. ".speaker", slide.speaker, { type = "string" })
        check_field(errors, sw .. ".text", slide.text, { type = "string" })
      end
    end
  end
end

local function check_world_tour(errors, content)
  local catalog = content.world_tour
  if type(catalog) ~= "table" then
    errors[#errors + 1] = "content.world_tour: table is missing"
    return
  end
  local orders = {}
  local count = 0
  for id, world in pairs(catalog) do
    count = count + 1
    local where = "world_tour." .. tostring(id)
    if world.id ~= id then errors[#errors + 1] = where .. ".id: must match key" end
    check_field(errors, where .. ".order", world.order, { type = "number", min = 1, max = 9 })
    check_field(errors, where .. ".type", world.type, { type = "string", one_of = { "core", "secret" } })
    check_field(errors, where .. ".name", world.name, { type = "string" })
    check_field(errors, where .. ".genre", world.genre, { type = "string" })
    check_field(errors, where .. ".duration_seconds", world.duration_seconds, { type = "number", min = 480, max = 720 })
    check_field(errors, where .. ".grade_profile", world.grade_profile, { type = "string" })
    check_field(errors, where .. ".mastery_id", world.mastery_id, { type = "string" })
    if world.order then
      if orders[world.order] then errors[#errors + 1] = where .. ".order: duplicate order" end
      orders[world.order] = true
    end
    if content.grade_profiles and content.grade_profiles.profiles
      and not content.grade_profiles.profiles[world.grade_profile]
    then
      errors[#errors + 1] = where .. ".grade_profile: unknown profile"
    end
    for _, grade in ipairs({ "C", "B", "A", "S" }) do
      local claim = world.rewards and world.rewards[grade]
      if not claim or not content.meta_rewards or not content.meta_rewards[claim] then
        errors[#errors + 1] = where .. ".rewards." .. grade .. ": unknown claim"
      end
    end
    if world.first_clear_unlock and not catalog[world.first_clear_unlock] then
      errors[#errors + 1] = where .. ".first_clear_unlock: unknown world"
    end
    if world.type == "secret" then
      if type(world.parents) ~= "table" or #world.parents ~= 2 then
        errors[#errors + 1] = where .. ".parents: secret worlds require two parents"
      else
        for index, parent in ipairs(world.parents) do
          if not catalog[parent] then
            errors[#errors + 1] = string.format("%s.parents[%d]: unknown world", where, index)
          end
        end
      end
    end
  end
  if count ~= 9 then errors[#errors + 1] = "content.world_tour: expected exactly nine worlds" end

  for id, waves in pairs(content.world_tour_waves or {}) do
    if not catalog[id] then
      errors[#errors + 1] = "world_tour_waves." .. tostring(id) .. ": unknown world"
    else
      check_waves(errors, waves, content)
    end
  end
end

local function check_grade_profiles(errors, grade_profiles)
  if type(grade_profiles) ~= "table" or type(grade_profiles.profiles) ~= "table" then
    errors[#errors + 1] = "content.grade_profiles: table is missing"
    return
  end
  for id, profile in pairs(grade_profiles.profiles) do
    local total = 0
    for _, pillar in ipairs({ "groove", "impact", "control", "craft", "world_mastery" }) do
      check_field(errors, "grade_profiles." .. id .. "." .. pillar,
        profile[pillar], { type = "number", min = 0, max = 100 })
      total = total + (tonumber(profile[pillar]) or 0)
    end
    if total ~= 100 then
      errors[#errors + 1] = "grade_profiles." .. id .. ": weights must sum to 100"
    end
  end
end

local function check_meta_perks(errors, content)
  local perks = content.meta_perks
  if type(perks) ~= "table" then
    errors[#errors + 1] = "content.meta_perks: table is missing"
    return
  end
  local count = 0
  for id, perk in pairs(perks) do
    count = count + 1
    local where = "meta_perks." .. tostring(id)
    if perk.id ~= id then errors[#errors + 1] = where .. ".id: must match key" end
    check_field(errors, where .. ".name", perk.name, { type = "string" })
    check_field(errors, where .. ".max_rank", perk.max_rank, { type = "number", min = 1, max = 5 })
    check_field(errors, where .. ".balance_revision", perk.balance_revision, { type = "number", min = 1 })
    if type(perk.source) ~= "table" then
      errors[#errors + 1] = where .. ".source: table is required"
    elseif perk.source.type == "world_grade"
      and (not content.world_tour or not content.world_tour[perk.source.world_id])
    then
      errors[#errors + 1] = where .. ".source.world_id: unknown world"
    end
    for rank = 2, perk.max_rank or 1 do
      if not perk.prices or type(perk.prices[rank]) ~= "number" then
        errors[#errors + 1] = string.format("%s.prices[%d]: price is required", where, rank)
      end
    end
    if type(perk.modifiers) ~= "table" or #perk.modifiers == 0 then
      errors[#errors + 1] = where .. ".modifiers: non-empty array is required"
    end
  end
  if count ~= 19 then errors[#errors + 1] = "content.meta_perks: expected exactly nineteen perks" end
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
  if content.stages ~= nil then check_stages(errors, content.stages, content) end
  if content.narrative ~= nil then check_narrative(errors, content.narrative) end
  local has_world_tour_catalog = content.world_tour ~= nil
    or content.meta_perks ~= nil or content.meta_rewards ~= nil
    or content.grade_profiles ~= nil or content.remix_tiers ~= nil
  if has_world_tour_catalog then
    check_grade_profiles(errors, content.grade_profiles)
    check_world_tour(errors, content)
    check_meta_perks(errors, content)
    check_world_stages(errors, content.world_stages, content)
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
