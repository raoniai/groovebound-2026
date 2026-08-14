local H = require("tests.helpers")
local GlobalAudioControl = require("src.ui.global_audio_control")

local T = {}

local function control_for(kind)
  local screen = { kind = kind }
  return GlobalAudioControl.new({
    states = { top = function() return screen end },
  })
end

T["global mute stays off live run overlays and remains on cutscenes and menus"] = function()
  for _, kind in ipairs({ "run", "pause", "level_up", "chest_reward", "stage_complete" }) do
    H.is_false(control_for(kind):is_visible())
  end
  for _, kind in ipairs({ "cutscene", "title", "world_tour", "results", "options" }) do
    H.is_true(control_for(kind):is_visible())
  end
end

T["global mute is compact and anchored to the lower left"] = function()
  local previous = _G.love
  _G.love = { graphics = { getDimensions = function() return 1280, 720 end } }
  local rect = control_for("title"):_rect()
  _G.love = previous
  H.eq(rect.x, 12)
  H.eq(rect.w, 36)
  H.eq(rect.h, 36)
  H.eq(rect.y, 672)
end

return T
