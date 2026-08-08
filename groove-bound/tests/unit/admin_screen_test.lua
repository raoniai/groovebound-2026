local H = require("tests.helpers")
local AdminScreen = require("src.ui.screens.admin")
local Tuning = require("src.debug.tuning")
local definitions = require("src.config.admin_controls")

local T = {}

local function fresh()
  local state_calls = { pops = 0 }
  local states = {
    pop = function()
      state_calls.pops = state_calls.pops + 1
    end,
  }
  local app = {
    tuning = Tuning(definitions),
    states = states,
    log = {
      info = function() end,
    },
  }
  local screen = AdminScreen(app)
  screen.max_visible = #definitions
  screen.selected = 1
  screen.scroll = 1
  return screen, app.tuning, state_calls
end

T["keyboard changes and resets the selected control"] = function()
  local screen, tuning = fresh()
  screen:keypressed("right")
  H.eq(tuning:get("simulation.time_scale"), 1.1)
  screen:keypressed("backspace")
  H.eq(tuning:get("simulation.time_scale"), 1)
end

T["gamepad navigation and adjustment use the same tuning model"] = function()
  local screen, tuning = fresh()
  screen:gamepadpressed(nil, "dpdown")
  H.eq(screen.selected, 2)
  screen:gamepadpressed(nil, "dpright")
  H.is_true(tuning:get("test.enhanced_mode"))
  screen:gamepadpressed(nil, "y")
  H.is_false(tuning:get("test.enhanced_mode"))
end

T["mouse plus button adjusts its exact row"] = function()
  local screen, tuning = fresh()
  screen.rows = {
    [1] = {
      x = 0, y = 0, w = 200, h = 30,
      minus = { x = 100, y = 0, w = 30, h = 30 },
      plus = { x = 160, y = 0, w = 30, h = 30 },
    },
  }
  screen.reset_all_rect = { x = 0, y = 100, w = 80, h = 30 }
  screen.close_rect = { x = 100, y = 100, w = 80, h = 30 }
  H.is_true(screen:mousepressed(170, 10, 1))
  H.eq(tuning:get("simulation.time_scale"), 1.1)
end

T["F1 Escape and gamepad close actions pop the modal"] = function()
  local screen, _, calls = fresh()
  screen:keypressed("f1")
  H.eq(calls.pops, 1)
  screen:keypressed("escape")
  H.eq(calls.pops, 2)
  screen:gamepadpressed(nil, "b")
  H.eq(calls.pops, 3)
end

T["run-tool shortcuts call their exact active combat commands"] = function()
  local screen = fresh()
  local calls = { level = 0, evolution = 0, boss = 0, clear = 0 }
  screen.app.active_run = {
    combat = {
      admin_grant_level = function() calls.level = calls.level + 1 end,
      admin_prepare_evolution = function() calls.evolution = calls.evolution + 1 end,
      admin_spawn_final_boss = function() calls.boss = calls.boss + 1 end,
      admin_clear_stage = function() calls.clear = calls.clear + 1 end,
    },
  }
  H.is_true(screen:keypressed("g"))
  H.is_true(screen:keypressed("e"))
  H.is_true(screen:keypressed("b"))
  H.is_true(screen:keypressed("n"))
  H.eq(calls.level, 1)
  H.eq(calls.evolution, 1)
  H.eq(calls.boss, 1)
  H.eq(calls.clear, 1)
end

return T
