local H = require("tests.helpers")
local InputEventGate = require("src.game.input_event_gate")

local T = {}

T["one D-pad press cannot navigate again through its mirrored arrow key"] = function()
  local now = 10
  local gate = InputEventGate.new({ clock = function() return now end })
  H.is_true(gate:accept("gamepad", "dpright"))
  now = 10.01
  H.is_false(gate:accept("keyboard", "right"))
end

T["mirrored events are deduplicated regardless of which device arrives first"] = function()
  local now = 20
  local gate = InputEventGate.new({ clock = function() return now end })
  H.is_true(gate:accept("keyboard", "down"))
  now = 20.01
  H.is_false(gate:accept("gamepad", "dpdown"))
  now = 20.20
  H.is_true(gate:accept("gamepad", "dpdown"))
end

T["PlayStation Options normalizes to pause through standard and raw events"] = function()
  local gate = InputEventGate.new()
  H.eq(gate:gamepad_button("start"), "pause")
  H.eq(gate:gamepad_button("back"), "pause")
  H.eq(gate:joystick_button(7), "pause")
  H.eq(gate:joystick_button(10), "pause")
end

return T
