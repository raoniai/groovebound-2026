local H = require("tests.helpers")
local StageCompleteScreen = require("src.ui.screens.stage_complete")

local T = {}

local function fresh(outcome)
  local result
  local app = {
    profile = { options = { reduced_motion = false } },
    states = { pop = function(_, value) result = value end },
  }
  local screen = StageCompleteScreen(app, {
    outcome = outcome or "stage_clear",
    stage_index = outcome == "victory" and 2 or 1,
    stage_name = outcome == "victory" and "THE ORBIT LINE" or "BACKBEAT STREETS",
    stats = { kills = 120, bosses = 1 },
  })
  return screen, function() return result end
end

T["stage completion requires a deliberate confirmation after its entrance"] = function()
  local screen, result = fresh("stage_clear")
  H.is_false(screen:keypressed("return"))
  H.is_nil(result())
  screen:update(0.9)
  H.is_true(screen:keypressed("return"))
  H.eq(result().kind, "stage_complete")
  H.eq(result().outcome, "stage_clear")
end

T["campaign completion uses the same confirmation gate"] = function()
  local screen, result = fresh("victory")
  screen:update(1)
  H.is_true(screen:gamepadpressed(nil, "a"))
  H.eq(result().outcome, "victory")
end

return T
