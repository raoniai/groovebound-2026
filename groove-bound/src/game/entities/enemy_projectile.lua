local class = require("src.core.class")

local EnemyProjectile = class()

function EnemyProjectile:init()
  self.dead = true
end

function EnemyProjectile:reset(opts)
  self.kind = "enemy_projectile"
  self.assets = opts.assets
  self.projectile_kind = opts.projectile_kind or "note_bolt"
  self.x, self.y = opts.x, opts.y
  self.dx, self.dy = opts.dx, opts.dy
  self.speed = opts.speed or 260
  self.damage = opts.damage or 10
  self.radius = opts.radius or 8
  self.lifetime = opts.lifetime or 4
  self.color = opts.color or { 1.0, 0.30, 0.72, 1 }
  self.anim_time = 0
  self.anim_phase = ((math.floor(self.x * 5 + self.y * 3)) % 628) / 100
  self.dead = false
end

function EnemyProjectile:update(dt, arena)
  self.x = self.x + self.dx * self.speed * dt
  self.y = self.y + self.dy * self.speed * dt
  self.lifetime = self.lifetime - dt
  self.anim_time = self.anim_time + dt
  if self.lifetime <= 0 or not arena:contains(self.x, self.y, self.radius) then
    self.dead = true
  end
end

function EnemyProjectile:draw()
  local cycle = self.anim_time * 2.6 + self.anim_phase
  local sideways = math.sin(cycle) * 1.8
  local x = self.x - self.dy * sideways
  local y = self.y + self.dx * sideways
  local scale_x = 1 + math.sin(cycle) * 0.08
  local scale_y = 1 + math.cos(cycle * 0.78) * 0.07
  local rotation = math.atan2(self.dy, self.dx)
  if self.projectile_kind == "static_wave" then
    local pulse = 0.72 + math.sin(cycle * 3.1) * 0.18
    love.graphics.setColor(1.0, 0.10, 0.52, 0.24)
    love.graphics.circle("fill", x, y, (self.radius + 10) * pulse)
    love.graphics.setColor(0.30, 0.94, 1.0, 0.94)
    love.graphics.setLineWidth(3)
    love.graphics.circle("line", x, y, self.radius + 7)
    love.graphics.setLineWidth(1)
  end
  if self.assets and self.assets.draw_enemy_projectile
    and self.assets:draw_enemy_projectile(
      self.projectile_kind, x, y, self.radius * 2,
      rotation, self.color, scale_x, scale_y)
  then
    return
  end
  love.graphics.push()
  love.graphics.translate(x, y)
  love.graphics.scale(scale_x, scale_y)
  love.graphics.setColor(self.color)
  love.graphics.circle("fill", 0, 0, self.radius)
  love.graphics.setColor(1, 0.92, 0.42, 0.85)
  love.graphics.circle("line", 0, 0, self.radius + 4)
  love.graphics.line(-self.dx * 18, -self.dy * 18, 0, 0)
  love.graphics.pop()
end

return EnemyProjectile
