-- The playfield: a rectangle with walls. Owns bounds math (clamp/contains)
-- and its own rendering. Entities query it; nothing else knows arena size.

local class = require("src.core.class")
local settings = require("src.config.settings")

local Arena = class()

function Arena:init(opts)
  opts = opts or {}
  local cfg = settings.arena
  self.stage = opts.stage or {}
  self.width = opts.width or self.stage.width or cfg.width
  self.height = opts.height or self.stage.height or cfg.height
  self.wall = opts.wall or cfg.wall
  self.assets = opts.assets
  self.obstacles = opts.obstacles or self.stage.obstacles or {
    { x = 420, y = 360, w = 120, h = 180, icon = { col = 1, row = 1 } },
    { x = 910, y = 280, w = 150, h = 120, icon = { col = 2, row = 1 } },
    { x = 1420, y = 420, w = 150, h = 120, icon = { col = 3, row = 1 } },
    { x = 650, y = 980, w = 180, h = 115, icon = { col = 4, row = 1 } },
    { x = 1300, y = 1080, w = 130, h = 180, icon = { col = 1, row = 1 } },
  }
  self.decorations = opts.decorations or self.stage.decorations or {
    { x = 280, y = 790, size = 120, icon = { col = 1, row = 2 } },
    { x = 1120, y = 700, size = 105, icon = { col = 2, row = 2 } },
    { x = 1700, y = 820, size = 135, icon = { col = 3, row = 2 } },
    { x = 980, y = 1330, size = 100, icon = { col = 4, row = 2 } },
  }
end

function Arena:center()
  return self.width / 2, self.height / 2
end

-- Clamp a point so a body of the given radius stays inside the walls.
function Arena:clamp(x, y, radius)
  radius = radius or 0
  local lo = self.wall + radius
  return math.max(lo, math.min(x, self.width - self.wall - radius)),
         math.max(lo, math.min(y, self.height - self.wall - radius))
end

function Arena:contains(x, y, radius)
  radius = radius or 0
  local lo = self.wall + radius
  return x >= lo and y >= lo
     and x <= self.width - self.wall - radius
     and y <= self.height - self.wall - radius
end

local function circle_hits_rect(x, y, radius, rect)
  local nearest_x = math.max(rect.x, math.min(x, rect.x + rect.w))
  local nearest_y = math.max(rect.y, math.min(y, rect.y + rect.h))
  local dx, dy = x - nearest_x, y - nearest_y
  return dx * dx + dy * dy < radius * radius
end

local function draw_floor_surface(arena, style, tint, veil)
  local atlas = arena.assets and arena.assets.floor_surfaces
    and arena.assets.floor_surfaces[style]
  if not atlas then return false end
  local quads = arena.assets.floor_surface_quads[style]
  local cell_w = arena.assets.floor_surface_cell_w[style]
  local cell_h = arena.assets.floor_surface_cell_h[style]
  local tile_size = 256
  love.graphics.setColor(tint)
  for row = 0, math.ceil(arena.height / tile_size) - 1 do
    for column = 0, math.ceil(arena.width / tile_size) - 1 do
      local variant = (column * 17 + row * 31 + column * row * 3) % 4
      local col = variant % 2 + 1
      local quad_row = math.floor(variant / 2) + 1
      love.graphics.draw(
        atlas, quads[quad_row][col],
        column * tile_size, row * tile_size, 0,
        (tile_size + 1) / cell_w, (tile_size + 1) / cell_h)
    end
  end
  love.graphics.setColor(veil)
  love.graphics.rectangle("fill", 0, 0, arena.width, arena.height)
  return true
end

function Arena:blocked(x, y, radius)
  for _, obstacle in ipairs(self.obstacles) do
    if circle_hits_rect(x, y, radius, obstacle) then return true end
  end
  return false
end

function Arena:resolve_movement(old_x, old_y, x, y, radius)
  x, y = self:clamp(x, y, radius)
  if self:blocked(x, old_y, radius) then x = old_x end
  if self:blocked(x, y, radius) then y = old_y end
  if self:blocked(x, y, radius) then return old_x, old_y end
  return x, y
end

function Arena:draw()
  local cfg = settings.arena
  local floor_tint = self.stage.floor_tint or { 0.58, 0.54, 0.66, 0.78 }
  local veil_color = self.stage.veil_color or { 0.08, 0.06, 0.13, 0.42 }
  local environment_atlas = self.stage.environment_atlas or "stage1"

  -- Floor.
  love.graphics.setColor(cfg.floor_color)
  love.graphics.rectangle("fill", 0, 0, self.width, self.height)

  if not draw_floor_surface(
    self, self.stage.floor_style or "backbeat", floor_tint, veil_color)
    and self.assets and self.assets.floor
  then
    love.graphics.setColor(floor_tint)
    local tile_size = 128
    local columns = math.ceil(self.width / tile_size)
    local rows = math.ceil(self.height / tile_size)
    for row = 0, rows - 1 do
      for column = 0, columns - 1 do
        local index = (column * 17 + row * 31) % #self.assets.floor_quads + 1
        love.graphics.draw(
          self.assets.floor,
          self.assets.floor_quads[index],
          column * tile_size,
          row * tile_size)
      end
    end

    love.graphics.setColor(veil_color)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
  end

  if self.assets and self.assets.environment then
    for _, decoration in ipairs(self.decorations) do
      self.assets:draw_environment(
        decoration.icon, decoration.x, decoration.y, decoration.size,
        {
          color = { 1, 1, 1, 0.72 },
          atlas = decoration.atlas or environment_atlas,
        })
    end
  end

  if self.assets and self.assets.environment then
    for _, obstacle in ipairs(self.obstacles) do
      self.assets:draw_environment(
        obstacle.icon,
        obstacle.x + obstacle.w / 2,
        obstacle.y + obstacle.h / 2,
        math.max(obstacle.w, obstacle.h),
        { atlas = obstacle.atlas or environment_atlas })
    end
  end

  -- Walls.
  love.graphics.setColor(cfg.wall_color)
  love.graphics.rectangle("fill", 0, 0, self.width, self.wall)
  love.graphics.rectangle("fill", 0, self.height - self.wall, self.width, self.wall)
  love.graphics.rectangle("fill", 0, 0, self.wall, self.height)
  love.graphics.rectangle("fill", self.width - self.wall, 0, self.wall, self.height)
end

return Arena
