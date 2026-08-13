local H = require("tests.helpers")
local OptionsScreen = require("src.ui.screens.options")
local PauseScreen = require("src.ui.screens.pause")

local T = {}

local function with_dimensions(w, h, fn)
  local previous = _G.love
  _G.love = {
    graphics = { getDimensions = function() return w, h end },
  }
  local ok, err = xpcall(fn, debug.traceback)
  _G.love = previous
  if not ok then error(err, 0) end
end

T["pause controller moves in four directions and confirms focused action"] = function()
  with_dimensions(1280, 720, function()
    local copied = 0
    local app = {
      log = { info = function() end },
      states = { pop = function() end, push = function() end },
      active_run = { copy_seed = function() copied = copied + 1 end },
    }
    local screen = PauseScreen(app)
    screen:enter()
    H.is_true(screen:gamepadpressed(nil, "dpdown"))
    H.eq(screen.button_list.focus_index, 2)
    H.is_true(screen:gamepadpressed(nil, "dpright"))
    H.eq(screen.button_list.focus_index, 2)
    H.is_true(screen:gamepadpressed(nil, "a"))
    H.eq(copied, 1)
  end)
end

T["settings dpad stays in column vertically and crosses columns horizontally"] = function()
  with_dimensions(1280, 720, function()
    local screen = OptionsScreen({})
    screen:_layout()
    local first_x = screen.rows[screen.selected].rect.x
    screen:gamepadpressed(nil, "dpdown")
    H.eq(screen.selected, 2)
    H.eq(screen.rows[screen.selected].rect.x, first_x)
    screen:gamepadpressed(nil, "dpright")
    H.is_true(screen.rows[screen.selected].rect.x > first_x)
  end)
end

T["settings shoulder hold repeats until release and persists once"] = function()
  with_dimensions(1280, 720, function()
    local saves = 0
    local app = {
      profile = { options = { master_volume = 0.40 } },
      save = { save = function() saves = saves + 1 end },
    }
    local screen = OptionsScreen(app)
    screen:_layout()
    H.is_true(screen:gamepadpressed(nil, "rightshoulder"))
    H.near(app.profile.options.master_volume, 0.41)
    screen:update(0.50)
    H.is_true(app.profile.options.master_volume > 0.41)
    H.eq(saves, 0)
    H.is_true(screen:gamepadreleased(nil, "rightshoulder"))
    H.eq(saves, 1)
    H.is_nil(screen.hold)
    local released_value = app.profile.options.master_volume
    screen:update(0.50)
    H.near(app.profile.options.master_volume, released_value)
  end)
end

return T
