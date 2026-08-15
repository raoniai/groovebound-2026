local H = require("tests.helpers")
local Content = require("src.content.init")
local PerkSummary = require("src.ui.perk_summary")

local T = {}

T["perk summary reports owned ranks and actual modifier totals"] = function()
  local summary = PerkSummary.collect(Content, { perks = {
    pocket_drive = { rank = 3 },
    spotlight_spin = { rank = 1 },
  } })
  H.eq(summary.total, 19)
  H.eq(summary.owned, 2)
  H.eq(summary.ranks, 4)
  H.eq(summary.entries[1].label, "Base damage")
  H.eq(summary.entries[1].value, "+6%")
  H.eq(summary.entries[2].value, "+1")
end

return T
