-- Camera: smooth-damped follow, clamped to arena bounds, trauma-based shake.
--
-- Clamping: the view never shows the void outside the walls (the old camera
-- did). When the arena is smaller than the screen on an axis, the view
-- centers on the arena instead.
--
-- Shake: effects add trauma in [0,1]; offset magnitude is trauma² so small
-- hits barely nudge and big hits slam. No integer-only math.random misuse
-- (a latent crash in the prototype).
--
-- Dimensions and randomness are injected so every method is unit-testable.

local class = require("src.core.class")
local settings = require("src.config.settings")

local Camera = class()

function Camera:init(opts)
  opts = opts or {}
  self.x = opts.x or 0
  self.y = opts.y or 0
  self.get_dimensions = opts.get_dimensions or function()
    return love.graphics.getDimensions()
  end
  self.random = opts.random or math.random -- fn() -> [0,1)
  self.bounds = nil                        -- {w, h} arena size, nil = unclamped
  self.trauma = 0
  self.shake_x, self.shake_y = 0, 0
  self.shake_enabled = opts.shake_enabled ~= false
  self.zoom = math.max(0.75, math.min(1.5, opts.zoom or 1))
end

function Camera:set_bounds(w, h)
  self.bounds = { w = w, h = h }
  self:_clamp()
end

function Camera:set_zoom(value)
  self.zoom = math.max(0.75, math.min(1.5, value or 1))
  self:_clamp()
  return self.zoom
end

function Camera:add_trauma(amount)
  self.trauma = math.min(1, self.trauma + amount)
end

function Camera:_clamp()
  if not self.bounds then return end
  local sw, sh = self.get_dimensions()
  local view_w, view_h = sw / self.zoom, sh / self.zoom

  if self.bounds.w <= view_w then
    self.x = self.bounds.w / 2
  else
    self.x = math.max(view_w / 2,
      math.min(self.x, self.bounds.w - view_w / 2))
  end

  if self.bounds.h <= view_h then
    self.y = self.bounds.h / 2
  else
    self.y = math.max(view_h / 2,
      math.min(self.y, self.bounds.h - view_h / 2))
  end
end

-- Snap directly to a target (used on run start so there is no initial pan).
function Camera:snap(tx, ty)
  self.x, self.y = tx, ty
  self:_clamp()
end

function Camera:follow(tx, ty, dt)
  local cfg = settings.camera
  local t = math.min(1, dt * cfg.follow_lerp)
  self.x = self.x + (tx - self.x) * t
  self.y = self.y + (ty - self.y) * t
  self:_clamp()
end

function Camera:update(dt)
  local cfg = settings.camera
  if self.trauma > 0 then
    self.trauma = math.max(0, self.trauma - cfg.trauma_decay * dt)
  end

  if self.trauma > 0 and self.shake_enabled then
    local magnitude = cfg.max_shake * self.trauma * self.trauma
    self.shake_x = (self.random() * 2 - 1) * magnitude
    self.shake_y = (self.random() * 2 - 1) * magnitude
  else
    self.shake_x, self.shake_y = 0, 0
  end
end

function Camera:apply()
  local sw, sh = self.get_dimensions()
  love.graphics.push()
  love.graphics.translate(
    math.floor(sw / 2 + self.shake_x),
    math.floor(sh / 2 + self.shake_y))
  love.graphics.scale(self.zoom, self.zoom)
  love.graphics.translate(-self.x, -self.y)
end

function Camera:detach()
  love.graphics.pop()
end

function Camera:screen_to_world(sx, sy)
  local sw, sh = self.get_dimensions()
  return (sx - sw / 2) / self.zoom + self.x,
    (sy - sh / 2) / self.zoom + self.y
end

function Camera:world_to_screen(wx, wy)
  local sw, sh = self.get_dimensions()
  return (wx - self.x) * self.zoom + sw / 2,
    (wy - self.y) * self.zoom + sh / 2
end

return Camera
