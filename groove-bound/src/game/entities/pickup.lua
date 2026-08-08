local class = require("src.core.class")

local Pickup = class()

local colors = {
  heal = { 1.0, 0.34, 0.46, 1 },
  magnet = { 0.30, 0.94, 1.0, 1 },
  damage = { 1.0, 0.68, 0.20, 1 },
  defense = { 0.38, 0.72, 1.0, 1 },
  speed = { 0.46, 1.0, 0.66, 1 },
}

function Pickup:init() self.dead = true end

function Pickup:reset(opts)
  self.kind = "pickup"
  self.pickup_kind = assert(opts.kind)
  self.assets = opts.assets
  self.x, self.y = opts.x, opts.y
  self.radius = 14
  self.dead = false
  self.phase = opts.phase or 0
  self.magnetized = false
end

function Pickup:update(dt, player, pickup_radius, pickup_speed)
  pickup_radius = pickup_radius or 0
  pickup_speed = pickup_speed or 0
  self.phase = self.phase + dt * 2.5
  local dx, dy = player.x - self.x, player.y - self.y
  local distance_sq = dx * dx + dy * dy
  if self.magnetized or distance_sq <= (pickup_radius + self.radius) ^ 2 then
    local distance = math.sqrt(distance_sq)
    if distance > 0.001 then
      local speed = pickup_speed * (self.magnetized and 2.4
        or (1 + math.max(0, 1 - distance / pickup_radius)))
      self.x = self.x + dx / distance * speed * dt
      self.y = self.y + dy / distance * speed * dt
      dx, dy = player.x - self.x, player.y - self.y
      distance_sq = dx * dx + dy * dy
    end
  end
  local collect = player.radius + self.radius + 4
  if distance_sq <= collect * collect then
    self.dead = true
    return true
  end
  return false
end

function Pickup:draw()
  local color = colors[self.pickup_kind] or { 1, 1, 1, 1 }
  local pulse = 1 + math.sin(self.phase) * 0.08
  love.graphics.setColor(color[1], color[2], color[3], 0.20)
  love.graphics.circle("fill", self.x, self.y, 24 * pulse)
  if self.assets and self.assets.draw_pickup then
    self.assets:draw_pickup(
      self.pickup_kind, self.x, self.y, 48 * pulse,
      { rotation = math.sin(self.phase * 0.55) * 0.035 })
    return
  end
  love.graphics.setColor(0.035, 0.025, 0.08, 0.96)
  love.graphics.circle("fill", self.x, self.y, 15 * pulse)
  love.graphics.setColor(color)
  love.graphics.setLineWidth(3)
  love.graphics.circle("line", self.x, self.y, 15 * pulse)
  if self.pickup_kind == "heal" then
    love.graphics.line(self.x - 7, self.y, self.x + 7, self.y)
    love.graphics.line(self.x, self.y - 7, self.x, self.y + 7)
  elseif self.pickup_kind == "magnet" then
    love.graphics.arc("line", "open", self.x, self.y - 2, 9,
      0, math.pi)
    love.graphics.line(self.x - 9, self.y - 2, self.x - 9, self.y + 8)
    love.graphics.line(self.x + 9, self.y - 2, self.x + 9, self.y + 8)
  elseif self.pickup_kind == "damage" then
    love.graphics.polygon("line", self.x + 1, self.y - 10,
      self.x - 7, self.y + 1, self.x - 1, self.y + 1,
      self.x - 4, self.y + 10, self.x + 8, self.y - 3,
      self.x + 2, self.y - 3)
  elseif self.pickup_kind == "defense" then
    love.graphics.polygon("line", self.x, self.y - 10,
      self.x + 9, self.y - 5, self.x + 7, self.y + 6,
      self.x, self.y + 11, self.x - 7, self.y + 6, self.x - 9, self.y - 5)
  else
    love.graphics.line(self.x - 9, self.y + 6, self.x + 6, self.y - 7)
    love.graphics.line(self.x - 8, self.y - 1, self.x + 1, self.y - 9)
    love.graphics.line(self.x - 9, self.y + 9, self.x, self.y + 9)
  end
  love.graphics.setLineWidth(1)
end

return Pickup
