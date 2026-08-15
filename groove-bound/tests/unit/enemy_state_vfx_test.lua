local H = require("tests.helpers")
local VFXSystem = require("src.game.systems.vfx_system")

local T = {}

T["enemy death snapshots advance without retaining a live enemy"] = function()
  local draws = {}
  local assets = {
    draw_enemy_state = function(_, id, state, frame, x, y, size, opts)
      draws[#draws + 1] = {
        id = id, state = state, frame = frame,
        x = x, y = y, size = size, flip_x = opts.flip_x,
      }
    end,
  }
  local vfx = VFXSystem(assets)
  vfx:spawn("enemy_death", 40, 60, {
    enemy_id = "monotone", enemy_size = 70,
    flip_x = true, duration = 0.4,
  })
  vfx:draw()
  vfx:update(0.21)
  vfx:draw()
  H.eq(draws[1].id, "monotone")
  H.eq(draws[1].state, "death")
  H.eq(draws[1].frame, 1)
  H.eq(draws[2].frame, 3)
  H.eq(draws[2].size, 70)
  H.is_true(draws[2].flip_x)
end

return T
