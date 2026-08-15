-- Run HUD: health bar, run timer, and (in debug) an FPS/entity readout.
-- Screen-space only; drawn after the camera detaches. Fonts come from the
-- cached registry — creating fonts in draw() is banned.

local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local Icons = require("src.ui.icons")
local Hints = require("src.ui.controller_hints")
local NumberFormat = require("src.ui.number_format")
local RankBadge = require("src.ui.rank_badge")
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
  -- Pending points have a persistent clickable CTA and do not duplicate into
  -- the right alert rail.
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

function HUD:timer_rect(width)
  local side_w = math.max(260, math.min(300, width * 0.235))
  local timer_w = math.max(240, math.min(340, width - side_w * 2 - 24))
  return { x = (width - timer_w) / 2, y = 6, w = timer_w, h = 62 }
end

function HUD:layout_metrics(width)
  local panel_w = math.max(260, math.min(300, width * 0.235))
  local bar_x = 18
  local bar_w = panel_w - 20
  local capacity = math.max(1, self.combat.inventory
    and self.combat.inventory.capacity or 6)
  local slot_gap = 5
  local slot_size = math.floor(math.min(40,
    (bar_w - slot_gap * (capacity - 1)) / capacity))
  local rack_step = capacity > 1
    and (bar_w - slot_size) / (capacity - 1) or 0
  return {
    panel = { x = 8, y = 8, w = panel_w, h = 182 },
    bar_x = bar_x, bar_w = bar_w,
    hp_label_y = 14, hp_y = 26, hp_h = 14,
    guard_label_y = 43, guard_y = 55, guard_h = 11,
    xp_label_y = 69, xp_y = 81, xp_h = 10,
    rack_y = 98, support_y = 143,
    slot_size = slot_size, rack_step = rack_step,
  }
end

function HUD:mousepressed(x, y, button)
  if button ~= 1 then return false end
  x, y = UIScale.point(x, y, self.ui_scale)
  for _, rect in ipairs(self.level_up_tip_rects or {}) do
    if contains(rect, x, y) and self.opts.on_level_up then
      return self.opts.on_level_up() == true
    end
  end
  if contains(self.clear_alerts_rect, x, y) then return self:clear_alerts() end
  for index, rect in ipairs(self.alert_close_rects) do
    if contains(rect, x, y) then return self:dismiss_alert(self.current_alerts[index]) end
  end
  return false
end

local function draw_panel(assets, x, y, w, h, accent, alpha)
  accent = accent or { 0.42, 0.36, 0.66, 1 }
  local panel_alpha = alpha or 0.50
  assets:draw_upgrade_card_frame(x, y, w, h, {
    corner = math.min(18, h * 0.32),
    color = {
      math.max(0.58, accent[1]), math.max(0.58, accent[2]),
      math.max(0.58, accent[3]), math.min(0.96, panel_alpha + 0.34),
    },
  })
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
  local metrics = self:layout_metrics(w)
  local panel = metrics.panel
  local bar_x, bar_w = metrics.bar_x, metrics.bar_w
  local hp_frac = math.max(0, self.player.hp / self.player.max_hp)
  local health_state = self.player:health_state()
  local options = self.player.options or {}
  local effects = options.hit_flash ~= false and options.reduced_flash ~= true
  local pulse_speed = health_state == "critical" and 10 or 3.5
  local urgency = health_state == "normal" and 0
    or effects and (0.5 + 0.5 * math.sin(self.ctx.time * pulse_speed)) or 0.55

  draw_panel(assets, panel.x, panel.y, panel.w, panel.h,
    health_state == "critical" and { 1.0, 0.12, 0.24, 1 }
      or health_state == "concern" and { 1.0, 0.48, 0.18, 1 }
      or { 0.28, 0.72, 1.0, 1 }, 0.50)

  love.graphics.setFont(Fonts.get(9))
  love.graphics.setColor(0.88, 0.87, 0.94, 0.94)
  love.graphics.print(string.format("HP %d / %d",
    math.floor(self.player.hp), self.player.max_hp), bar_x, metrics.hp_label_y)
  if health_state ~= "normal" then
    Icons.draw(health_state == "critical" and "critical" or "warning",
      bar_x + bar_w - 7, metrics.hp_label_y + 5, 11,
      health_state == "critical"
        and { 1.0, 0.24, 0.34, 0.56 + urgency * 0.30 }
        or { 1.0, 0.62, 0.24, 0.58 })
  end
  assets:draw_segmented_bar(bar_x, metrics.hp_y, bar_w, metrics.hp_h, hp_frac, {
    frame_color = health_state == "critical"
      and { 1.0, 0.38, 0.48, 0.68 + urgency * 0.30 }
      or { 1, 1, 1, 0.66 },
    fill_color = health_state == "critical"
      and { 1.0, 0.04 + urgency * 0.10, 0.14, 0.82 + urgency * 0.18 }
      or health_state == "concern" and { 1.0, 0.34, 0.16, 1 }
      or { 0.90, 0.20, 0.28, 1 },
  })

  local guard = math.max(0, self.player.guard or 0)
  local guard_capacity = math.max(25,
    self.player.passive_guard_capacity or 0, guard)
  love.graphics.setFont(Fonts.get(9))
  love.graphics.setColor(0.78, 0.84, 0.96, 0.90)
  love.graphics.print("GUARD " .. math.floor(guard), bar_x, metrics.guard_label_y)
  assets:draw_segmented_bar(bar_x, metrics.guard_y, bar_w, metrics.guard_h,
    guard / guard_capacity, {
      frame_color = { 0.64, 0.82, 1.0, 0.54 },
      fill_color = { 0.26, 0.58, 1.0, 0.96 },
    })

  local xp_frac = self.combat.xp:progress()
  love.graphics.setColor(0.72, 0.90, 0.82, 0.90)
  love.graphics.print(string.format("XP %d%%", math.floor(xp_frac * 100)),
    bar_x, metrics.xp_label_y)
  RankBadge.draw(assets, bar_x + bar_w - 24, metrics.xp_label_y - 2, 23,
    self.combat.xp.level)
  assets:draw_segmented_bar(bar_x, metrics.xp_y, bar_w, metrics.xp_h, xp_frac, {
    frame_color = { 1, 1, 1, 0.50 },
    fill_color = { 0.18, 0.92, 0.62, 1 },
  })

  for slot = 1, self.combat.inventory.capacity do
    local rack_x = bar_x + (slot - 1) * metrics.rack_step
    local instance = self.combat.inventory:get_slot(slot)
    draw_slot(assets, rack_x, metrics.rack_y, metrics.slot_size, instance ~= nil)
    if instance then
      local definition = self.combat.content.weapons[instance.id]
      assets:draw_weapon_icon(definition.icon,
        rack_x + metrics.slot_size / 2, metrics.rack_y + metrics.slot_size / 2,
        metrics.slot_size * 0.80)
      RankBadge.draw(assets, rack_x + metrics.slot_size - 18,
        metrics.rack_y - 4, 22, instance.level,
        { maxed = instance.level >= definition.max_level })
    end
  end
  for slot = 1, self.combat.progression.passives.capacity do
    local support_x = bar_x + (slot - 1) * metrics.rack_step
    local instance = self.combat.progression.passives.slots[slot]
    draw_slot(assets, support_x, metrics.support_y, metrics.slot_size,
      instance ~= nil)
    if instance then
      local definition = self.combat.content.passives[instance.id]
      assets:draw_support_icon(definition.icon,
        support_x + metrics.slot_size / 2,
        metrics.support_y + metrics.slot_size / 2, metrics.slot_size * 0.74)
      RankBadge.draw(assets, support_x + metrics.slot_size - 18,
        metrics.support_y - 4, 22, instance.level,
        { maxed = instance.level >= definition.max_level })
    end
  end

  self.level_up_tip_rects = {}
  if self.combat.xp.pending_choices > 0 then
    local rect = { x = panel.x, y = panel.y + panel.h + 8,
      w = panel.w, h = 40 }
    local reduced = options.reduced_motion == true
    local pulse = reduced and 1 or 0.94 + math.sin(self.ctx.time * 5) * 0.06
    draw_panel(assets, rect.x, rect.y, rect.w, rect.h,
      { 1.0, 0.72, 0.20, 1 }, 0.56 * pulse)
    love.graphics.setColor(1.0, 0.84, 0.30, 1)
    love.graphics.setFont(Fonts.get(13))
    love.graphics.printf("SPEND LEVEL POINTS", rect.x + 14, rect.y + 13,
      rect.w - 66, "center")
    RankBadge.draw(assets, rect.x + rect.w - 43, rect.y + 3, 34,
      self.combat.xp.pending_choices)
    local tip_y, tip_w, tip_h, tip_gap = rect.y + rect.h + 3, 32, 20, 6
    local tip_x = rect.x + (rect.w - tip_w * 2 - tip_gap) / 2
    self.level_up_tip_rects = {
      { x = tip_x, y = tip_y, w = tip_w, h = tip_h },
      { x = tip_x + tip_w + tip_gap, y = tip_y, w = tip_w, h = tip_h },
    }
    for _, tip in ipairs(self.level_up_tip_rects) do
      draw_panel(assets, tip.x, tip.y, tip.w, tip.h,
        { 0.34, 0.94, 1.0, 1 }, 0.48)
    end
    Hints.draw_glyph("triangle", tip_x + tip_w / 2, tip_y + tip_h / 2, 15)
    love.graphics.setColor(0.80, 0.96, 1.0, 1)
    love.graphics.setFont(Fonts.get(11))
    love.graphics.printf("L", tip_x + tip_w + tip_gap, tip_y + 5,
      tip_w, "center")
  end

  -- Run timer, top-center. The lower line is deliberately one row: stage on
  -- the left, remaining time on the right, with elapsed time held centrally.
  local minutes = math.floor(self.ctx.time / 60)
  local seconds = math.floor(self.ctx.time % 60)
  local timer = self:timer_rect(w)
  local timer_x, timer_y, timer_w, timer_h =
    timer.x, timer.y, timer.w, timer.h
  draw_panel(assets, timer_x, timer_y, timer_w, timer_h,
    { 0.68, 0.42, 0.90, 1 }, 0.50)
  love.graphics.setFont(Fonts.get(28))
  love.graphics.setColor(settings.ui.text_color)
  love.graphics.printf(string.format("%02d:%02d", minutes, seconds),
    timer_x, 12, timer_w, "center")
  love.graphics.setFont(Fonts.get(12))
  love.graphics.setColor(0.78, 0.72, 0.88, 1)
  local stage = self.combat:stage_snapshot(self.ctx.time)
  if stage.is_overtime then
    local overtime = math.floor(stage.overtime)
    love.graphics.setColor(1.0, 0.34, 0.46, 1)
    love.graphics.printf(string.format("STAGE %d/%d  •  %s",
      stage.stage, stage.count, stage.name), timer_x + 16, 45,
      timer_w - 110, "left")
    love.graphics.printf(string.format("+%02d:%02d",
      math.floor(overtime / 60), overtime % 60), timer_x + timer_w - 90,
      45, 74, "right")
  else
    local remaining = math.ceil(stage.remaining)
    love.graphics.printf(string.format("STAGE %d/%d  •  %s",
      stage.stage, stage.count, stage.name), timer_x + 16, 45,
      timer_w - 110, "left")
    love.graphics.printf(string.format("%02d:%02d",
      math.floor(remaining / 60), remaining % 60),
      timer_x + timer_w - 90, 45, 74, "right")
  end

  -- Dedicated sprite devices keep score and combo distinct and legible.
  local score_devices = {
    { x = w - 272, w = 130, label = "SCORE", value = NumberFormat.integer(self.combat.stats.score), icon = 11 },
    { x = w - 138, w = 130, label = "COMBO", value = "×" .. self.combat.stats.combo, icon = 12 },
  }
  for _, device in ipairs(score_devices) do
    draw_panel(assets, device.x, 8, device.w, 56,
      { 0.70, 0.42, 0.90, 1 }, 0.50)
    assets:draw_menu_stat_icon(device.icon, device.x + 9, 18, 34,
      { color = { 1, 1, 1, 0.94 } })
    love.graphics.setColor(0.70, 0.72, 0.84, 1)
    love.graphics.setFont(Fonts.get(9))
    love.graphics.print(device.label, device.x + 48, 17)
    love.graphics.setColor(1.0, 0.78, 0.26, 1)
    love.graphics.setFont(Fonts.get(13))
    love.graphics.printf(device.value, device.x + 48, 31,
      device.w - 57, "left")
  end

  local toast_y = 72
  if self.opts.get_world_mechanic_rect then
    local reserved = self.opts.get_world_mechanic_rect(w)
    if reserved then toast_y = math.max(toast_y, reserved.y + reserved.h + 8) end
  end
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
    draw_panel(assets, toast_x, toast_y, toast_w, toast_h,
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
    local boss_w, boss_h = math.max(240,
      math.min(520, w * 0.50, w - panel.w * 2 - 24)), 14
    local boss_x, boss_y = (w - boss_w) / 2, timer_y + timer_h + 20
    assets:draw_segmented_bar(boss_x, boss_y, boss_w, boss_h,
      boss.hp / boss.max_hp, { fill_color = { 0.95, 0.18, 0.48, 1 } })
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.get(11))
    local boss_label = boss.definition.name
      .. (boss.overtime_enraged and "  •  OVERTIME ×3" or "")
    love.graphics.printf(boss_label, boss_x, boss_y - 15, boss_w, "center")
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
      draw_panel(assets, w - 190, buff_y, 174, 32, color, 0.50)
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
