-- Read-only view of the save directory used by unfused Windows .love builds.
-- Fused executables write to %APPDATA%\groove-bound instead, so ProfileStore
-- can use this backend to import validated v2 settings and slots once.

local WindowsLegacyBackend = {}

local function safe_name(name)
  return type(name) == "string"
    and not name:find("[/\\]")
    and not name:find("..", 1, true)
end

function WindowsLegacyBackend.detect(opts)
  opts = opts or {}
  local platform = opts.platform or function()
    return love and love.system and love.system.getOS() or "Unknown"
  end
  local fused = opts.fused or function()
    return love and love.filesystem and love.filesystem.isFused() == true
  end
  local appdata = opts.appdata or function() return os.getenv("APPDATA") end
  local open_file = opts.open_file or io.open

  if platform() ~= "Windows" or not fused() then return nil end
  local root = appdata()
  if type(root) ~= "string" or root == "" then return nil end
  local base = root .. "\\LOVE\\groove-bound"

  local function read(name)
    if not safe_name(name) then return nil end
    local handle = open_file(base .. "\\" .. name, "rb")
    if not handle then return nil end
    local contents = handle:read("*a")
    handle:close()
    return contents
  end

  return {
    read = read,
    exists = function(name) return read(name) ~= nil end,
    write = function() return nil, "external save source is read-only" end,
    remove = function() return nil, "external save source is read-only" end,
    replace = function() return nil, "external save source is read-only" end,
    source_directory = base,
  }
end

return WindowsLegacyBackend
