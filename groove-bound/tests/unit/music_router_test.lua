local H = require("tests.helpers")
local MusicRouter = require("src.audio.music_router")

local T = {}

T["title is the fallback cue for the top-level title screen"] = function()
  local intent = MusicRouter.route({ screen = "title" })
  H.eq(intent.cue, "title")
  H.is_nil(intent.overlay)
  H.eq(intent.duck_db, 0)
  H.is_false(intent.preserve_underlay)
end

T["cutscene slides route to their exact reversible cues"] = function()
  H.eq(MusicRouter.route({ screen = "cutscene", scene_id = "prologue", slide_index = 1 }).cue,
    "prologue_city")
  H.eq(MusicRouter.route({ screen = "cutscene", scene_id = "prologue", slide_index = 2 }).cue,
    "prologue_break")
  H.eq(MusicRouter.route({ screen = "cutscene", scene_id = "prologue", slide_index = 3 }).cue,
    "prologue_resolve")
  H.eq(MusicRouter.route({ screen = "cutscene", scene_id = "stage2_transition", slide_index = 2 }).cue,
    "first_press")
  H.eq(MusicRouter.route({ screen = "cutscene", scene_id = "stage2_transition", slide_index = 3 }).cue,
    "dead_line_recovery")
  H.eq(MusicRouter.route({ screen = "cutscene", scene_id = "ending", slide_index = 1 }).cue,
    "ending_teaser")
end

T["character routes and results never leak the title cue"] = function()
  H.eq(MusicRouter.route({ screen = "character_select" }).cue, "character_select")
  H.eq(MusicRouter.route({ screen = "cutscene", scene_id = "joe_intro", slide_index = 2 }).cue,
    "joe_intro")
  H.eq(MusicRouter.route({ screen = "cutscene", scene_id = "lyra_intro", slide_index = 1 }).cue,
    "lyra_intro")
  H.eq(MusicRouter.route({ screen = "results", outcome = "victory" }).cue,
    "victory_results")
  H.eq(MusicRouter.route({ screen = "results", outcome = "defeat" }).cue,
    "defeat_results")
end

T["gameplay uses live wave index and bosses override intensity"] = function()
  H.eq(MusicRouter.route({ screen = "run", stage_index = 1, wave_index = 1 }).cue,
    "stage1_opening")
  H.eq(MusicRouter.route({ screen = "run", stage_index = 1, wave_index = 3 }).cue,
    "stage1_pressure")
  H.eq(MusicRouter.route({ screen = "run", stage_index = 1, wave_index = 6 }).cue,
    "stage1_overload")
  H.eq(MusicRouter.route({ screen = "run", stage_index = 1, wave_index = 6,
    boss_id = "metronome_guardian" }).cue, "metronome_guardian")
  H.eq(MusicRouter.route({ screen = "run", stage_index = 1, wave_index = 7,
    boss_id = "static_baron" }).cue, "static_baron")
  H.eq(MusicRouter.route({ screen = "run", stage_index = 2, wave_index = 1 }).cue,
    "stage2_arrival")
  H.eq(MusicRouter.route({ screen = "run", stage_index = 2, wave_index = 4 }).cue,
    "stage2_escalation")
  H.eq(MusicRouter.route({ screen = "run", stage_index = 2, wave_index = 7 }).cue,
    "stage2_overload")
end

T["every World Tour world resolves to its own gameplay route pack"] = function()
  local expected = {
    funk = "world_funk_route",
    soul = "world_soul_route",
    disco = "world_disco_route",
    jazz = "world_electro_route",
    house = "world_house_route",
    electro = "world_electro_route",
    techno = "world_techno_route",
    cosmic_boogie = "world_cosmic_boogie_route",
    soulful_garage = "world_soulful_garage_route",
    future_funk = "world_future_funk_route",
  }
  for world_id, cue in pairs(expected) do
    H.eq(MusicRouter.route({ screen = "run", world_id = world_id }).cue, cue)
  end
end

T["World Tour menus keep the neutral hub groove continuous"] = function()
  H.eq(MusicRouter.route({ screen = "world_tour", world_id = "funk" }).cue,
    "world_tour_hub")
  H.eq(MusicRouter.route({ screen = "world_loadout", world_id = "disco" }).cue,
    "world_tour_hub")
end

T["playable World Tour routes and bosses use their unique packs"] = function()
  local cases = {
    { "funk", nil, "world_funk_route" },
    { "funk", "boogie_tank", "world_funk_boogie_tank" },
    { "funk", "mothership_of_funk", "world_funk_mothership" },
    { "soul", nil, "world_soul_route" },
    { "soul", "organ_colossus", "world_soul_organ_colossus" },
    { "soul", "velvet_titan", "world_soul_velvet_titan" },
    { "disco", nil, "world_disco_route" },
    { "disco", "laser_conductor", "world_disco_laser_conductor" },
    { "disco", "prism_monarch", "world_disco_prism_monarch" },
  }
  for _, case in ipairs(cases) do
    local intent = MusicRouter.route({ screen = "run", world_id = case[1],
      stage_index = 1, wave_index = 7, boss_id = case[2] })
    H.eq(intent.cue, case[3])
  end
end

T["Grand Orchestrator final phase latches and low health layers only at matching tempo"] = function()
  local phase_one = MusicRouter.route({ screen = "run", stage_index = 2,
    wave_index = 9, boss_id = "grand_orchestrator", boss_phase_two = false,
    low_health = true })
  H.eq(phase_one.cue, "grand_orchestrator_p1")
  H.eq(phase_one.overlay, "low_health")
  local final = MusicRouter.route({ screen = "run", stage_index = 2,
    wave_index = 9, boss_id = "grand_orchestrator", boss_phase_two = true,
    low_health = true })
  H.eq(final.cue, "grand_orchestrator_final")
  H.is_nil(final.overlay)
end

T["browsing databases uses their persistent utility music"] = function()
  for screen, cue in pairs({ arsenal = "arsenal", perk_database = "arsenal",
      admin = "admin" }) do
    local intent = MusicRouter.route({ screen = screen })
    H.eq(intent.cue, cue)
    H.is_true(intent.preserve_underlay)
    H.is_true(intent.immediate)
  end
end

T["run overlays continue and duck the current world music"] = function()
  for _, screen in ipairs({ "pause", "level_up", "chest_reward" }) do
    local intent = MusicRouter.route({ screen = screen,
      current_cue = "world_funk_route", has_evolution = false })
    H.eq(intent.cue, "world_funk_route")
    H.is_false(intent.preserve_underlay)
    H.eq(intent.duck_db, -5)
  end
  H.eq(MusicRouter.route({ screen = "level_up", has_evolution = true }).cue,
    "evolution")
end

T["nested options continue the audible cue beneath them"] = function()
  local intent = MusicRouter.route({ screen = "options", modal_origin = "pause",
    current_cue = "world_soul_route" })
  H.eq(intent.cue, "world_soul_route")
  H.is_false(intent.preserve_underlay)
  H.eq(intent.duck_db, -5)
end

T["stage clear event passes through the first-press cutscene exactly once"] = function()
  local event = { cue = "stage_clear_sting", serial = 4 }
  local intent = MusicRouter.route({ screen = "cutscene",
    scene_id = "stage2_transition", slide_index = 1, sting = event })
  H.eq(intent.cue, "first_press")
  H.eq(intent.sting, event)
end

return T
