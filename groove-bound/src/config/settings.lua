-- Engine/feel tunables. Gameplay numbers (weapon damage, enemy hp, waves)
-- live in src/content/ — never here. Nothing in src/game may hardcode a
-- numeric tunable; it reads from here or from content.

local is_release = require("src.config.release_profile").is_release()

return {
  player = {
    speed = 220,        -- base movement speed, px/sec
    size  = 16,         -- collision/render diameter
    hp    = 100,
  },

  arena = {
    width  = 2000,
    height = 1600,
    wall   = 20,        -- wall thickness
    floor_color = { 0.09, 0.08, 0.14, 1 },
    grid_color  = { 0.14, 0.12, 0.20, 1 },
    grid_step   = 100,  -- background grid spacing (visual only)
    wall_color  = { 0.35, 0.30, 0.50, 1 },
  },

  camera = {
    follow_lerp  = 6,    -- higher = snappier follow
    trauma_decay = 1.6,  -- trauma units shed per second
    max_shake    = 12,   -- px offset at full trauma
  },

  input = {
    deadzone = 0.25,    -- gamepad stick deadzone
  },

  world = {
    cell_size = 64,     -- spatial hash cell size (~2x max entity radius)
  },

  run = {
    duration = 360,
    stage_duration = 180,
    stage_count = 2,
    final_boss_at = 174,
    hard_timeout = 660,
  },

  combat = {
    target_range = 1400,
    player_invulnerability = 0.75,
    enemy_contact_cooldown = 0.65,
    projectile_spawn_offset = 22,
  },

  xp = {
    first_level = 20,
    per_level = 15,
    pickup_radius = 180,
    pickup_speed = 360,
  },

  ui = {
    background_color = { 0.06, 0.05, 0.10, 1 },
    accent_color     = { 0.95, 0.75, 0.20, 1 }, -- gold
    text_color       = { 0.92, 0.92, 0.95, 1 },
    button = {
      fill    = { 0.16, 0.14, 0.24, 1 },
      hover   = { 0.28, 0.24, 0.42, 1 },
      border  = { 0.55, 0.50, 0.75, 1 },
      focus   = { 0.95, 0.75, 0.20, 1 },
    },
  },

  debug = {
    enabled = not is_release,
    admin = {
      enabled = not is_release,
      toggle_key = "f1",
    },
    overlay = {
      max_rows  = 12,
      ttl_secs  = 10,
      font_size = 15,
      toggle_key = "tab",
      visible = false,
    },
    channels = {
      -- Per-channel log toggles; unlisted channels default to enabled.
      boot  = true,
      state = true,
    },
  },

  save = {
    filename = "save.json",
    defaults = {
      coins = 0,
      options = {
        master_volume = 1.0,
        music_volume = 0.8,
        sfx_volume   = 0.8,
        muted = false,
        screen_shake = true,
        hit_flash = true,
        vibration = true,
        aim_assist = true,
        difficulty = "medium",
        camera_zoom = 1.0,
        deadzone = 0.25,
        fullscreen = false,
        controls = {},
      },
    },
  },
}
