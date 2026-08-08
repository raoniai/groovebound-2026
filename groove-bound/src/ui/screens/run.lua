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
  self.ctx:update(sim_dt)

  self.player:update(sim_dt, self.input, self.camera, self.arena)
  self.ctx.world:moved(self.player)
  local outcome = self.combat:update(sim_dt)

  self.camera:follow(self.player.x, self.player.y, sim_dt)
  self.camera:update(sim_dt)

  if outcome == "stage_clear" and not self.transitioning then
    self.transitioning = true
    self.music_event_serial = self.music_event_serial + 1
    self.music_event = {
      cue = "stage_clear_sting",
      serial = self.music_event_serial,
    }
    local CutsceneScreen = require("src.ui.screens.cutscene")
    self.app.states:push(CutsceneScreen(
      self.app,
      self.app.content.narrative.stage2_transition,
      { result = "stage2" }))
  elseif outcome == "victory" and not self.finished then
    self.finished = true
    local CutsceneScreen = require("src.ui.screens.cutscene")
    self.app.states:push(CutsceneScreen(
      self.app,
      self.app.content.narrative.ending,
      { result = "campaign_complete" }))
  elseif outcome == "defeat" and not self.finished then
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
  return self.ctx.seed
end

function RunScreen:resume(result)
  self.choice_open = false
  if result == "stage2" then
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
  self.player:draw()
  self.combat.vfx:draw()
  Hitboxes.draw(self.ctx.world)
  self.camera:detach()

  self.hud:draw()
  self:_draw_reward_chest_pointer()
  if self.seed_notice > 0 then
    local Fonts = require("src.ui.fonts")
    love.graphics.setFont(Fonts.get(14))
    love.graphics.setColor(0.96, 0.78, 0.22, math.min(1, self.seed_notice))
    love.graphics.printf("SEED COPIED", 0, love.graphics.getHeight() - 42,
      love.graphics.getWidth(), "center")
  end
end

function RunScreen:_draw_reward_chest_pointer()
  local target, best_distance
  self.ctx.world:each("reward_chest", function(chest)
    local dx, dy = chest.x - self.player.x, chest.y - self.player.y
    local distance = dx * dx + dy * dy
    if not target or distance < best_distance then
      target, best_distance = chest, distance
    end
  end)
  if not target then return end

  local w, h = love.graphics.getDimensions()
  local target_x, target_y = self.camera:world_to_screen(target.x, target.y)
  local vx, vy = target_x - w / 2, target_y - h / 2
  if math.abs(vx) + math.abs(vy) < 0.01 then vx, vy = 0, -1 end
  local margin = 56
  local x_scale = (w / 2 - margin) / math.max(0.001, math.abs(vx))
  local y_scale = (h / 2 - margin) / math.max(0.001, math.abs(vy))
  local scale = math.min(x_scale, y_scale)
  local x = w / 2 + vx * scale
  local y = h / 2 + vy * scale
  local angle = math.atan2(vy, vx)
  local pulse = 1 + math.sin(self.ctx.time * 5) * 0.08

  love.graphics.setColor(0.025, 0.012, 0.07, 0.90)
  love.graphics.circle("fill", x, y, 24 * pulse)
  love.graphics.setColor(1.0, 0.74, 0.20, 0.98)
  love.graphics.setLineWidth(2)
  love.graphics.circle("line", x, y, 24 * pulse)
  love.graphics.push()
  love.graphics.translate(x, y)
  love.graphics.rotate(angle)
  love.graphics.polygon("fill", 18, 0, -5, -10, -1, 0, -5, 10)
  love.graphics.pop()
  love.graphics.setLineWidth(1)
end

function RunScreen:keypressed(key)
  local settings = require("src.config.settings")
  if settings.debug.admin.enabled and key == settings.debug.admin.toggle_key then
    local AdminScreen = require("src.ui.screens.admin")
    self.app.states:push(AdminScreen(self.app))
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
