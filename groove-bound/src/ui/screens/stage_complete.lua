local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local Hints = require("src.ui.controller_hints")
local UIScale = require("src.ui.scale")

local StageCompleteScreen = class()
StageCompleteScreen.kind = "stage_complete"
StageCompleteScreen.opaque = false

local READY_DELAY = 0.75

local function contains(rect, x, y)
  return rect and x >= rect.x and y >= rect.y
    and x <= rect.x + rect.w and y <= rect.y + rect.h
end

function StageCompleteScreen:init(app, payload)
  self.app = app
  self.payload = assert(payload)
  self.elapsed = 0
  self.continue_rect = nil
end

function StageCompleteScreen:enter()
  self:_layout()
end

function StageCompleteScreen:_layout()
  local w, h, scale = UIScale.dimensions()
  self.ui_scale = scale
  self.continue_rect = {
    x = w / 2 - 160,
    y = h / 2 + 112,
    w = 320,
    h = 54,
  }
end

function StageCompleteScreen:resize()
  self:_layout()
end

function StageCompleteScreen:update(dt)
  self.elapsed = self.elapsed + dt
end

function StageCompleteScreen:is_ready()
  return self.elapsed >= READY_DELAY
end

function StageCompleteScreen:header_cell()
  if self.payload.mode == "world_tour" then return 4 end
  if self.payload.outcome == "victory" then return 3 end
  return self.payload.stage_index == 1 and 1 or 2
end

function StageCompleteScreen:_continue()
  if not self:is_ready() then return false end
  self.app.states:pop({
    kind = "stage_complete",
    outcome = self.payload.outcome,
  })
  return true
end

function StageCompleteScreen:draw()
  local screen_w, screen_h = love.graphics.getDimensions()
  local reduced = self.app.profile.options.reduced_motion == true
  local entrance = math.min(1, self.elapsed / READY_DELAY)
  local eased = 1 - (1 - entrance) ^ 3
  local panel_scale = reduced and 1 or (0.90 + eased * 0.10)

  love.graphics.setColor(0.01, 0.003, 0.025, 0.78 * eased)
  love.graphics.rectangle("fill", 0, 0, screen_w, screen_h)
  local w, h = UIScale.begin()

  love.graphics.push()
  love.graphics.translate(w / 2, h / 2)
  love.graphics.scale(panel_scale, panel_scale)
  love.graphics.translate(-w / 2, -h / 2)

  local panel_w = math.min(720, w - 64)
  local panel_h = math.min(410, h - 92)
  local panel_x = (w - panel_w) / 2
  local panel_y = (h - panel_h) / 2
  love.graphics.setColor(0.025, 0.012, 0.070, 0.98)
  love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 18, 18)
  self.app.assets:draw_hud_frame(panel_x, panel_y, panel_w, panel_h, {
    color = { 1.0, 0.72, 0.20, 0.96 * eased },
  })

  local crest_size = 118
  local crest_bob = reduced and 0 or math.sin(self.elapsed * 3.4) * 3
  local world_col = self.payload.world_id == "funk" and 2
    or self.payload.world_id == "soul" and 3
    or self.payload.world_id == "disco" and 4 or 1
  self.app.assets:draw_world_interface(world_col, 1,
    panel_x + 36, panel_y + 28 + crest_bob,
    crest_size, crest_size,
    { color = { 1, 1, 1, eased } })

  local complete_title = self.payload.outcome == "victory"
    and (self.payload.mode == "world_tour"
      and "WORLD MASTERED" or "CAMPAIGN COMPLETE")
    or ("STAGE " .. self.payload.stage_index .. " COMPLETE")
  love.graphics.setFont(Fonts.get(30))
  love.graphics.setColor(1.0, 0.76, 0.22, 1)
  love.graphics.printf(complete_title,
    panel_x + 174, panel_y + 48, panel_w - 214, "center")
  love.graphics.setFont(Fonts.get(19))
  love.graphics.setColor(0.34, 0.94, 1.0, 1)
  love.graphics.printf(self.payload.stage_name,
    panel_x + 174, panel_y + 91, panel_w - 214, "center")

  local status_y = panel_y + 158
  local status_gap = 16
  local status_w = 230
  local status_start = w / 2 - status_w - status_gap / 2
  for index, status in ipairs({
    { kind = "chest", text = "ENCORE CHEST CLAIMED",
      color = { 1.0, 0.70, 0.20, 0.95 } },
    { kind = "mechanic", text = "WORLD MECHANIC SECURED",
      color = { 0.28, 0.90, 1.0, 0.95 } },
  }) do
    local x = status_start + (index - 1) * (status_w + status_gap)
    love.graphics.setColor(0.042, 0.020, 0.090, 0.94)
    love.graphics.rectangle("fill", x, status_y, status_w, 58, 9, 9)
    love.graphics.setColor(status.color[1], status.color[2], status.color[3], eased)
    love.graphics.rectangle("line", x, status_y, status_w, 58, 9, 9)
    if status.kind == "chest" then
      self.app.assets:draw_stage_clear_chest(
        x + 30, status_y + 29, 50, { color = { 1, 1, 1, eased } })
    elseif self.payload.world_id == "funk" then
      self.app.assets:draw_funk_pad(5, x + 5, status_y + 4, 50, 50,
        { color = { 1, 1, 1, eased } })
    else
      local row = self.payload.world_id == "soul" and 1 or 2
      self.app.assets:draw_world_mechanic(5, row,
        x + 5, status_y + 4, 50, 50,
        { color = { 1, 1, 1, eased } })
    end
    love.graphics.setFont(Fonts.get(12))
    love.graphics.setColor(0.86, 0.84, 0.92, eased)
    love.graphics.printf(status.text, x + 58, status_y + 19,
      status_w - 66, "center")
  end

  local stats = self.payload.stats or {}
  local stats_y = panel_y + 226
  local stat_values = {
    { col = world_col, value = stats.kills or 0, label = "ENEMIES CLEARED",
      color = { 0.88, 0.34, 1.0, 0.92 } },
    { col = 5, value = stats.bosses or 1, label = "BOSSES DEFEATED",
      color = { 1.0, 0.72, 0.20, 0.92 } },
  }
  local stat_w = 210
  local stat_start = w / 2 - stat_w - 10
  for index, stat in ipairs(stat_values) do
    local x = stat_start + (index - 1) * (stat_w + 20)
    love.graphics.setColor(0.045, 0.022, 0.090, 0.92)
    love.graphics.rectangle("fill", x, stats_y, stat_w, 70, 10, 10)
    love.graphics.setColor(stat.color[1], stat.color[2], stat.color[3], eased)
    love.graphics.rectangle("line", x, stats_y, stat_w, 70, 10, 10)
    self.app.assets:draw_world_interface(stat.col, 2,
      x + 8, stats_y + 7, 56, 56, { color = { 1, 1, 1, eased } })
    love.graphics.setFont(Fonts.get(23))
    love.graphics.setColor(1.0, 0.76, 0.22, eased)
    love.graphics.printf(tostring(stat.value), x + 66, stats_y + 11,
      stat_w - 76, "center")
    love.graphics.setFont(Fonts.get(11))
    love.graphics.setColor(0.76, 0.74, 0.86, eased)
    love.graphics.printf(stat.label, x + 66, stats_y + 41,
      stat_w - 76, "center")
  end

  love.graphics.pop()

  if self:is_ready() then
    local rect = self.continue_rect
    love.graphics.setColor(0.08, 0.04, 0.14, 0.98)
    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 10, 10)
    self.app.assets:draw_menu_button_icon(
      1, 1, rect.x + 10, rect.y + 6, 42, 42)
    love.graphics.setColor(1.0, 0.76, 0.22, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 10, 10)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Fonts.get(19))
    love.graphics.printf("CONTINUE", rect.x + 46, rect.y + 16,
      rect.w - 56, "center")
  end

  love.graphics.setColor(0.015, 0.01, 0.05, 0.94)
  love.graphics.rectangle("fill", 0, h - 40, w, 40)
  Hints.draw(self:is_ready() and {
    { symbol = "cross", label = "Continue" },
  } or {
    { symbol = "options", label = "Securing resonance" },
  }, h - 30, w, { font_size = 13, glyph_size = 18, gap = 18 })
  UIScale.finish()
end

function StageCompleteScreen:keypressed(key)
  if key == "return" or key == "space" or key == "x" then
    return self:_continue()
  end
  return false
end

function StageCompleteScreen:gamepadpressed(_, button)
  if button == "a" then return self:_continue() end
  return false
end

function StageCompleteScreen:mousepressed(x, y, button)
  x, y = UIScale.point(x, y, self.ui_scale)
  if button == 1 and contains(self.continue_rect, x, y) then
    return self:_continue()
  end
  return false
end

return StageCompleteScreen
