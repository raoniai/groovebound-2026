-- Run screen: builds a RunContext on enter and destroys it on exit.
-- All per-run objects live inside the context; nothing survives to the
-- next run. Pause is a pushed modal, not a boolean.

local class = require("src.core.class")
local Arena = require("src.game.arena")
local Camera = require("src.game.camera")
local HUD = require("src.ui.hud")
local Hitboxes = require("src.debug.hitboxes")
local Input = require("src.game.input")
local Player = require("src.game.entities.player")
local RunContext = require("src.game.run_context")
local CombatSystem = require("src.game.systems.combat_system")
local WorldMechanicSystem = require("src.game.systems.world_mechanic_system")
local JourneyProgress = require("src.meta.journey_progress")
local WorldTourSession = require("src.meta.world_tour_session")

local RunScreen = class()
RunScreen.kind = "run"

local function deep_copy(value)
  if type(value) ~= "table" then return value end
  local result = {}
  for key, item in pairs(value) do
    result[deep_copy(key)] = deep_copy(item)
  end
  return result
end

local function world_stages(content, world_id)
  local stages = assert(content.world_stages[world_id])
  return stages[1] and stages or { stages }
end

function RunScreen:init(app, opts)
  self.app = app
  self.opts = opts or {}
  self.mode = self.opts.mode or "prologue"
  self.world_id = self.opts.world_id
  if app.content then
    self.stages = self.mode == "world_tour"
      and world_stages(app.content, self.world_id)
      or app.content.stages
  end
end

function RunScreen:enter()
  self.mode = self.opts.mode or "prologue"
  self.world_id = self.opts.world_id
  self.stages = self.mode == "world_tour"
    and world_stages(self.app.content, self.world_id)
    or self.app.content.stages
  self.character = self.app.content.characters[
    self.opts.character_id
      or (self.app.slot and self.app.slot.journey.character_id ~= ""
        and self.app.slot.journey.character_id) or "joe"]
  self.ctx = RunContext({
    seed = self.opts.seed,
    app_bus = self.app.bus,
    tuning = self.app.tuning,
  })
  self.app.log.info("state", "Run started (seed " .. self.ctx.seed .. ")")

  self.arena = Arena({
    assets = self.app.assets,
    reduced_motion = self.app.profile and self.app.profile.options.reduced_motion,
    stage = self.stages[1],
  })
  self.input = Input({ deadzone = self.app.profile.options.deadzone })

  self.camera = Camera({
    random = function() return self.ctx.rng.vfx:random() end,
    zoom = self.app.profile.options.camera_zoom,
  })
  self.camera:set_bounds(self.arena.width, self.arena.height)

  local cx, cy = self.arena:center()
  self.player = self.ctx.world:add("player", Player({
    x = cx,
    y = cy,
    tuning = self.app.tuning,
    assets = self.app.assets,
    options = self.app.profile.options,
    character = self.character,
  }))
  self.camera:snap(self.player.x, self.player.y)

  self.combat = CombatSystem({
    ctx = self.ctx,
    content = self.app.content,
    tuning = self.app.tuning,
    assets = self.app.assets,
    arena = self.arena,
    player = self.player,
    camera = self.camera,
    options = self.app.profile.options,
    character = self.character,
    stages = self.stages,
    mode = self.mode,
    fresh_world_entry = self.mode == "world_tour" and not self.opts.build,
  })
  if self.mode == "world_tour" and self.opts.build then
    self.combat.progression:restore(self.opts.build)
  elseif self.mode == "world_tour" and self.opts.starter_loadout then
    self.combat.progression:grant_starter_loadout(self.opts.starter_loadout)
  end
  self.world_mechanic = self.stages[1].mechanic
    and WorldMechanicSystem({
      definition = self.stages[1].mechanic,
      player = self.player,
      combat = self.combat,
    }) or nil
  self.world_mechanic_totals = {
    activations = 0,
    opportunities = 0,
    best_chain = 0,
    encores = 0,
  }
  self.hud = HUD(self.ctx, self.player, self.combat, {
    on_level_up = function() return self:open_level_up() end,
    has_world_mechanic = function() return self.world_mechanic ~= nil end,
    get_world_mechanic_rect = function(width)
      if not self.world_mechanic then return nil end
      return self:world_mechanic_hud_rect(width)
    end,
  })
  self.finished = false
  self.transitioning = false
  self.choice_open = false
  self.auto_snoozed_points = 0
  self.pending_outcome = nil
  self.seed_notice = 0
  self.music_event_serial = 0
  self.music_event = nil
  self.app.active_run = self
end

function RunScreen:_world_mechanic_snapshot()
  if not self.world_mechanic then return nil end
  local current = self.world_mechanic:snapshot()
  return {
    activations = self.world_mechanic_totals.activations
      + current.activations,
    opportunities = self.world_mechanic_totals.opportunities
      + current.opportunities,
    best_chain = math.max(
      self.world_mechanic_totals.best_chain, current.best_chain),
    chain = current.chain,
    boost_remaining = current.boost_remaining,
    encores = self.world_mechanic_totals.encores + (current.encores or 0),
  }
end

function RunScreen:_capture_world_mechanic()
  if not self.world_mechanic then return end
  local current = self.world_mechanic:snapshot()
  self.world_mechanic_totals.activations =
    self.world_mechanic_totals.activations + current.activations
  self.world_mechanic_totals.opportunities =
    self.world_mechanic_totals.opportunities + current.opportunities
  self.world_mechanic_totals.best_chain = math.max(
    self.world_mechanic_totals.best_chain, current.best_chain)
  self.world_mechanic_totals.encores = self.world_mechanic_totals.encores
    + (current.encores or 0)
end

function RunScreen:_begin_world_stage(index)
  self:_capture_world_mechanic()
  self.arena = Arena({
    assets = self.app.assets,
    reduced_motion = self.app.profile and self.app.profile.options.reduced_motion,
    stage = self.stages[index],
  })
  self.camera:set_bounds(self.arena.width, self.arena.height)
  self.combat:begin_stage(index, self.arena)
  self.camera:snap(self.player.x, self.player.y)
  self.world_mechanic = self.stages[index].mechanic
    and WorldMechanicSystem({
      definition = self.stages[index].mechanic,
      player = self.player,
      combat = self.combat,
    }) or nil
  self.transitioning = false
  self.finished = false
  self.pending_outcome = nil
  self.music_event = nil
end

function RunScreen:_results_payload(outcome)
  local payload = {
    outcome = outcome,
    mode = self.mode,
    world_id = self.world_id,
    stats = self.combat.stats,
    level = self.combat.xp.level,
    progression = self.combat.progression:snapshot(),
    time = self.ctx.time,
    character = self.character,
    stages_cleared = outcome == "victory" and #self.stages
      or self.combat.stage_index - 1,
    stage_count = #self.stages,
    health_fraction = self.player.hp / math.max(1, self.player.max_hp),
  }
  if outcome == "defeat" and self.mode == "world_tour" then
    payload.retry = {
      mode = "world_tour",
      world_id = self.world_id,
      character_id = self.character.id,
      build = self.opts.build and deep_copy(self.opts.build) or nil,
      starter_loadout = self.opts.starter_loadout
        and deep_copy(self.opts.starter_loadout) or nil,
    }
  end
  payload.world_mechanic = self:_world_mechanic_snapshot()
  return payload
end

function RunScreen:_show_results(outcome)
  local payload = self:_results_payload(outcome)
  if self.mode == "world_tour" then
    if outcome == "victory" then
      WorldTourSession.capture(
        self.app, self.character.id, payload.progression)
    else
      WorldTourSession.clear(self.app)
    end
  end
  JourneyProgress.record_result(self.app, payload)
  local ResultsScreen = require("src.ui.screens.results")
  self.app.states:push(ResultsScreen(self.app, payload))
end

function RunScreen:exit()
  if self.app.active_run == self then self.app.active_run = nil end
  self.ctx:destroy()
  self.app.log.info("state", "Run ended")
end

function RunScreen:update(dt)
  local time_scale = self.app.tuning
    and self.app.tuning:get("simulation.time_scale") or 1
  local sim_dt = dt * time_scale
  self.seed_notice = math.max(0, self.seed_notice - dt)
  local outcome = self.pending_outcome
  if not outcome and self.ctx then
    self.ctx:update(sim_dt)
    self.player:update(sim_dt, self.input, self.camera, self.arena)
    self.ctx.world:moved(self.player)
    if self.world_mechanic then
      local previous_activations = self.world_mechanic.activations
      self.world_mechanic:update(sim_dt, self.ctx.time)
      if self.world_mechanic.activations > previous_activations then
        local snapshot = self.world_mechanic:snapshot()
        self.combat:on_world_mechanic_success(self.world_mechanic.definition)
        local pad = self.world_mechanic.definition.pads[snapshot.success_index]
        if pad then
          self.combat.vfx:spawn("hit", pad.x, pad.y, {
            scale = 0.82, duration = 0.72,
            color = { 0.44, 1.0, 0.68, 1 },
          })
        end
        if self.app.assets then self.app.assets:play("level_up", 0.10) end
      end
    end
    outcome = self.combat:update(sim_dt)
    self.camera:follow(self.player.x, self.player.y, sim_dt)
    self.camera:update(sim_dt)
  end

  local chest_reveal = self.combat:take_pending_chest_reveal()
  if chest_reveal and not self.choice_open then
    if chest_reveal.auto_selected and not chest_reveal.has_evolution then
      self.choice_open = false
    else
      self.choice_open = true
      self.pending_outcome = outcome
      local ChestRewardScreen = require("src.ui.screens.chest_reward")
      self.app.states:push(ChestRewardScreen(
        self.app, chest_reveal))
    end
  elseif outcome == "stage_clear" and not self.transitioning then
    self.pending_outcome = nil
    self.transitioning = true
    local StageCompleteScreen = require("src.ui.screens.stage_complete")
    local stage = self.stages[self.combat.stage_index]
    self.app.states:push(StageCompleteScreen(self.app, {
      outcome = "stage_clear",
      stage_index = self.combat.stage_index,
      stage_name = stage.name,
      stats = self.combat.stats,
      mode = self.mode,
      world_id = self.world_id,
    }))
  elseif outcome == "victory" and not self.finished then
    self.pending_outcome = nil
    self.finished = true
    local StageCompleteScreen = require("src.ui.screens.stage_complete")
    local stage = self.stages[self.combat.stage_index]
    self.app.states:push(StageCompleteScreen(self.app, {
      outcome = "victory",
      stage_index = self.combat.stage_index,
      stage_name = stage.name,
      stats = self.combat.stats,
      mode = self.mode,
      world_id = self.world_id,
    }))
  elseif outcome == "defeat" and not self.finished then
    self.pending_outcome = nil
    self.finished = true
    self:_show_results("defeat")
  elseif self.combat.xp:has_pending_choice() and not self.choice_open
    and self.combat.progression.can_auto_select
    and self.combat.progression:can_auto_select()
  then
    while self.combat.xp:has_pending_choice()
      and self.combat.progression:can_auto_select()
    do
      self.combat.progression:auto_select()
      self.combat.xp:consume_choice()
    end
    self.auto_snoozed_points = 0
  elseif self.combat.xp:has_pending_choice() and not self.choice_open
    and self.app.profile.options.automatic_level_up == true
    and self.combat.xp.pending_choices > (self.auto_snoozed_points or 0)
  then
    self:open_level_up()
  end
end

function RunScreen:open_level_up()
  if self.choice_open or not self.combat
    or not self.combat.xp:has_pending_choice()
  then
    return false
  end
  self.choice_open = true
  local LevelUpScreen = require("src.ui.screens.level_up")
  self.app.states:push(LevelUpScreen(self.app, self.combat))
  return true
end

function RunScreen:copy_seed()
  love.system.setClipboardText(tostring(self.ctx.seed))
  self.seed_notice = 1.8
  self.status_notice_text = "SEED COPIED"
  return self.ctx.seed
end

function RunScreen:adjust_camera_zoom(direction)
  local zoom = self.camera:set_zoom(
    (self.app.profile.options.camera_zoom or 1) + direction * 0.25)
  self.app.profile.options.camera_zoom = zoom
  self.app.save:save(self.app.profile)
  self.seed_notice = 1.4
  self.status_notice_text = string.format("ZOOM %d%%", math.floor(zoom * 100 + 0.5))
  return zoom
end

function RunScreen:resume(result)
  self.choice_open = false
  if result and result.kind == "level_up_closed" then
    self.auto_snoozed_points = self.combat.xp.pending_choices
  elseif result and (result.kind == "level_up_complete"
    or result.kind == "skip" or result.kind == "weapon_add"
    or result.kind == "weapon_level" or result.kind == "passive_add"
    or result.kind == "passive_level" or result.kind == "heal"
    or result.kind == "guard" or result.kind == "coins")
  then
    self.auto_snoozed_points = 0
  end
  if result and result.kind == "stage_complete" then
    self.music_event_serial = self.music_event_serial + 1
    self.music_event = {
      cue = "stage_clear_sting",
      serial = self.music_event_serial,
    }
    if self.mode == "world_tour" then
      if result.outcome == "stage_clear"
        and self.combat.stage_index < #self.stages
      then
        self:_begin_world_stage(self.combat.stage_index + 1)
        return
      end
      self:_show_results("victory")
      return
    end
    local CutsceneScreen = require("src.ui.screens.cutscene")
    if result.outcome == "stage_clear" then
      self.app.states:push(CutsceneScreen(
        self.app,
        self.app.content.narrative.stage2_transition,
        { result = "stage2" }))
    else
      self.app.states:push(CutsceneScreen(
        self.app,
        self.app.content.narrative.ending,
        { result = "campaign_complete" }))
    end
  elseif result == "stage2" then
    self.music_event = nil
    self.arena = Arena({
      assets = self.app.assets,
      reduced_motion = self.app.profile and self.app.profile.options.reduced_motion,
      stage = self.stages[2],
    })
    self.camera:set_bounds(self.arena.width, self.arena.height)
    self.combat:begin_stage(2, self.arena)
    self.camera:snap(self.player.x, self.player.y)
    self.transitioning = false
  elseif result == "campaign_complete" then
    self:_show_results("victory")
  end
end

function RunScreen:draw()
  self.camera:apply()
  self.arena:draw()
  self:_draw_world_mechanic()
  self.ctx.world:each("xp_gem", function(gem) gem:draw() end)
  self.ctx.world:each("pickup", function(pickup) pickup:draw() end)
  self.ctx.world:each("reward_chest", function(chest) chest:draw() end)
  self.ctx.world:each("enemy", function(enemy) enemy:draw() end)
  self.ctx.world:each("projectile", function(projectile) projectile:draw() end)
  self.ctx.world:each(
    "enemy_projectile", function(projectile) projectile:draw() end)
  self.player.show_aim = self.app.states:top() == self
  self.player:draw()
  self.arena:draw_overlays()
  self.combat.vfx:draw()
  Hitboxes.draw(self.ctx.world)
  self.camera:detach()

  self:_draw_player_feedback()
  self:_draw_boss_warning()
  self.hud:draw()
  self:_draw_boss_pointers()
  self:_draw_reward_chest_pointers()
  self:_draw_world_mechanic_hud()
  if self.seed_notice > 0 then
    local Fonts = require("src.ui.fonts")
    love.graphics.setFont(Fonts.get(14))
    love.graphics.setColor(0.96, 0.78, 0.22, math.min(1, self.seed_notice))
    love.graphics.printf(self.status_notice_text or "SEED COPIED",
      0, love.graphics.getHeight() - 42,
      love.graphics.getWidth(), "center")
  end
end

function RunScreen:_draw_world_mechanic()
  if not self.world_mechanic then return end
  local snapshot = self.world_mechanic:snapshot()
  local definition = self.world_mechanic.definition
  for index, pad in ipairs(definition.pads) do
    local active = index == snapshot.active_index
    local frame = active and snapshot.frame or 1
    local succeeded = index == snapshot.success_index and snapshot.notice > 0
    local reduced = self.app.profile.options.reduced_motion == true
    local success_pulse = succeeded and not reduced
      and (1 + math.sin(self.ctx.time * 16) * 0.08) or 1
    local size = (active and 230 or 185) * success_pulse
    if succeeded then
      frame = snapshot.encore_remaining > 0 and 7 or 5
    elseif active and (definition.kind == "charge"
        or definition.kind == "call_response") then
      frame = math.max(2, math.min(4, math.floor(
        (snapshot.charge or 0) / definition.charge_seconds * 3) + 2))
    elseif active and (definition.kind == "relay"
        or definition.kind == "prism_relay") then
      frame = 6
    elseif snapshot.boost_remaining > 0 then
      frame = 8
    end
    local color = succeeded and { 1, 0.94, 0.38, 1 }
      or active and { 1, 1, 1, 0.96 } or { 0.52, 0.44, 0.68, 0.38 }
    self.app.assets:draw_world_mechanic_variant(definition.world_id,
      frame, pad.x-size/2, pad.y-size/2, size, size, { color=color })
  end
end

function RunScreen:_draw_world_mechanic_hud()
  if not self.world_mechanic then return end
  local Fonts = require("src.ui.fonts")
  local snapshot = self.world_mechanic:snapshot()
  local w = love.graphics.getWidth()
  local rect = self:world_mechanic_hud_rect(w)
  local panel_w, panel_h = rect.w, rect.h
  local x, y = rect.x, rect.y
  local icon_size = 42
  local boosted = snapshot.boost_remaining > 0
  self.app.assets:draw_upgrade_card_frame(x, y, panel_w, panel_h, {
    corner = 24,
    color = { 0.82, 0.74, 1.0, 0.96 },
  })
  local mechanic_id = self.world_mechanic.definition.id
  local icon_col = mechanic_id == "funk_hold_the_pocket" and 2
    or mechanic_id == "soul_resonance_reserve" and 3
    or mechanic_id == "disco_spotlight_flow" and 4 or 5
  self.app.assets:draw_world_interface(icon_col, 1,
    x + 14, y + (panel_h - icon_size) / 2, icon_size, icon_size)
  local success = snapshot.notice > 0
  love.graphics.setColor(success and { 0.42, 1.0, 0.70, 1 }
    or boosted and { 1.0, 0.76, 0.20, 1 }
    or { 0.30, 0.94, 1.0, 1 })
  love.graphics.setFont(Fonts.heading(10))
  local title = success and snapshot.reward_text
    or mechanic_id == "soul_resonance_reserve"
      and (boosted and ("RESONANCE RESTORED  •  CHAIN ×" .. snapshot.chain)
        or "HOLD THE LIT RESONANCE POOL")
    or mechanic_id == "disco_spotlight_flow"
      and (boosted and ("SPOTLIGHT FLOW  •  CHAIN ×" .. snapshot.chain)
        or "STEP INTO THE MOVING SPOTLIGHT")
    or mechanic_id == "jazz_improvisation"
      and (boosted and ("CHANGES RESOLVED  •  CHAIN ×" .. snapshot.chain)
        or "LAND THE LIT CHORD CHANGE")
    or boosted and ("POCKET BOOST  •  CHAIN ×" .. snapshot.chain)
      or "MOVE TO THE LIT BASS PAD"
  local text_x = x + icon_size + 20
  local text_w = panel_w - icon_size - 34
  love.graphics.printf(title, text_x, y + 14, text_w, "left")
  love.graphics.setColor(0.80, 0.78, 0.90, 1)
  love.graphics.setFont(Fonts.body(9))
  local detail = success and (snapshot.encore_remaining > 0
      and "ENCORE ACTIVE  •  BOSS BREAK CHARGED" or "REWARD SECURED")
    or boosted and ("CHAIN ×" .. snapshot.chain)
    or self.world_mechanic.definition.kind == "charge" and "HOLD TO CHARGE"
    or self.world_mechanic.definition.kind == "call_response"
      and "CHARGE, THEN ANSWER"
    or self.world_mechanic.definition.kind == "relay" and "FOLLOW THE RELAY"
    or self.world_mechanic.definition.kind == "prism_relay"
      and "KEEP THE FLOW MOVING"
    or self.world_mechanic.definition.kind == "changes"
      and "ADAPT TO EACH CHANGE"
    or "ENTER THE HIGHLIGHT"
  love.graphics.printf(detail, text_x, y + 38, text_w, "left")
end

function RunScreen:world_mechanic_hud_rect(width)
  local panel_w = math.min(264, math.max(220, width * 0.22))
  return { x = width - panel_w - 8, y = 76, w = panel_w, h = 64 }
end

function RunScreen:boss_warning_state()
  local threat = self.combat:boss_threat_snapshot()
  if not threat.active or not threat.player_in_range then return { active = false } end
  return {
    active = true,
    title = threat.boss_id == "static_baron"
      and "DANGER: STATIC WAVE RANGE"
      or "DANGER: BOSS ATTACK RANGE",
    detail = threat.windup and threat.windup > 0
      and "ATTACK CHARGING" or "MOVE OUT OF RANGE",
  }
end

function RunScreen:_draw_boss_warning()
  local warning = self:boss_warning_state()
  if not warning.active then return end
  local w, h = love.graphics.getDimensions()
  local reduced = self.app.profile.options.reduced_flash == true
    or self.app.profile.options.hit_flash == false
  local pulse = reduced and 0.55
    or (0.45 + 0.18 * math.sin(self.ctx.time * 7))
  love.graphics.setColor(1.0, 0.22, 0.46, 0.20 + pulse * 0.18)
  love.graphics.setLineWidth(reduced and 2 or 3)
  love.graphics.rectangle("line", 10, 10, w - 20, h - 20, 12, 12)
  love.graphics.setLineWidth(1)

  -- The danger border remains immediate combat feedback. Its text is routed
  -- through the right-side alert stack so it cannot cover the timer or playfield.
end

function RunScreen:_draw_player_feedback()
  local w, h = love.graphics.getDimensions()
  local hit_alpha = self.player.hit_pulse > 0
    and self.player.hit_pulse / 0.26 or 0
  if hit_alpha > 0 then
    love.graphics.setColor(1.0, 0.16, 0.24, 0.10 + hit_alpha * 0.17)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setColor(1.0, 0.72, 0.78, hit_alpha * 0.38)
    love.graphics.setLineWidth(4 + hit_alpha * 7)
    love.graphics.rectangle("line", 4, 4, w - 8, h - 8, 12, 12)
    love.graphics.setLineWidth(1)
  end

  local state = self.player:health_state()
  if state == "normal" then return end
  local effects = self.app.profile.options.hit_flash ~= false
  local speed = state == "critical" and 10 or 3.5
  local pulse = effects and (0.5 + 0.5 * math.sin(self.ctx.time * speed)) or 0.45
  local strength = state == "critical" and 0.18 or 0.075
  love.graphics.setColor(1.0, state == "critical" and 0.04 or 0.24,
    0.16, strength * pulse)
  local edge = state == "critical" and 26 or 15
  love.graphics.rectangle("fill", 0, 0, w, edge)
  love.graphics.rectangle("fill", 0, h - edge, w, edge)
  love.graphics.rectangle("fill", 0, 0, edge, h)
  love.graphics.rectangle("fill", w - edge, 0, edge, h)
end

function RunScreen:reward_chest_pointer(chest, w, h)
  if not w or not h then w, h = love.graphics.getDimensions() end
  local target_x, target_y = self.camera:world_to_screen(chest.x, chest.y)
  local margin = 56
  if target_x >= margin and target_x <= w - margin
    and target_y >= margin + 36 and target_y <= h - margin
  then
    return {
      x = target_x,
      y = target_y - 50,
      angle = math.pi / 2,
      on_screen = true,
    }
  end

  local source_x, source_y = self.camera:world_to_screen(
    self.player.x, self.player.y)
  local vx, vy = target_x - source_x, target_y - source_y
  if math.abs(vx) + math.abs(vy) < 0.01 then vx, vy = 0, -1 end
  local scale = math.huge
  if vx > 0 then
    scale = math.min(scale, (w - margin - source_x) / vx)
  elseif vx < 0 then
    scale = math.min(scale, (margin - source_x) / vx)
  end
  if vy > 0 then
    scale = math.min(scale, (h - margin - source_y) / vy)
  elseif vy < 0 then
    scale = math.min(scale, (margin - source_y) / vy)
  end
  scale = math.max(0, math.min(1, scale))
  return {
    x = source_x + vx * scale,
    y = source_y + vy * scale,
    angle = math.atan2(vy, vx),
    on_screen = false,
  }
end

function RunScreen:_draw_reward_chest_pointers()
  local w, h = love.graphics.getDimensions()
  local pointers = self:reward_chest_pointers(w, h)
  for index, pointer in ipairs(pointers) do
    local pulse = 1 + math.sin(self.ctx.time * 5 + index * 0.8) * 0.08

    love.graphics.setColor(0.025, 0.012, 0.07, 0.90)
    love.graphics.circle("fill", pointer.x, pointer.y, 24 * pulse)
    love.graphics.setColor(1.0, 0.74, 0.20, 0.98)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", pointer.x, pointer.y, 24 * pulse)
    love.graphics.push()
    love.graphics.translate(pointer.x, pointer.y)
    love.graphics.rotate(pointer.angle)
    love.graphics.polygon("fill", 18, 0, -5, -10, -1, 0, -5, 10)
    love.graphics.pop()
  end
  love.graphics.setLineWidth(1)
end

function RunScreen:_draw_boss_pointers()
  local w, h = love.graphics.getDimensions()
  local pointers = self:boss_pointers(w, h)
  local Fonts = require("src.ui.fonts")
  for index, pointer in ipairs(pointers) do
    local pulse = 1 + math.sin(self.ctx.time * 4.5 + index) * 0.10
    love.graphics.setColor(0.035, 0.008, 0.065, 0.94)
    love.graphics.circle("fill", pointer.x, pointer.y, 29 * pulse)
    love.graphics.setColor(1.0, 0.22, 0.62, 1)
    love.graphics.setLineWidth(3)
    love.graphics.circle("line", pointer.x, pointer.y, 29 * pulse)
    love.graphics.push()
    love.graphics.translate(pointer.x, pointer.y)
    love.graphics.rotate(pointer.angle)
    love.graphics.polygon("fill", 22, 0, -7, -12, -2, 0, -7, 12)
    love.graphics.pop()
    love.graphics.setFont(Fonts.get(11))
    love.graphics.setColor(1.0, 0.86, 0.94, 1)
    love.graphics.printf("BOSS", pointer.x - 32, pointer.y + 34, 64, "center")
  end
  love.graphics.setLineWidth(1)
end

function RunScreen:reward_chest_pointers(w, h)
  local pointers = {}
  self.ctx.world:each("reward_chest", function(chest)
    pointers[#pointers + 1] = self:reward_chest_pointer(chest, w, h)
  end)
  return pointers
end

function RunScreen:boss_pointers(w, h)
  local pointers = {}
  self.ctx.world:each("enemy", function(enemy)
    if not enemy.dead and enemy.definition.boss_type == "final" then
      local pointer = self:reward_chest_pointer(enemy, w, h)
      pointer.label = string.upper(enemy.definition.name or "BOSS")
      pointers[#pointers + 1] = pointer
    end
  end)
  return pointers
end

function RunScreen:keypressed(key)
  local settings = require("src.config.settings")
  if settings.debug.admin.enabled and key == settings.debug.admin.toggle_key then
    local AdminScreen = require("src.ui.screens.admin")
    self.app.states:push(AdminScreen(self.app))
    return true
  end
  if key == "=" or key == "+" or key == "kp+" then
    self:adjust_camera_zoom(1)
    return true
  elseif key == "-" or key == "kp-" then
    self:adjust_camera_zoom(-1)
    return true
  end
  if Input.is_action(key, "pause") then
    local PauseScreen = require("src.ui.screens.pause")
    self.app.states:push(PauseScreen(self.app))
    return true
  end
  if key == "l" then return self:open_level_up() end
  if key == "backspace" and self.hud then
    return self.hud:dismiss_top_alert()
  elseif key == "delete" and self.hud then
    return self.hud:clear_alerts()
  end
  if key == "f3" then
    Hitboxes.toggle()
    return true
  elseif key == "c" then
    self:copy_seed()
    return true
  end
  return false
end

function RunScreen:gamepadpressed(_, button)
  if Input.is_gamepad_action(button, "pause") then
    local PauseScreen = require("src.ui.screens.pause")
    self.app.states:push(PauseScreen(self.app))
    return true
  end
  if button == "y" then return self:open_level_up() end
  if button == "leftshoulder" and self.hud then
    return self.hud:dismiss_top_alert()
  elseif button == "rightshoulder" and self.hud then
    return self.hud:clear_alerts()
  end
  return false
end

function RunScreen:mousepressed(x, y, button)
  if self.hud and self.hud:mousepressed(x, y, button) then return true end
  return false
end

return RunScreen
