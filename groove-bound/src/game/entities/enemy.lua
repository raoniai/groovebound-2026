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
  self.options = opts.options or {}
  self.x, self.y = opts.x, opts.y
  -- Physical crowd movement stays compact, while the projectile hurt area
  -- follows the visible sprite. Keeping these separate prevents shots from
  -- slipping through rendered limbs without turning enemies into huge walls.
  self.body_radius = opts.definition.size
  self.hurt_radius = opts.definition.hurtbox_radius or math.max(
    self.body_radius,
    (opts.definition.sprite_size or self.body_radius * 2) * 0.38)
  self.radius = self.hurt_radius
  self.hp = opts.definition.hp * (opts.health_multiplier or 1)
  self.max_hp = self.hp
  self.dead = false
  self.rewards_claimed = false
  self.suppress_reward_chest = false
  self.anim_time = 0
  self.anim_frame = 1
  self.anim_row = directions.down
  self.contact_cooldown = 0
  self.attack_cooldown = opts.definition.attack_interval or 0
  self.attack_windup = 0
  self.attack_just_fired = false
  self.brain_time = 0
  self.navigation_timer = 0
  self.navigation_dx, self.navigation_dy = nil, nil
  self.navigation_routed = false
  self.navigation_target_x, self.navigation_target_y = nil, nil
  self.flash = 0
  self.knockback_x, self.knockback_y = 0, 0
  self.overtime_multiplier = 1
  self.overtime_enraged = false
  self.target_in_attack_range = false
  self.target_distance = math.huge
end

function Enemy:enrage_overtime(multiplier)
  if self.overtime_enraged then return false end
  multiplier = multiplier or 3
  self.overtime_enraged = true
  self.overtime_multiplier = multiplier
  self.hp = self.hp * multiplier
  self.max_hp = self.max_hp * multiplier
  return true
end

function Enemy:update(dt, player, speed_multiplier, arena)
  if self.dead then return nil end
  self.contact_cooldown = math.max(0, self.contact_cooldown - dt)
  self.flash = math.max(0, self.flash - dt)
  self.attack_cooldown = math.max(0, self.attack_cooldown - dt)
  self.attack_just_fired = false
  self.brain_time = self.brain_time + dt
  local dx, dy = player.x - self.x, player.y - self.y
  local length = math.sqrt(dx * dx + dy * dy)
  self.target_distance = length
  self.target_in_attack_range = (self.definition.attack_range or 0) > 0
    and length <= self.definition.attack_range
  if self.attack_windup > 0 then
    self.attack_windup = math.max(0, self.attack_windup - dt)
    if self.attack_windup == 0 then
      self.attack_just_fired = true
    end
  end
  if length > 0.001 and self.definition.brain ~= "static" then
    dx, dy = dx / length, dy / length
    local speed = self.definition.speed * speed_multiplier * self.overtime_multiplier
    if self.definition.brain == "zigzag" then
      local wobble = math.sin(self.brain_time * 5 + self.x * 0.01) * 0.65
      dx, dy = dx - dy * wobble, dy + dx * wobble
      local adjusted = math.sqrt(dx * dx + dy * dy)
      dx, dy = dx / adjusted, dy / adjusted
    elseif self.definition.brain == "charger" then
      local cycle = self.brain_time % 3.2
      speed = speed * (cycle > 2.35 and 2.7 or 0.62)
    elseif self.definition.brain == "ranged" then
      local preferred = self.definition.preferred_range or 320
      if length < preferred - 45 then
        dx, dy = -dx, -dy
      elseif length <= preferred + 45 then
        dx, dy = -dy, dx
        speed = speed * 0.62
      end
    elseif self.definition.brain == "orbit" then
      local approach = length > 260 and 0.72 or 0.18
      dx, dy = dx * approach - dy, dy * approach + dx
      local adjusted = math.sqrt(dx * dx + dy * dy)
      dx, dy = dx / adjusted, dy / adjusted
      speed = speed * 0.82
    elseif self.definition.brain == "pulse" and length < 145 then
      speed = speed * 0.28
    end
    -- Keep movement resolution local and constant-cost. The visibility-graph
    -- route calculation became multiplicative with large crowds near stage
    -- equipment; axis sliding below gives the original lightweight behavior.
    local old_x, old_y = self.x, self.y
    local next_x = self.x + (dx * speed + self.knockback_x) * dt
    local next_y = self.y + (dy * speed + self.knockback_y) * dt
    if arena.resolve_movement then
      self.x, self.y = arena:resolve_movement(
        old_x, old_y, next_x, next_y, self.body_radius)
    else
      self.x, self.y = arena:clamp(next_x, next_y, self.body_radius)
    end

    if math.abs(dx) > math.abs(dy) then
      self.anim_row = dx > 0 and directions.right or directions.left
    else
      self.anim_row = dy > 0 and directions.down or directions.up
    end
  end
  local knockback_decay = math.max(0, 1 - dt * 10)
  self.knockback_x = self.knockback_x * knockback_decay
  self.knockback_y = self.knockback_y * knockback_decay

  local attack_range = self.definition.attack_range or 0
  if self.definition.attack_kind
    and self.attack_cooldown <= 0
    and self.attack_windup <= 0
    and length <= attack_range
  then
    self.attack_windup = self.definition.windup or 0.45
    self.attack_cooldown = self.definition.attack_interval or 2
  end

  self.anim_time = self.anim_time + dt
  self.anim_frame = math.floor(self.anim_time * 12) % 6 + 1
  if self.attack_just_fired then
    local attack_x, attack_y = player.x - self.x, player.y - self.y
    local attack_length = math.sqrt(attack_x * attack_x + attack_y * attack_y)
    return {
      kind = self.definition.attack_kind,
      dx = attack_length > 0.001 and attack_x / attack_length or 1,
      dy = attack_length > 0.001 and attack_y / attack_length or 0,
    }
  end
end

function Enemy:push(dx, dy, force)
  self.knockback_x = self.knockback_x + dx * force
  self.knockback_y = self.knockback_y + dy * force
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
  if self.dead then return end
  local color = self.definition.color or { 1, 1, 1, 1 }
  if self.definition.attack_kind == "static_wave" and self.target_in_attack_range then
    local reduced = self.options.reduced_flash == true
      or self.options.hit_flash == false
    local pulse = reduced and 0.55
      or (0.5 + 0.5 * math.sin(self.brain_time * 12))
    local range = self.definition.attack_range
    love.graphics.setColor(1.0, 0.12, 0.38, 0.055 + pulse * 0.075)
    love.graphics.circle("fill", self.x, self.y, range)
    love.graphics.setColor(1.0, 0.32, 0.58, 0.48 + pulse * 0.38)
    love.graphics.setLineWidth(5)
    love.graphics.circle("line", self.x, self.y, range)
    love.graphics.setLineWidth(1)
  end
  if self.flash > 0 then
    color = math.floor(self.flash * 60) % 2 == 0
      and { 1, 1, 1, 1 }
      or { 1, 0.36, 0.72, 1 }
  elseif self.attack_windup > 0 then
    color = { 1, 0.70, 0.24, 1 }
  end

  if self.assets and self.definition.sprite then
    self.assets:draw_enemy_variant(
      self.definition.sprite,
      self.x,
      self.y,
      self.definition.sprite_size or 82,
      {
        color = color,
        flip_x = self.anim_row == directions.left,
      })
  elseif self.assets and self.assets.enemy then
    self.assets.enemy.walk:draw(
      self.anim_frame,
      self.anim_row,
      self.x,
      self.y,
      { scale = 0.82, color = color })
  else
    love.graphics.setColor(color)
    love.graphics.circle("fill", self.x, self.y, self.body_radius)
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
