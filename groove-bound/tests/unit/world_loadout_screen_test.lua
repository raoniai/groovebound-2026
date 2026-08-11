local H = require("tests.helpers")
local Content = require("src.content.init")
local WorldLoadoutScreen = require("src.ui.screens.world_loadout")

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

T["starter loadout enforces exact free weapon and support counts"] = function()
  local screen = WorldLoadoutScreen({ content = Content }, {
    world = Content.world_tour.disco,
    character_id = "joe",
  })
  H.is_false(screen:ready())
  H.is_true(screen:toggle_weapon("bass_drop"))
  H.is_true(screen:toggle_passive("quickstep"))
  H.is_true(screen:ready())
  H.is_false(screen:toggle_weapon("cymbal_slicer"))
  local loadout = screen:selection()
  H.eq(loadout.weapons[1], "bass_drop")
  H.eq(loadout.passives[1], "quickstep")
end

T["starter-loadout dpad moves vertically within the icon grid"] = function()
  with_dimensions(1280, 720, function()
    local screen = WorldLoadoutScreen({ content = Content }, {
      world = Content.world_tour.disco,
      character_id = "joe",
    })
    screen:_layout()
    screen:gamepadpressed(nil, "dpdown")
    H.eq(screen.buttons.focus_index, 9)
    screen:gamepadpressed(nil, "dpright")
    H.eq(screen.buttons.focus_index, 10)
  end)
end

return T
