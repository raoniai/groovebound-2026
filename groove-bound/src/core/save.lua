-- Versioned JSON save/load with an injectable filesystem backend.
--
-- In-game the backend is love.filesystem; tests inject an in-memory table.
-- Saves carry a schema version; loading an older version runs it through
-- registered migrations so save formats can evolve without wiping players.
--
--   local store = Save.new({ filename = "save.json" })   -- LÖVE backend
--   local store = Save.new({ backend = fake, filename = "t" }) -- test backend
--   store:load()  -> data table (defaults when no file / corrupt file)
--   store:save(data)

local class = require("src.core.class")
local json = require("lib.json")
local sha256 = require("src.core.sha256")

local Save = class()

Save.SCHEMA_VERSION = 1

-- Migrations: index N upgrades a version-N save to version N+1.
Save.migrations = {}

local function love_backend()
  return {
    read = function(name)
      local ok, contents = pcall(love.filesystem.read, name)
      if ok then return contents end
      return nil
    end,
    write = function(name, contents)
      return love.filesystem.write(name, contents)
    end,
    remove = function(name)
      if not love.filesystem.getInfo(name) then return true end
      return love.filesystem.remove(name)
    end,
    exists = function(name)
      return love.filesystem.getInfo(name, "file") ~= nil
    end,
    replace = function(source, destination)
      local contents, read_error = love.filesystem.read(source)
      if not contents then return nil, read_error end
      local ok, write_error = love.filesystem.write(destination, contents)
      if not ok then return nil, write_error end
      local removed, remove_error = love.filesystem.remove(source)
      if not removed then return nil, remove_error end
      return true
    end,
  }
end

Save.default_backend = love_backend

function Save:init(opts)
  opts = opts or {}
  self.filename = assert(opts.filename, "Save requires a filename")
  self.backend = opts.backend or love_backend()
  self.defaults = opts.defaults or {}
  self.kind = opts.kind
  self.schema_version = opts.schema_version or Save.SCHEMA_VERSION
  self.strict = opts.strict == true
  self.validator = opts.validator
  self.next_filename = self.filename .. ".next"
  self.backup_filename = self.filename .. ".bak"
end

local function deep_copy(t)
  if type(t) ~= "table" then return t end
  local out = {}
  for k, v in pairs(t) do
    out[k] = deep_copy(v)
  end
  return out
end

local function fill_missing(data, defaults)
  for key, value in pairs(defaults) do
    if data[key] == nil then
      data[key] = deep_copy(value)
    elseif type(value) == "table" and type(data[key]) == "table" then
      fill_missing(data[key], value)
    end
  end
end

local function canonical_encode(value, seen)
  local value_type = type(value)
  if value_type ~= "table" then return json.encode(value) end

  seen = seen or {}
  assert(not seen[value], "cannot encode circular reference")
  seen[value] = true

  local count = 0
  for _ in pairs(value) do count = count + 1 end
  local parts = {}
  if count == #value then
    for i = 1, #value do parts[i] = canonical_encode(value[i], seen) end
    seen[value] = nil
    return "[" .. table.concat(parts, ",") .. "]"
  end

  local keys = {}
  for key in pairs(value) do
    assert(type(key) == "string", "object keys must be strings")
    keys[#keys + 1] = key
  end
  table.sort(keys)
  for _, key in ipairs(keys) do
    parts[#parts + 1] = json.encode(key) .. ":" .. canonical_encode(value[key], seen)
  end
  seen[value] = nil
  return "{" .. table.concat(parts, ",") .. "}"
end

local function integrity_payload(version, kind, data)
  return canonical_encode({ version = version, kind = kind, data = data })
end

function Save:_encode(data)
  local envelope = {
    version = self.schema_version,
    kind = self.kind,
    data = data,
  }
  envelope.integrity = {
    algorithm = "sha256",
    checksum = sha256.digest(integrity_payload(envelope.version, envelope.kind, envelope.data)),
  }
  return json.encode(envelope)
end

function Save:_decode(raw)
  if type(raw) ~= "string" then return nil, "missing" end
  local ok, decoded = pcall(json.decode, raw)
  if not ok or type(decoded) ~= "table" then return nil, "invalid_json" end
  if decoded.version ~= self.schema_version or decoded.kind ~= self.kind then
    return nil, "invalid_envelope"
  end
  if type(decoded.data) ~= "table" or type(decoded.integrity) ~= "table"
      or decoded.integrity.algorithm ~= "sha256"
      or type(decoded.integrity.checksum) ~= "string" then
    return nil, "invalid_envelope"
  end
  local expected = sha256.digest(integrity_payload(decoded.version, decoded.kind, decoded.data))
  if decoded.integrity.checksum ~= expected then return nil, "checksum_mismatch" end
  if self.validator then
    local valid, validation_error = self.validator(decoded.data)
    if valid ~= true then return nil, validation_error or "validation_failed" end
  end
  return decoded.data
end

function Save:_exists(filename)
  if self.backend.exists then return self.backend.exists(filename) end
  return self.backend.read(filename) ~= nil
end

function Save:_recover(filename, source)
  local raw = self.backend.read(filename)
  local data, decode_error = self:_decode(raw)
  if not data then return nil, decode_error end
  local ok, write_error = self.backend.write(self.filename, raw)
  if not ok then return nil, write_error end
  local restored, restore_error = self:_decode(self.backend.read(self.filename))
  if not restored then return nil, restore_error end
  return restored, { status = "recovered", source = source }
end

function Save:load()
  if self.kind then
    local raw = self.backend.read(self.filename)
    if raw then
      local data = self:_decode(raw)
      if data then
        fill_missing(data, self.defaults)
        return data, { status = "loaded", source = "active" }
      end
      local recovered, status = self:_recover(self.backup_filename, "backup")
      if recovered then return recovered, status end
      if self.strict then
        return nil, { status = "recovery_failed", source = "none" }
      end
      return deep_copy(self.defaults), { status = "default", source = "defaults" }
    end

    local recovered, status = self:_recover(self.next_filename, "next")
    if recovered then return recovered, status end
    local backup, backup_status = self:_recover(self.backup_filename, "backup")
    if backup then return backup, backup_status end
    return deep_copy(self.defaults), { status = "default", source = "defaults" }
  end

  local raw = self.backend.read(self.filename)
  if not raw then
    return deep_copy(self.defaults)
  end

  local ok, decoded = pcall(json.decode, raw)
  if not ok or type(decoded) ~= "table" or type(decoded.version) ~= "number" then
    -- Corrupt or unversioned save: fall back to defaults rather than crash.
    return deep_copy(self.defaults)
  end

  local data = decoded.data or {}
  local version = decoded.version
  while version < Save.SCHEMA_VERSION do
    local migrate = Save.migrations[version]
    if not migrate then
      -- No path forward; safest is defaults.
      return deep_copy(self.defaults)
    end
    data = migrate(data)
    version = version + 1
  end

  -- Fill any missing keys from defaults (new settings added since the save).
  fill_missing(data, self.defaults)

  return data
end

function Save:save(data)
  if self.kind then
    local encoded = self:_encode(data)
    local next_ok, next_error = self.backend.write(self.next_filename, encoded)
    if not next_ok then return nil, next_error end
    if not self:_decode(self.backend.read(self.next_filename)) then
      return nil, "next file failed validation"
    end

    if self:_exists(self.filename) then
      local active_raw = self.backend.read(self.filename)
      if not self:_decode(active_raw) then
        return nil, "active file is invalid; recovery required"
      end
      local backup_ok, backup_error = self.backend.write(self.backup_filename, active_raw)
      if not backup_ok then return nil, backup_error end
      if not self:_decode(self.backend.read(self.backup_filename)) then
        return nil, "backup file failed validation"
      end
    end

    local replaced, replace_error = self.backend.replace(self.next_filename, self.filename)
    if not replaced then return nil, replace_error end
    if not self:_decode(self.backend.read(self.filename)) then
      return nil, "active file failed validation"
    end
    if self.backend.remove and self:_exists(self.next_filename) then
      self.backend.remove(self.next_filename)
    end
    return true
  end

  local envelope = {
    version = Save.SCHEMA_VERSION,
    data = data,
  }
  return self.backend.write(self.filename, json.encode(envelope))
end

function Save:clear()
  local filenames = { self.filename, self.backup_filename, self.next_filename }
  for _, filename in ipairs(filenames) do
    if self:_exists(filename) then
      if not self.backend.remove then return nil, "save backend cannot remove files" end
      local removed, remove_error = self.backend.remove(filename)
      if not removed then return nil, remove_error end
    end
  end
  return true
end

return Save
