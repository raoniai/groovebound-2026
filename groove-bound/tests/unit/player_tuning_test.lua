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

return T
