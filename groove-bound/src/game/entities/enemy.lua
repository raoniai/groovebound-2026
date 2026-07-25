local class = require("src.core.class")

local Enemy = class()

local directions = {
  down = 1,
  up = 2,
  left = 3,
  right = 4,
}

function Enemy:init()
  self.dead = true
end

function Enemy:reset(opts)
  self.kind = "enemy"
  self.id = assert(opts.definition.id)
  self.definition = opts.definition
  self.assets = opts.assets
  self.x, self.y = opts.x, opts.y
  self.radius = opts.definition.size
  self.hp = opts.definition.hp
  self.max_hp = opts.definition.hp
  self.dead = false
  self.rewards_claimed = false
  self.anim_time = 0
  self.anim_frame = 1
  self.anim_row = directions.down
  self.contact_cooldown = 0
  self.attack_cooldown = opts.definition.attack_interval or 0
  self.brain_time = 0
  self.flash = 0
end

function Enemy:update(dt, player, speed_multiplier, arena)
  self.contact_cooldown = math.max(0, self.contact_cooldown - dt)
  self.flash = math.max(0, self.flash - dt)
  self.attack_cooldown = math.max(0, self.attack_cooldown - dt)
  self.brain_time = self.brain_time + dt
  local dx, dy = player.x - self.x, player.y - self.y
  local length = math.sqrt(dx * dx + dy * dy)
  if length > 0.001 and self.definition.brain ~= "static" then
    dx, dy = dx / length, dy / length
    local speed = self.definition.speed * speed_multiplier
    if self.definition.brain == "zigzag" then
      local wobble = math.sin(self.brain_time * 5 + self.x * 0.01) * 0.65
      dx, dy = dx - dy * wobble, dy + dx * wobble
      local adjusted = math.sqrt(dx * dx + dy * dy)
      dx, dy = dx / adjusted, dy / adjusted
    elseif self.definition.brain == "charger" then
      local cycle = self.brain_time % 3.2
      speed = speed * (cycle > 2.35 and 2.7 or 0.62)
    end
    self.x = self.x + dx * speed * dt
    self.y = self.y + dy * speed * dt
    self.x, self.y = arena:clamp(self.x, self.y, self.radius)

    if math.abs(dx) > math.abs(dy) then
      self.anim_row = dx > 0 and directions.right or directions.left
    else
      self.anim_row = dy > 0 and directions.down or directions.up
    end
  end

  self.anim_time = self.anim_time + dt
  self.anim_frame = math.floor(self.anim_time * 12) % 6 + 1
end

function Enemy:take_damage(amount)
  if self.dead then return false end
  self.hp = self.hp - amount
  self.flash = 0.08
  if self.hp <= 0 then
    self.hp = 0
    self.dead = true
    return true
  end
  return false
end

function Enemy:draw()
  local color = self.definition.color or { 1, 1, 1, 1 }
  if self.flash > 0 then color = { 1, 1, 1, 1 } end

  if self.assets and self.assets.enemy then
    self.assets.enemy.walk:draw(
      self.anim_frame,
      self.anim_row,
      self.x,
      self.y,
      { scale = 0.82, color = color })
  else
    love.graphics.setColor(color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
  end

  if self.hp < self.max_hp then
    local width = 38
    love.graphics.setColor(0.06, 0.04, 0.08, 0.9)
    love.graphics.rectangle("fill", self.x - width / 2, self.y + 25, width, 4)
    love.graphics.setColor(0.9, 0.18, 0.28, 1)
    love.graphics.rectangle("fill", self.x - width / 2, self.y + 25, width * self.hp / self.max_hp, 4)
  end
end

return Enemy
