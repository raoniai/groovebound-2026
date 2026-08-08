local Fonts = require("src.ui.fonts")

local Hints = {}

local colors = {
  cross = { 0.32, 0.72, 1.0, 1 },
  circle = { 1.0, 0.36, 0.46, 1 },
  square = { 0.96, 0.42, 0.82, 1 },
  triangle = { 0.34, 1.0, 0.68, 1 },
  dpad = { 0.86, 0.84, 0.92, 1 },
  options = { 0.96, 0.76, 0.22, 1 },
}

local function glyph_width(symbol, size)
  return symbol == "options" and size * 1.55 or size
end

function Hints.draw_glyph(symbol, x, y, size)
  local color = colors[symbol] or colors.dpad
  local r = size / 2
  love.graphics.setColor(color)
  love.graphics.setLineWidth(math.max(2, math.floor(size / 10)))
  if symbol == "cross" then
    love.graphics.line(x - r * 0.55, y - r * 0.55, x + r * 0.55, y + r * 0.55)
    love.graphics.line(x + r * 0.55, y - r * 0.55, x - r * 0.55, y + r * 0.55)
  elseif symbol == "circle" then
    love.graphics.circle("line", x, y, r * 0.70)
  elseif symbol == "square" then
    love.graphics.rectangle("line", x - r * 0.66, y - r * 0.66,
      r * 1.32, r * 1.32, 2, 2)
  elseif symbol == "triangle" then
    love.graphics.polygon("line", x, y - r * 0.76,
      x + r * 0.72, y + r * 0.62,
      x - r * 0.72, y + r * 0.62)
  elseif symbol == "dpad" then
    local q = r * 0.44
    love.graphics.rectangle("line", x - q, y - r * 0.88, q * 2, r * 1.76)
    love.graphics.rectangle("line", x - r * 0.88, y - q, r * 1.76, q * 2)
  else
    love.graphics.rectangle("line", x - r * 1.05, y - r * 0.48,
      r * 2.1, r * 0.96, r * 0.32, r * 0.32)
    love.graphics.circle("fill", x - r * 0.30, y, 1.5)
    love.graphics.circle("fill", x + r * 0.30, y, 1.5)
  end
  love.graphics.setLineWidth(1)
end

function Hints.draw(items, y, width, opts)
  opts = opts or {}
  local font = Fonts.get(opts.font_size or 14)
  local glyph_size = opts.glyph_size or 20
  local gap = opts.gap or 24
  local total = 0
  for _, item in ipairs(items) do
    total = total + glyph_width(item.symbol, glyph_size) + 8
      + font:getWidth(item.label)
  end
  total = total + gap * math.max(0, #items - 1)
  local x = (opts.x or 0) + ((width or love.graphics.getWidth()) - total) / 2
  love.graphics.setFont(font)
  for _, item in ipairs(items) do
    local gw = glyph_width(item.symbol, glyph_size)
    Hints.draw_glyph(item.symbol, x + gw / 2, y + glyph_size / 2, glyph_size)
    love.graphics.setColor(opts.text_color or { 0.78, 0.76, 0.86, 1 })
    love.graphics.print(item.label, x + gw + 8,
      y + (glyph_size - font:getHeight()) / 2)
    x = x + gw + 8 + font:getWidth(item.label) + gap
  end
end

return Hints
