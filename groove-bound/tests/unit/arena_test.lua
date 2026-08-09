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

T["navigation routes enemies around solid stage equipment"] = function()
  local a = Arena({
    width = 1000,
    height = 800,
    wall = 20,
    obstacles = {
      { x = 400, y = 250, w = 120, h = 300,
        icon = { col = 1, row = 1 }, pass_behind = false },
    },
  })
  H.is_false(a:segment_clear(300, 400, 650, 400, 12))
  local dx, dy, routed = a:navigation_direction(300, 400, 650, 400, 12)
  H.is_true(routed)
  H.is_true(dx > 0)
  H.is_true(math.abs(dy) > 0.1)
end

T["stage-specific dimensions override the global arena fallback"] = function()
  local a = Arena({ stage = { width = 5000, height = 3200 } })
  H.eq(a.width, 5000)
  H.eq(a.height, 3200)
  local cx, cy = a:center()
  H.eq(cx, 2500)
  H.eq(cy, 1600)
end

T["tall scenery blocks only at its base so players can pass behind the top"] = function()
  local a = Arena({
    width = 1000,
    height = 800,
    wall = 20,
    obstacles = {
      { x = 400, y = 200, w = 120, h = 300,
        icon = { col = 1, row = 1 }, pass_behind = true },
    },
  })
  H.is_false(a:blocked(460, 250, 12))
  H.is_true(a:blocked(460, 470, 12))
end

T["safe drop placement moves a chest out of blocked geometry deterministically"] = function()
  local a = Arena({
    width = 1000,
    height = 800,
    wall = 20,
    obstacles = {
      { x = 430, y = 330, w = 140, h = 140,
        icon = { col = 1, row = 1 } },
    },
  })
  local x, y = a:safe_drop_position(500, 400, 24)
  H.is_false(a:blocked(x, y, 24))
  H.is_true(a:contains(x, y, 24))
  local second_x, second_y = a:safe_drop_position(500, 400, 24)
  H.eq(x, second_x)
  H.eq(y, second_y)
end

return T
