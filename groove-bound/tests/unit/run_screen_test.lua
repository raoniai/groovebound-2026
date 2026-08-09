local H = require("tests.helpers")
local Camera = require("src.game.camera")
local Content = require("src.content.init")
local RunScreen = require("src.ui.screens.run")

local T = {}

local function fresh()
  local screen = RunScreen({}, {})
  screen.camera = Camera({
    x = 1360,
    y = 800,
    get_dimensions = function() return 1280, 720 end,
  })
  screen.player = { x = 1820, y = 800 }
  return screen
end

T["visible chest arrows sit above and point directly down to each chest"] = function()
  local screen = fresh()
  local pointer = screen:reward_chest_pointer({ x = 1520, y = 800 }, 1280, 720)
  H.is_true(pointer.on_screen)
  H.eq(pointer.x, 800)
  H.eq(pointer.y, 310)
  H.near(pointer.angle, math.pi / 2)
end

T["offscreen chest arrows aim from the actual player position"] = function()
  local screen = fresh()
  local pointer = screen:reward_chest_pointer({ x = 2200, y = 650 }, 1280, 720)
  H.is_false(pointer.on_screen)
  H.eq(pointer.x, 1224)
  H.is_true(pointer.y < 360)
  H.is_true(pointer.angle < 0)
end

T["every active chest receives its own pointer"] = function()
  local screen = fresh()
  local chests = {
    { x = 1520, y = 800 },
    { x = 2200, y = 650 },
    { x = 900, y = 1000 },
  }
  screen.ctx = {
    world = {
      each = function(_, kind, callback)
        H.eq(kind, "reward_chest")
        for _, chest in ipairs(chests) do callback(chest) end
      end,
    },
  }
  local pointers = screen:reward_chest_pointers(1280, 720)
  H.eq(#pointers, 3)
end

T["a final chest reveal completes before its pending stage transition"] = function()
  local pushed = {}
  local queue = {
    { roll = 1, rewards = {
      { kind = "weapon_level", id = "kazoo_pistol",
        title = "Kazoo Pistol  R2", description = "More buzz." },
    } },
  }
  local app = {
    content = Content,
    tuning = { get = function() return 1 end },
    states = {
      push = function(_, state) pushed[#pushed + 1] = state.kind end,
    },
  }
  local screen = RunScreen(app, {})
  screen.seed_notice = 0
  screen.choice_open = false
  screen.transitioning = false
  screen.finished = false
  screen.pending_outcome = "stage_clear"
  screen.music_event_serial = 0
  screen.combat = {
    take_pending_chest_reveal = function()
      return table.remove(queue, 1)
    end,
    xp = { has_pending_choice = function() return false end },
  }

  screen:update(0.1)
  H.eq(pushed[1], "chest_reward")
  H.eq(screen.pending_outcome, "stage_clear")
  screen:resume({ kind = "chest_reward" })
  screen:update(0.1)
  H.eq(pushed[2], "cutscene")
  H.is_nil(screen.pending_outcome)
end

return T
