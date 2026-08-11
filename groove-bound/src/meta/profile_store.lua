local class = require("src.core.class")
local Save = require("src.core.save")
local Defaults = require("src.meta.defaults")
local SlotValidator = require("src.meta.slot_validator")
local ExportCodec = require("src.meta.export_codec")
local MigrationV1ToV2 = require("src.meta.migration_v1_to_v2")

local ProfileStore = class()

local function in_range(value, minimum, maximum)
  return type(value) == "number" and value >= minimum and value <= maximum
end

local function validate_device_settings(device)
  if type(device) ~= "table" then return nil, "Device Settings must be a table" end
  if device.settings_revision ~= 1 then return nil, "unsupported settings revision" end
  if type(device.active_slot) ~= "number" or device.active_slot % 1 ~= 0
      or device.active_slot < 1 or device.active_slot > 3 then
    return nil, "active Slot must be 1, 2, or 3"
  end

  local options = device.options
  if type(options) ~= "table" then return nil, "Device Settings options are required" end
  if not in_range(options.master_volume, 0, 1)
      or not in_range(options.music_volume, 0, 1)
      or not in_range(options.sfx_volume, 0, 1) then
    return nil, "volume values must be between 0 and 1"
  end
  if not in_range(options.camera_zoom, 0.75, 1.5) then
    return nil, "camera zoom must be between 0.75 and 1.5"
  end
  if not in_range(options.deadzone, 0, 0.95) then
    return nil, "deadzone must be between 0 and 0.95"
  end
  if not in_range(options.latency_offset_ms, -500, 500) then
    return nil, "latency offset must be between -500 and 500 milliseconds"
  end
  if type(options.controls) ~= "table" then return nil, "controls must be a table" end

  local timing_windows = { relaxed = true, standard = true, tight = true }
  if not timing_windows[options.timing_window] then return nil, "invalid timing window" end

  local booleans = {
    "muted", "fullscreen", "aim_assist", "vibration", "screen_shake",
    "hit_flash", "reduced_flash", "reduced_motion", "rhythm_visual_cues",
    "rhythm_audio_cues", "rhythm_vibration",
  }
  for _, key in ipairs(booleans) do
    if type(options[key]) ~= "boolean" then return nil, key .. " must be boolean" end
  end
  return true
end

function ProfileStore:init(opts)
  opts = opts or {}
  self.backend = opts.backend or Save.default_backend()
  self.legacy_backend = opts.legacy_backend
  self.clock = opts.clock or function() return os.date("!%Y-%m-%dT%H:%M:%SZ") end
  self.slots = {}
  self.device_settings = Save({
    filename = "device-settings.json",
    backend = self.backend,
    defaults = Defaults.device_settings,
    kind = "device_settings",
    schema_version = 2,
    strict = true,
    validator = validate_device_settings,
  })
  self.migration_marker = Save({
    filename = "legacy-import.json",
    backend = self.backend,
    defaults = {},
    kind = "legacy_import_marker",
    schema_version = 2,
    strict = true,
    validator = function(marker)
      if type(marker.source_checksum) ~= "string" or #marker.source_checksum ~= 64
          or marker.source_version ~= 1 or type(marker.imported_at) ~= "string" then
        return nil, "invalid legacy migration marker"
      end
      return true
    end,
  })
end

function ProfileStore:import_external_version_two()
  if not self.legacy_backend then
    return false, { status = "external_source_unavailable" }
  end
  if self.backend.exists("device-settings.json")
      or self.backend.exists("slot-1.json")
      or self.backend.exists("slot-2.json")
      or self.backend.exists("slot-3.json") then
    return false, { status = "target_version_two_exists" }
  end

  local source = ProfileStore({
    backend = self.legacy_backend,
    clock = self.clock,
  })
  local device, device_status = source:load_device_settings()
  if not device or device_status.status == "default" then
    return false, { status = "external_version_two_not_found" }
  end

  local slots = {}
  for slot_id = 1, 3 do
    local slot = source:load_slot(slot_id)
    if slot then slots[slot_id] = slot end
  end

  local saved, save_error = self:save_device_settings(device)
  if not saved then
    return nil, { status = "external_import_failed", error = save_error }
  end
  local imported_slots = 0
  for slot_id = 1, 3 do
    if slots[slot_id] then
      local slot_saved, slot_error = self:save_slot(slot_id, slots[slot_id])
      if not slot_saved then
        self.device_settings:clear()
        for rollback_id = 1, 3 do self:_slot_store(rollback_id):clear() end
        return nil, { status = "external_import_failed", error = slot_error }
      end
      imported_slots = imported_slots + 1
    end
  end
  return true, { status = "external_version_two_imported", slots = imported_slots }
end

local function valid_slot_id(slot_id)
  return type(slot_id) == "number" and slot_id % 1 == 0
    and slot_id >= 1 and slot_id <= 3
end

function ProfileStore:_slot_store(slot_id)
  assert(valid_slot_id(slot_id), "Slot ID must be 1, 2, or 3")
  if not self.slots[slot_id] then
    self.slots[slot_id] = Save({
      filename = "slot-" .. slot_id .. ".json",
      backend = self.backend,
      defaults = Defaults.new_slot(slot_id, self.clock()),
      kind = "progression_slot",
      schema_version = 2,
      strict = true,
      validator = function(slot) return SlotValidator.validate(slot, slot_id) end,
    })
  end
  return self.slots[slot_id]
end

function ProfileStore:load_device_settings()
  return self.device_settings:load()
end

function ProfileStore:save_device_settings(device)
  return self.device_settings:save(device)
end

function ProfileStore:load_slot(slot_id)
  local slot, status = self:_slot_store(slot_id):load()
  if status and status.status == "default" then
    return nil, { status = "empty", source = "none" }
  end
  return slot, status
end

function ProfileStore:create_slot(slot_id)
  local existing = self:load_slot(slot_id)
  if existing then return nil, "Slot already exists" end

  local slot = Defaults.new_slot(slot_id, self.clock())
  local saved, save_error = self:_slot_store(slot_id):save(slot)
  if not saved then return nil, save_error end
  return slot
end

function ProfileStore:save_slot(slot_id, slot)
  return self:_slot_store(slot_id):save(slot)
end

function ProfileStore:reset_slot(slot_id)
  return self:_slot_store(slot_id):clear()
end

function ProfileStore:export_slot(slot_id, opts)
  local slot, load_status = self:load_slot(slot_id)
  if not slot then return nil, load_status and load_status.status or "Slot is empty" end
  opts = opts or {}
  return ExportCodec.encode(slot, {
    game_version = opts.game_version,
    exported_at = opts.exported_at or self.clock(),
  })
end

function ProfileStore:preview_import(encoded)
  local document, decode_error = ExportCodec.decode(encoded)
  if not document then return nil, decode_error end
  return {
    source_slot_id = document.source_slot_id,
    exported_at = document.exported_at,
    game_version = document.game_version,
    wallet_coins = document.slot.wallet and document.slot.wallet.coins or 0,
    prologue_completed = document.slot.prologue
      and document.slot.prologue.completed == true,
  }
end

function ProfileStore:import_slot(encoded, target_slot_id, opts)
  assert(valid_slot_id(target_slot_id), "Slot ID must be 1, 2, or 3")
  local document, decode_error = ExportCodec.decode(encoded)
  if not document then return nil, decode_error end

  local existing = self:load_slot(target_slot_id)
  opts = opts or {}
  if existing and opts.confirm_overwrite ~= true then
    return nil, "overwrite confirmation required"
  end

  document.slot.slot_id = target_slot_id
  local valid, validation_error = SlotValidator.validate(document.slot, target_slot_id)
  if not valid then return nil, validation_error end
  return self:save_slot(target_slot_id, document.slot)
end

function ProfileStore:migrate_legacy_v1()
  local marker, marker_status = self.migration_marker:load()
  if marker and marker_status.status ~= "default" then
    return false, { status = "already_migrated", source_checksum = marker.source_checksum }
  end

  if self.backend.exists("device-settings.json") or self.backend.exists("slot-1.json") then
    return false, { status = "version_two_exists" }
  end

  local prepared, prepare_error = MigrationV1ToV2.prepare(
    self.backend.read("save.json"), self.clock())
  if not prepared then return false, { status = "not_migrated", error = prepare_error } end

  local device_saved, device_error = self:save_device_settings(prepared.device)
  if not device_saved then
    return nil, { status = "failed", error = device_error }
  end
  local slot_saved, slot_error = self:save_slot(1, prepared.slot)
  if not slot_saved then
    self.device_settings:clear()
    return nil, { status = "failed", error = slot_error }
  end
  local marker_saved, marker_error = self.migration_marker:save(prepared.marker)
  if not marker_saved then
    self.device_settings:clear()
    self:_slot_store(1):clear()
    return nil, { status = "failed", error = marker_error }
  end

  return true, { status = "migrated", source_checksum = prepared.marker.source_checksum }
end

function ProfileStore:activate()
  local external_result, external_status = self:import_external_version_two()
  if external_result == nil then return nil, external_status end
  local migration_result, migration_status = self:migrate_legacy_v1()
  if migration_result == nil then return nil, migration_status end

  local device, device_status = self:load_device_settings()
  if not device then
    return nil, {
      status = "device_settings_recovery_failed",
      migration = migration_status,
      device = device_status,
    }
  end
  if device_status.status == "default" then
    local saved, save_error = self:save_device_settings(device)
    if not saved then
      return nil, { status = "device_settings_create_failed", error = save_error }
    end
    device_status = { status = "created", source = "defaults" }
  end

  return device, {
    external = external_status,
    migration = migration_status,
    device = device_status,
  }
end

return ProfileStore
