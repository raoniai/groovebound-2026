local H = require("tests.helpers")
local Content = require("src.content.init")
local LevelUpScreen = require("src.ui.screens.level_up")

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

T["evolution guide contains only recipes for currently slotted weapons"] = function()
  local screen = setmetatable({
    app = { content = Content },
    combat = {
      progression = {
        evolution_progress = function()
          return {
            { id = "kazoo_studio", base = Content.weapons.kazoo_pistol,
              support = Content.passives.breath_control,
              result = Content.weapons.brass_barrage },
          }
        end,
      },
    },
  }, LevelUpScreen)
  local records = screen:evolution_records()
  H.eq(#records, 1)
  H.eq(records[1].base.id, "kazoo_pistol")
  H.eq(records[1].result.id, "brass_barrage")
end

T["level-up dpad moves down to CTAs and across the CTA row"] = function()
  with_dimensions(1280, 720, function()
    local screen = setmetatable({
      offer = { {}, {}, {} },
      combat = { progression = { reroll = function() end } },
    }, LevelUpScreen)
    screen:_layout()
    screen:gamepadpressed(nil, "dpdown")
    H.eq(screen.buttons.focus_index, 4)
    screen:gamepadpressed(nil, "dpright")
    H.eq(screen.buttons.focus_index, 5)
    screen:gamepadpressed(nil, "dpup")
    H.eq(screen.buttons.focus_index, 2)
  end)
end

return T
