-- Player entity: movement, aim, health, damage state, and animation selection.
-- Combat and weapon progression stay system-owned (single-owner rule).

local class = require("src.core.class")
local TestMode = require("src.game.test_mode")
local settings = require("src.config.settings")

local Player = class()

local directions = {
  down = 1,
  up = 2,
  left = 3,
  right = 4,
}

local animations = {
  idle = { frames = { 1 }, fps = 0 },
  walk = { frames = { 3, 4 }, fps = 8 },
  -- Blend the two walk contacts with the stronger run poses. This creates a
  -- readable four-step footfall cycle instead of ping-ponging near-duplicates.
  run = { frames = { 3, 5, 4, 6 }, fps = 12 },
  hurt = { frames = { 7, 8 }, fps = 8 },
}

function Player:init(opts)
  opts = opts or {}
  local cfg = settings.player
  self.x = opts.x or 0
  self.y = opts.y or 0
  self.base_speed = cfg.speed
  self.speed = cfg.speed
  self.tuning = opts.tuning
  self.assets = opts.assets
  self.options = opts.options or {}
  self.character = opts.character or {
    id = "joe",
    stats = {
      vitality = 1, power = 1, speed = 1,
      defense = 1, tempo = 1, resonance = 1,
    },
  }
  local stats = self.character.stats or {}
  self.radius = cfg.size / 2
  self.base_speed = cfg.speed * (stats.speed or 1)
  self.speed = self.base_speed
  self.hp = math.floor(cfg.hp * (stats.vitality or 1) + 0.5)
  self.max_hp = self.hp
  self.base_max_hp = self.hp
  self.defense_multiplier = stats.defense or 1
  self.passive_speed_multiplier = 1
  self.temporary_speed_multiplier = 1
  self.world_speed_multiplier = 1
  self.temporary_defense_multiplier = 1
  self.time_since_hit = 5
  self.aim_x, self.aim_y = 1, 0
  self.anim_time = 0
  self.anim_frame = 1
  self.anim_row = directions.down
  self.moving = false
  self.animation_state = "idle"
  self.hurt_timer = 0
  self.knockback_x, self.knockback_y = 0, 0
  self.invulnerability = 0
  self.flash = 0
  self.hit_pulse = 0
  self.last_damage = 0
  self.dead = false
  self.guard = self.character.starting_guard or 0
end

function Player:update(dt, input, camera, arena)
  self.invulnerability = math.max(0, self.invulnerability - dt)
  self.flash = math.max(0, self.flash - dt)
  self.hit_pulse = math.max(0, self.hit_pulse - dt)
  self.hurt_timer = math.max(0, self.hurt_timer - dt)
  local mx, my = input:move_vector()
  local speed_multiplier = self.tuning and self.tuning:get("player.speed_multiplier") or 1
  speed_multiplier = speed_multiplier * TestMode.factor(self.tuning)
  local previous_since_hit = self.time_since_hit
  self.time_since_hit = self.time_since_hit + dt
  local regeneration_dt = math.max(0, self.time_since_hit - 5)
    - math.max(0, previous_since_hit - 5)
  if regeneration_dt > 0 and self.hp > 0 and self.hp < self.max_hp then
    self.hp = math.min(self.max_hp,
      self.hp + self.max_hp * 0.0002 * regeneration_dt)
  end
  self.speed = self.base_speed * speed_multiplier * self.passive_speed_multiplier
    * self.temporary_speed_multiplier * self.world_speed_multiplier
  local old_x, old_y = self.x, self.y
  local next_x = self.x + (mx * self.speed + self.knockback_x) * dt
  local next_y = self.y + (my * self.speed + self.knockback_y) * dt
  local knockback_decay = math.max(0, 1 - dt * 9)
  self.knockback_x = self.knockback_x * knockback_decay
  self.knockback_y = self.knockback_y * knockback_decay
  if arena.resolve_movement then
    self.x, self.y = arena:resolve_movement(
      old_x, old_y, next_x, next_y, self.radius)
  else
    self.x, self.y = arena:clamp(next_x, next_y, self.radius)
  end

  self.aim_x, self.aim_y = input:aim_vector(self.x, self.y, camera)
  self.aim_device = input.aim_device
  self.aim_target_x = input.last_pointer_world_x
  self.aim_target_y = input.last_pointer_world_y
  self.moving = math.abs(mx) + math.abs(my) > 0.01
  local facing_x, facing_y = self.moving and mx or self.aim_x, self.moving and my or self.aim_y
  if math.abs(facing_x) > math.abs(facing_y) then
    self.anim_row = facing_x > 0 and directions.right or directions.left
  else
    self.anim_row = facing_y > 0 and directions.down or directions.up
  end
  self.anim_time = self.anim_time + dt
  if self.hurt_timer > 0 then
    self.animation_state = "hurt"
  elseif not self.moving then
    self.animation_state = "idle"
  elseif self.speed >= self.base_speed * 1.32 then
    self.animation_state = "run"
  else
    self.animation_state = "walk"
  end
  local animation = animations[self.animation_state]
  if self.animation_state == "idle" then self.anim_time = 0 end
  local frame_index = animation.fps == 0 and 1
    or math.floor(self.anim_time * animation.fps) % #animation.frames + 1
  self.anim_frame = animation.frames[frame_index]
end

function Player:health_state()
  local fraction = self.hp / math.max(1, self.max_hp)
  if fraction < 0.05 then return "critical" end
  if fraction < 0.20 then return "concern" end
  return "normal"
end

function Player:take_damage(amount, push_x, push_y, push_force)
  if self.dead or self.invulnerability > 0 then return false end
  if self.tuning and self.tuning:get("player.invincible") then return false end
  amount = amount / math.max(0.25,
    self.defense_multiplier * self.temporary_defense_multiplier)
  local absorbed = math.min(self.guard, amount)
  self.guard = self.guard - absorbed
  amount = amount - absorbed
  self.hp = math.max(0, self.hp - amount)
  self.last_damage = amount
  self.time_since_hit = 0
  self.invulnerability = settings.combat.player_invulnerability
  self.flash = self.options.hit_flash == false and 0 or 0.18
  self.hit_pulse = self.options.hit_flash == false and 0 or 0.26
  self.hurt_timer = 0.34
  self.knockback_x = (push_x or 0) * (push_force or 0)
  self.knockback_y = (push_y or 0) * (push_force or 0)
  if self.hp <= 0 then self.dead = true end
  return true
end

function Player:draw()
  local tint = self.flash > 0 and { 1, 0.45, 0.45, 1 } or { 1, 1, 1, 1 }
  local character_sheet = self.assets
    and self.assets.player
    and self.assets.player.characters
    and self.assets.player.characters[self.character.id]
  if character_sheet then
    character_sheet:draw(
      self.anim_frame, self.anim_row, self.x, self.y,
      { scale = 0.36, color = tint, origin_y = 172 })
  elseif self.assets and self.assets.player and self.assets.player.v2 then
    self.assets.player.v2:draw(
      self.anim_frame, self.anim_row, self.x, self.y,
      { scale = 0.31, color = tint, origin_y = 210 })
  elseif self.assets and self.assets.player then
    local sheet = self.moving and self.assets.player.run or self.assets.player.idle
    local shadow = self.moving and self.assets.player.run_shadow or self.assets.player.idle_shadow
    shadow:draw(self.anim_frame, self.anim_row, self.x + 2, self.y + 5, {
      scale = 0.9,
      color = { 1, 1, 1, 0.58 },
    })
    sheet:draw(self.anim_frame, self.anim_row, self.x, self.y, {
      scale = 0.9,
      color = tint,
    })
  else
    love.graphics.setColor(tint)
    love.graphics.circle("fill", self.x, self.y, self.radius)
  end

  -- A restrained pointer follows the mouse; gamepad aim holds a nearby
  -- direction marker. The former line made the character feel offset.
  local target_x = self.aim_target_x or (self.x + self.aim_x * 72)
  local target_y = self.aim_target_y or (self.y + self.aim_y * 72)
  if self.show_aim ~= false and self.assets and self.assets.draw_aim_cursor then
    self.assets:draw_aim_cursor(
      target_x, target_y, self.aim_device == "mouse" and 52 or 44,
      { color = { 1, 1, 1, self.aim_device == "mouse" and 0.78 or 0.64 } })
  elseif self.show_aim ~= false then
    love.graphics.setColor(0.36, 0.92, 1.0, 0.52)
    love.graphics.circle("line", target_x, target_y, 7)
  end
end

return Player
