local H = require("tests.helpers")
local XPRewards = require("src.game.xp_rewards")

local T = {}

local function total(drops)
  local value = 0
  for _, drop in ipairs(drops) do value = value + drop.value end
  return value
end

T["common enemies drop one small gem without changing XP"] = function()
  local drops = XPRewards.split(10, { xp = 10 })
  H.eq(#drops, 1)
  H.eq(drops[1].tier, 1)
  H.eq(total(drops), 10)
end

T["tough regular and elite enemies drop richer gem showers"] = function()
  local tough = XPRewards.split(47, { xp = 47 })
  local elite = XPRewards.split(82, { xp = 82, elite = true })
  H.eq(#tough, 2)
  H.eq(tough[1].tier, 2)
  H.eq(#elite, 3)
  H.eq(elite[1].tier, 3)
  H.eq(total(tough), 47)
  H.eq(total(elite), 82)
end

T["bosses use the legendary tier and preserve scaled reward totals"] = function()
  local drops = XPRewards.split(1253, { xp = 1000, boss_type = "final" })
  H.eq(#drops, 8)
  H.eq(drops[1].tier, 4)
  H.eq(total(drops), 1253)
end

return T
