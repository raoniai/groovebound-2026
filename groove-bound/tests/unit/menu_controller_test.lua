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
    local muted = false
    local app = {
      log = { info = function() end },
      states = { pop = function() end, push = function() end },
      profile = { options = { muted = false, master_volume = 1,
        music_volume = 1, sfx_volume = 1 } },
      music = { set_volume = function(_, volume) muted = volume == 0 end },
      save = { save = function() end },
    }
    local screen = PauseScreen(app)
    screen:enter()
    H.is_true(screen:gamepadpressed(nil, "dpdown"))
    H.eq(screen.button_list.focus_index, 2)
    H.is_true(screen:gamepadpressed(nil, "dpright"))
    H.eq(screen.button_list.focus_index, 2)
    H.is_true(screen:gamepadpressed(nil, "a"))
    H.is_true(muted)
    H.is_true(app.profile.options.muted)
    H.eq(#screen.button_list.buttons, 4)
    for _, button in ipairs(screen.button_list.buttons) do
      H.is_false(button.label == "COPY RUN SEED")
    end
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

T["difficulty choice cycles directly and rebalances an active run"] = function()
  with_dimensions(1280, 720, function()
    local changed
    local app = {
      profile = { options = {
        difficulty = "medium", master_volume = 1,
        music_volume = 1, sfx_volume = 1, muted = false,
      } },
      active_run = { combat = {
        set_difficulty = function(_, value, previous)
          changed = { value = value, previous = previous }
        end,
      } },
      save = { save = function() end },
    }
    local screen = OptionsScreen(app)
    screen:_layout()
    local difficulty
    for _, row in ipairs(screen.rows) do
      if row.key == "difficulty" then difficulty = row break end
    end
    H.is_true(difficulty ~= nil)
    screen.selected = difficulty.focus
    H.is_true(screen:gamepadpressed(nil, "rightshoulder"))
    H.eq(app.profile.options.difficulty, "hard")
    H.eq(changed.previous, "medium")
    H.eq(changed.value, "hard")
    H.is_true(screen:gamepadpressed(nil, "a"))
    H.eq(app.profile.options.difficulty, "super_hard")
    H.is_true(screen:keypressed("-"))
    H.eq(app.profile.options.difficulty, "hard")
    H.is_true(screen:mousepressed(
      difficulty.minus_rect.x + 2, difficulty.minus_rect.y + 2, 1))
    H.eq(app.profile.options.difficulty, "medium")
    H.is_true(screen:mousepressed(
      difficulty.plus_rect.x + 2, difficulty.plus_rect.y + 2, 1))
    H.eq(app.profile.options.difficulty, "hard")
  end)
end

return T
