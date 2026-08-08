-- App-level controller/keyboard event gate. Some controller drivers mirror a
-- D-pad press as a keyboard arrow, while LÖVE also emits the gamepad event.
-- Keep those two device paths from advancing a menu twice.

local InputEventGate = {}
InputEventGate.__index = InputEventGate

function InputEventGate.new(opts)
  return setmetatable({
    clock = opts and opts.clock or os.clock,
    mirror_window = opts and opts.mirror_window or 0.075,
    last = {},
  }, InputEventGate)
end

local keyboard_actions = {
  right = "right", d = "right",
  left = "left", a = "left",
  up = "up", w = "up",
  down = "down", s = "down",
  escape = "pause", p = "pause",
}

local gamepad_actions = {
  dpright = "right",
  dpleft = "left",
  dpup = "up",
  dpdown = "down",
  start = "pause",
  back = "pause",
}

local function logical_action(source, code)
  if source == "keyboard" then return keyboard_actions[code] end
  if source == "gamepad" then return gamepad_actions[code] end
  if source == "joystick" and (code == 7 or code == 10) then return "pause" end
  return nil
end

function InputEventGate:accept(source, code)
  local action = logical_action(source, code)
  if not action then return true end

  local now = self.clock()
  local prior = self.last[action]
  self.last[action] = { source = source, at = now }
  if prior and prior.source ~= source and now - prior.at <= self.mirror_window then
    return false
  end
  return true
end

function InputEventGate:gamepad_button(button)
  if button == "start" or button == "back" then return "pause" end
  return button
end

function InputEventGate:joystick_button(button)
  -- Common SDL/HID indices for the PlayStation Options button. The raw path
  -- is only used as a pause fallback; normal gameplay remains on mappings.
  if button == 7 or button == 10 then return "pause" end
  return button
end

return InputEventGate
