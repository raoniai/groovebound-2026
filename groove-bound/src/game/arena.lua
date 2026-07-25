-- The playfield: a rectangle with walls. Owns bounds math (clamp/contains)
-- and its own rendering. Entities query it; nothing else knows arena size.

local class = require("src.core.class")
local settings = require("src.config.settings")

local Arena = class()

function Arena:init(opts)
  opts = opts or {}
  local cfg = settings.arena
  self.width = opts.width or cfg.width
  self.height = opts.height or cfg.height
  self.wall = opts.wall or cfg.wall
  self.assets = opts.assets
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

function Arena:draw()
  local cfg = settings.arena

  -- Floor.
  love.graphics.setColor(cfg.floor_color)
  love.graphics.rectangle("fill", 0, 0, self.width, self.height)

  if self.assets and self.assets.floor then
    love.graphics.setColor(0.58, 0.54, 0.66, 0.78)
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

    love.graphics.setColor(0.08, 0.06, 0.13, 0.42)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
  end

  -- Background grid so motion is readable on a flat floor.
  love.graphics.setColor(cfg.grid_color[1], cfg.grid_color[2], cfg.grid_color[3], 0.42)
  love.graphics.setLineWidth(1)
  for x = cfg.grid_step, self.width - 1, cfg.grid_step do
    love.graphics.line(x, 0, x, self.height)
  end
  for y = cfg.grid_step, self.height - 1, cfg.grid_step do
    love.graphics.line(0, y, self.width, y)
  end

  -- Walls.
  love.graphics.setColor(cfg.wall_color)
  love.graphics.rectangle("fill", 0, 0, self.width, self.wall)
  love.graphics.rectangle("fill", 0, self.height - self.wall, self.width, self.wall)
  love.graphics.rectangle("fill", 0, 0, self.wall, self.height)
  love.graphics.rectangle("fill", self.width - self.wall, 0, self.wall, self.height)
end

return Arena
