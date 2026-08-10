local json = require("lib.json")
local sha256 = require("src.core.sha256")
local Defaults = require("src.meta.defaults")

local Migration = {}

local function deep_copy(value)
  return json.decode(json.encode(value))
end

function Migration.prepare(raw, timestamp)
  if type(raw) ~= "string" then return nil, "legacy save is missing" end
  local ok, legacy = pcall(json.decode, raw)
  if not ok or type(legacy) ~= "table" or legacy.version ~= 1
      or type(legacy.data) ~= "table" then
    return nil, "legacy save is not a valid version-one envelope"
  end

  local coins = legacy.data.coins or 0
  if type(coins) ~= "number" or coins < 0 or coins % 1 ~= 0 then
    return nil, "legacy coins are invalid"
  end

  local source_checksum = sha256.digest(raw)
  local device = deep_copy(Defaults.device_settings)
  local legacy_options = legacy.data.options
  if legacy_options ~= nil and type(legacy_options) ~= "table" then
    return nil, "legacy options are invalid"
  end
  for key, value in pairs(legacy_options or {}) do
    local default_value = device.options[key]
    if default_value ~= nil and type(value) == type(default_value) then
      device.options[key] = deep_copy(value)
    end
  end

  local slot = Defaults.new_slot(1, timestamp)
  slot.wallet.coins = coins
  slot.wallet.lifetime_earned = coins
  slot.migrations = {
    source_version = 1,
    source_checksum = source_checksum,
    imported_at = timestamp,
  }

  return {
    device = device,
    slot = slot,
    marker = {
      source_version = 1,
      source_checksum = source_checksum,
      imported_at = timestamp,
      device_settings_revision = 1,
      slot_revision = 1,
    },
  }
end

return Migration
