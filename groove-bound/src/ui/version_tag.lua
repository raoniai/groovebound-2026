local Fonts = require("src.ui.fonts")

local VersionTag = {}

function VersionTag.layout(bounds, corner, inset)
  inset = inset or 10
  local width, height = 54, 18
  local right = corner == "bottom-right" or corner == "top-right"
  local bottom = corner == "bottom-left" or corner == "bottom-right"
  return {
    x = right and bounds.x + bounds.w - width - inset or bounds.x + inset,
    y = bottom and bounds.y + bounds.h - height - inset or bounds.y + inset,
    w = width,
    h = height,
  }
end

function VersionTag.draw(label, rect)
  love.graphics.setColor(0.015, 0.02, 0.055, 0.78)
  love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 3, 3)
  love.graphics.setColor(0.28, 0.82, 0.92, 0.58)
  love.graphics.rectangle("line", rect.x + 0.5, rect.y + 0.5,
    rect.w - 1, rect.h - 1, 3, 3)
  love.graphics.setFont(Fonts.get(9))
  love.graphics.setColor(0.76, 0.84, 0.92, 0.82)
  love.graphics.printf(label, rect.x, rect.y + 4, rect.w, "center")
end

return VersionTag
