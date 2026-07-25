-- Cached sprite-sheet quads and nearest-neighbour rendering.

local class = require("src.core.class")

local SpriteSheet = class()

function SpriteSheet:init(opts)
  local path = assert(opts.path, "sprite path required")
  self.image = love.graphics.newImage(path)
  self.image:setFilter("nearest", "nearest")
  self.frame_w = assert(opts.frame_w, "frame width required")
  self.frame_h = assert(opts.frame_h, "frame height required")
  self.cols = opts.cols or math.floor(self.image:getWidth() / self.frame_w)
  self.rows = opts.rows or math.floor(self.image:getHeight() / self.frame_h)
  self.quads = {}

  for row = 1, self.rows do
    self.quads[row] = {}
    for col = 1, self.cols do
      self.quads[row][col] = love.graphics.newQuad(
        (col - 1) * self.frame_w,
        (row - 1) * self.frame_h,
        self.frame_w,
        self.frame_h,
        self.image:getDimensions())
    end
  end
end

function SpriteSheet:draw(frame, row, x, y, opts)
  opts = opts or {}
  frame = ((frame or 1) - 1) % self.cols + 1
  row = math.max(1, math.min(row or 1, self.rows))
  local sx = opts.flip_x and -(opts.scale or 1) or (opts.scale or 1)
  local sy = opts.scale_y or opts.scale or 1
  love.graphics.setColor(opts.color or { 1, 1, 1, 1 })
  love.graphics.draw(
    self.image,
    self.quads[row][frame],
    x,
    y,
    opts.rotation or 0,
    sx,
    sy,
    opts.origin_x or self.frame_w / 2,
    opts.origin_y or self.frame_h / 2)
end

return SpriteSheet
