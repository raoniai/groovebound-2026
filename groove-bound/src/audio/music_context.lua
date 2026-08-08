local MusicContext = {}

function MusicContext.snapshot(app)
  local top = app.states:top()
  local context = {
    screen = top and top.kind or "title",
  }
  local stack = app.states.stack or {}

  if top and top.scene then
    context.scene_id = top.scene.id
    context.slide_index = top.index
  end
  if top and top.result then context.outcome = top.result.outcome end

  local audible_screen = top
  if context.screen == "options" or context.screen == "controls" then
    for index = #stack - 1, 1, -1 do
      local kind = stack[index].kind
      if kind ~= "options" and kind ~= "controls" then
        context.modal_origin = kind
        audible_screen = stack[index]
        break
      end
    end
  end
  if context.screen == "level_up" or context.modal_origin == "level_up" then
    for _, choice in ipairs((audible_screen and audible_screen.offer) or {}) do
      if choice.kind == "evolution" then
        context.has_evolution = true
        break
      end
    end
  end

  local run = app.active_run
  if run and run.combat then
    context.stage_index = run.combat.stage_index
    context.wave_index = run.combat.spawner
      and run.combat.spawner.active_wave_index or 0
    if run.combat.music_snapshot then
      local boss = run.combat:music_snapshot()
      context.boss_id = boss.boss_id
      context.boss_hp_fraction = boss.boss_hp_fraction
      context.boss_phase_two = boss.boss_phase_two
    end
    if run.player and run.player.max_hp > 0 then
      context.player_hp_fraction = run.player.hp / run.player.max_hp
      local previous = app.music and app.music:snapshot().overlay
      context.low_health = context.player_hp_fraction <= 0.25
        or (previous == "low_health" and context.player_hp_fraction < 0.35)
    end
    if run.music_event then context.sting = run.music_event end
  end

  return context
end

return MusicContext
