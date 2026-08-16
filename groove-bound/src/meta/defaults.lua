local Defaults = {}

Defaults.device_settings = {
  settings_revision = 1,
  active_slot = 1,
  options = {
    master_volume = 1.0,
    music_volume = 0.8,
    sfx_volume = 0.8,
    muted = false,
    fullscreen = false,
    camera_zoom = 1.0,
    controls = {},
    deadzone = 0.25,
    aim_assist = true,
    difficulty = "medium",
    vibration = true,
    automatic_level_up = false,
    screen_shake = true,
    hit_flash = true,
    reduced_flash = false,
    reduced_motion = false,
    rhythm_visual_cues = true,
    rhythm_audio_cues = true,
    rhythm_vibration = false,
    timing_window = "standard",
    latency_offset_ms = 0,
  },
}

function Defaults.new_slot(slot_id, timestamp)
  return {
    slot_id = slot_id,
    slot_revision = 1,
    created_at = timestamp,
    last_played_at = timestamp,
    total_play_seconds = 0,
    prologue = {
      completed = false,
      clears = 0,
    },
    journey = {
      state = "empty",
      character_id = "",
      current_route = "prologue",
      active_world_id = "",
    },
    wallet = {
      coins = 0,
      lifetime_earned = 0,
      lifetime_spent = 0,
      lifetime_refunded = 0,
    },
    worlds = {},
    perks = {},
    claims = {},
    records = {
      prologue = {},
      worlds = {},
    },
    statistics = {
      runs_started = 0,
      victories = 0,
      defeats = 0,
      abandoned_runs = 0,
      total_run_seconds = 0,
      enemies_defeated = 0,
      bosses_defeated = 0,
      damage_dealt = 0,
      damage_taken = 0,
      xp_collected = 0,
      chests_opened = 0,
      evolutions_completed = 0,
      highest_combo = 0,
    },
    migrations = {},
  }
end

return Defaults
