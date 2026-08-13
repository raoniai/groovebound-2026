local MusicRouter = {}

local world_routes = {
  funk = "world_funk_route",
  soul = "world_soul_route",
  disco = "world_disco_route",
  house = "world_house_route",
  electro = "world_electro_route",
  techno = "world_techno_route",
  cosmic_boogie = "world_cosmic_boogie_route",
  soulful_garage = "world_soulful_garage_route",
  future_funk = "world_future_funk_route",
}

local world_bosses = {
  boogie_tank = "world_funk_boogie_tank",
  mothership_of_funk = "world_funk_mothership",
  organ_colossus = "world_soul_organ_colossus",
  velvet_titan = "world_soul_velvet_titan",
  laser_conductor = "world_disco_laser_conductor",
  prism_monarch = "world_disco_prism_monarch",
  kickdrum_constructor = "world_house_kickdrum_constructor",
  voltage_vandal = "world_electro_voltage_vandal",
  loop_architect = "world_techno_loop_architect",
  celestial_selector = "world_cosmic_boogie_celestial_selector",
  night_shift_conductor = "world_soulful_garage_night_shift_conductor",
  the_recompiler = "world_future_funk_recompiler",
}

local function modal(cue)
  return {
    cue = cue,
    overlay = nil,
    duck_db = 0,
    preserve_underlay = true,
    immediate = true,
  }
end

local function continuous(context, fallback)
  return {
    cue = context.current_cue or fallback or "title",
    overlay = nil,
    duck_db = -5,
    preserve_underlay = false,
    immediate = false,
  }
end

local function cutscene(context)
  if context.scene_id == "prologue" then
    if context.slide_index == 1 then return "prologue_city" end
    if context.slide_index == 2 then return "prologue_break" end
    return "prologue_resolve"
  elseif context.scene_id == "joe_intro" then
    return "joe_intro"
  elseif context.scene_id == "lyra_intro" then
    return "lyra_intro"
  elseif context.scene_id == "stage2_transition" then
    return context.slide_index and context.slide_index >= 3
      and "dead_line_recovery" or "first_press"
  elseif context.scene_id == "ending" then
    return "ending_teaser"
  end
end

local function gameplay(context)
  if context.world_id then
    return world_bosses[context.boss_id]
      or world_routes[context.world_id]
      or "world_tour_hub"
  end
  if context.boss_id == "grand_orchestrator" then
    return context.boss_phase_two
      and "grand_orchestrator_final" or "grand_orchestrator_p1"
  elseif context.boss_id == "static_baron" then
    return "static_baron"
  elseif context.boss_id == "metronome_guardian" then
    return "metronome_guardian"
  elseif context.boss_id == "turntable_sentinel" then
    return "turntable_sentinel"
  end

  local wave = context.wave_index or 1
  if context.stage_index == 2 then
    if wave >= 7 then return "stage2_overload" end
    if wave >= 4 then return "stage2_escalation" end
    return "stage2_arrival"
  end
  if wave >= 6 then return "stage1_overload" end
  if wave >= 3 then return "stage1_pressure" end
  return "stage1_opening"
end

function MusicRouter.route(context)
  context = context or {}
  local screen = context.screen or "title"

  if screen == "results" then
    return {
      cue = context.outcome == "victory" and "victory_results" or "defeat_results",
      overlay = nil,
      duck_db = 0,
      preserve_underlay = false,
      immediate = true,
    }
  end

  if screen == "cutscene" then
    return {
      cue = cutscene(context) or "title",
      overlay = nil,
      duck_db = -4,
      preserve_underlay = false,
      sting = context.sting,
    }
  end

  if screen == "options" or screen == "controls" then
    return continuous(context, context.modal_origin or "title")
  end
  if screen == "admin" then return modal("admin") end
  if screen == "arsenal" then return modal("arsenal") end
  if screen == "perk_database" then return modal("arsenal") end
  if screen == "level_up" then
    if context.has_evolution then return modal("evolution") end
    return continuous(context, "level_up")
  end
  if screen == "chest_reward" then return continuous(context, "level_up") end
  if screen == "pause" then return continuous(context, "pause") end
  if screen == "stage_complete" then return modal("stage_clear") end

  if screen == "run" then
    local cue = gameplay(context)
    return {
      cue = cue,
      overlay = context.low_health and cue == "grand_orchestrator_p1"
        and "low_health" or nil,
      duck_db = 0,
      preserve_underlay = false,
      immediate = context.boss_id ~= nil or context.boss_phase_two == true,
      align = context.boss_id and nil or "bar",
    }
  end
  if screen == "character_select" then
    return {
      cue = "character_select",
      overlay = nil,
      duck_db = 0,
      preserve_underlay = false,
    }
  end
  if screen == "world_tour" or screen == "world_loadout" then
    return {
      cue = "world_tour_hub",
      overlay = nil,
      duck_db = 0,
      preserve_underlay = false,
      immediate = false,
    }
  end
  return {
    cue = "title",
    overlay = nil,
    duck_db = 0,
    preserve_underlay = false,
  }
end

return MusicRouter
