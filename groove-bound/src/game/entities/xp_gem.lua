local class = require("src.core.class")

local XPGem = class()

function XPGem:init()
  self.dead = true
end

function XPGem:reset(opts)
  self.kind = "xp_gem"
  self.assets = opts.assets
  self.x, self.y = opts.x, opts.y
  self.value = opts.value
  self.radius = 8
  self.dead = false
  self.phase = opts.phase or 0
end

function XPGem:update(dt, player, pickup_radius, pickup_speed)
  self.phase = self.phase + dt * 4
  local dx, dy = player.x - self.x, player.y - self.y
  local distance_sq = dx * dx + dy * dy
  if distance_sq <= (pickup_radius + self.radius) ^ 2 then
    local distance = math.sqrt(distance_sq)
    if distance > 0.001 then
      local speed = pickup_speed * (1 + math.max(0, 1 - distance / pickup_radius))
      self.x = self.x + dx / distance * speed * dt
      self.y = self.y + dy / distance * speed * dt
    end
  end

  local collect_radius = player.radius + self.radius
  if distance_sq <= collect_radius * collect_radius then
    self.dead = true
    return true
  end
  return false
end

function XPGem:draw()
  local pulse = 0.85 + math.sin(self.phase) * 0.12
  love.graphics.setColor(0.2, 0.95, 0.75, 0.24)
  love.graphics.circle("fill", self.x, self.y, 15 * pulse)
  if self.assets and self.assets.xp_gem then
    love.graphics.setColor(0.55, 1, 0.85, 1)
    local image = self.assets.xp_gem
    love.graphics.draw(
      image,
      self.x,
      self.y,
      self.phase * 0.08,
      0.28 * pulse,
      0.28 * pulse,
      image:getWidth() / 2,
      image:getHeight() / 2)
  else
    love.graphics.setColor(0.3, 1, 0.8, 1)
    love.graphics.circle("fill", self.x, self.y, self.radius)
  end
end

return XPGem
