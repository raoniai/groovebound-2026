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
  love.graphics.setColor(0.28, 0.92, 1.0, 0.28)
  love.graphics.circle("fill", w / 2, panel_y + 115, 92 + math.sin(self.elapsed * 4) * 6)
  love.graphics.setColor(1.0, 0.74, 0.20, 1)
  love.graphics.setLineWidth(3)
  love.graphics.rectangle("line", panel_x, panel_y, panel_w, panel_h, 18, 18)
  love.graphics.setLineWidth(1)

  local complete_title = self.payload.outcome == "victory"
    and "CAMPAIGN COMPLETE" or ("STAGE " .. self.payload.stage_index .. " COMPLETE")
  love.graphics.setFont(Fonts.get(38))
  love.graphics.setColor(1.0, 0.76, 0.22, 1)
  love.graphics.printf(complete_title, panel_x + 28, panel_y + 58, panel_w - 56, "center")
  love.graphics.setFont(Fonts.get(22))
  love.graphics.setColor(0.34, 0.94, 1.0, 1)
  love.graphics.printf(self.payload.stage_name, panel_x + 28, panel_y + 112, panel_w - 56, "center")
  love.graphics.setFont(Fonts.get(16))
  love.graphics.setColor(0.86, 0.84, 0.92, 1)
  love.graphics.printf("ENCORE CHEST CLAIMED  •  RESONANCE SECURED",
    panel_x + 28, panel_y + 154, panel_w - 56, "center")

  local stats = self.payload.stats or {}
  love.graphics.setColor(0.08, 0.04, 0.14, 0.96)
  love.graphics.rectangle("fill", w / 2 - 190, panel_y + 198, 380, 58, 10, 10)
  love.graphics.setFont(Fonts.get(16))
  love.graphics.setColor(0.76, 0.74, 0.86, 1)
  love.graphics.printf(string.format("%d ENEMIES CLEARED   •   %d BOSS DEFEATED",
    stats.kills or 0, stats.bosses or 1), w / 2 - 190, panel_y + 218, 380, "center")

  love.graphics.pop()

  if self:is_ready() then
    local rect = self.continue_rect
    love.graphics.setColor(0.08, 0.04, 0.14, 0.98)
    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 10, 10)
    love.graphics.setColor(1.0, 0.76, 0.22, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 10, 10)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Fonts.get(19))
    love.graphics.printf("CONTINUE", rect.x, rect.y + 16, rect.w, "center")
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
