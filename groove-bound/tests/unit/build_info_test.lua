local H = require("tests.helpers")
local BuildInfo = require("src.config.build_info")

local T = {}

T["loose source shows an explicit development version"] = function()
  local info = BuildInfo.detect(function(path)
    if path == "VERSION" then return "0.8.4\n" end
  end)
  H.eq(info.version, "0.8.4")
  H.eq(info.profile, "source")
  H.eq(info.label, "v0.8.4-dev")
end

T["release marker shows the exact packaged version"] = function()
  local info = BuildInfo.detect(function(path)
    if path == "VERSION" then return "0.8.4\n" end
    return "profile=release\nversion=0.8.4\ncommit=abc123\ndirty=false\n"
  end)
  H.eq(info.profile, "release")
  H.eq(info.label, "v0.8.4")
  H.eq(info.commit, "abc123")
  H.is_false(info.dirty)
end

T["release marker cannot disagree with canonical VERSION"] = function()
  local ok = pcall(BuildInfo.detect, function(path)
    if path == "VERSION" then return "0.8.4\n" end
    return "profile=release\nversion=0.8.3\n"
  end)
  H.is_false(ok)
end

T["compact menu version contains only the canonical v number"] = function()
  local source = BuildInfo.detect(function(path)
    if path == "VERSION" then return "0.9.5\n" end
  end)
  H.eq(BuildInfo.version_label(source), "v0.9.5")
  H.is_nil(BuildInfo.version_label(source):match("dev"))
end

return T
