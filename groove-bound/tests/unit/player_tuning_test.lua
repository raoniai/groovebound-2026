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

return T
