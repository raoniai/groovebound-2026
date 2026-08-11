local H = require("tests.helpers")
local ControllerManager = require("src.game.controller_manager")

local T = {}

local function stick(opts)
  opts = opts or {}
  local joystick = {
    connected = opts.connected ~= false,
    gamepad = opts.gamepad ~= false,
    axes = opts.axes or {},
    vibrations = {},
  }
  function joystick:isConnected() return self.connected end
  function joystick:isGamepad() return self.gamepad end
  function joystick:getGamepadAxis(name) return self.axes[name] or 0 end
  function joystick:setVibration(left, right, duration)
    self.vibrations[#self.vibrations + 1] = { left, right, duration }
    return true
  end
  return joystick
end

T["active controller remains stable when list order changes"] = function()
  local first = stick({ axes = { rightx = 0.75 } })
  local second = stick({ axes = { rightx = -0.4 } })
  local devices = { first, second }
  local manager = ControllerManager({ get_joysticks = function() return devices end })
  H.eq(manager:axis("rightx"), 0.75)
  devices = { second, first }
  H.eq(manager:axis("rightx"), 0.75)
end

T["disconnect selects the next connected gamepad"] = function()
  local first = stick({ axes = { leftx = 1 } })
  local second = stick({ axes = { leftx = -1 } })
  local devices = { first, second }
  local manager = ControllerManager({ get_joysticks = function() return devices end })
  H.eq(manager:axis("leftx"), 1)
  first.connected = false
  H.eq(manager:axis("leftx"), -1)
end

T["non-gamepad devices are ignored"] = function()
  local generic = stick({ gamepad = false, axes = { leftx = 1 } })
  local gamepad = stick({ axes = { leftx = 0.5 } })
  local manager = ControllerManager({
    get_joysticks = function() return { generic, gamepad } end,
  })
  H.eq(manager:axis("leftx"), 0.5)
end

T["hot-plugged controller becomes active and receives vibration"] = function()
  local devices = {}
  local gamepad = stick()
  local manager = ControllerManager({ get_joysticks = function() return devices end })
  H.eq(manager:axis("rightx"), 0)
  devices = { gamepad }
  manager:added(gamepad)
  H.is_true(manager:vibrate(0.2, 0.6, 0.1))
  H.eq(#gamepad.vibrations, 1)
  H.near(gamepad.vibrations[1][2], 0.6)
end

return T
