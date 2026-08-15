local H = require("tests.helpers")
local MusicContext = require("src.audio.music_context")

local T = {}

T["adapter identifies the top-level title screen"] = function()
  local context = MusicContext.snapshot({
    states = {
      top = function() return { kind = "title" } end,
    },
  })
  H.eq(context.screen, "title")
end

T["adapter exposes cutscene, modal, wave, boss, health and evolution state"] = function()
  local stack = {
    { kind = "run" },
    { kind = "level_up", offer = { { kind = "evolution" } } },
    { kind = "options" },
  }
  local context = MusicContext.snapshot({
    states = {
      stack = stack,
      top = function() return stack[#stack] end,
    },
    music = { snapshot = function() return { overlay = "low_health" } end },
    active_run = {
      player = { hp = 30, max_hp = 100 },
      combat = {
        stage_index = 2,
        spawner = { active_wave_index = 7 },
        music_snapshot = function()
          return { boss_id = "grand_orchestrator", boss_hp_fraction = 0.42,
            boss_phase_two = true }
        end,
      },
    },
  })
  H.eq(context.screen, "options")
  H.eq(context.modal_origin, "level_up")
  H.eq(context.stage_index, 2)
  H.eq(context.wave_index, 7)
  H.eq(context.boss_id, "grand_orchestrator")
  H.is_true(context.boss_phase_two)
  H.is_true(context.low_health)
  H.is_true(context.has_evolution)
end

T["adapter exposes the exact cutscene slide and result outcome"] = function()
  local cutscene = { kind = "cutscene", scene = { id = "prologue" }, index = 2 }
  local context = MusicContext.snapshot({
    states = { stack = { cutscene }, top = function() return cutscene end },
  })
  H.eq(context.scene_id, "prologue")
  H.eq(context.slide_index, 2)

  local results = { kind = "results", result = { outcome = "victory" } }
  context = MusicContext.snapshot({
    states = { stack = { results }, top = function() return results end },
  })
  H.eq(context.outcome, "victory")
end

T["adapter exposes selected World Tour and loadout identities"] = function()
  local tour = { kind = "world_tour", selected = 2,
    worlds = { { id = "funk" }, { id = "soul" } } }
  local context = MusicContext.snapshot({
    states = { stack = { tour }, top = function() return tour end },
    music = { snapshot = function() return { cue = "world_funk_route" } end },
  })
  H.eq(context.world_id, "soul")
  H.eq(context.current_cue, "world_funk_route")

  local loadout = { kind = "world_loadout", world = { id = "disco" } }
  context = MusicContext.snapshot({
    states = { stack = { loadout }, top = function() return loadout end },
  })
  H.eq(context.world_id, "disco")
end

return T
