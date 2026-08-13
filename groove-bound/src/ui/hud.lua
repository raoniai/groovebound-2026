-- Run HUD: health bar, run timer, and (in debug) an FPS/entity readout.
-- Screen-space only; drawn after the camera detaches. Fonts come from the
-- cached registry — creating fonts in draw() is banned.

local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local Icons = require("src.ui.icons")
local settings = require("src.config.settings")
local UIScale = require("src.ui.scale")

local HUD = class()

function HUD:init(ctx, player, combat, opts)
  self.ctx = ctx
  self.player = player
  self.combat = combat
  self.opts = opts or {}
  self.dismissed_alerts = {}
  self.current_alerts = {}
  self.alert_close_rects = {}
  self.right_bottom = 68
end

local function contains(rect, x, y)
  return rect and x >= rect.x and x <= rect.x + rect.w
    and y >= rect.y and y <= rect.y + rect.h
end

function HUD:_raw_alerts(stage)
  local alerts = {}
  local function add(id, text, icon, color, alpha)
    if text and text ~= "" then
      alerts[#alerts + 1] = {
        id = id, text = text, icon = icon, color = color,
        alpha = math.min(1, alpha or 1), signature = id .. "\0" .. text,
      }
    end
  end
  if self.combat.xp.notification > 0 then
    add("level", string.format("LEVEL-UP POINTS  ×%d",
      self.combat.xp.pending_choices), 1, { 1.0, 0.76, 0.22, 1 },
      self.combat.xp.notification)
  end
  if self.combat.progression.evolution_notice > 0 then
    add("evolution", self.combat.progression.evolution_notice_text
      or "EVOLUTION READY", 2, { 1.0, 0.76, 0.22, 1 },
      self.combat.progression.evolution_notice)
  end
  local threat = self.combat:boss_threat_snapshot()
  if threat.active and threat.player_in_range then
    add("danger", threat.windup and threat.windup > 0
      and "BOSS ATTACK CHARGING" or "MOVE OUT OF BOSS RANGE",
      3, { 1.0, 0.24, 0.42, 1 }, 1)
  end
  if self.combat.wave_notice_time > 0 then
    add("wave", self.combat.wave_notice, 3, { 1.0, 0.42, 0.65, 1 },
      self.combat.wave_notice_time)
  end
  if self.combat.pickup_notice > 0 then
    add("pickup", self.combat.pickup_notice_text, 4,
      { 0.38, 1.0, 0.76, 1 }, self.combat.pickup_notice)
  end
  if self.combat.progression.upgrade_notice > 0 then
    add("upgrade", self.combat.progression.upgrade_notice_text or "UPGRADED",
      5, { 0.34, 1.0, 0.68, 1 },
      self.combat.progression.upgrade_notice)
  end
  if stage.notice > 0 then
    add("stage", stage.notice_text, 6, { 0.42, 0.92, 1.0, 1 }, stage.notice)
  end
  return alerts
end

function HUD:alert_entries(stage)
  local raw = self:_raw_alerts(stage)
  local active = {}
  for _, alert in ipairs(raw) do active[alert.id] = alert.signature end
  for id, signature in pairs(self.dismissed_alerts) do
    if active[id] ~= signature then self.dismissed_alerts[id] = nil end
  end
  local visible = {}
  for _, alert in ipairs(raw) do
    if self.dismissed_alerts[alert.id] ~= alert.signature then
      visible[#visible + 1] = alert
    end
  end
  return visible
end

function HUD:dismiss_alert(alert)
  if not alert then return false end
  self.dismissed_alerts[alert.id] = alert.signature
  return true
end

function HUD:dismiss_top_alert()
  return self:dismiss_alert(self.current_alerts[1])
end

function HUD:clear_alerts()
  if #self.current_alerts == 0 then return false end
  for _, alert in ipairs(self.current_alerts) do self:dismiss_alert(alert) end
  return true
end

function HUD:right_column_bottom()
  return self.right_bottom or 68
end

function HUD:mousepressed(x, y, button)
  if button ~= 1 then return false end
  x, y = UIScale.point(x, y, self.ui_scale)
  if contains(self.level_up_rect, x, y) and self.opts.on_level_up then
    return self.opts.on_level_up() == true
  end
  if contains(self.clear_alerts_rect, x, y) then return self:clear_alerts() end
  for index, rect in ipairs(self.alert_close_rects) do
    if contains(rect, x, y) then return self:dismiss_alert(self.current_alerts[index]) end
  end
  return false
end

local function draw_panel(x, y, w, h, accent, alpha)
  accent = accent or { 0.42, 0.36, 0.66, 1 }
  local panel_alpha = alpha or 0.50
  love.graphics.setColor(0.022, 0.016, 0.055, panel_alpha)
  love.graphics.rectangle("fill", x, y, w, h, 7, 7)
  love.graphics.setColor(
    accent[1], accent[2], accent[3], math.min(0.62, panel_alpha * 1.16))
  love.graphics.setLineWidth(1)
  love.graphics.rectangle("line", x, y, w, h, 7, 7)
  love.graphics.line(x + 8, y, x + 31, y)
  love.graphics.line(x + w - 31, y + h, x + w - 8, y + h)
end

local function draw_slot(assets, x, y, size, active)
  love.graphics.setColor(0.018, 0.014, 0.045, active and 0.62 or 0.50)
  love.graphics.rectangle("fill", x + 2, y + 2, size - 4, size - 4, 5, 5)
  if assets and assets.draw_hud_slot then
    assets:draw_hud_slot(x, y, size, size,
      { color = { 1, 1, 1, active and 0.78 or 0.32 } })
  else
    love.graphics.setColor(0.34, 0.30, 0.48, active and 0.84 or 0.42)
    love.graphics.rectangle("line", x, y, size, size, 5, 5)
  end
end

function HUD:draw()
  local w, _, scale = UIScale.begin()
  self.ui_scale = scale
  local assets = self.combat.assets

  -- Health bar, top-left.
  local bar_x, bar_y, bar_w, bar_h = 18, 16, 258, 22
  local hp_frac = math.max(0, self.player.hp / self.player.max_hp)
  local health_state = self.player:health_state()
  local effects = self.player.options.hit_flash ~= false
  local pulse_speed = health_state == "critical" and 10 or 3.5
  local urgency = health_state == "normal" and 0
    or effects and (0.5 + 0.5 * math.sin(self.ctx.time * pulse_speed)) or 0.55

  draw_panel(8, 8, 280, 174,
    health_state == "critical" and { 1.0, 0.12, 0.24, 1 }
      or health_state == "concern" and { 1.0, 0.48, 0.18, 1 }
      or { 0.28, 0.72, 1.0, 1 }, 0.50)
  love.graphics.setColor(0.15, 0.12, 0.18, 0.85)
  love.graphics.rectangle("fill", bar_x, bar_y, bar_w, bar_h, 4, 4)
  love.graphics.setColor(health_state == "critical"
    and { 1.0, 0.05, 0.12, 1 }
    or health_state == "concern" and { 1.0, 0.34, 0.16, 1 }
    or { 0.85, 0.25, 0.30, 1 })
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
  if health_state ~= "normal" then
    local state_color = health_state == "critical"
      and { 1.0, 0.22, 0.32, 0.76 + urgency * 0.24 }
      or { 1.0, 0.62, 0.22, 0.76 + urgency * 0.24 }
    Icons.draw(health_state == "critical" and "critical" or "warning",
      bar_x + bar_w - 13, bar_y + bar_h / 2, 18, state_color)
    love.graphics.setColor(health_state == "critical"
      and { 1.0, 0.22, 0.32, 1 }
      or { 1.0, 0.62, 0.22, 1 })
    love.graphics.setFont(Fonts.get(13))
    love.graphics.print(health_state == "critical" and "CRITICAL HP" or "LOW HP",
      bar_x + bar_w - 96, bar_y + 3)
  end
  if self.player.hit_pulse > 0 and self.player.last_damage > 0 then
    local alpha = math.min(1, self.player.hit_pulse / 0.18)
    love.graphics.setColor(1.0, 0.82, 0.86, alpha)
    love.graphics.setFont(Fonts.get(18))
    love.graphics.printf(
      "-" .. math.ceil(self.player.last_damage) .. " HP",
      bar_x, bar_y + 30, bar_w, "right")
  end

  -- XP bar and rank.
  local xp_y = bar_y + bar_h + 8
  local xp_frac = self.combat.xp:progress()
  love.graphics.setColor(0.10, 0.12, 0.18, 0.9)
  love.graphics.rectangle("fill", bar_x, xp_y, bar_w, 10, 3, 3)
  love.graphics.setColor(0.18, 0.92, 0.72, 1)
  love.graphics.rectangle("fill", bar_x, xp_y, bar_w * xp_frac, 10, 3, 3)
  love.graphics.setFont(Fonts.get(12))
  love.graphics.setColor(settings.ui.text_color)
  local weapon = self.combat.inventory:get_slot(1)
  love.graphics.print(
    string.format("LV %d  •  %s R%d  •  W%d/%d  •  P%d/%d",
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
  local rack_y, slot_size, slot_gap = xp_y + 42, 42, 47
  for slot = 1, self.combat.inventory.capacity do
    local rack_x = bar_x + (slot - 1) * slot_gap
    local instance = self.combat.inventory:get_slot(slot)
    draw_slot(assets, rack_x, rack_y, slot_size, instance ~= nil)
    if instance then
      local definition = self.combat.content.weapons[instance.id]
      self.combat.assets:draw_weapon_icon(
        definition.icon, rack_x + slot_size / 2, rack_y + slot_size / 2, 34)
      love.graphics.setColor(settings.ui.accent_color)
      love.graphics.setFont(Fonts.get(14))
      love.graphics.printf("R" .. instance.level,
        rack_x, rack_y + slot_size - 14, slot_size - 2, "right")
    end
  end

  local support_y = rack_y + 47
  for slot = 1, self.combat.progression.passives.capacity do
    local support_x = bar_x + (slot - 1) * slot_gap
    local instance = self.combat.progression.passives.slots[slot]
    draw_slot(assets, support_x, support_y, slot_size, instance ~= nil)
    if instance then
      local definition = self.combat.content.passives[instance.id]
      self.combat.assets:draw_support_icon(
        definition.icon, support_x + slot_size / 2, support_y + slot_size / 2, 31)
      love.graphics.setColor(0.78, 0.48, 1.0, 1)
      love.graphics.setFont(Fonts.get(14))
      love.graphics.printf("R" .. instance.level,
        support_x, support_y + slot_size - 14, slot_size - 2, "right")
    end
  end

  self.level_up_rect = nil
  if self.combat.xp.pending_choices > 0 then
    local rect = { x = 8, y = 190, w = 280, h = 54 }
    self.level_up_rect = rect
    local reduced = self.player.options.reduced_motion == true
    local pulse = reduced and 1 or 0.92 + math.sin(self.ctx.time * 5) * 0.08
    draw_panel(rect.x, rect.y, rect.w, rect.h,
      { 1.0, 0.72, 0.20, 1 }, 0.58 * pulse)
    self.combat.assets:draw_level_alert_icon(
      1, rect.x + 31, rect.y + rect.h / 2, 44)
    love.graphics.setColor(1.0, 0.84, 0.30, 1)
    love.graphics.setFont(Fonts.get(17))
    love.graphics.print(string.format("SPEND LEVEL POINTS  ×%d",
      self.combat.xp.pending_choices), rect.x + 58, rect.y + 8)
    love.graphics.setColor(0.78, 0.77, 0.88, 1)
    love.graphics.setFont(Fonts.get(11))
    love.graphics.print(self.combat.options.automatic_level_up == true
      and "L / △ OPEN  •  AUTO MENU ON"
      or "L / △ OPEN  •  PLAY WHEN READY",
      rect.x + 58, rect.y + 33)
  end

  -- Run timer, top-center.
  local minutes = math.floor(self.ctx.time / 60)
  local seconds = math.floor(self.ctx.time % 60)
  draw_panel(w / 2 - 158, 6, 316, 58, { 0.68, 0.42, 0.90, 1 }, 0.50)
  love.graphics.setFont(Fonts.get(28))
  love.graphics.setColor(settings.ui.text_color)
  love.graphics.printf(string.format("%02d:%02d", minutes, seconds), 0, 14, w, "center")
  love.graphics.setFont(Fonts.get(15))
  love.graphics.setColor(0.78, 0.72, 0.88, 1)
  local stage = self.combat:stage_snapshot(self.ctx.time)
  if stage.is_overtime then
    local overtime = math.floor(stage.overtime)
    love.graphics.setColor(1.0, 0.34, 0.46, 1)
    love.graphics.printf(
      string.format("STAGE %d/%d  •  %s  •  OVERTIME +%02d:%02d",
        stage.stage, stage.count, stage.name,
        math.floor(overtime / 60), overtime % 60),
      0, 42, w, "center")
  else
    local remaining = math.ceil(stage.remaining)
    love.graphics.printf(
      string.format("STAGE %d/%d  •  %s  •  %02d:%02d",
        stage.stage, stage.count, stage.name,
        math.floor(remaining / 60), remaining % 60),
      0, 42, w, "center")
  end

  local toast_y = 72
  self.current_alerts = self:alert_entries(stage)
  self.alert_close_rects = {}
  self.clear_alerts_rect = nil
  if #self.current_alerts > 0 then
    love.graphics.setColor(0.66, 0.66, 0.78, 1)
    love.graphics.setFont(Fonts.get(10))
    love.graphics.print("ALERTS", w - 286, toast_y + 2)
    self.clear_alerts_rect = { x = w - 78, y = toast_y, w = 70, h = 18 }
    love.graphics.setColor(0.54, 0.88, 1.0, 1)
    love.graphics.printf("CLEAR ALL", w - 78, toast_y + 2, 66, "right")
    toast_y = toast_y + 22
  end
  for index, alert in ipairs(self.current_alerts) do
    local toast_x, toast_w, toast_h = w - 286, 278, 34
    draw_panel(toast_x, toast_y, toast_w, toast_h,
      alert.color, 0.48 * alert.alpha)
    self.combat.assets:draw_level_alert_icon(
      alert.icon, toast_x + 19, toast_y + toast_h / 2, 26,
      { color = { 1, 1, 1, alert.alpha } })
    love.graphics.setColor(
      alert.color[1], alert.color[2], alert.color[3], alert.alpha)
    love.graphics.setFont(Fonts.get(12))
    love.graphics.printf(alert.text, toast_x + 38, toast_y + 10,
      toast_w - 72, "left")
    love.graphics.setColor(0.76, 0.76, 0.86, alert.alpha)
    love.graphics.setFont(Fonts.get(14))
    love.graphics.printf("×", toast_x + toast_w - 28, toast_y + 8, 18, "center")
    self.alert_close_rects[index] = {
      x = toast_x + toast_w - 34, y = toast_y, w = 34, h = toast_h,
    }
    toast_y = toast_y + toast_h + 4
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
    local boss_label = boss.definition.name
      .. (boss.overtime_enraged and "  •  OVERTIME ×3" or "")
    love.graphics.printf(boss_label, boss_x, boss_y - 18, boss_w, "center")
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
  draw_panel(w - 272, 10, 264, 54, { 0.70, 0.42, 0.90, 1 }, 0.50)
  Icons.draw("score", w - 248, 37, 22, { 1.0, 0.72, 0.24, 0.92 })
  love.graphics.printf(
    string.format("SCORE %06d   COMBO ×%d",
      self.combat.stats.score, self.combat.stats.combo),
    0, 31, w - 20, "right")

  local buff_colors = {
    damage = { 1.0, 0.68, 0.20, 1 },
    defense = { 0.38, 0.72, 1.0, 1 },
    speed = { 0.46, 1.0, 0.66, 1 },
  }
  local buff_labels = { damage = "DAMAGE +50%", defense = "DEFENSE +50%", speed = "SPEED +35%" }
  local buff_y = toast_y + 6
  for _, kind in ipairs({ "damage", "defense", "speed" }) do
    local remaining = self.combat.buffs[kind]
    if remaining > 0 then
      local color = buff_colors[kind]
      love.graphics.setColor(0.045, 0.035, 0.09, 0.50)
      love.graphics.rectangle("fill", w - 190, buff_y, 174, 32, 5, 5)
      love.graphics.setColor(color)
      love.graphics.rectangle("line", w - 190, buff_y, 174, 32, 5, 5)
      love.graphics.setFont(Fonts.get(14))
      love.graphics.printf(buff_labels[kind] .. "  " .. string.format("%.1fs", remaining),
        w - 182, buff_y + 9, 158, "center")
      buff_y = buff_y + 38
    end
  end
  self.right_bottom = buff_y

  if self.combat.tuning:get("test.enhanced_mode") then
    love.graphics.setColor(1.0, 0.32, 0.66, 0.94)
    love.graphics.setFont(Fonts.get(16))
    love.graphics.printf("5X TEST MODE", 0, 72, w - 16, "right")
  end
  UIScale.finish()
end

return HUD
