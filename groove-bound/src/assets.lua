-- Runtime asset registry for the first playable remake slice.
--
-- All paths point into the isolated legacy namespace so gameplay code never
-- depends on filenames and future art replacement stays mechanical.

local SpriteSheet = require("src.render.sprite_sheet")

local Assets = {}
Assets.__index = Assets

local function image(path)
  local value = love.graphics.newImage(path)
  value:setFilter("nearest", "nearest")
  return value
end

local function source(path, volume)
  local value = love.audio.newSource(path, "static")
  value:setVolume(volume or 0.25)
  return value
end

function Assets.load()
  local self = setmetatable({}, Assets)

  self.player = {
    idle = SpriteSheet({
      path = "assets/legacy/images/player/idle.png",
      frame_w = 64, frame_h = 64, cols = 12, rows = 4,
    }),
    idle_shadow = SpriteSheet({
      path = "assets/legacy/images/player/idle-shadow.png",
      frame_w = 64, frame_h = 64, cols = 12, rows = 4,
    }),
    run = SpriteSheet({
      path = "assets/legacy/images/player/run.png",
      frame_w = 64, frame_h = 64, cols = 8, rows = 4,
    }),
    run_shadow = SpriteSheet({
      path = "assets/legacy/images/player/run-shadow.png",
      frame_w = 64, frame_h = 64, cols = 8, rows = 4,
    }),
  }

  self.enemy = {
    walk = SpriteSheet({
      path = "assets/legacy/images/enemy/walk.png",
      frame_w = 64, frame_h = 64, cols = 6, rows = 4,
    }),
    death = SpriteSheet({
      path = "assets/legacy/images/enemy/death.png",
      frame_w = 64, frame_h = 64, cols = 11, rows = 4,
    }),
  }

  self.floor = image("assets/legacy/images/floor-tiles1.jpg")
  self.floor_quads = {}
  for row = 0, 1 do
    for col = 0, 3 do
      self.floor_quads[#self.floor_quads + 1] = love.graphics.newQuad(
        col * 128, row * 128, 128, 128, self.floor:getDimensions())
    end
  end

  self.projectile = image("assets/legacy/images/projectile.png")
  self.xp_gem = image("assets/legacy/images/xp-gem.png")
  self.gameover = image("assets/legacy/images/ui/gameover.png")
  self.icon = image("assets/legacy/images/ui/icon.png")
  self.weapon_icons = image("assets/generated/weapon-icons-atlas.png")
  self.weapon_icon_quads = {}
  for row = 1, 2 do
    self.weapon_icon_quads[row] = {}
    for col = 1, 4 do
      self.weapon_icon_quads[row][col] = love.graphics.newQuad(
        (col - 1) * 256,
        (row - 1) * 256,
        256,
        256,
        self.weapon_icons:getDimensions())
    end
  end

  self.sfx = {
    projectile = source("assets/legacy/sfx/projectile.ogg", 0.08),
    xp = source("assets/legacy/sfx/xp.ogg", 0.18),
    enemy_death = source("assets/legacy/sfx/enemy-death.ogg", 0.12),
    level_up = source("assets/legacy/sfx/level-up.ogg", 0.22),
  }
  self.sfx_base = {
    projectile = 0.08,
    xp = 0.18,
    enemy_death = 0.12,
    level_up = 0.22,
  }
  self.last_sound = {}

  return self
end

function Assets:draw_weapon_icon(icon, x, y, size, opts)
  opts = opts or {}
  icon = icon or { col = 1, row = 1 }
  local quad = self.weapon_icon_quads[icon.row][icon.col]
  local scale = size / 256
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(
    self.weapon_icons,
    quad,
    x,
    y,
    opts.rotation or 0,
    scale,
    scale,
    128,
    128)
end

function Assets:set_sfx_volume(value)
  value = math.max(0, math.min(1, value or 1))
  for name, sound in pairs(self.sfx) do
    sound:setVolume(self.sfx_base[name] * value)
  end
end

function Assets:play(name, minimum_interval)
  local sound = self.sfx[name]
  if not sound then return end
  local now = love.timer.getTime()
  minimum_interval = minimum_interval or 0
  if now - (self.last_sound[name] or -math.huge) < minimum_interval then return end
  self.last_sound[name] = now
  sound:stop()
  sound:play()
end

return Assets
