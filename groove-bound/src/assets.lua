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

local function grid_quads(value, columns, rows)
  local width, height = value:getDimensions()
  local cell_w, cell_h = width / columns, height / rows
  local result = {}
  for row = 1, rows do
    result[row] = {}
    for col = 1, columns do
      result[row][col] = love.graphics.newQuad(
        (col - 1) * cell_w, (row - 1) * cell_h,
        cell_w, cell_h, width, height)
    end
  end
  return result, cell_w, cell_h
end

function Assets.load()
  local self = setmetatable({}, Assets)

  self.player = {
    v2 = SpriteSheet({
      path = "assets/generated/player-v2-sheet.png",
      frame_w = 256, frame_h = 256, cols = 4, rows = 4,
    }),
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
  self.player.characters = {
    joe = SpriteSheet({
      path = "assets/generated/campaign/joe-action-sheet.png",
      frame_w = 221, frame_h = 221, cols = 8, rows = 4,
    }),
    lyra = SpriteSheet({
      path = "assets/generated/campaign/lyra-action-sheet.png",
      frame_w = 221, frame_h = 221, cols = 8, rows = 4,
    }),
  }

  self.campaign = {
    logo = image("assets/generated/campaign/groove-bound-logo.png"),
    portraits = image("assets/generated/campaign/character-portraits-atlas.png"),
    cutscenes = {
      prologue = image("assets/generated/cutscenes/prologue-atlas.png"),
      campaign = image("assets/generated/cutscenes/campaign-atlas.png"),
    },
  }
  self.campaign.portrait_quads,
    self.campaign.portrait_cell_w,
    self.campaign.portrait_cell_h = grid_quads(self.campaign.portraits, 2, 1)
  self.campaign.cutscene_quads = {}
  for id, atlas in pairs(self.campaign.cutscenes) do
    self.campaign.cutscene_quads[id] = grid_quads(atlas, 2, 2)
  end

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

  self.enemy.variants = image("assets/generated/enemy-variants-atlas.png")
  self.enemy.variant_quads = {}
  for row = 1, 2 do
    self.enemy.variant_quads[row] = {}
    for col = 1, 4 do
      self.enemy.variant_quads[row][col] = love.graphics.newQuad(
        (col - 1) * 256, (row - 1) * 256, 256, 256,
        self.enemy.variants:getDimensions())
    end
  end
  self.enemy.stage2 = image("assets/generated/campaign/stage2-enemies-atlas.png")
  self.enemy.stage2_quads,
    self.enemy.stage2_cell_w,
    self.enemy.stage2_cell_h = grid_quads(self.enemy.stage2, 4, 2)

  self.floor = image("assets/legacy/images/floor-tiles1.jpg")
  self.floor_quads = {}
  for row = 0, 1 do
    for col = 0, 3 do
      self.floor_quads[#self.floor_quads + 1] = love.graphics.newQuad(
        col * 128, row * 128, 128, 128, self.floor:getDimensions())
    end
  end

  self.projectile = image("assets/legacy/images/projectile.png")
  self.projectile_atlas = image("assets/generated/campaign/projectile-atlas.png")
  self.projectile_quads = grid_quads(self.projectile_atlas, 6, 4)
  self.projectile_cells = {}
  local projectile_ids = {
    "kazoo_pistol", "bass_drop", "cymbal_slicer", "feedback_loop",
    "drum_circle", "trumpet_burst", "vinyl_scratch", "synth_wave",
    "triangle_tracer", "cello_lance", "maraca_orbit", "tuning_fork",
    "keytar_chord", "bell_tower", "tape_repeater", "laser_harp",
    "brass_barrage", "improvised_solo", "subwoofer_supernova",
    "orbital_ovation", "thunderhead_ensemble", "golden_fortissimo",
    "gravity_groove", "neon_crescendo",
  }
  for index, id in ipairs(projectile_ids) do
    self.projectile_cells[id] = {
      col = (index - 1) % 6 + 1,
      row = math.floor((index - 1) / 6) + 1,
    }
  end
  self.combat_fx = SpriteSheet({
    path = "assets/generated/campaign/combat-fx-atlas.png",
    frame_w = 313, frame_h = 313, cols = 4, rows = 4,
  })
  self.xp_gem = image("assets/legacy/images/xp-gem.png")
  self.gameover = image("assets/legacy/images/ui/gameover.png")
  self.icon = image("assets/generated/campaign/app-icon.png")
  self.weapon_icons = image("assets/generated/weapon-icons-atlas.png")
  self.weapon_icons_2 = image("assets/generated/weapon-icons-atlas-2.png")
  self.evolved_weapon_icons = image("assets/generated/evolved-weapon-icons-atlas.png")
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

  self.support_icons = image("assets/generated/support-icons-atlas.png")
  self.support_icon_quads = {}
  self.environment = image("assets/generated/environment-atlas.png")
  self.environment_quads = {}
  for row = 1, 2 do
    self.support_icon_quads[row] = {}
    self.environment_quads[row] = {}
    for col = 1, 4 do
      self.support_icon_quads[row][col] = love.graphics.newQuad(
        (col - 1) * 256, (row - 1) * 256, 256, 256,
        self.support_icons:getDimensions())
      self.environment_quads[row][col] = love.graphics.newQuad(
        (col - 1) * 256, (row - 1) * 256, 256, 256,
        self.environment:getDimensions())
    end
  end
  self.environment_stage2 = image(
    "assets/generated/campaign/stage2-environment-atlas.png")
  self.environment_stage2_quads,
    self.environment_stage2_cell_w,
    self.environment_stage2_cell_h = grid_quads(
      self.environment_stage2, 4, 2)

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
  local atlas = self.weapon_icons
  if icon.atlas == "base2" then atlas = self.weapon_icons_2
  elseif icon.atlas == "evolved" then atlas = self.evolved_weapon_icons end
  local scale = size / 256
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(
    atlas,
    quad,
    x,
    y,
    opts.rotation or 0,
    scale,
    scale,
    128,
    128)
end

function Assets:draw_support_icon(icon, x, y, size, opts)
  opts = opts or {}
  local quad = self.support_icon_quads[icon.row][icon.col]
  local scale = size / 256
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(
    self.support_icons, quad, x, y, opts.rotation or 0,
    scale, scale, 128, 128)
end

function Assets:draw_enemy_variant(icon, x, y, size, opts)
  opts = opts or {}
  local atlas = self.enemy.variants
  local quad = self.enemy.variant_quads[icon.row][icon.col]
  local cell_size = 256
  if icon.atlas == "stage2" then
    atlas = self.enemy.stage2
    quad = self.enemy.stage2_quads[icon.row][icon.col]
    cell_size = math.max(self.enemy.stage2_cell_w, self.enemy.stage2_cell_h)
  end
  local scale = size / cell_size
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(
    atlas, quad, x, y, 0,
    opts.flip_x and -scale or scale, scale,
    icon.atlas == "stage2" and self.enemy.stage2_cell_w / 2 or 128,
    icon.atlas == "stage2" and self.enemy.stage2_cell_h / 2 or 128)
end

function Assets:draw_environment(icon, x, y, size, opts)
  opts = opts or {}
  local atlas = self.environment
  local quad = self.environment_quads[icon.row][icon.col]
  local origin_x, origin_y, cell_size = 128, 128, 256
  if opts.atlas == "stage2" then
    atlas = self.environment_stage2
    quad = self.environment_stage2_quads[icon.row][icon.col]
    origin_x = self.environment_stage2_cell_w / 2
    origin_y = self.environment_stage2_cell_h / 2
    cell_size = math.max(
      self.environment_stage2_cell_w, self.environment_stage2_cell_h)
  end
  local scale = size / cell_size
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(atlas, quad, x, y, 0, scale, scale, origin_x, origin_y)
end

function Assets:draw_projectile(weapon_id, x, y, size, rotation, color)
  local cell = self.projectile_cells[weapon_id]
  if not cell then return false end
  local quad = self.projectile_quads[cell.row][cell.col]
  local scale = math.max(12, size * 2.5) / 256
  love.graphics.setColor(color or { 1, 1, 1, 1 })
  love.graphics.draw(
    self.projectile_atlas, quad, x, y, rotation or 0,
    scale, scale, 128, 128)
  return true
end

function Assets:draw_portrait(icon, x, y, w, h, opts)
  opts = opts or {}
  local quad = self.campaign.portrait_quads[icon.row][icon.col]
  local scale = math.max(
    w / self.campaign.portrait_cell_w,
    h / self.campaign.portrait_cell_h)
  local draw_w = self.campaign.portrait_cell_w * scale
  local draw_h = self.campaign.portrait_cell_h * scale
  local previous_scissor = { love.graphics.getScissor() }
  love.graphics.setScissor(x, y, w, h)
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(
    self.campaign.portraits, quad,
    x + (w - draw_w) / 2,
    y - (draw_h - h) * (opts.focus_y or 0.30),
    0, scale, scale)
  if previous_scissor[1] then
    love.graphics.setScissor(
      previous_scissor[1], previous_scissor[2],
      previous_scissor[3], previous_scissor[4])
  else
    love.graphics.setScissor()
  end
end

function Assets:draw_cutscene(atlas_id, col, row, x, y, w, h, opts)
  opts = opts or {}
  local atlas = self.campaign.cutscenes[atlas_id]
  local quad = self.campaign.cutscene_quads[atlas_id][row][col]
  local _, _, cell_w, cell_h = quad:getViewport()
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(atlas, quad, x, y, 0, w / cell_w, h / cell_h)
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
