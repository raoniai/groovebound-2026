local H = require("tests.helpers")
local Defaults = require("src.meta.defaults")
local TitleScreen = require("src.ui.screens.title")

local T = {}

local function with_dimensions(fn)
  local previous = _G.love
  _G.love = {
    graphics = {
      getDimensions = function() return 1280, 720 end,
      getWidth = function() return 1280 end,
      getHeight = function() return 720 end,
    },
  }
  local ok, error_message = xpcall(fn, debug.traceback)
  _G.love = previous
  if not ok then error(error_message, 0) end
end

T["active campaign promotes Continue Campaign to the first primary action"] = function()
  with_dimensions(function()
    local slot = Defaults.new_slot(1, "now")
    slot.journey.state = "in_progress"
    local screen = TitleScreen({ slot = slot })
    screen:_layout()
    H.eq(#screen.button_list.buttons, 8)
    H.eq(screen.button_list.buttons[1].label, "CONTINUE CAMPAIGN")
    H.eq(screen.button_list.buttons[1].variant, "primary")
    H.eq(screen.button_list.buttons[2].label, "REPLAY PROLOGUE")
    H.eq(screen.button_list.buttons[3].label, "NEW GAME")
    H.eq(screen.button_list.buttons[4].label, "WORLD TOUR")
    H.eq(screen.button_list.buttons[5].label, "PERK CATALOG")
    H.eq(screen.button_list.buttons[8].label, "RESET CAMPAIGN")
    H.eq(screen.button_list.buttons[8].variant, "danger")
    H.eq(#screen.dividers, 2)
    H.eq(screen.button_list.focus_index, 1)
  end)
end

T["empty campaign keeps Start New Game as the main action"] = function()
  with_dimensions(function()
    local screen = TitleScreen({ slot = nil })
    screen:_layout()
    H.eq(#screen.button_list.buttons, 5)
    H.eq(screen.button_list.buttons[1].label, "START NEW GAME")
    H.eq(screen.button_list.buttons[2].label, "WORLD TOUR CATALOG")
    H.eq(screen.button_list.buttons[3].label, "PERK CATALOG")
    H.eq(#screen.dividers, 1)
  end)
end

return T
