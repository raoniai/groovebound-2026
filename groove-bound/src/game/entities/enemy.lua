local class = require("src.core.class")
local EnemyAnimation = require("src.render.enemy_animation")

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
  self.variant_anim_phase = EnemyAnimation.phase(self.id, self.x, self.y)
  self.visual_state = "walk"
  self.visual_state_time = 0
  self.hit_remaining = 0
  self.attack_recovery = 0
  self.attack_windup_total = 0
  self.contact_cooldown = 0
  self.attack_cooldown = opts.definition.attack_interval or 0
  self.attack_windup = 0
  self.attack_just_fired = false
  self.attack_pattern_index = 1
  self.phase = 1
  self.broken_remaining = 0
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

function Enemy:update(dt, player, speed_multiplier, arena, attack_interval_multiplier)
  if self.dead then return nil end
  self.contact_cooldown = math.max(0, self.contact_cooldown - dt)
  self.flash = math.max(0, self.flash - dt)
  self.hit_remaining = math.max(0, self.hit_remaining - dt)
  self.attack_recovery = math.max(0, self.attack_recovery - dt)
  self.attack_cooldown = math.max(0, self.attack_cooldown - dt)
  self.attack_just_fired = false
  self.brain_time = self.brain_time + dt
  self.broken_remaining = math.max(0, self.broken_remaining - dt)
  local dx, dy = player.x - self.x, player.y - self.y
  local length = math.sqrt(dx * dx + dy * dy)
  self.target_distance = length
  self.target_in_attack_range = (self.definition.attack_range or 0) > 0
    and length <= self.definition.attack_range
  if self.definition.boss_type == "final" then
    local fraction = self.hp / math.max(1, self.max_hp)
    self.phase = fraction > .66 and 1 or fraction > .30 and 2 or 3
  end
  if self.attack_windup > 0 then
    self.attack_windup = math.max(0, self.attack_windup - dt)
    if self.attack_windup == 0 then
      self.attack_just_fired = true
      self.attack_recovery = 0.18
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
    self.attack_windup_total = self.attack_windup
    local phase_interval = self.phase == 3 and .72
      or self.phase == 2 and .86 or 1
    self.attack_cooldown = (self.definition.attack_interval or 2)
      * phase_interval * (attack_interval_multiplier or 1)
  end

  self.anim_time = self.anim_time + dt
  self.anim_frame = math.floor(self.anim_time * 12) % 6 + 1
  local visual_state = self.hit_remaining > 0 and "hit"
    or (self.definition.attack_kind
      and (self.attack_windup > 0 or self.attack_recovery > 0)) and "attack"
    or "walk"
  if visual_state ~= self.visual_state then
    self.visual_state = visual_state
    self.visual_state_time = 0
  else
    self.visual_state_time = self.visual_state_time + dt
  end
  if self.attack_just_fired then
    local attack_x, attack_y = player.x - self.x, player.y - self.y
    local attack_length = math.sqrt(attack_x * attack_x + attack_y * attack_y)
    local patterns = self.definition.attack_patterns
    local pattern = patterns and patterns[self.attack_pattern_index]
    if pattern then
      self.attack_pattern_index = self.attack_pattern_index % #patterns + 1
    end
    return {
      kind = pattern and pattern.kind or self.definition.attack_kind,
      projectile_class = pattern and pattern.projectile_class,
      count = pattern and pattern.count
        and pattern.count + (self.phase - 1) * 2 or nil,
      spread = pattern and pattern.spread
        and math.max(7, pattern.spread - (self.phase - 1) * 2) or nil,
      phase = self.phase,
      dx = attack_length > 0.001 and attack_x / attack_length or 1,
      dy = attack_length > 0.001 and attack_y / attack_length or 0,
    }
  end
end

function Enemy:push(dx, dy, force)
  if self.definition.boss_type == "final" then
    if self.attack_windup > 0 then return end
    force = math.min(force * (1 - (self.definition.knockback_resistance or .90)),
      self.definition.max_knockback_per_hit or 10)
  end
  self.knockback_x = self.knockback_x + dx * force
  self.knockback_y = self.knockback_y + dy * force
end

function Enemy:apply_world_break(amount)
  if self.definition.boss_type ~= "final" or self.dead then return false end
  self.break_progress = (self.break_progress or 0) + (amount or 0)
  local threshold = self.definition.break_threshold or 3
  if self.break_progress < threshold then return false end
  self.break_progress = self.break_progress - threshold
  self.broken_remaining = self.definition.break_seconds or 4
  return true
end

function Enemy:take_damage(amount)
  if self.broken_remaining > 0 then
    amount = amount * (self.definition.break_damage_multiplier or 1.25)
  end
  if self.dead then return false end
  self.hp = self.hp - amount
  self.flash = 0.08
  self.hit_remaining = 0.22
  self.visual_state = "hit"
  self.visual_state_time = 0
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
  if self.definition.boss_type == "final" and self.target_in_attack_range then
    local reduced = self.options.reduced_flash == true
      or self.options.hit_flash == false
    local pulse = reduced and 0.45
      or (0.42 + 0.12 * math.sin(self.brain_time * 7))
    local range = self.definition.attack_range
    love.graphics.setColor(1.0, 0.32, 0.58, 0.24 + pulse * 0.28)
    love.graphics.setLineWidth(reduced and 2 or 3)
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

  if self.assets and self.assets.draw_enemy_state then
    local progress
    if self.visual_state == "hit" then
      progress = 1 - self.hit_remaining / 0.22
    elseif self.visual_state == "attack" then
      if self.attack_windup > 0 then
        progress = 0.66 * (1 - self.attack_windup
          / math.max(0.001, self.attack_windup_total))
      else
        progress = 0.66 + 0.34 * (1 - self.attack_recovery / 0.18)
      end
    end
    local state_frame = EnemyAnimation.frame(
      self.definition, self.visual_state, self.visual_state_time,
      self.variant_anim_phase, progress)
    self.assets:draw_enemy_state(
      self.id,
      self.visual_state,
      state_frame,
      self.x,
      self.y,
      self.definition.sprite_size or 82,
      {
        color = color,
        flip_x = self.anim_row == directions.left,
      })
  elseif self.assets and self.definition.sprite then
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
