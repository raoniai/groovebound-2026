local json = require("lib.json")
local sha256 = require("src.core.sha256")

local ExportCodec = {}

local function canonical_encode(value, seen)
  if type(value) ~= "table" then return json.encode(value) end
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
    assert(type(key) == "string", "export object keys must be strings")
    keys[#keys + 1] = key
  end
  table.sort(keys)
  for _, key in ipairs(keys) do
    parts[#parts + 1] = json.encode(key) .. ":" .. canonical_encode(value[key], seen)
  end
  seen[value] = nil
  return "{" .. table.concat(parts, ",") .. "}"
end

local function payload(document)
  return {
    export_kind = document.export_kind,
    export_version = document.export_version,
    game_version = document.game_version,
    exported_at = document.exported_at,
    source_slot_id = document.source_slot_id,
    slot = document.slot,
  }
end

function ExportCodec.encode(slot, opts)
  opts = opts or {}
  local document = {
    export_kind = "groove_bound_progression_slot",
    export_version = 1,
    game_version = assert(opts.game_version, "game version is required"),
    exported_at = assert(opts.exported_at, "export timestamp is required"),
    source_slot_id = slot.slot_id,
    slot = slot,
  }
  document.integrity = {
    algorithm = "sha256",
    checksum = sha256.digest(canonical_encode(payload(document))),
  }
  return json.encode(document)
end

function ExportCodec.decode(encoded)
  if type(encoded) ~= "string" then return nil, "import must be encoded text" end
  local ok, document = pcall(json.decode, encoded)
  if not ok or type(document) ~= "table" then return nil, "invalid import JSON" end
  if document.export_kind ~= "groove_bound_progression_slot"
      or document.export_version ~= 1 then
    return nil, "unsupported import format"
  end
  if type(document.game_version) ~= "string" or type(document.exported_at) ~= "string"
      or type(document.source_slot_id) ~= "number" or type(document.slot) ~= "table" then
    return nil, "invalid import metadata"
  end
  if type(document.integrity) ~= "table" or document.integrity.algorithm ~= "sha256"
      or type(document.integrity.checksum) ~= "string" then
    return nil, "missing import integrity"
  end
  local expected = sha256.digest(canonical_encode(payload(document)))
  if document.integrity.checksum ~= expected then return nil, "import checksum mismatch" end
  return document
end

return ExportCodec
