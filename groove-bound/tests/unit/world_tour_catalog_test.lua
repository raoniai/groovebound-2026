local H = require("tests.helpers")
local Validate = require("src.content.validate")

local T = {}

T["World Tour catalog has nine stable worlds and first two wave sets"] = function()
  local content = require("src.content.init")
  local count = 0
  for _ in pairs(content.world_tour) do count = count + 1 end
  H.eq(count, 9)
  H.eq(content.world_tour.funk.order, 1)
  H.eq(content.world_tour.funk.first_clear_unlock, "soul")
  H.eq(content.world_tour.soul.order, 2)
  H.eq(content.world_tour.funk.implementation_status, "catalog_ready")
  H.eq(content.world_tour.soul.implementation_status, "catalog_ready")
  H.is_true(#content.world_tour_waves.funk >= 5)
  H.is_true(#content.world_tour_waves.soul >= 5)
end

T["global meta catalog has nineteen perks and valid grade weights"] = function()
  local content = require("src.content.init")
  local count = 0
  for _ in pairs(content.meta_perks) do count = count + 1 end
  H.eq(count, 19)
  H.eq(content.meta_perks.open_ears.source.type, "prologue_clear")
  H.eq(content.meta_perks.pocket_drive.source.world_id, "funk")
  for _, profile in pairs(content.grade_profiles.profiles) do
    H.eq(profile.groove + profile.impact + profile.control
      + profile.craft + profile.world_mastery, 100)
  end
end

T["full content validation accepts the World Tour catalog"] = function()
  local content = require("src.content.init")
  H.eq(#Validate.check(content), 0)
end

return T
