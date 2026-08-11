local H = require("tests.helpers")
local widgets = require("src.ui.widgets.button")

local T = {}

local function grid()
  local buttons = {}
  for row = 0, 1 do
    for column = 0, 1 do
      buttons[#buttons + 1] = widgets.Button({
        label = tostring(#buttons + 1),
        x = column * 180, y = row * 100, w = 140, h = 60,
      })
    end
  end
  return widgets.ButtonList(buttons)
end

T["four-direction focus follows geometry instead of list order"] = function()
  local list = grid()
  H.is_true(list:move_focus_direction("down"))
  H.eq(list.focus_index, 3)
  H.is_true(list:move_focus_direction("right"))
  H.eq(list.focus_index, 4)
  H.is_true(list:move_focus_direction("up"))
  H.eq(list.focus_index, 2)
  H.is_true(list:move_focus_direction("left"))
  H.eq(list.focus_index, 1)
end

T["gamepad dpad uses spatial navigation and A confirms"] = function()
  local presses = 0
  local list = grid()
  list.buttons[3].on_press = function() presses = presses + 1 end
  H.is_true(list:gamepadpressed("dpdown"))
  H.eq(list.focus_index, 3)
  H.is_true(list:gamepadpressed("a"))
  H.eq(presses, 1)
end

return T
