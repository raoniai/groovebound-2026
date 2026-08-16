local H = require("tests.helpers")
local ProfileStore = require("src.meta.profile_store")

local T = {}

local function fake_fs(initial)
  local files = initial or {}
  return {
    read = function(name) return files[name] end,
    write = function(name, contents)
      files[name] = contents
      return true
    end,
    remove = function(name)
      files[name] = nil
      return true
    end,
    exists = function(name) return files[name] ~= nil end,
    replace = function(source, destination)
      if files[source] == nil then return nil, "source missing" end
      files[destination] = files[source]
      files[source] = nil
      return true
    end,
    files = files,
  }
end

T["Device Settings persist shared options independently of progression Slots"] = function()
  local store = ProfileStore({ backend = fake_fs() })
  local device = store:load_device_settings()

  H.eq(device.active_slot, 1)
  H.is_false(device.options.reduced_motion)
  H.is_false(device.options.automatic_level_up)
  H.is_true(device.options.rhythm_visual_cues)
  H.eq(device.options.timing_window, "standard")
  H.eq(device.options.difficulty, "medium")

  device.active_slot = 3
  device.options.camera_zoom = 1.5
  device.options.latency_offset_ms = -35
  device.options.difficulty = "hard"
  H.is_true(store:save_device_settings(device))

  local loaded = store:load_device_settings()
  H.eq(loaded.active_slot, 3)
  H.near(loaded.options.camera_zoom, 1.5)
  H.eq(loaded.options.latency_offset_ms, -35)
  H.eq(loaded.options.difficulty, "hard")
end

T["progression Slots are created lazily and persist in isolation"] = function()
  local store = ProfileStore({
    backend = fake_fs(),
    clock = function() return "2026-08-10T02:00:00Z" end,
  })

  local missing, missing_status = store:load_slot(2)
  H.is_nil(missing)
  H.eq(missing_status.status, "empty")

  local slot1 = store:create_slot(1)
  H.eq(slot1.slot_id, 1)
  H.eq(slot1.created_at, "2026-08-10T02:00:00Z")
  H.eq(slot1.wallet.coins, 0)
  H.is_false(slot1.prologue.completed)

  slot1.wallet.coins = 725
  H.is_true(store:save_slot(1, slot1))
  local slot2 = store:create_slot(2)

  local loaded1 = store:load_slot(1)
  local loaded2 = store:load_slot(2)
  H.eq(loaded1.wallet.coins, 725)
  H.eq(loaded2.wallet.coins, 0)
  H.eq(slot2.slot_id, 2)
end

T["reset clears one progression Slot while preserving Device Settings"] = function()
  local store = ProfileStore({ backend = fake_fs(), clock = function() return "now" end })
  local device = store:load_device_settings()
  device.active_slot = 2
  H.is_true(store:save_device_settings(device))

  local slot = store:create_slot(2)
  slot.wallet.coins = 300
  H.is_true(store:save_slot(2, slot))
  H.is_true(store:reset_slot(2))

  local missing, status = store:load_slot(2)
  H.is_nil(missing)
  H.eq(status.status, "empty")
  H.eq(store:load_device_settings().active_slot, 2)
end

T["Slot export previews and imports progression without Device Settings"] = function()
  local store = ProfileStore({ backend = fake_fs(), clock = function() return "now" end })
  local device = store:load_device_settings()
  device.options.master_volume = 0.35
  H.is_true(store:save_device_settings(device))

  local source = store:create_slot(1)
  source.wallet.coins = 950
  H.is_true(store:save_slot(1, source))

  local encoded = store:export_slot(1, {
    game_version = "0.6.0",
    exported_at = "2026-08-10T03:00:00Z",
  })
  local preview = store:preview_import(encoded)
  H.eq(preview.source_slot_id, 1)
  H.eq(preview.wallet_coins, 950)

  H.is_true(store:import_slot(encoded, 3))
  local imported = store:load_slot(3)
  H.eq(imported.slot_id, 3)
  H.eq(imported.wallet.coins, 950)
  H.near(store:load_device_settings().options.master_volume, 0.35)
end

T["legacy migration preserves save.json and imports options and coins once"] = function()
  local legacy = '{"version":1,"data":{"coins":420,"options":{"music_volume":0.2,"camera_zoom":1.25}}}'
  local fs = fake_fs({ ["save.json"] = legacy })
  local store = ProfileStore({ backend = fs, clock = function() return "migration-time" end })

  local migrated, status = store:migrate_legacy_v1()
  H.is_true(migrated)
  H.eq(status.status, "migrated")
  H.eq(fs.read("save.json"), legacy)
  H.near(store:load_device_settings().options.music_volume, 0.2)
  H.near(store:load_device_settings().options.camera_zoom, 1.25)
  H.eq(store:load_slot(1).wallet.coins, 420)

  local repeated, repeated_status = store:migrate_legacy_v1()
  H.is_false(repeated)
  H.eq(repeated_status.status, "already_migrated")
  H.eq(store:load_slot(1).wallet.coins, 420)
end

T["activation migrates once and returns the runtime Device Settings profile"] = function()
  local fs = fake_fs({
    ["save.json"] = '{"version":1,"data":{"coins":75,"options":{"fullscreen":true}}}',
  })
  local store = ProfileStore({ backend = fs, clock = function() return "activation-time" end })

  local profile, activation = store:activate()
  H.is_true(profile.options.fullscreen)
  H.eq(activation.migration.status, "migrated")
  H.eq(store:load_slot(1).wallet.coins, 75)

  local loaded_again, second_activation = store:activate()
  H.is_true(loaded_again.options.fullscreen)
  H.eq(second_activation.migration.status, "already_migrated")
  H.eq(store:load_slot(1).wallet.coins, 75)
end

T["external version two import preserves validated settings and Slots"] = function()
  local source_fs = fake_fs()
  local source = ProfileStore({ backend = source_fs, clock = function() return "source-time" end })
  local device = source:load_device_settings()
  device.active_slot = 2
  device.options.music_volume = 0.35
  H.is_true(source:save_device_settings(device))
  local slot = source:create_slot(2)
  slot.wallet.coins = 880
  H.is_true(source:save_slot(2, slot))

  local target_fs = fake_fs()
  local target = ProfileStore({
    backend = target_fs,
    legacy_backend = source_fs,
    clock = function() return "target-time" end,
  })
  local profile, activation = target:activate()
  H.eq(activation.external.status, "external_version_two_imported")
  H.eq(activation.external.slots, 1)
  H.eq(profile.active_slot, 2)
  H.near(profile.options.music_volume, 0.35)
  H.eq(target:load_slot(2).wallet.coins, 880)
  H.is_true(source_fs.exists("device-settings.json"), "source must remain intact")

  local _, repeated = target:activate()
  H.eq(repeated.external.status, "target_version_two_exists")
  H.eq(target:load_slot(2).wallet.coins, 880)
end

T["external version two import never overwrites an existing target"] = function()
  local source_fs = fake_fs()
  local source = ProfileStore({ backend = source_fs })
  local source_device = source:load_device_settings()
  source_device.options.music_volume = 0.1
  H.is_true(source:save_device_settings(source_device))

  local target_fs = fake_fs()
  local target = ProfileStore({ backend = target_fs, legacy_backend = source_fs })
  local target_device = target:load_device_settings()
  target_device.options.music_volume = 0.9
  H.is_true(target:save_device_settings(target_device))

  local profile, activation = target:activate()
  H.eq(activation.external.status, "target_version_two_exists")
  H.near(profile.options.music_volume, 0.9)
end

return T
