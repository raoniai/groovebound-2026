local H = require("tests.helpers")
local Tuning = require("src.debug.tuning")
local definitions = require("src.config.admin_controls")

local T = {}

local function fresh()
  return Tuning(definitions)
end

T["all admin controls have stable unique ids and valid defaults"] = function()
  local tuning = fresh()
  local seen = {}
  for _, definition in ipairs(tuning:list()) do
    H.is_false(seen[definition.id] == true, "duplicate id")
    seen[definition.id] = true
    H.eq(tuning:get(definition.id), definition.default)
  end
end

T["numeric controls clamp to declared bounds"] = function()
  local tuning = fresh()
  H.eq(tuning:set("simulation.time_scale", -100), 0.1)
  H.eq(tuning:set("simulation.time_scale", 100), 3.0)
  H.eq(tuning:set("projectiles.max_active", 99999), 3000)
end

T["numeric controls snap to their declared step"] = function()
  local tuning = fresh()
  H.near(tuning:set("player.speed_multiplier", 1.073), 1.05)
  H.eq(tuning:set("projectiles.max_active", 562), 550)
end

T["adjust changes numbers and toggles booleans"] = function()
  local tuning = fresh()
  H.near(tuning:adjust("combat.fire_rate_multiplier", 1), 1.1)
  H.near(tuning:adjust("combat.fire_rate_multiplier", -1), 1.0)
  H.is_true(tuning:adjust("player.invincible", 1))
  H.is_false(tuning:adjust("player.invincible", -1))
  H.is_false(tuning:adjust("ui.show_evolution_requirements", -1))
  H.is_true(tuning:adjust("ui.show_evolution_requirements", 1))
end

T["reset selected and reset all restore safe defaults"] = function()
  local tuning = fresh()
  tuning:set("combat.damage_multiplier", 8)
  tuning:set("projectiles.per_shot_bonus", 9)
  tuning:reset("combat.damage_multiplier")
  H.eq(tuning:get("combat.damage_multiplier"), 1)
  tuning:reset_all()
  H.eq(tuning:get("projectiles.per_shot_bonus"), 0)
end

T["snapshot is detached from live values"] = function()
  local tuning = fresh()
  local snapshot = tuning:snapshot()
  snapshot["simulation.time_scale"] = 2
  H.eq(tuning:get("simulation.time_scale"), 1)
end

T["unknown controls fail loudly"] = function()
  local tuning = fresh()
  H.errors(function() tuning:get("projectiles.typo") end)
  H.errors(function() tuning:set("projectiles.typo", 1) end)
end

T["formatting distinguishes track BPM and boolean values"] = function()
  local tuning = fresh()
  H.eq(tuning:format("beat.bpm_override"), "TRACK")
  H.eq(tuning:format("player.invincible"), "OFF")
  tuning:set("beat.bpm_override", 120)
  H.eq(tuning:format("beat.bpm_override"), "120")
end

return T
