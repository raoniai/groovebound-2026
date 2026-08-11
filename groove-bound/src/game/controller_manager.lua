-- Stable active-controller ownership for polling and vibration. LÖVE can
-- reorder getJoysticks() after hot-plug events, so gameplay must not bind to
-- whichever device happens to occupy index one on a given frame.

local class = require("src.core.class")

local ControllerManager = class()

local function available(joystick)
  if not joystick then return false end
  if joystick.isConnected and joystick:isConnected() == false then return false end
  if joystick.isGamepad and joystick:isGamepad() == false then return false end
  return true
end

function ControllerManager:init(opts)
  opts = opts or {}
  self.get_joysticks = opts.get_joysticks or function()
    if not love or not love.joystick then return {} end
    return love.joystick.getJoysticks()
  end
  self.active = nil
end

function ControllerManager:_present(joysticks, target)
  for _, joystick in ipairs(joysticks) do
    if joystick == target and available(joystick) then return true end
  end
  return false
end

function ControllerManager:current()
  local joysticks = self.get_joysticks() or {}
  if self.active and self:_present(joysticks, self.active) then
    return self.active
  end
  self.active = nil
  for _, joystick in ipairs(joysticks) do
    if available(joystick) then
      self.active = joystick
      break
    end
  end
  return self.active
end

function ControllerManager:added(joystick)
  if not self.active and available(joystick) then self.active = joystick end
end

function ControllerManager:removed(joystick)
  if self.active == joystick then self.active = nil end
end

function ControllerManager:axis(name)
  local joystick = self:current()
  if not joystick or not joystick.getGamepadAxis then return 0 end
  return joystick:getGamepadAxis(name) or 0
end

function ControllerManager:vibrate(left, right, duration)
  local joystick = self:current()
  if not joystick or not joystick.setVibration then return false end
  local ok = joystick:setVibration(left, right, duration)
  return ok ~= false
end

ControllerManager.shared = ControllerManager()

return ControllerManager
