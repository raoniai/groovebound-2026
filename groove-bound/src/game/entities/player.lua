-- Player entity: movement, aim, health, damage state, and animation selection.
-- Combat and weapon progression stay system-owned (single-owner rule).

local class = require("src.core.class")
local settings = require("src.config.settings")

local Player = class()

local directions = {
  down = 1,
  up = 2,
  left = 3,
  right = 4,
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
  self.radius = cfg.size / 2
  self.hp = cfg.hp
  self.max_hp = cfg.hp
  self.base_max_hp = cfg.hp
  self.passive_speed_multiplier = 1
  self.aim_x, self.aim_y = 1, 0
  self.anim_time = 0
  self.anim_frame = 1
  self.anim_row = directions.down
  self.moving = false
  self.invulnerability = 0
  self.flash = 0
  self.dead = false
  self.guard = 0
end

function Player:update(dt, input, camera, arena)
  self.invulnerability = math.max(0, self.invulnerability - dt)
  self.flash = math.max(0, self.flash - dt)
  local mx, my = input:move_vector()
  local speed_multiplier = self.tuning and self.tuning:get("player.speed_multiplier") or 1
  self.speed = self.base_speed * speed_multiplier * self.passive_speed_multiplier
  local old_x, old_y = self.x, self.y
  local next_x = self.x + mx * self.speed * dt
  local next_y = self.y + my * self.speed * dt
  if arena.resolve_movement then
    self.x, self.y = arena:resolve_movement(
      old_x, old_y, next_x, next_y, self.radius)
  else
    self.x, self.y = arena:clamp(next_x, next_y, self.radius)
  end

  self.aim_x, self.aim_y = input:aim_vector(self.x, self.y, camera)
  self.moving = math.abs(mx) + math.abs(my) > 0.01
  local facing_x, facing_y = self.moving and mx or self.aim_x, self.moving and my or self.aim_y
  if math.abs(facing_x) > math.abs(facing_y) then
    self.anim_row = facing_x > 0 and directions.right or directions.left
  else
    self.anim_row = facing_y > 0 and directions.down or directions.up
  end
  self.anim_time = self.anim_time + dt
  local fps = self.moving and 14 or 7
  local frames = self.assets and self.assets.player.v2 and 4
    or (self.moving and 8 or 4)
  self.anim_frame = math.floor(self.anim_time * fps) % frames + 1
end

function Player:take_damage(amount)
  if self.dead or self.invulnerability > 0 then return false end
  if self.tuning and self.tuning:get("player.invincible") then return false end
  local absorbed = math.min(self.guard, amount)
  self.guard = self.guard - absorbed
  amount = amount - absorbed
  self.hp = math.max(0, self.hp - amount)
  self.invulnerability = settings.combat.player_invulnerability
  self.flash = self.options.hit_flash == false and 0 or 0.12
  if self.hp <= 0 then self.dead = true end
  return true
end

function Player:draw()
  local tint = self.flash > 0 and { 1, 0.45, 0.45, 1 } or { 1, 1, 1, 1 }
  if self.assets and self.assets.player and self.assets.player.v2 then
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

  -- Aim indicator.
  love.graphics.setColor(0.4, 0.95, 0.55, 0.9)
  love.graphics.line(
    self.x + self.aim_x * self.radius,
    self.y + self.aim_y * self.radius,
    self.x + self.aim_x * self.radius * 2.2,
    self.y + self.aim_y * self.radius * 2.2)
end

return Player
