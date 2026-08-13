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

return T
