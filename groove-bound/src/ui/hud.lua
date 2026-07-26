-- Run HUD: health bar, run timer, and (in debug) an FPS/entity readout.
-- Screen-space only; drawn after the camera detaches. Fonts come from the
-- cached registry — creating fonts in draw() is banned.

local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")

local HUD = class()

function HUD:init(ctx, player, combat)
  self.ctx = ctx
  self.player = player
  self.combat = combat
end

function HUD:draw()
  local w = love.graphics.getWidth()

  -- Health bar, top-left.
  local bar_x, bar_y, bar_w, bar_h = 16, 16, 280, 24
  local hp_frac = math.max(0, self.player.hp / self.player.max_hp)

  love.graphics.setColor(0.15, 0.12, 0.18, 0.85)
  love.graphics.rectangle("fill", bar_x, bar_y, bar_w, bar_h, 4, 4)
  love.graphics.setColor(0.85, 0.25, 0.30, 1)
  love.graphics.rectangle("fill", bar_x, bar_y, bar_w * hp_frac, bar_h, 4, 4)
  love.graphics.setColor(0.6, 0.55, 0.7, 1)
  love.graphics.setLineWidth(1)
  love.graphics.rectangle("line", bar_x, bar_y, bar_w, bar_h, 4, 4)

  love.graphics.setColor(settings.ui.text_color)
  love.graphics.setFont(Fonts.get(15))
  love.graphics.print(
    string.format("HP %d / %d   GUARD %d",
      math.floor(self.player.hp), self.player.max_hp, self.player.guard),
    bar_x + 8, bar_y + 3)

  -- XP bar and rank.
  local xp_y = bar_y + bar_h + 8
  local xp_frac = self.combat.xp:progress()
  love.graphics.setColor(0.10, 0.12, 0.18, 0.9)
  love.graphics.rectangle("fill", bar_x, xp_y, bar_w, 10, 3, 3)
  love.graphics.setColor(0.18, 0.92, 0.72, 1)
  love.graphics.rectangle("fill", bar_x, xp_y, bar_w * xp_frac, 10, 3, 3)
  love.graphics.setFont(Fonts.get(14))
  love.graphics.setColor(settings.ui.text_color)
  local weapon = self.combat.inventory:get_slot(1)
  love.graphics.print(
    string.format("LV %d  %s R%d  W%d/%d  P%d/%d",
      self.combat.xp.level,
      self.combat.content.weapons[weapon.id].name,
      weapon.level,
      self.combat.inventory:count(),
      self.combat.inventory.capacity,
      self.combat.progression.passives:count(),
      self.combat.progression.passives.capacity),
    bar_x, xp_y + 14)

  -- Always-visible weapon rack. This mirrors the authoritative inventory so
  -- players can read every active emitter and rank without opening a menu.
  local rack_y = xp_y + 48
  for slot = 1, self.combat.inventory.capacity do
    local rack_x = bar_x + (slot - 1) * 56
    love.graphics.setColor(0.08, 0.07, 0.13, 0.88)
    love.graphics.rectangle("fill", rack_x, rack_y, 48, 48, 5, 5)
    local instance = self.combat.inventory:get_slot(slot)
    if instance then
      local definition = self.combat.content.weapons[instance.id]
      self.combat.assets:draw_weapon_icon(
        definition.icon, rack_x + 24, rack_y + 23, 42)
      love.graphics.setColor(settings.ui.accent_color)
      love.graphics.setFont(Fonts.get(14))
      love.graphics.printf("R" .. instance.level, rack_x, rack_y + 34, 48, "right")
    else
      love.graphics.setColor(0.27, 0.24, 0.35, 1)
      love.graphics.rectangle("line", rack_x, rack_y, 48, 48, 5, 5)
      love.graphics.setFont(Fonts.get(14))
      love.graphics.printf(tostring(slot), rack_x, rack_y + 16, 48, "center")
    end
  end

  local support_y = rack_y + 56
  for slot = 1, self.combat.progression.passives.capacity do
    local support_x = bar_x + (slot - 1) * 56
    love.graphics.setColor(0.08, 0.07, 0.13, 0.88)
    love.graphics.rectangle("fill", support_x, support_y, 48, 40, 5, 5)
    local instance = self.combat.progression.passives.slots[slot]
    if instance then
      local definition = self.combat.content.passives[instance.id]
      self.combat.assets:draw_support_icon(
        definition.icon, support_x + 21, support_y + 19, 34)
      love.graphics.setColor(0.78, 0.48, 1.0, 1)
      love.graphics.setFont(Fonts.get(14))
      love.graphics.printf("R" .. instance.level, support_x, support_y + 27, 48, "right")
    else
      love.graphics.setColor(0.27, 0.24, 0.35, 1)
      love.graphics.rectangle("line", support_x, support_y, 48, 40, 5, 5)
    end
  end

  -- Run timer, top-center.
  local minutes = math.floor(self.ctx.time / 60)
  local seconds = math.floor(self.ctx.time % 60)
  love.graphics.setFont(Fonts.get(28))
  love.graphics.setColor(settings.ui.text_color)
  love.graphics.printf(string.format("%02d:%02d", minutes, seconds), 0, 14, w, "center")
  love.graphics.setFont(Fonts.get(15))
  love.graphics.setColor(0.78, 0.72, 0.88, 1)
  local stage = self.combat:stage_snapshot(self.ctx.time)
  local remaining = math.ceil(stage.remaining)
  love.graphics.printf(
    string.format("STAGE %d/%d  •  %s  •  %02d:%02d",
      stage.stage,
      stage.count,
      stage.name,
      math.floor(remaining / 60),
      remaining % 60),
    0, 42, w, "center")

  if self.combat.xp.notification > 0 then
    love.graphics.setFont(Fonts.get(30))
    love.graphics.setColor(0.96, 0.78, 0.22, math.min(1, self.combat.xp.notification))
    love.graphics.printf("LEVEL UP!", 0, 92, w, "center")
  end

  if self.combat.progression.evolution_notice > 0 then
    local alpha = math.min(1, self.combat.progression.evolution_notice)
    love.graphics.setColor(0.08, 0.04, 0.14, 0.92 * alpha)
    love.graphics.rectangle("fill", w / 2 - 250, 104, 500, 48, 7, 7)
    love.graphics.setColor(1.0, 0.76, 0.22, alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", w / 2 - 250, 104, 500, 48, 7, 7)
    love.graphics.setFont(Fonts.get(18))
    love.graphics.printf(
      self.combat.progression.evolution_notice_text or "YOU CAN EVOLVE NOW",
      w / 2 - 238, 119, 476, "center")
  end

  if self.combat.wave_notice_time > 0 then
    love.graphics.setFont(Fonts.get(28))
    love.graphics.setColor(0.96, 0.42, 0.65, math.min(1, self.combat.wave_notice_time))
    love.graphics.printf(self.combat.wave_notice, 0, 132, w, "center")
  end

  if stage.notice > 0 then
    local alpha = math.min(1, stage.notice)
    love.graphics.setColor(0.04, 0.02, 0.08, 0.86 * alpha)
    love.graphics.rectangle("fill", w / 2 - 300, 164, 600, 64, 8, 8)
    love.graphics.setColor(0.34, 1.0, 0.74, alpha)
    love.graphics.setFont(Fonts.get(28))
    love.graphics.printf(stage.notice_text, w / 2 - 280, 181, 560, "center")
  end

  local boss
  self.ctx.world:each("enemy", function(enemy)
    if enemy.definition.boss_type then boss = enemy end
  end)
  if boss then
    local boss_w, boss_h = math.min(560, w * 0.55), 16
    local boss_x, boss_y = (w - boss_w) / 2, 70
    love.graphics.setColor(0.08, 0.04, 0.12, 0.95)
    love.graphics.rectangle("fill", boss_x, boss_y, boss_w, boss_h, 4, 4)
    love.graphics.setColor(0.95, 0.18, 0.48, 1)
    love.graphics.rectangle("fill", boss_x, boss_y, boss_w * boss.hp / boss.max_hp, boss_h, 4, 4)
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.get(15))
    love.graphics.printf(boss.definition.name, boss_x, boss_y - 18, boss_w, "center")
  end

  -- Debug readout, top-right.
  if settings.debug.enabled and settings.debug.overlay.visible then
    love.graphics.setFont(Fonts.get(14))
    love.graphics.setColor(0.6, 0.9, 0.6, 0.9)
    local text = string.format(
      "fps %d  %.2fms  enemies %d  bullets %d/%d  gems %d  pools %d/%d/%d  kills %d  seed %d",
      love.timer.getFPS(),
      self.combat.frame_time_ms,
      self.ctx.world:count("enemy"),
      self.ctx.world:count("projectile"),
      self.ctx.world:count("enemy_projectile"),
      self.ctx.world:count("xp_gem"),
      self.combat.enemy_pool.created,
      self.combat.projectile_pool.created,
      self.combat.gem_pool.created,
      self.combat.stats.kills,
      self.ctx.seed)
    love.graphics.printf(text, 0, 18, w - 16, "right")
  end

  love.graphics.setFont(Fonts.get(14))
  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.printf(
    string.format("SCORE %06d   COMBO ×%d",
      self.combat.stats.score, self.combat.stats.combo),
    0, 48, w - 16, "right")
end

return HUD
