local H = require("tests.helpers")
local CursorPolicy = require("src.ui.cursor_policy")

local T = {}

T["system cursor is hidden only during active gameplay"] = function()
  H.is_false(CursorPolicy.visible_for({ kind = "run" }))
  H.is_true(CursorPolicy.visible_for({ kind = "pause" }))
  H.is_true(CursorPolicy.visible_for({ kind = "level_up" }))
  H.is_true(CursorPolicy.visible_for({ kind = "cutscene" }))
  H.is_true(CursorPolicy.visible_for(nil))
end

return T
