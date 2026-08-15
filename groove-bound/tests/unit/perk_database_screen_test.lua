local H = require("tests.helpers")
local Content = require("src.content.init")
local Defaults = require("src.meta.defaults")
local PerkDatabase = require("src.ui.screens.perk_database")

local T = {}

local function with_dimensions(w, h, fn)
  local previous = _G.love
  _G.love = { graphics = {
    getDimensions = function() return w, h end,
    getWidth = function() return w end,
    getHeight = function() return h end,
  } }
  local ok, err = xpcall(fn, debug.traceback)
  _G.love = previous
  if not ok then error(err, 0) end
end

T["perk catalog reserves one third for the summary panel"] = function()
  with_dimensions(1280, 720, function()
    local screen = PerkDatabase({
      content = Content, slot = Defaults.new_slot(1, "now"), assets = {},
    })
    screen:_layout()
    H.eq(screen.columns, 4)
    H.is_true(screen.detail.w > 360)
    H.is_true(screen.detail.x > screen.grid.x + screen.grid.w)
    H.eq(screen.buttons.buttons[1].y, screen.buttons.buttons[2].y)
  end)
end

return T
