local class = require("src.core.class")

local EnemyProjectile = class()

function EnemyProjectile:init()
  self.dead = true
end

function EnemyProjectile:reset(opts)
  self.kind = "enemy_projectile"
  self.x, self.y = opts.x, opts.y
  self.dx, self.dy = opts.dx, opts.dy
  self.speed = opts.speed or 260
  self.damage = opts.damage or 10
  self.radius = opts.radius or 8
  self.lifetime = opts.lifetime or 4
  self.color = opts.color or { 1.0, 0.30, 0.72, 1 }
  self.dead = false
end

function EnemyProjectile:update(dt, arena)
  self.x = self.x + self.dx * self.speed * dt
  self.y = self.y + self.dy * self.speed * dt
  self.lifetime = self.lifetime - dt
  if self.lifetime <= 0 or not arena:contains(self.x, self.y, self.radius) then
    self.dead = true
  end
end

function EnemyProjectile:draw()
  love.graphics.setColor(self.color)
  love.graphics.circle("fill", self.x, self.y, self.radius)
  love.graphics.setColor(1, 0.92, 0.42, 0.85)
  love.graphics.circle("line", self.x, self.y, self.radius + 4)
  love.graphics.line(
    self.x - self.dx * 18, self.y - self.dy * 18,
    self.x, self.y)
end

return EnemyProjectile
