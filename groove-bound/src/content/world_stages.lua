-- First end-to-end World Tour slice. It deliberately reuses stable arena art
-- while the authored Funk mechanic and run records establish the new loop.

return {
  funk = {
    id = "world_funk",
    world_id = "funk",
    name = "THE POCKET DISTRICT",
    subtitle = "Hold the pocket. Catch the gold downbeat.",
    width = 5000,
    height = 3200,
    base_duration = 240,
    wave_base_duration = 600,
    waves = require("src.content.world_tour_waves.funk"),
    final_boss = "breakbeat_bruiser",
    floor_style = "backbeat",
    floor_tint = { 0.78, 0.58, 0.92, 1 },
    veil_color = { 0.045, 0.015, 0.075, 0.34 },
    grid_color = { 1.0, 0.68, 0.18, 0.40 },
    environment_atlas = "stage1",
    mechanic = {
      id = "funk_hold_the_pocket",
      cycle_seconds = 2.2,
      active_window = 0.28,
      boost_seconds = 2.8,
      boost_multiplier = 1.55,
      radius = 112,
      pads = {
        { x = 2500, y = 1600 },
        { x = 2050, y = 1280 },
        { x = 2950, y = 1280 },
        { x = 2050, y = 1920 },
        { x = 2950, y = 1920 },
      },
    },
    obstacles = {
      { x = 820, y = 550, w = 180, h = 220, icon = { col = 1, row = 1 } },
      { x = 1540, y = 430, w = 230, h = 145, icon = { col = 2, row = 1 } },
      { x = 3240, y = 470, w = 230, h = 145, icon = { col = 3, row = 1 } },
      { x = 4010, y = 620, w = 170, h = 230, icon = { col = 4, row = 1 } },
      { x = 750, y = 2380, w = 220, h = 150, icon = { col = 2, row = 1 } },
      { x = 1580, y = 2570, w = 170, h = 230, icon = { col = 1, row = 1 } },
      { x = 3300, y = 2530, w = 220, h = 150, icon = { col = 3, row = 1 } },
      { x = 4100, y = 2310, w = 180, h = 230, icon = { col = 4, row = 1 } },
    },
    decorations = {
      { x = 1180, y = 1120, size = 160, icon = { col = 1, row = 2 } },
      { x = 3820, y = 1080, size = 170, icon = { col = 2, row = 2 } },
      { x = 1160, y = 2050, size = 150, icon = { col = 3, row = 2 } },
      { x = 3820, y = 2100, size = 165, icon = { col = 4, row = 2 } },
    },
  },
}
