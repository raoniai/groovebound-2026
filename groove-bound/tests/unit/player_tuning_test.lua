local H = require("tests.helpers")
local Player = require("src.game.entities.player")
local Tuning = require("src.debug.tuning")
local definitions = require("src.config.admin_controls")

local T = {}

T["admin player speed multiplier is consumed by movement"] = function()
  local tuning = Tuning(definitions)
  tuning:set("player.speed_multiplier", 2)
  local player = Player({ x = 0, y = 0, tuning = tuning })
  local input = {
    move_vector = function() return 1, 0 end,
    aim_vector = function() return 1, 0 end,
  }
  local arena = {
    clamp = function(_, x, y) return x, y end,
  }
  player:update(0.5, input, nil, arena)
  H.eq(player.speed, player.base_speed * 2)
  H.eq(player.x, player.base_speed)
end

T["five-times test mode multiplies player movement speed"] = function()
  local tuning = Tuning(definitions)
  tuning:set("test.enhanced_mode", true)
  local player = Player({ x = 0, y = 0, tuning = tuning })
  local input = {
    move_vector = function() return 1, 0 end,
    aim_vector = function() return 1, 0 end,
  }
  local arena = { clamp = function(_, x, y) return x, y end }

  player:update(0.2, input, nil, arena)
  H.eq(player.speed, player.base_speed * 5)
  H.eq(player.x, player.base_speed)
end

T["character stats and movement speed select idle walk run and hurt states"] = function()
  local tuning = Tuning(definitions)
  local character = require("src.content.characters").lyra
  local player = Player({
    x = 100, y = 100, tuning = tuning, character = character,
  })
  local moving = true
  local input = {
    move_vector = function() return moving and 1 or 0, 0 end,
    aim_vector = function() return 1, 0 end,
  }
  local arena = { clamp = function(_, x, y) return x, y end }

  moving = false
  player:update(0.1, input, nil, arena)
  H.eq(player.animation_state, "idle")

  moving = true
  player:update(0.1, input, nil, arena)
  H.eq(player.animation_state, "walk")

  tuning:set("player.speed_multiplier", 1.5)
  player:update(0.1, input, nil, arena)
  H.eq(player.animation_state, "run")

  H.is_true(player:take_damage(10, -1, 0, 120))
  player:update(0.01, input, nil, arena)
  H.eq(player.animation_state, "hurt")
  H.is_true(player.knockback_x < 0)
  H.is_true(player.max_hp < 100)
end

T["run animation cycles through four distinct locomotion poses"] = function()
  local tuning = Tuning(definitions)
  tuning:set("player.speed_multiplier", 1.5)
  local player = Player({ x = 0, y = 0, tuning = tuning })
  local input = {
    move_vector = function() return 1, 0 end,
    aim_vector = function() return 1, 0 end,
  }
  local arena = { clamp = function(_, x, y) return x, y end }

  player:update(0, input, nil, arena)
  H.eq(player.anim_frame, 3)
  player:update(0.1, input, nil, arena)
  H.eq(player.anim_frame, 5)
  player:update(0.1, input, nil, arena)
  H.eq(player.anim_frame, 4)
end

T["idle remains on one still frame regardless of elapsed time"] = function()
  local tuning = Tuning(definitions)
  local player = Player({ x = 0, y = 0, tuning = tuning })
  local input = {
    move_vector = function() return 0, 0 end,
    aim_vector = function() return 1, 0 end,
  }
  local arena = { clamp = function(_, x, y) return x, y end }

  player:update(0.1, input, nil, arena)
  H.eq(player.anim_frame, 1)
  player:update(4.7, input, nil, arena)
  H.eq(player.anim_frame, 1)
end

T["health concern and critical states use strict twenty and five percent boundaries"] = function()
  local player = Player({ x = 0, y = 0, tuning = Tuning(definitions) })
  player.hp = player.max_hp * 0.20
  H.eq(player:health_state(), "normal")
  player.hp = player.max_hp * 0.199
  H.eq(player:health_state(), "concern")
  player.hp = player.max_hp * 0.05
  H.eq(player:health_state(), "concern")
  player.hp = player.max_hp * 0.049
  H.eq(player:health_state(), "critical")
end

T["taking damage records a visible hit pulse and exact health loss"] = function()
  local player = Player({ x = 0, y = 0, tuning = Tuning(definitions) })
  local before = player.hp
  H.is_true(player:take_damage(13, -1, 0, 180))
  H.near(player.hp, before - 13)
  H.near(player.last_damage, 13)
  H.is_true(player.hit_pulse > 0)
  H.is_true(player.knockback_x < 0)
end

T["health regenerates at 0.02 percent per second only after five hit-free seconds"] = function()
  local tuning = Tuning(definitions)
  local player = Player({ x = 0, y = 0, tuning = tuning })
  local input = {
    move_vector = function() return 1, 0 end,
    aim_vector = function() return 1, 0 end,
  }
  local arena = { clamp = function(_, x, y) return x, y end }
  H.is_true(player:take_damage(20))
  local damaged = player.hp
  player:update(5, input, nil, arena)
  H.near(player.hp, damaged)
  player:update(1, input, nil, arena)
  H.near(player.hp, damaged + player.max_hp * 0.0002, 1e-8)
end

T["temporary speed and defense multipliers affect movement and incoming damage"] = function()
  local tuning = Tuning(definitions)
  local player = Player({ x = 0, y = 0, tuning = tuning })
  player.temporary_speed_multiplier = 1.35
  player.temporary_defense_multiplier = 1.5
  local input = {
    move_vector = function() return 1, 0 end,
    aim_vector = function() return 1, 0 end,
  }
  local arena = { clamp = function(_, x, y) return x, y end }
  player:update(1, input, nil, arena)
  H.near(player.x, player.base_speed * 1.35)
  local hp = player.hp
  H.is_true(player:take_damage(15))
  H.near(player.hp, hp - 10)
end

return T
