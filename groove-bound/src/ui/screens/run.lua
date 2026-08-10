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

local RunScreen = class()
RunScreen.kind = "run"

function RunScreen:init(app, opts)
  self.app = app
  self.opts = opts or {}
end

function RunScreen:enter()
  self.character = self.app.content.characters[
    self.opts.character_id or "joe"]
  self.ctx = RunContext({
    seed = self.opts.seed,
    app_bus = self.app.bus,
    tuning = self.app.tuning,
  })
  self.app.log.info("state", "Run started (seed " .. self.ctx.seed .. ")")

  self.arena = Arena({
    assets = self.app.assets,
    stage = self.app.content.stages[1],
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
  })
  self.hud = HUD(self.ctx, self.player, self.combat)
  self.finished = false
  self.transitioning = false
  self.choice_open = false
  self.pending_outcome = nil
  self.seed_notice = 0
  self.music_event_serial = 0
  self.music_event = nil
  self.app.active_run = self
end

function RunScreen:_results_payload(outcome)
  return {
    outcome = outcome,
    stats = self.combat.stats,
    level = self.combat.xp.level,
    progression = self.combat.progression:snapshot(),
    time = self.ctx.time,
    character = self.character,
    stages_cleared = outcome == "victory" and 2 or self.combat.stage_index - 1,
  }
end

function RunScreen:_show_results(outcome)
  local ResultsScreen = require("src.ui.screens.results")
  self.app.states:push(ResultsScreen(
    self.app, self:_results_payload(outcome)))
end

function RunScreen:exit()
  if self.app.active_run == self then self.app.active_run = nil end
  self.ctx:destroy()
  self.app.log.info("state", "Run ended")
end

function RunScreen:update(dt)
  local time_scale = self.app.tuning:get("simulation.time_scale")
  local sim_dt = dt * time_scale
  self.seed_notice = math.max(0, self.seed_notice - dt)
  local outcome = self.pending_outcome
  if not outcome then
    self.ctx:update(sim_dt)
    self.player:update(sim_dt, self.input, self.camera, self.arena)
    self.ctx.world:moved(self.player)
    outcome = self.combat:update(sim_dt)
    self.camera:follow(self.player.x, self.player.y, sim_dt)
    self.camera:update(sim_dt)
  end

  local chest_reveal = self.combat:take_pending_chest_reveal()
  if chest_reveal and not self.choice_open then
    self.choice_open = true
    self.pending_outcome = outcome
    local ChestRewardScreen = require("src.ui.screens.chest_reward")
    self.app.states:push(ChestRewardScreen(
      self.app, chest_reveal))
  elseif outcome == "stage_clear" and not self.transitioning then
    self.pending_outcome = nil
    self.transitioning = true
    local StageCompleteScreen = require("src.ui.screens.stage_complete")
    local stage = self.app.content.stages[self.combat.stage_index]
    self.app.states:push(StageCompleteScreen(self.app, {
      outcome = "stage_clear",
      stage_index = self.combat.stage_index,
      stage_name = stage.name,
      stats = self.combat.stats,
    }))
  elseif outcome == "victory" and not self.finished then
    self.pending_outcome = nil
    self.finished = true
    local StageCompleteScreen = require("src.ui.screens.stage_complete")
    local stage = self.app.content.stages[self.combat.stage_index]
    self.app.states:push(StageCompleteScreen(self.app, {
      outcome = "victory",
      stage_index = self.combat.stage_index,
      stage_name = stage.name,
      stats = self.combat.stats,
    }))
  elseif outcome == "defeat" and not self.finished then
    self.pending_outcome = nil
    self.finished = true
    self:_show_results("defeat")
  elseif self.combat.xp:has_pending_choice() and not self.choice_open then
    self.choice_open = true
    local LevelUpScreen = require("src.ui.screens.level_up")
    self.app.states:push(LevelUpScreen(self.app, self.combat))
  end
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
  if result and result.kind == "stage_complete" then
    self.music_event_serial = self.music_event_serial + 1
    self.music_event = {
      cue = "stage_clear_sting",
      serial = self.music_event_serial,
    }
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
      stage = self.app.content.stages[2],
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
  if self.seed_notice > 0 then
    local Fonts = require("src.ui.fonts")
    love.graphics.setFont(Fonts.get(14))
    love.graphics.setColor(0.96, 0.78, 0.22, math.min(1, self.seed_notice))
    love.graphics.printf(self.status_notice_text or "SEED COPIED",
      0, love.graphics.getHeight() - 42,
      love.graphics.getWidth(), "center")
  end
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
  local Fonts = require("src.ui.fonts")
  local w, h = love.graphics.getDimensions()
  local reduced = self.app.profile.options.reduced_flash == true
    or self.app.profile.options.hit_flash == false
  local pulse = reduced and 0.72
    or (0.55 + 0.45 * math.sin(self.ctx.time * 13))
  love.graphics.setColor(1.0, 0.05, 0.24, 0.10 + pulse * 0.12)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.setColor(1.0, 0.22, 0.46, 0.72 + pulse * 0.24)
  love.graphics.setLineWidth(6)
  love.graphics.rectangle("line", 6, 6, w - 12, h - 12, 12, 12)
  love.graphics.setLineWidth(1)

  local panel_w = math.min(440, w - 48)
  love.graphics.setColor(0.035, 0.008, 0.055, 0.94)
  love.graphics.rectangle("fill", (w - panel_w) / 2, 22, panel_w, 64, 10, 10)
  love.graphics.setColor(1.0, 0.30, 0.52, 1)
  love.graphics.setFont(Fonts.get(20))
  love.graphics.printf(warning.title, (w - panel_w) / 2, 31, panel_w, "center")
  love.graphics.setColor(1.0, 0.88, 0.94, 1)
  love.graphics.setFont(Fonts.get(13))
  love.graphics.printf(warning.detail, (w - panel_w) / 2, 59, panel_w, "center")
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
  return false
end

return RunScreen
