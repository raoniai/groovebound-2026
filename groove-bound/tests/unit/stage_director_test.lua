local H = require("tests.helpers")
local StageDirector = require("src.game.systems.stage_director")

local T = {}

T["countdown advances through deterministic sixty-second stages"] = function()
  local director = StageDirector({ duration = 60, count = 3 })
  H.eq(director.stage, 1)
  H.eq(director:remaining(0), 60)
  H.eq(director:remaining(59.25), 0.75)

  director:update(0.1, 60)
  H.eq(director.stage, 2)
  H.eq(director:remaining(60), 60)
  H.eq(director.notice_text, "STAGE 1 CLEAR  •  STAGE 2")

  director:update(0.1, 120)
  H.eq(director.stage, 3)
  H.eq(director:remaining(120), 60)
end

T["final stage countdown clamps at zero instead of creating phantom stages"] = function()
  local director = StageDirector({ duration = 60, count = 3 })
  director:update(0.1, 999)
  H.eq(director.stage, 3)
  H.eq(director:remaining(999), 0)
end

T["stage transition notice expires on real simulation time"] = function()
  local director = StageDirector({ duration = 60, count = 3 })
  director:update(0.1, 60)
  H.is_true(director.notice > 0)
  director:update(4, 64)
  H.eq(director.notice, 0)
end

return T
