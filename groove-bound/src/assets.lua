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

local function grid_quads(value, columns, rows, inset)
  local width, height = value:getDimensions()
  local cell_w, cell_h = width / columns, height / rows
  inset = inset or 0
  local sample_w, sample_h = cell_w - inset * 2, cell_h - inset * 2
  local result = {}
  for row = 1, rows do
    result[row] = {}
    for col = 1, columns do
      result[row][col] = love.graphics.newQuad(
        (col - 1) * cell_w + inset, (row - 1) * cell_h + inset,
        sample_w, sample_h, width, height)
    end
  end
  return result, sample_w, sample_h
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
    logo = image("assets/generated/campaign/groove-bound-title-v2.png"),
    title_background = image("assets/generated/campaign/title-background-v3.png"),
    portraits = image("assets/generated/campaign/character-portraits-atlas.png"),
    character_logos = {
      joe = image("assets/generated/campaign/joe-logo.png"),
      lyra = image("assets/generated/campaign/lyra-vex-logo.png"),
    },
    aim_reticle = image("assets/generated/campaign/aim-reticle.png"),
    hud_slot_frame = image("assets/generated/campaign/hud-slot-frame.png"),
    talking = {
      joe = image("assets/generated/campaign/joe-talking-strip.png"),
      lyra = image("assets/generated/campaign/lyra-talking-strip.png"),
    },
    cutscenes = {
      prologue = image("assets/generated/cutscenes/prologue-atlas.png"),
      campaign = image("assets/generated/cutscenes/campaign-atlas.png"),
    },
  }
  self.campaign.portrait_quads,
    self.campaign.portrait_cell_w,
    self.campaign.portrait_cell_h = grid_quads(self.campaign.portraits, 2, 1)
  local frame = self.campaign.hud_slot_frame
  local frame_w, frame_h = frame:getDimensions()
  local corner, frame_strip = 96, 64
  self.campaign.hud_frame_parts = {
    top_left = love.graphics.newQuad(0, 0, corner, corner, frame_w, frame_h),
    top_right = love.graphics.newQuad(
      frame_w - corner, 0, corner, corner, frame_w, frame_h),
    bottom_left = love.graphics.newQuad(
      0, frame_h - corner, corner, corner, frame_w, frame_h),
    bottom_right = love.graphics.newQuad(
      frame_w - corner, frame_h - corner,
      corner, corner, frame_w, frame_h),
    top = love.graphics.newQuad(
      160, 0, frame_strip, corner, frame_w, frame_h),
    bottom = love.graphics.newQuad(
      160, frame_h - corner, frame_strip, corner, frame_w, frame_h),
    left = love.graphics.newQuad(
      0, 160, corner, frame_strip, frame_w, frame_h),
    right = love.graphics.newQuad(
      frame_w - corner, 160, corner, frame_strip, frame_w, frame_h),
  }
  self.campaign.hud_frame_corner = corner
  self.campaign.hud_frame_strip = frame_strip
  self.campaign.cutscene_quads = {}
  for id, atlas in pairs(self.campaign.cutscenes) do
    self.campaign.cutscene_quads[id] = grid_quads(atlas, 2, 2)
  end
  self.campaign.talking_quads = {}
  self.campaign.talking_cell_w = {}
  self.campaign.talking_cell_h = {}
  for id, strip in pairs(self.campaign.talking) do
    self.campaign.talking_quads[id],
      self.campaign.talking_cell_w[id],
      self.campaign.talking_cell_h[id] = grid_quads(strip, 2, 1)
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
  self.enemy.funk = image("assets/generated/campaign/funk-enemies-atlas.png")
  self.enemy.funk_quads,
    self.enemy.funk_cell_w,
    self.enemy.funk_cell_h = grid_quads(self.enemy.funk, 4, 2, 2)

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
  self.xp_gems = image("assets/generated/campaign/xp-gems-atlas.png")
  self.xp_gem_quads,
    self.xp_gem_cell_w,
    self.xp_gem_cell_h = grid_quads(self.xp_gems, 2, 2)
  self.pickups = image("assets/generated/campaign/pickup-consumables-atlas.png")
  self.pickup_quads,
    self.pickup_cell_w,
    self.pickup_cell_h = grid_quads(self.pickups, 4, 2)
  self.reward_chest = image(
    "assets/generated/campaign/musical-chest-atlas.png")
  self.stage_clear_chest = image(
    "assets/generated/campaign/stage-clear-chest.png")
  self.chest_luck_reveal = image(
    "assets/generated/campaign/chest-luck-reveal-atlas.png")
  self.chest_luck_reveal_quads,
    self.chest_luck_reveal_cell_w,
    self.chest_luck_reveal_cell_h = grid_quads(
      self.chest_luck_reveal, 5, 2, 2)
  self.completion_ui = image(
    "assets/generated/campaign/completion-ui-atlas.png")
  self.completion_ui_quads,
    self.completion_ui_cell_w,
    self.completion_ui_cell_h = grid_quads(self.completion_ui, 4, 2, 2)
  self.funk_pocket_pads = image(
    "assets/generated/campaign/funk-pocket-pad-atlas.png")
  self.funk_pocket_pad_quads,
    self.funk_pocket_pad_cell_w,
    self.funk_pocket_pad_cell_h = grid_quads(self.funk_pocket_pads, 5, 1)
  self.world_tour_ui = image(
    "assets/generated/campaign/world-tour-ui-atlas.png")
  self.world_tour_ui_quads,
    self.world_tour_ui_cell_w,
    self.world_tour_ui_cell_h = grid_quads(self.world_tour_ui, 5, 2)
  self.menu_button_icons = image(
    "assets/generated/campaign/menu-button-icons-atlas.png")
  self.menu_button_icon_quads,
    self.menu_button_icon_cell_w,
    self.menu_button_icon_cell_h = grid_quads(self.menu_button_icons, 5, 2)
  self.reward_chest_quads,
    self.reward_chest_cell_w,
    self.reward_chest_cell_h = grid_quads(self.reward_chest, 4, 2)
  self.floor_surfaces = {
    backbeat = image("assets/generated/campaign/backbeat-floor-atlas.png"),
    orbit = image("assets/generated/campaign/orbit-floor-atlas.png"),
    funk = image("assets/generated/campaign/funk-floor-atlas.png"),
  }
  self.floor_surface_quads = {}
  self.floor_surface_cell_w = {}
  self.floor_surface_cell_h = {}
  for id, atlas in pairs(self.floor_surfaces) do
    self.floor_surface_quads[id],
      self.floor_surface_cell_w[id],
      self.floor_surface_cell_h[id] = grid_quads(atlas, 2, 2)
  end
  self.gameover = image("assets/generated/campaign/game-over-v2.png")
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
  self.environment_backbeat_expansion = image(
    "assets/generated/campaign/backbeat-environment-expansion-atlas.png")
  self.environment_backbeat_expansion_quads,
    self.environment_backbeat_expansion_cell_w,
    self.environment_backbeat_expansion_cell_h = grid_quads(
      self.environment_backbeat_expansion, 4, 2)
  self.environment_orbit_expansion = image(
    "assets/generated/campaign/orbit-environment-expansion-atlas.png")
  self.environment_orbit_expansion_quads,
    self.environment_orbit_expansion_cell_w,
    self.environment_orbit_expansion_cell_h = grid_quads(
      self.environment_orbit_expansion, 4, 2)
  self.environment_funk = image(
    "assets/generated/campaign/funk-environment-atlas.png")
  self.environment_funk_quads,
    self.environment_funk_cell_w,
    self.environment_funk_cell_h = grid_quads(
      self.environment_funk, 4, 2, 2)
  self.environment_upper_quads = {}

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

function Assets:draw_character_logo(id, x, y, w, h, opts)
  opts = opts or {}
  local logo = self.campaign.character_logos[id]
  if not logo then return false end
  local scale = math.min(w / logo:getWidth(), h / logo:getHeight())
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(
    logo, x + w / 2, y + h / 2, opts.rotation or 0,
    scale, scale, logo:getWidth() / 2, logo:getHeight() / 2)
  return true
end

local function draw_centered_fit(value, x, y, w, h, opts)
  opts = opts or {}
  local image_w, image_h = value:getDimensions()
  local scale = math.min(w / image_w, h / image_h)
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(
    value, x + w / 2, y + h / 2, opts.rotation or 0,
    scale, scale, image_w / 2, image_h / 2)
end

function Assets:draw_hud_frame(x, y, w, h, opts)
  opts = opts or {}
  local image_value = self.campaign.hud_slot_frame
  local parts = self.campaign.hud_frame_parts
  local source_corner = self.campaign.hud_frame_corner
  local source_strip = self.campaign.hud_frame_strip
  local corner = math.min(opts.corner or 11, w / 3, h / 3)
  local scale = corner / source_corner
  local tile = source_strip * scale
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })

  local inner_w, inner_h = math.max(0, w - corner * 2),
    math.max(0, h - corner * 2)
  local horizontal_count = math.max(1, math.ceil(inner_w / tile))
  local vertical_count = math.max(1, math.ceil(inner_h / tile))
  local horizontal_start = x + corner
    - (horizontal_count * tile - inner_w) / 2
  local vertical_start = y + corner
    - (vertical_count * tile - inner_h) / 2

  for index = 0, horizontal_count - 1 do
    local piece_x = horizontal_start + index * tile
    love.graphics.draw(image_value, parts.top,
      piece_x, y, 0, scale, scale)
    love.graphics.draw(image_value, parts.bottom,
      piece_x, y + h - corner, 0, scale, scale)
  end
  for index = 0, vertical_count - 1 do
    local piece_y = vertical_start + index * tile
    love.graphics.draw(image_value, parts.left,
      x, piece_y, 0, scale, scale)
    love.graphics.draw(image_value, parts.right,
      x + w - corner, piece_y, 0, scale, scale)
  end

  love.graphics.draw(image_value, parts.top_left, x, y, 0, scale, scale)
  love.graphics.draw(image_value, parts.top_right,
    x + w - corner, y, 0, scale, scale)
  love.graphics.draw(image_value, parts.bottom_left,
    x, y + h - corner, 0, scale, scale)
  love.graphics.draw(image_value, parts.bottom_right,
    x + w - corner, y + h - corner, 0, scale, scale)
  return true
end

function Assets:draw_hud_slot(x, y, w, h, opts)
  self:draw_hud_frame(x, y, w, h, opts)
  return true
end

function Assets:draw_aim_cursor(x, y, size, opts)
  draw_centered_fit(
    self.campaign.aim_reticle,
    x - size / 2, y - size / 2, size, size, opts)
  return true
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
  elseif icon.atlas == "funk" then
    atlas = self.enemy.funk
    quad = self.enemy.funk_quads[icon.row][icon.col]
    cell_size = math.max(self.enemy.funk_cell_w, self.enemy.funk_cell_h)
  end
  local scale = size / cell_size
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(
    atlas, quad, x, y, 0,
    opts.flip_x and -scale or scale, scale,
    icon.atlas == "stage2" and self.enemy.stage2_cell_w / 2
      or icon.atlas == "funk" and self.enemy.funk_cell_w / 2 or 128,
    icon.atlas == "stage2" and self.enemy.stage2_cell_h / 2
      or icon.atlas == "funk" and self.enemy.funk_cell_h / 2 or 128)
end

local function environment_source(self, icon, atlas_id)
  local atlas = self.environment
  local quad = self.environment_quads[icon.row][icon.col]
  local cell_w, cell_h = 256, 256
  if atlas_id == "stage2" then
    atlas = self.environment_stage2
    quad = self.environment_stage2_quads[icon.row][icon.col]
    cell_w, cell_h = self.environment_stage2_cell_w,
      self.environment_stage2_cell_h
  elseif atlas_id == "backbeat_expansion" then
    atlas = self.environment_backbeat_expansion
    quad = self.environment_backbeat_expansion_quads[icon.row][icon.col]
    cell_w, cell_h = self.environment_backbeat_expansion_cell_w,
      self.environment_backbeat_expansion_cell_h
  elseif atlas_id == "orbit_expansion" then
    atlas = self.environment_orbit_expansion
    quad = self.environment_orbit_expansion_quads[icon.row][icon.col]
    cell_w, cell_h = self.environment_orbit_expansion_cell_w,
      self.environment_orbit_expansion_cell_h
  elseif atlas_id == "funk" then
    atlas = self.environment_funk
    quad = self.environment_funk_quads[icon.row][icon.col]
    cell_w, cell_h = self.environment_funk_cell_w,
      self.environment_funk_cell_h
  end
  return atlas, quad, cell_w, cell_h
end

function Assets:draw_environment(icon, x, y, size, opts)
  opts = opts or {}
  local atlas, quad, cell_w, cell_h = environment_source(
    self, icon, opts.atlas)
  local origin_x, origin_y = cell_w / 2, cell_h / 2
  local cell_size = math.max(cell_w, cell_h)
  local scale = size / cell_size
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(atlas, quad, x, y, 0, scale, scale, origin_x, origin_y)
end

function Assets:draw_environment_upper(icon, x, y, size, opts)
  opts = opts or {}
  local atlas, quad, cell_w, cell_h = environment_source(
    self, icon, opts.atlas)
  local viewport_x, viewport_y = quad:getViewport()
  local fraction = opts.fraction or 0.56
  local upper_h = math.max(1, math.floor(cell_h * fraction))
  local cache_key = table.concat({
    opts.atlas or "stage1", icon.row, icon.col, upper_h,
  }, ":")
  local upper = self.environment_upper_quads[cache_key]
  if not upper then
    upper = love.graphics.newQuad(
      viewport_x, viewport_y, cell_w, upper_h, atlas:getDimensions())
    self.environment_upper_quads[cache_key] = upper
  end
  local scale = size / math.max(cell_w, cell_h)
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(
    atlas, upper, x, y, 0, scale, scale, cell_w / 2, cell_h / 2)
end

function Assets:draw_projectile(
  weapon_id, x, y, size, rotation, color, scale_x, scale_y)
  local cell = self.projectile_cells[weapon_id]
  if not cell then return false end
  local quad = self.projectile_quads[cell.row][cell.col]
  local scale = math.max(12, size * 2.5) / 256
  scale_x = scale_x or 1
  scale_y = scale_y or 1
  love.graphics.setColor(color or { 1, 1, 1, 1 })
  love.graphics.draw(
    self.projectile_atlas, quad, x, y, rotation or 0,
    scale * scale_x, scale * scale_y, 128, 128)
  return true
end

function Assets:draw_enemy_projectile(
  projectile_kind, x, y, size, rotation, color, scale_x, scale_y)
  local sprite = projectile_kind == "note_bolt"
    and "brass_barrage" or "neon_crescendo"
  return self:draw_projectile(
    sprite, x, y, math.max(size, 10), rotation,
    color, scale_x * 1.18, scale_y * 1.18)
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
  local scissor_x, scissor_y = love.graphics.transformPoint(x, y)
  local scissor_right, scissor_bottom = love.graphics.transformPoint(
    x + w, y + h)
  love.graphics.setScissor(
    math.min(scissor_x, scissor_right),
    math.min(scissor_y, scissor_bottom),
    math.abs(scissor_right - scissor_x),
    math.abs(scissor_bottom - scissor_y))
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

function Assets:draw_talking_character(id, frame, x, bottom, height, opts)
  opts = opts or {}
  local strip = self.campaign.talking[id]
  if not strip then return false end
  local cell_w = self.campaign.talking_cell_w[id]
  local cell_h = self.campaign.talking_cell_h[id]
  local quad = self.campaign.talking_quads[id][1][frame]
  local scale = height / cell_h
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(
    strip, quad, x, bottom, opts.rotation or 0,
    scale, scale, cell_w / 2, cell_h)
  return true
end

local pickup_cells = {
  heal = { col = 1, row = 1 },
  magnet = { col = 2, row = 1 },
  damage = { col = 3, row = 1 },
  defense = { col = 4, row = 1 },
  speed = { col = 1, row = 2 },
}

function Assets:draw_pickup(kind, x, y, size, opts)
  local cell = pickup_cells[kind]
  if not cell then return false end
  opts = opts or {}
  local scale = size / math.max(self.pickup_cell_w, self.pickup_cell_h)
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(
    self.pickups, self.pickup_quads[cell.row][cell.col], x, y,
    opts.rotation or 0, scale, scale,
    self.pickup_cell_w / 2, self.pickup_cell_h / 2)
  return true
end

function Assets:draw_xp_gem(tier, x, y, size, opts)
  tier = math.max(1, math.min(4, tier or 1))
  opts = opts or {}
  local col = (tier - 1) % 2 + 1
  local row = math.floor((tier - 1) / 2) + 1
  local scale = size / math.max(self.xp_gem_cell_w, self.xp_gem_cell_h)
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(
    self.xp_gems, self.xp_gem_quads[row][col], x, y,
    opts.rotation or 0, scale, scale,
    self.xp_gem_cell_w / 2, self.xp_gem_cell_h / 2)
  return true
end

function Assets:draw_reward_chest(frame, x, y, size, opts)
  frame = math.max(1, math.min(8, frame or 1))
  opts = opts or {}
  local col = (frame - 1) % 4 + 1
  local row = math.floor((frame - 1) / 4) + 1
  local scale = size / math.max(
    self.reward_chest_cell_w, self.reward_chest_cell_h)
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(
    self.reward_chest, self.reward_chest_quads[row][col], x, y,
    opts.rotation or 0, scale, scale,
    self.reward_chest_cell_w / 2, self.reward_chest_cell_h / 2)
  return true
end

function Assets:draw_stage_clear_chest(x, y, size, opts)
  draw_centered_fit(
    self.stage_clear_chest,
    x - size / 2, y - size / 2, size, size, opts)
  return true
end

local function draw_atlas_cell(atlas, quads, cell_w, cell_h,
    col, row, x, y, w, h, opts)
  opts = opts or {}
  local scale = math.min(w / cell_w, h / cell_h)
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(
    atlas, quads[row][col], x + w / 2, y + h / 2,
    opts.rotation or 0, scale, scale, cell_w / 2, cell_h / 2)
  return true
end

function Assets:draw_chest_luck(frame, x, y, w, h, opts)
  frame = math.max(1, math.min(5, frame or 1))
  return draw_atlas_cell(
    self.chest_luck_reveal, self.chest_luck_reveal_quads,
    self.chest_luck_reveal_cell_w, self.chest_luck_reveal_cell_h,
    frame, 1, x, y, w, h, opts)
end

function Assets:draw_reward_stage(frame, x, y, w, h, opts)
  frame = math.max(1, math.min(5, frame or 5))
  return draw_atlas_cell(
    self.chest_luck_reveal, self.chest_luck_reveal_quads,
    self.chest_luck_reveal_cell_w, self.chest_luck_reveal_cell_h,
    frame, 2, x, y, w, h, opts)
end

function Assets:draw_completion_ui(col, row, x, y, w, h, opts)
  col = math.max(1, math.min(4, col or 1))
  row = math.max(1, math.min(2, row or 1))
  return draw_atlas_cell(
    self.completion_ui, self.completion_ui_quads,
    self.completion_ui_cell_w, self.completion_ui_cell_h,
    col, row, x, y, w, h, opts)
end

function Assets:draw_funk_pad(frame, x, y, w, h, opts)
  frame = math.max(1, math.min(5, frame or 1))
  return draw_atlas_cell(
    self.funk_pocket_pads, self.funk_pocket_pad_quads,
    self.funk_pocket_pad_cell_w, self.funk_pocket_pad_cell_h,
    frame, 1, x, y, w, h, opts)
end

function Assets:draw_world_tour_icon(col, row, x, y, w, h, opts)
  col = math.max(1, math.min(5, col or 1))
  row = math.max(1, math.min(2, row or 1))
  return draw_atlas_cell(
    self.world_tour_ui, self.world_tour_ui_quads,
    self.world_tour_ui_cell_w, self.world_tour_ui_cell_h,
    col, row, x, y, w, h, opts)
end

function Assets:draw_menu_button_icon(col, row, x, y, w, h, opts)
  col = math.max(1, math.min(5, col or 1))
  row = math.max(1, math.min(2, row or 1))
  return draw_atlas_cell(
    self.menu_button_icons, self.menu_button_icon_quads,
    self.menu_button_icon_cell_w, self.menu_button_icon_cell_h,
    col, row, x, y, w, h, opts)
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
