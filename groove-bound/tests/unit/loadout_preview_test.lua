local H = require("tests.helpers")
local Content = require("src.content.init")
local Preview = require("src.ui.loadout_preview")

local T = {}

T["loadout preview compares a hovered weapon without mutating selection"] = function()
  local weapons, passives = { "bass_drop" }, { "echo_chamber" }
  local current = Preview.compute(Content, "joe", weapons, passives)
  local next_value = Preview.compute(Content, "joe", weapons, passives,
    { kind = "weapon", id = "cymbal_slicer" })
  H.eq(#weapons, 1)
  H.eq(#passives, 1)
  H.eq(current.weapon_count, 2)
  H.eq(current.projectiles, 4)
  H.eq(next_value.weapon_count, 3)
  H.eq(next_value.projectiles, 7)
end

T["loadout preview includes passive health guard and speed bonuses"] = function()
  local value = Preview.compute(Content, "joe", {}, {
    "encore", "safety_vest", "quickstep",
  })
  H.eq(value.max_hp, 132)
  H.eq(value.guard, 30)
  H.is_true(value.speed > 1)
end

return T
