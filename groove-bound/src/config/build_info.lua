-- Player-visible build identity. VERSION is the single source version; the
-- generated release marker distinguishes a packaged build from loose source.

local BuildInfo = {}

local function read_text(path)
  if love and love.filesystem and love.filesystem.read then
    local ok, contents = pcall(love.filesystem.read, path)
    if ok and type(contents) == "string" then return contents end
  end
  local handle = io.open(path, "rb")
  if not handle then return nil end
  local contents = handle:read("*a")
  handle:close()
  return contents
end

local function clean(value)
  return value and value:match("^%s*(.-)%s*$") or nil
end

local function parse_marker(contents)
  local values = {}
  for line in (contents or ""):gmatch("[^\r\n]+") do
    local key, value = line:match("^([%w_-]+)=(.*)$")
    if key then values[key] = clean(value) end
  end
  return values
end

function BuildInfo.detect(reader)
  reader = reader or read_text
  local source_version = assert(clean(reader("VERSION")), "VERSION is missing")
  local marker = parse_marker(reader("release-build.txt"))
  if marker.profile == "release" and marker.version then
    assert(marker.version == source_version,
      "release marker version does not match VERSION")
    return {
      version = marker.version,
      profile = "release",
      commit = marker.commit,
      dirty = marker.dirty == "true",
      label = "v" .. marker.version,
    }
  end
  return {
    version = source_version,
    profile = "source",
    dirty = true,
    label = "v" .. source_version .. "-dev",
  }
end

local current

function BuildInfo.current()
  if not current then current = BuildInfo.detect() end
  return current
end

function BuildInfo.label()
  return BuildInfo.current().label
end

return BuildInfo
