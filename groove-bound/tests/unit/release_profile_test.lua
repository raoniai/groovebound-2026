local H = require("tests.helpers")
local ReleaseProfile = require("src.config.release_profile")

local T = {}

T["source checkout remains a development profile"] = function()
  local profile = ReleaseProfile.detect(function() return false end)
  H.is_false(profile.is_release)
  H.eq(profile.marker, "release-build.txt")
end

T["packaged marker selects the release profile"] = function()
  local requested
  local profile = ReleaseProfile.detect(function(path)
    requested = path
    return true
  end)
  H.is_true(profile.is_release)
  H.eq(requested, "release-build.txt")
end

return T
