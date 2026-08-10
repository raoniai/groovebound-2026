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

T["every living final boss receives a pointer while ordinary enemies do not"] = function()
  local screen = fresh()
  local enemies = {
    { x = 1520, y = 800, dead = false,
      definition = { boss_type = "final", name = "Static Baron" } },
    { x = 900, y = 1000, dead = false,
      definition = { boss_type = nil, name = "Monotone" } },
  }
  screen.ctx = {
    world = {
      each = function(_, kind, callback)
        H.eq(kind, "enemy")
        for _, enemy in ipairs(enemies) do callback(enemy) end
      end,
    },
  }
  local pointers = screen:boss_pointers(1280, 720)
  H.eq(#pointers, 1)
  H.eq(pointers[1].label, "STATIC BARON")
  H.is_true(pointers[1].on_screen)
end

T["boss danger warning names the attack when the player is in range"] = function()
  local screen = fresh()
  screen.combat = {
    boss_threat_snapshot = function()
      return {
        active = true,
        boss_id = "static_baron",
        name = "Static Baron",
        player_in_range = true,
        windup = 0.4,
      }
    end,
  }
  local warning = screen:boss_warning_state()
  H.is_true(warning.active)
  H.eq(warning.title, "DANGER: STATIC WAVE RANGE")
  H.eq(warning.detail, "ATTACK CHARGING")
end

T["plus and minus adjust and persist gameplay zoom presets"] = function()
  local saved = 0
  local screen = RunScreen({
    profile = { options = { camera_zoom = 1.0 } },
    save = { save = function() saved = saved + 1 end },
  }, {})
  screen.camera = Camera({
    get_dimensions = function() return 1280, 720 end,
  })
  H.is_true(screen:keypressed("="))
  H.near(screen.camera.zoom, 1.25)
  H.near(screen.app.profile.options.camera_zoom, 1.25)
  H.is_true(screen:keypressed("-"))
  H.near(screen.camera.zoom, 1.0)
  H.eq(saved, 2)
end

T["a final chest reveal and stage confirmation complete before the cutscene"] = function()
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
    stage_index = 1,
    stats = { kills = 0, bosses = 1 },
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
  H.eq(pushed[2], "stage_complete")
  H.is_nil(screen.pending_outcome)
  screen:resume({ kind = "stage_complete", outcome = "stage_clear" })
  H.eq(pushed[3], "cutscene")
end

T["World Tour stage confirmation advances into its second playable arena"] = function()
  local began
  local screen = RunScreen({ content = Content }, {
    mode = "world_tour", world_id = "funk",
  })
  screen.mode = "world_tour"
  screen.world_id = "funk"
  screen.stages = Content.world_stages.funk
  screen.app.assets = nil
  screen.player = { x = 0, y = 0, max_hp = 100, hp = 100, guard = 0 }
  screen.camera = {
    set_bounds = function() end,
    snap = function() end,
  }
  screen.combat = {
    stage_index = 1,
    begin_stage = function(_, index) began = index end,
  }
  screen.world_mechanic = nil
  screen.world_mechanic_totals = {
    activations = 0, opportunities = 0, best_chain = 0,
  }
  screen.music_event_serial = 0
  screen:resume({ kind = "stage_complete", outcome = "stage_clear" })
  H.eq(began, 2)
  H.eq(screen.arena.stage.id, "world_funk_golden_afterparty")
  H.eq(screen.world_mechanic.definition.id, "funk_hold_the_pocket")
  H.is_false(screen.transitioning)
end

return T
