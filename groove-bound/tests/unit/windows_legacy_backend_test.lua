local H = require("tests.helpers")
local WindowsLegacyBackend = require("src.meta.windows_legacy_backend")

local T = {}

T["backend is available only for fused Windows builds"] = function()
  H.is_nil(WindowsLegacyBackend.detect({
    platform = function() return "macOS" end,
    fused = function() return true end,
  }))
  H.is_nil(WindowsLegacyBackend.detect({
    platform = function() return "Windows" end,
    fused = function() return false end,
  }))
end

T["backend reads the unfused AppData save without writing it"] = function()
  local opened_path
  local handle = {
    read = function() return "profile-envelope" end,
    close = function() end,
  }
  local backend = WindowsLegacyBackend.detect({
    platform = function() return "Windows" end,
    fused = function() return true end,
    appdata = function() return "C:\\Users\\Player\\AppData\\Roaming" end,
    open_file = function(path, mode)
      opened_path = path .. "|" .. mode
      return handle
    end,
  })
  H.eq(backend.read("device-settings.json"), "profile-envelope")
  H.eq(opened_path,
    "C:\\Users\\Player\\AppData\\Roaming\\LOVE\\groove-bound\\device-settings.json|rb")
  local ok, reason = backend.write("device-settings.json", "changed")
  H.is_nil(ok)
  H.eq(reason, "external save source is read-only")
end

T["backend rejects unsafe filenames"] = function()
  local opened = false
  local backend = WindowsLegacyBackend.detect({
    platform = function() return "Windows" end,
    fused = function() return true end,
    appdata = function() return "C:\\Data" end,
    open_file = function() opened = true end,
  })
  H.is_nil(backend.read("..\\secret.txt"))
  H.is_false(opened)
end

return T
