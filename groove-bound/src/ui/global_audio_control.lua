local AudioSettings = require("src.audio.audio_settings")
local Fonts = require("src.ui.fonts")
local Icons = require("src.ui.icons")
local UIScale = require("src.ui.scale")

local GlobalAudioControl = {}
GlobalAudioControl.__index = GlobalAudioControl

function GlobalAudioControl.new(app)
  return setmetatable({ app = app, hovered = false }, GlobalAudioControl)
end

function GlobalAudioControl:is_visible()
  local top = self.app.states and self.app.states:top()
  local kind = top and top.kind
  return kind ~= "run" and kind ~= "pause" and kind ~= "level_up"
    and kind ~= "chest_reward" and kind ~= "stage_complete"
end

function GlobalAudioControl:_rect()
  local w, h = love.graphics.getDimensions()
  local scale = UIScale.factor(w, h)
  local size, margin = 36 * scale, 12 * scale
  return { x = margin, y = h - size - margin,
    w = size, h = size, scale = scale }
end

function GlobalAudioControl:contains(x, y)
  if not self:is_visible() then return false end
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
  if not self:is_visible() then return end
  local r = self:_rect()
  local muted = self.app.profile.options.muted
  self.app.assets:draw_cta_frame(r.x, r.y, r.w, r.h, {
    corner = r.w * 0.30,
    color = muted and { 1.0, 0.52, 0.62, self.hovered and 1 or 0.88 }
      or { 0.72, 0.96, 1.0, self.hovered and 1 or 0.88 },
  })
  Icons.draw(muted and "speaker_off" or "speaker",
    r.x + r.w / 2, r.y + r.h / 2, 17 * r.scale,
    muted and { 1.0, 0.38, 0.50, 1 } or { 0.88, 0.96, 1.0, 1 })
  if self.hovered then
    local label = muted and "UNMUTE" or "MUTE"
    local font = Fonts.get(math.floor(13 * r.scale + 0.5))
    local tw = font:getWidth(label) + 18 * r.scale
    self.app.assets:draw_cta_frame(r.x + r.w + 8 * r.scale,
      r.y + 7 * r.scale, tw, 30 * r.scale, {
        corner = 8 * r.scale, color = { 0.74, 0.94, 1.0, 0.96 },
      })
    love.graphics.setFont(font)
    love.graphics.setColor(0.92, 0.92, 0.97, 1)
    love.graphics.printf(label, r.x + r.w + 8 * r.scale,
      r.y + 14 * r.scale, tw, "center")
  end
end

return GlobalAudioControl
