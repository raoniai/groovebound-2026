local class = require("src.core.class")

local Projectile = class()

local function animation_phase(weapon_id, x, y)
  local value = math.floor((x or 0) * 7 + (y or 0) * 11)
  for index = 1, #(weapon_id or "") do
    value = value + string.byte(weapon_id, index) * index
  end
  return (value % 628) / 100
end

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
  self.anim_time = 0
  self.anim_phase = animation_phase(
    self.source_weapon_id, self.x, self.y)
  self.dead = false
  for enemy in pairs(self.hit) do self.hit[enemy] = nil end
end

function Projectile:update(dt, arena)
  self.x = self.x + self.dx * self.speed * dt
  self.y = self.y + self.dy * self.speed * dt
  self.lifetime = self.lifetime - dt
  self.anim_time = self.anim_time + dt
  if self.lifetime <= 0 or not arena:contains(self.x, self.y, self.radius) then
    self.dead = true
  end
end

function Projectile:render_pose()
  local cycle = self.anim_time * 3.0 + self.anim_phase
  local sideways = math.sin(cycle) * 2.2
  local forward = math.cos(cycle * 0.73) * 1.1
  return {
    x = self.x - self.dy * sideways + self.dx * forward,
    y = self.y + self.dx * sideways + self.dy * forward,
    scale_x = 1 + math.sin(cycle) * 0.07,
    scale_y = 1 + math.cos(cycle * 0.82) * 0.06,
  }
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
  local pose = self:render_pose()
  if self.assets and self.assets.draw_projectile
    and self.assets:draw_projectile(
      self.source_weapon_id, pose.x, pose.y,
      self.radius * 2, rotation, self.color, pose.scale_x, pose.scale_y)
  then
    return
  elseif self.assets and self.assets.projectile then
    love.graphics.setColor(self.color)
    local image = self.assets.projectile
    love.graphics.draw(
      image,
      pose.x,
      pose.y,
      rotation,
      0.62 * pose.scale_x,
      0.62 * pose.scale_y,
      image:getWidth() / 2,
      image:getHeight() / 2)
  else
    love.graphics.setColor(self.color)
    love.graphics.push()
    love.graphics.translate(pose.x, pose.y)
    love.graphics.scale(pose.scale_x, pose.scale_y)
    love.graphics.circle("fill", 0, 0, self.radius)
    love.graphics.pop()
  end
end

return Projectile
