local H = require("tests.helpers")
local VersionTag = require("src.ui.version_tag")

local T = {}

local function inside(inner, outer)
  return inner.x >= outer.x and inner.y >= outer.y
    and inner.x + inner.w <= outer.x + outer.w
    and inner.y + inner.h <= outer.y + outer.h
end

T["tiny version tags remain inside title and pause corners"] = function()
  local title = { x = 0, y = 0, w = 800, h = 600 }
  local pause = { x = 120, y = 90, w = 560, h = 374 }
  local title_tag = VersionTag.layout(title, "bottom-left")
  local pause_tag = VersionTag.layout(pause, "bottom-right", 12)
  H.is_true(inside(title_tag, title))
  H.is_true(inside(pause_tag, pause))
  H.is_true(title_tag.w <= 60 and title_tag.h <= 20)
  H.is_true(pause_tag.w <= 60 and pause_tag.h <= 20)
end

return T
