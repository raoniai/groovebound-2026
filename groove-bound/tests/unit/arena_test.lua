local H = require("tests.helpers")
local Arena = require("src.game.arena")

local T = {}

local function arena()
  return Arena({ width = 1000, height = 800, wall = 20 })
end

T["clamp keeps a body inside the walls"] = function()
  local a = arena()
  local x, y = a:clamp(-50, -50, 10)
  H.eq(x, 30) -- wall 20 + radius 10
  H.eq(y, 30)

  x, y = a:clamp(5000, 5000, 10)
  H.eq(x, 970) -- width 1000 - wall 20 - radius 10
  H.eq(y, 770) -- height 800 - wall 20 - radius 10
end

T["clamp leaves interior points untouched"] = function()
  local a = arena()
  local x, y = a:clamp(500, 400, 10)
  H.eq(x, 500)
  H.eq(y, 400)
end

T["contains accounts for radius"] = function()
  local a = arena()
  H.is_true(a:contains(500, 400, 10))
  H.is_false(a:contains(25, 400, 10), "body would overlap wall")
  H.is_true(a:contains(25, 400, 0))
end

T["center is the midpoint"] = function()
  local a = arena()
  local cx, cy = a:center()
  H.eq(cx, 500)
  H.eq(cy, 400)
end

T["solid stage equipment blocks circle movement"] = function()
  local a = Arena({
    width = 1000,
    height = 800,
    wall = 20,
    obstacles = {
      { x = 400, y = 300, w = 120, h = 100, icon = { col = 1, row = 1 } },
    },
  })
  H.is_true(a:blocked(390, 350, 15))
  H.is_false(a:blocked(300, 350, 15))
  local x, y = a:resolve_movement(370, 350, 430, 350, 12)
  H.eq(x, 370)
  H.eq(y, 350)
end

return T
