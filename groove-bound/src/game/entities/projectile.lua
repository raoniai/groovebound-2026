local class = require("src.core.class")

local Projectile = class()

local persistent_families = {
  lobbed_bomb = true,
  area_effect = true,
  orbital = true,
  beam = true,
  storm = true,
  deployable = true,
}

local function animation_phase(weapon_id, x, y)
  local value = math.floor((x or 0) * 7 + (y or 0) * 11)
  for index = 1, #(weapon_id or "") do
    value = value + string.byte(weapon_id, index) * index
  end
  return (value % 628) / 100
end

local function distance_sq(ax, ay, bx, by)
  local dx, dy = bx - ax, by - ay
  return dx * dx + dy * dy
end

function Projectile:init()
  self.dead = true
  self.hit = {}
  self.visual_targets = {}
end

function Projectile:reset(opts)
  self.kind = "projectile"
  self.assets = opts.assets
  self.player = opts.player
  self.x, self.y = opts.x, opts.y
  self.start_x, self.start_y = opts.x, opts.y
  self.target_x = opts.target_x or opts.x
  self.target_y = opts.target_y or opts.y
  self.dx, self.dy = opts.dx or 1, opts.dy or 0
  self.speed = opts.speed or 0
  self.damage = opts.damage
  self.base_radius = opts.radius or math.max(3, (opts.size or 6) / 2)
  self.radius = self.base_radius
  self.lifetime = opts.lifetime or 1
  self.total_lifetime = self.lifetime
  self.pierce = opts.pierce or 0
  self.knockback = opts.knockback or 0
  self.color = opts.color or { 1, 1, 1, 1 }
  self.source_weapon_id = opts.source_weapon_id
  self.attack_family = opts.attack_family or "linear"
  self.visual_id = opts.visual_id or self.source_weapon_id
  self.animation_frames = opts.animation_frames or 5
  self.animation_fps = opts.animation_fps or 12
  self.animation_mode = opts.animation_mode
  self.coverage = opts.coverage or math.max(
    self.base_radius, self.speed * self.lifetime)
  self.effect_radius = opts.effect_radius or self.base_radius
  self.hit_cooldown = opts.hit_cooldown
  self.flight_time = math.max(0.01, opts.flight_time or 0.45)
  self.active_duration = opts.active_duration
    or (self.attack_family == "storm" and 0.38 or 0.30)
  if self.attack_family == "beam" or self.attack_family == "storm" then
    self.lifetime = self.active_duration
    self.total_lifetime = self.active_duration
  end
  if self.attack_family == "lobbed_bomb"
    or self.attack_family == "deployable"
  then
    self.animation_duration = self.flight_time + self.active_duration
  elseif self.attack_family == "beam" or self.attack_family == "storm" then
    self.animation_duration = self.active_duration
  else
    self.animation_duration = self.total_lifetime
  end
  self.return_delay = opts.return_delay or self.lifetime * 0.48
  self.angular_speed = opts.angular_speed or 3
  self.orbit_angle = opts.orbit_angle or 0
  self.beam_length = self.coverage
  self.beam_width = self.effect_radius
  self.wave_width = self.effect_radius
  self.wave_depth = math.max(48, self.base_radius * 5)
  self.max_targets = opts.max_targets or 1
  self.follow_player = opts.follow_player == true
  self.phase = (self.attack_family == "lobbed_bomb"
      or self.attack_family == "deployable") and "flight" or "active"
  self.returning = false
  self.age = 0
  self.anim_time = 0
  self.anim_phase = animation_phase(
    self.source_weapon_id, self.x, self.y)
  self.unique_hits = 0
  self.dead = false
  for enemy in pairs(self.hit) do self.hit[enemy] = nil end
  for index = #self.visual_targets, 1, -1 do
    self.visual_targets[index] = nil
  end
end

function Projectile:animation_progress()
  local duration = math.max(0.001, self.animation_duration or 0.001)
  return math.min(1, self.age / duration)
end

function Projectile:animation_frame()
  local frames = math.max(1, self.animation_frames or 5)
  return math.min(frames, math.floor(self:animation_progress() * frames) + 1)
end

function Projectile:_update_flight()
  local progress = math.min(1, self.age / self.flight_time)
  self.x = self.start_x + (self.target_x - self.start_x) * progress
  self.y = self.start_y + (self.target_y - self.start_y) * progress
  if progress >= 1 then
    self.phase = "active"
    self.x, self.y = self.target_x, self.target_y
    self.radius = self.effect_radius
  end
end

function Projectile:update(dt, arena)
  self.age = self.age + dt
  self.anim_time = self.anim_time + dt

  if self.attack_family == "lobbed_bomb"
    or self.attack_family == "deployable"
  then
    if self.phase == "flight" then self:_update_flight() end
    if self.phase == "active"
      and self.age >= self.flight_time + self.active_duration
    then
      self.dead = true
    end
    return
  end

  if self.attack_family == "area_effect" then
    if self.follow_player and self.player then
      self.x, self.y = self.player.x, self.player.y
    end
    self.radius = self.effect_radius
  elseif self.attack_family == "orbital" and self.player then
    self.orbit_angle = self.orbit_angle + self.angular_speed * dt
    self.x = self.player.x + math.cos(self.orbit_angle) * self.effect_radius
    self.y = self.player.y + math.sin(self.orbit_angle) * self.effect_radius
    self.radius = self.base_radius
  elseif self.attack_family == "beam" then
    if self.player then self.x, self.y = self.player.x, self.player.y end
    if self.age >= self.active_duration then
      self.dead = true
      return
    end
  elseif self.attack_family == "storm" then
    if self.player then self.x, self.y = self.player.x, self.player.y end
    if self.age >= self.active_duration then self.dead = true end
    return
  elseif self.attack_family == "boomerang" then
    if not self.returning and self.age >= self.return_delay then
      self.returning = true
    end
    if self.returning and self.player then
      local vx, vy = self.player.x - self.x, self.player.y - self.y
      local length = math.sqrt(vx * vx + vy * vy)
      if length <= self.base_radius + (self.player.radius or 0) then
        self.dead = true
        return
      elseif length > 0 then
        self.dx, self.dy = vx / length, vy / length
      end
    end
    self.x = self.x + self.dx * self.speed * dt
    self.y = self.y + self.dy * self.speed * dt
  else
    self.x = self.x + self.dx * self.speed * dt
    self.y = self.y + self.dy * self.speed * dt
  end

  self.lifetime = self.lifetime - dt
  if self.lifetime <= 0 then
    self.dead = true
    return
  end
  if (self.attack_family == "linear" or self.attack_family == "wave")
    and distance_sq(self.start_x, self.start_y, self.x, self.y)
      >= self.coverage * self.coverage
  then
    self.dead = true
    return
  end
  if (self.attack_family == "linear"
      or self.attack_family == "boomerang"
      or self.attack_family == "wave")
    and not arena:contains(self.x, self.y, self.base_radius)
  then
    self.dead = true
  end
end

function Projectile:is_damage_active()
  if self.dead or self.phase ~= "active" then return false end
  if self.animation_mode ~= "one_shot" then return true end

  local progress = self:animation_progress()
  if self.attack_family == "beam" then
    return progress >= 0.30 and progress < 0.68
  elseif self.attack_family == "storm" then
    return progress >= 0.20 and progress < 0.72
  end
  return true
end

function Projectile:claim_collision_scan()
  return self:is_damage_active()
end

function Projectile:contains_target(enemy)
  if not self:is_damage_active() then return false end
  -- Existing unit fixtures exercise pierce ownership without a world position.
  if enemy.x == nil or enemy.y == nil then return true end

  if self.attack_family == "beam" then
    local ex, ey = enemy.x - self.x, enemy.y - self.y
    local forward = ex * self.dx + ey * self.dy
    if forward < 0 or forward > self.beam_length then return false end
    local side = math.abs(ex * -self.dy + ey * self.dx)
    return side <= self.beam_width / 2 + (enemy.radius or 0)
  elseif self.attack_family == "wave" then
    local ex, ey = enemy.x - self.x, enemy.y - self.y
    local forward = math.abs(ex * self.dx + ey * self.dy)
    local side = math.abs(ex * -self.dy + ey * self.dx)
    return forward <= self.wave_depth / 2 + (enemy.radius or 0)
      and side <= self.wave_width / 2 + (enemy.radius or 0)
  end

  local radius = self.base_radius
  if self.attack_family == "lobbed_bomb"
    or self.attack_family == "area_effect"
    or self.attack_family == "deployable"
  then
    radius = self.effect_radius
  elseif self.attack_family == "storm" then
    radius = self.coverage
  end
  local combined = radius + (enemy.radius or 0)
  return distance_sq(self.x, self.y, enemy.x, enemy.y)
    <= combined * combined
end

function Projectile:render_pose()
  local cycle = self.anim_time * 3.0 + self.anim_phase
  local sideways, forward = 0, 0
  if self.attack_family == "linear" or self.attack_family == "boomerang" then
    sideways = math.sin(cycle) * 1.4
    forward = math.cos(cycle * 0.73) * 0.7
  end
  local arc = 0
  if (self.attack_family == "lobbed_bomb"
      or self.attack_family == "deployable") and self.phase == "flight"
  then
    local progress = math.min(1, self.age / self.flight_time)
    arc = math.sin(progress * math.pi) * math.max(30, self.base_radius * 5)
  end
  return {
    x = self.x - self.dy * sideways + self.dx * forward,
    y = self.y + self.dx * sideways + self.dy * forward - arc,
    scale_x = 1 + math.sin(cycle) * 0.035,
    scale_y = 1 + math.cos(cycle * 0.82) * 0.035,
  }
end

function Projectile:register_hit(enemy)
  if not self:contains_target(enemy) then return false end

  if self.attack_family == "boomerang" then
    local phases = self.hit[enemy]
    if not phases then
      phases = {}
      self.hit[enemy] = phases
    end
    local phase = self.returning and "returning" or "outbound"
    if phases[phase] then return false end
    phases[phase] = true
    return true
  end

  local previous = self.hit[enemy]
  if persistent_families[self.attack_family] then
    local interval = self.hit_cooldown or self.total_lifetime + 1
    if previous and self.age - previous < interval then return false end
    if not previous and self.attack_family == "storm"
      and self.unique_hits >= self.max_targets
    then
      return false
    end
    if not previous then
      self.unique_hits = self.unique_hits + 1
      if self.attack_family == "storm" and enemy.x and enemy.y then
        self.visual_targets[#self.visual_targets + 1] = {
          x = enemy.x,
          y = enemy.y,
        }
      end
    end
    self.hit[enemy] = self.age
    return true
  end

  if previous then return false end
  self.hit[enemy] = self.age
  if self.pierce > 0 then
    self.pierce = self.pierce - 1
  else
    self.dead = true
  end
  return true
end

function Projectile:_draw_attack_at(x, y, rotation, pose)
  return self.assets:draw_attack({
    visual_id = self.visual_id,
    family = self.attack_family,
    phase = self.phase,
    age = self.age,
    animation_frames = self.animation_frames,
    animation_fps = self.animation_fps,
    animation_mode = self.animation_mode,
    frame = self:animation_frame(),
    x = x,
    y = y,
    size = self.base_radius * 2,
    rotation = rotation,
    color = self.color,
    scale_x = pose.scale_x,
    scale_y = pose.scale_y,
    dx = self.dx,
    dy = self.dy,
    coverage = self.coverage,
    effect_radius = self.effect_radius,
    beam_length = self.beam_length,
    beam_width = self.beam_width,
    wave_width = self.wave_width,
  })
end

function Projectile:draw()
  local rotation = math.atan2(self.dy, self.dx)
  local pose = self:render_pose()
  if self.assets and self.assets.draw_attack then
    if self.attack_family == "storm" and #self.visual_targets > 0 then
      local drawn = false
      for _, target in ipairs(self.visual_targets) do
        drawn = self:_draw_attack_at(target.x, target.y, -math.pi / 2, pose)
          or drawn
      end
      if drawn then return end
    elseif self:_draw_attack_at(pose.x, pose.y, rotation, pose) then
      return
    end
  end

  if self.assets and self.assets.projectile then
    love.graphics.setColor(self.color)
    local image = self.assets.projectile
    love.graphics.draw(
      image, pose.x, pose.y, rotation,
      0.62 * pose.scale_x, 0.62 * pose.scale_y,
      image:getWidth() / 2, image:getHeight() / 2)
  else
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", pose.x, pose.y, self.base_radius)
  end
end

return Projectile
