local Fonts = require("src.ui.fonts")

local RankBadge = {}

function RankBadge.draw(assets, x, y, size, value, opts)
  opts = opts or {}
  local maxed = opts.maxed == true
  assets:draw_rank_badge_sprite(x, y, size, maxed, {
    color = opts.color or { 1, 1, 1, opts.alpha or 1 },
  })
  if maxed then return end

  local label = tostring(value or 0)
  local font = Fonts.heading(math.max(9, math.floor(size * (label:len() > 1 and 0.34 or 0.42))))
  love.graphics.setFont(font)
  love.graphics.setColor(opts.text_color or { 1.0, 0.94, 0.72, opts.alpha or 1 })
  love.graphics.printf(label, x, y + (size - font:getHeight()) / 2 - 1,
    size, "center")
end

return RankBadge
