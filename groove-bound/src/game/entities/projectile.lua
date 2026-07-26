local class = require("src.core.class")

local Projectile = class()

function Projectile:init()
  self.dead = true
  self.hit = {}
end

function Projectile:reset(opts)
  self.kind = "projectile"
  self.assets = opts.assets
  self.x, self.y = opts.x, opts.y
  self.dx, self.dy = opts.dx, opts.dy
  self.speed = opts.speed
  self.damage = opts.damage
  self.radius = opts.radius or math.max(3, (opts.size or 6) / 2)
  self.lifetime = opts.lifetime or 1
  self.pierce = opts.pierce or 0
  self.knockback = opts.knockback or 0
  self.color = opts.color or { 1, 1, 1, 1 }
  self.source_weapon_id = opts.source_weapon_id
  self.dead = false
  for enemy in pairs(self.hit) do self.hit[enemy] = nil end
end

function Projectile:update(dt, arena)
  self.x = self.x + self.dx * self.speed * dt
  self.y = self.y + self.dy * self.speed * dt
  self.lifetime = self.lifetime - dt
  if self.lifetime <= 0 or not arena:contains(self.x, self.y, self.radius) then
    self.dead = true
  end
end

function Projectile:register_hit(enemy)
  if self.hit[enemy] then return false end
  self.hit[enemy] = true
  if self.pierce > 0 then
    self.pierce = self.pierce - 1
  else
    self.dead = true
  end
  return true
end

function Projectile:draw()
  local rotation = math.atan2(self.dy, self.dx)
  if self.assets and self.assets.draw_projectile
    and self.assets:draw_projectile(
      self.source_weapon_id, self.x, self.y,
      self.radius * 2, rotation, self.color)
  then
    return
  elseif self.assets and self.assets.projectile then
    love.graphics.setColor(self.color)
    local image = self.assets.projectile
    love.graphics.draw(
      image,
      self.x,
      self.y,
      rotation,
      0.62,
      0.62,
      image:getWidth() / 2,
      image:getHeight() / 2)
  else
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
  end
end

return Projectile
