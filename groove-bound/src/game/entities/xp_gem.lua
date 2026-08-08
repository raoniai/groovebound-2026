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
  self.tier = math.max(1, math.min(4, opts.tier or 1))
  self.radius = 7 + self.tier
  self.dead = false
  self.phase = opts.phase or 0
  self.magnetized = false
end

function XPGem:update(dt, player, pickup_radius, pickup_speed)
  self.phase = self.phase + dt * 4
  local dx, dy = player.x - self.x, player.y - self.y
  local distance_sq = dx * dx + dy * dy
  if self.magnetized or distance_sq <= (pickup_radius + self.radius) ^ 2 then
    local distance = math.sqrt(distance_sq)
    if distance > 0.001 then
      local speed = pickup_speed * (self.magnetized and 2.4
        or (1 + math.max(0, 1 - distance / pickup_radius)))
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
  local aura = {
    { 0.25, 1.0, 0.62 },
    { 0.25, 0.78, 1.0 },
    { 1.0, 0.68, 0.18 },
    { 0.96, 0.26, 1.0 },
  }
  local color = aura[self.tier]
  love.graphics.setColor(color[1], color[2], color[3], 0.20)
  love.graphics.circle("fill", self.x, self.y, (12 + self.tier * 3) * pulse)
  if self.assets and self.assets.draw_xp_gem then
    self.assets:draw_xp_gem(
      self.tier, self.x, self.y, (31 + self.tier * 7) * pulse,
      { rotation = self.phase * (0.025 + self.tier * 0.008) })
    return
  end
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
