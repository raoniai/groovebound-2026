local H = require("tests.helpers")
local RNG = require("src.core.rng")
local SpawnDirector = require("src.game.systems.spawn_director")

local T = {}

local function make_director(opts)
  opts = opts or {}
  local active = 0
  local spawned = {}
  local values = {
    ["enemies.spawn_rate_multiplier"] = opts.rate or 1,
    ["enemies.max_active"] = opts.cap or 100,
  }
  local director = SpawnDirector({
    waves = opts.waves or {
      { at = 1, enemies = { { id = "monotone", count = 3, cadence = 1 } } },
    },
    rng = RNG.new(opts.seed or 1234).spawn,
    tuning = {
      get = function(_, id) return values[id] end,
    },
    arena = { width = 1000, height = 800, wall = 20 },
    focus_position = opts.focus_position,
    spawn_radius_min = opts.spawn_radius_min,
    spawn_radius_max = opts.spawn_radius_max,
    count_enemies = function() return active end,
    spawn = function(definition, x, y)
      active = active + 1
      spawned[#spawned + 1] = { id = definition.id, x = x, y = y }
    end,
  })
  return director, spawned, function(value) active = value end
end

local definitions = {
  monotone = { id = "monotone", size = 12 },
  tempo_leech = { id = "tempo_leech", size = 18 },
}

T["large arenas spawn pressure around the player instead of distant walls"] = function()
  local director, spawned = make_director({
    focus_position = function() return 500, 400 end,
    spawn_radius_min = 220,
    spawn_radius_max = 280,
    waves = {
      { at = 0, enemies = {
          { id = "monotone", count = 8, cadence = 0.01, continuous = false },
      } },
    },
  })
  director:update(1, 0, definitions)
  H.eq(#spawned, 8)
  for _, enemy in ipairs(spawned) do
    local dx, dy = enemy.x - 500, enemy.y - 400
    local distance = math.sqrt(dx * dx + dy * dy)
    H.is_true(distance >= 219 and distance <= 281)
    H.is_true(enemy.x > 20 and enemy.x < 980)
    H.is_true(enemy.y > 20 and enemy.y < 780)
  end
end

T["waves stay dormant until their scheduled run time"] = function()
  local director, spawned = make_director()
  director:update(0.5, 0.5, definitions)
  H.eq(#spawned, 0)
  H.is_false(director:finished())
  director:update(0.5, 1, definitions)
  H.eq(#spawned, 1)
end

T["spawn cadence responds to the live admin multiplier"] = function()
  local director, spawned = make_director({
    rate = 2,
    waves = {
      { at = 0, enemies = { { id = "monotone", count = 3, cadence = 1 } } },
    },
  })
  director:update(0, 0, definitions)
  H.eq(#spawned, 1)
  director:update(0.49, 0.49, definitions)
  H.eq(#spawned, 1)
  director:update(0.011, 0.501, definitions)
  H.eq(#spawned, 2)
end

T["maximum-active admin control is a hard spawn cap"] = function()
  local director, spawned, set_active = make_director({
    cap = 1,
    waves = {
      { at = 0, enemies = { { id = "monotone", count = 3, cadence = 0.1 } } },
    },
  })
  director:update(1, 0, definitions)
  H.eq(#spawned, 1)
  director:update(1, 1, definitions)
  H.eq(#spawned, 1)
  set_active(0)
  director:update(1, 2, definitions)
  H.eq(#spawned, 2)
end

T["the same seed produces the same edge spawn sequence"] = function()
  local a, spawned_a = make_director({ seed = 987 })
  local b, spawned_b = make_director({ seed = 987 })
  a:update(3, 1, definitions)
  b:update(3, 1, definitions)
  H.eq(#spawned_a, #spawned_b)
  for i = 1, #spawned_a do
    H.eq(spawned_a[i].x, spawned_b[i].x)
    H.eq(spawned_a[i].y, spawned_b[i].y)
  end
end

T["the active wave keeps spawning after its batch is cleared until the next wave"] = function()
  local director, spawned, set_active = make_director({
    waves = {
      { at = 0, enemies = { { id = "monotone", count = 1, cadence = 1 } } },
      { at = 3, enemies = { { id = "tempo_leech", count = 1, cadence = 1 } } },
    },
  })
  director:update(0, 0, definitions)
  H.eq(#spawned, 1)
  H.eq(spawned[1].id, "monotone")

  set_active(0) -- the player cleared the arena
  director:update(1.01, 1.01, definitions)
  H.eq(#spawned, 2)
  H.eq(spawned[2].id, "monotone")

  set_active(0)
  director:update(2, 3, definitions)
  H.eq(spawned[#spawned].id, "tempo_leech")
  H.is_false(director:finished())
end

return T
