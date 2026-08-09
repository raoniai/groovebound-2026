local AudioSettings = require("src.audio.audio_settings")
local Fonts = require("src.ui.fonts")
local Icons = require("src.ui.icons")
local UIScale = require("src.ui.scale")

local GlobalAudioControl = {}
GlobalAudioControl.__index = GlobalAudioControl

function GlobalAudioControl.new(app)
  return setmetatable({ app = app, hovered = false }, GlobalAudioControl)
end

function GlobalAudioControl:_rect()
  local w, h = love.graphics.getDimensions()
  local scale = UIScale.factor(w, h)
  local size, margin = 44 * scale, 14 * scale
  return { x = w - size - margin, y = h - size - margin,
    w = size, h = size, scale = scale }
end

function GlobalAudioControl:contains(x, y)
  local r = self:_rect()
  return x >= r.x and x <= r.x + r.w and y >= r.y and y <= r.y + r.h
end

function GlobalAudioControl:toggle()
  AudioSettings.toggle_muted(self.app)
end

function GlobalAudioControl:mousemoved(x, y)
  self.hovered = self:contains(x, y)
  return self.hovered
end

function GlobalAudioControl:mousepressed(x, y, button)
  if button == 1 and self:contains(x, y) then
    self:toggle()
    return true
  end
  return false
end

function GlobalAudioControl:draw()
  local r = self:_rect()
  local muted = self.app.profile.options.muted
  love.graphics.setColor(self.hovered and { 0.18, 0.16, 0.28, 0.98 }
    or { 0.035, 0.025, 0.08, 0.82 })
  love.graphics.rectangle("fill", r.x, r.y, r.w, r.h, 7, 7)
  love.graphics.setColor(muted and { 1.0, 0.38, 0.50, 1 }
    or { 0.30, 0.94, 1.0, 1 })
  love.graphics.setLineWidth(self.hovered and 2 or 1)
  love.graphics.rectangle("line", r.x, r.y, r.w, r.h, 7, 7)
  Icons.draw(muted and "speaker_off" or "speaker",
    r.x + r.w / 2, r.y + r.h / 2, 20 * r.scale,
    muted and { 1.0, 0.38, 0.50, 1 } or { 0.88, 0.96, 1.0, 1 })
  if self.hovered then
    local label = muted and "UNMUTE" or "MUTE"
    local font = Fonts.get(math.floor(13 * r.scale + 0.5))
    local tw = font:getWidth(label) + 18 * r.scale
    love.graphics.setColor(0.035, 0.025, 0.08, 0.96)
    love.graphics.rectangle("fill", r.x - tw - 8 * r.scale,
      r.y + 7 * r.scale, tw, 30 * r.scale, 5 * r.scale, 5 * r.scale)
    love.graphics.setFont(font)
    love.graphics.setColor(0.92, 0.92, 0.97, 1)
    love.graphics.printf(label, r.x - tw - 8 * r.scale,
      r.y + 14 * r.scale, tw, "center")
  end
end

return GlobalAudioControl
