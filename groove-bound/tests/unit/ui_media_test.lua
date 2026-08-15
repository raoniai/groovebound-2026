local H = require("tests.helpers")
local UIScale = require("src.ui.scale")
local EnemyAnimation = require("src.render.enemy_animation")
local enemies = require("src.content.enemies")

local T = {}

local function uint32_be(bytes)
  local a, b, c, d = bytes:byte(1, 4)
  return ((a * 256 + b) * 256 + c) * 256 + d
end

local function png_dimensions(path)
  local file = assert(io.open(path, "rb"))
  local header = file:read(24)
  file:close()
  H.eq(header:sub(1, 8), "\137PNG\r\n\26\n")
  return uint32_be(header:sub(17, 20)), uint32_be(header:sub(21, 24))
end

local function png_color_type(path)
  local file = assert(io.open(path, "rb"))
  local header = file:read(26)
  file:close()
  return header:byte(26)
end

T["runtime UI artwork and character logos have stable production mappings"] = function()
  for _, font_path in ipairs({
    "assets/fonts/Anton-Regular.ttf",
    "assets/fonts/Oswald-Variable.ttf",
    "assets/fonts/OFL-Anton.txt",
    "assets/fonts/OFL-Oswald.txt",
  }) do
    local file = assert(io.open(font_path, "rb"))
    H.is_true(#file:read(16) > 0)
    file:close()
  end
  local enemy_state_strips = 0
  for id, definition in pairs(enemies) do
    for _, state in ipairs({ "walk", "hit", "death", "attack" }) do
      if state ~= "attack" or definition.attack_kind then
        local frames = EnemyAnimation.frame_count(id, state)
        local path = "assets/generated/campaign/enemies/" .. id
          .. "/" .. state .. ".png"
        local width, height = png_dimensions(path)
        H.eq(width, frames * 256, id .. " " .. state .. " width")
        H.eq(height, 256, id .. " " .. state .. " height")
        H.eq(png_color_type(path), 6, id .. " " .. state .. " alpha")
        enemy_state_strips = enemy_state_strips + 1
      end
    end
  end
  H.eq(enemy_state_strips, 170)
  local new_w, new_h = png_dimensions(
    "assets/generated/campaign/ui/new-tag.png")
  H.is_true(new_w > new_h * 2)
  H.eq(png_color_type("assets/generated/campaign/ui/new-tag.png"), 6)
  local attribute_w, attribute_h = png_dimensions(
    "assets/generated/campaign/ui/upgrade-attribute-icons-atlas.png")
  H.eq(attribute_w, 1600)
  H.eq(attribute_h, 800)
  H.eq(png_color_type(
    "assets/generated/campaign/ui/upgrade-attribute-icons-atlas.png"), 6)
  for _, name in ipairs({
    "top-left", "top", "top-right", "left", "center", "right",
    "bottom-left", "bottom", "bottom-right",
  }) do
    local path = "assets/generated/campaign/ui/upgrade-card-frame-v2/"
      .. name .. ".png"
    local width, height = png_dimensions(path)
    H.is_true(width > 0)
    H.is_true(height > 0)
    H.eq(png_color_type(path), 6)
  end
  local menu_w, menu_h = png_dimensions(
    "assets/generated/campaign/ui/menu-category-icons-atlas-v2.png")
  H.eq(menu_w, 1600)
  H.eq(menu_h, 1200)
  H.eq(png_color_type(
    "assets/generated/campaign/ui/menu-category-icons-atlas-v2.png"), 6)
  for _, path in ipairs({
    "assets/generated/campaign/ui/menu-stat-icons-v1.png",
    "assets/generated/campaign/ui/settings-icons-v1.png",
  }) do
    local width, height = png_dimensions(path)
    H.eq(width, 1600)
    H.eq(height, 1600)
    H.eq(png_color_type(path), 6)
  end
  local alert_w, alert_h = png_dimensions(
    "assets/generated/campaign/ui/level-points-alert-icons-v1.png")
  H.eq(alert_w, 1536)
  H.eq(alert_h, 1024)
  H.eq(png_color_type(
    "assets/generated/campaign/ui/level-points-alert-icons-v1.png"), 6)
  for _, name in ipairs({
    "top-left", "top", "top-right", "left", "center", "right",
    "bottom-left", "bottom", "bottom-right",
  }) do
    local path = "assets/generated/campaign/ui/menu-focus-frame-v2/"
      .. name .. ".png"
    local width, height = png_dimensions(path)
    H.is_true(width > 0)
    H.is_true(height > 0)
    H.eq(png_color_type(path), 6)
  end
  for _, root in ipairs({ "cta-frame-v1", "cta-focus-v1" }) do
    for _, name in ipairs({
      "top-left", "top", "top-right", "left", "center", "right",
      "bottom-left", "bottom", "bottom-right",
    }) do
      local path = "assets/generated/campaign/ui/" .. root .. "/"
        .. name .. ".png"
      local width, height = png_dimensions(path)
      H.is_true(width > 0)
      H.is_true(height > 0)
      H.eq(png_color_type(path), 6)
    end
  end
  local hud_kit = "assets/generated/campaign/ui/hud-interface-kit-v1/"
  local hud_expected = {
    ["rank-badge.png"] = { 256, 256 },
    ["max-badge.png"] = { 256, 256 },
    ["bar-left.png"] = { 96, 64 },
    ["bar-middle.png"] = { 64, 64 },
    ["bar-right.png"] = { 96, 64 },
    ["bar-fill.png"] = { 64, 24 },
  }
  for name, dimensions in pairs(hud_expected) do
    local path = hud_kit .. name
    local width, height = png_dimensions(path)
    H.eq(width, dimensions[1])
    H.eq(height, dimensions[2])
    H.eq(png_color_type(path), 6)
  end
  local aim_w, aim_h = png_dimensions(
    "assets/generated/campaign/aim-reticle.png")
  H.eq(aim_w, aim_h)
  H.eq(png_color_type("assets/generated/campaign/aim-reticle.png"), 6)
  local slot_w, slot_h = png_dimensions(
    "assets/generated/campaign/hud-slot-frame.png")
  H.eq(slot_w, slot_h)
  H.eq(png_color_type("assets/generated/campaign/hud-slot-frame.png"), 6)
  local gameover_w, gameover_h = png_dimensions(
    "assets/generated/campaign/game-over-v2.png")
  H.is_true(gameover_w >= 1280)
  H.is_true(gameover_h >= 720)
  H.is_true(select(1, png_dimensions(
    "assets/generated/campaign/joe-logo.png")) >= 1000)
  H.is_true(select(1, png_dimensions(
    "assets/generated/campaign/lyra-vex-logo.png")) >= 1000)
  local encore_w, encore_h = png_dimensions(
    "assets/generated/campaign/stage-clear-chest.png")
  H.is_true(encore_w >= 1000)
  H.is_true(encore_h >= 1000)
  H.eq(png_color_type(
    "assets/generated/campaign/stage-clear-chest.png"), 6)
  for _, expected in ipairs({
    { "assets/generated/campaign/musical-chest-atlas.png", 1600, 800 },
    { "assets/generated/campaign/chest-luck-reveal-atlas.png", 2000, 800 },
    { "assets/generated/campaign/funk-pocket-pad-atlas.png", 1600, 400 },
    { "assets/generated/campaign/world-tour-ui-atlas.png", 2000, 1000 },
    { "assets/generated/campaign/world-interface-atlas.png", 2000, 1000 },
    { "assets/generated/campaign/menu-button-icons-atlas.png", 2000, 800 },
    { "assets/generated/campaign/completion-ui-atlas.png", 1600, 800 },
    { "assets/generated/campaign/meta-perks-atlas.png", 2000, 1600 },
    { "assets/generated/campaign/world-mechanics-atlas.png", 2000, 800 },
    { "assets/generated/campaign/funk-enemies-atlas.png", 1600, 800 },
    { "assets/generated/campaign/soul-enemies-atlas.png", 1600, 800 },
    { "assets/generated/campaign/disco-enemies-atlas.png", 1600, 800 },
    { "assets/generated/campaign/jazz-enemies-atlas.png", 1600, 800 },
    { "assets/generated/campaign/enemy-animation/backbeat-movement-atlas.png", 1024, 1536 },
    { "assets/generated/campaign/enemy-animation/orbit-movement-atlas.png", 1024, 1536 },
    { "assets/generated/campaign/enemy-animation/funk-movement-atlas.png", 1024, 1536 },
    { "assets/generated/campaign/enemy-animation/soul-movement-atlas.png", 1024, 1536 },
    { "assets/generated/campaign/enemy-animation/disco-movement-atlas.png", 1024, 1536 },
    { "assets/generated/campaign/enemy-animation/jazz-movement-atlas.png", 1024, 2048 },
    { "assets/generated/campaign/funk-environment-atlas.png", 1600, 800 },
    { "assets/generated/campaign/soul-environment-atlas.png", 1600, 800 },
    { "assets/generated/campaign/disco-environment-atlas.png", 1600, 800 },
    { "assets/generated/campaign/jazz-environment-atlas.png", 1600, 800 },
    { "assets/generated/evolved-weapon-icons-atlas-2.png", 1600, 800 },
  }) do
    local width, height = png_dimensions(expected[1])
    H.eq(width, expected[2])
    H.eq(height, expected[3])
    H.eq(png_color_type(expected[1]), 6)
  end
  local floor_w, floor_h = png_dimensions(
    "assets/generated/campaign/funk-floor-atlas.png")
  H.eq(floor_w, 1024)
  H.eq(floor_h, 1024)
  H.eq(png_color_type("assets/generated/campaign/funk-floor-atlas.png"), 2)
  local jazz_floor_w, jazz_floor_h = png_dimensions(
    "assets/generated/campaign/jazz-floor-atlas.png")
  H.eq(jazz_floor_w, 1024)
  H.eq(jazz_floor_h, 1024)
  H.eq(png_color_type("assets/generated/campaign/jazz-floor-atlas.png"), 2)
  local jazz_logo_w, jazz_logo_h = png_dimensions(
    "assets/generated/campaign/jazz-world-logo.png")
  H.is_true(jazz_logo_w >= 1000)
  H.is_true(jazz_logo_h >= 500)
  H.eq(png_color_type("assets/generated/campaign/jazz-world-logo.png"), 6)
  for _, world_id in ipairs({
    "jazz", "house", "techno", "cosmic-boogie",
    "soulful-garage", "future-funk",
  }) do
    local path = "assets/generated/campaign/world-emblems/"
      .. world_id .. ".png"
    local width, height = png_dimensions(path)
    H.eq(width, 512)
    H.eq(height, 512)
    H.eq(png_color_type(path), 6)
  end
end

T["World Tour atlas repair keeps every isolated sprite auditable"] = function()
  local json = require("lib.json")
  local path = "assets/generated/campaign/world-tour-sprites/manifest.json"
  local file = assert(io.open(path, "rb"))
  local manifest = json.decode(file:read("*a"))
  file:close()
  H.eq(manifest.schema, 1)
  H.eq(manifest.count, 147)
  H.eq(#manifest.records, 147)
  for _, record in ipairs(manifest.records) do
    H.is_true(record.atlas_repair.grid_preserved)
    H.is_true(record.atlas_repair.uniform_scale_only)
    H.is_true(record.atlas_repair.safe_gutter >= 8)
    H.eq(record.alpha_bounds[1], 0)
    H.eq(record.alpha_bounds[2], 0)
    H.eq(record.alpha_bounds[3], record.output_size[1])
    H.eq(record.alpha_bounds[4], record.output_size[2])
  end
end

T["new Stage 2 and ending videos are Ogg runtime media"] = function()
  for _, path in ipairs({
    "assets/video/runtime/cutscene-4-stage2_transition.ogv",
    "assets/video/runtime/cutscene-5-ending.ogv",
  }) do
    local file = assert(io.open(path, "rb"))
    local header = file:read(4)
    file:close()
    H.eq(header, "OggS")
  end
end

T["interface scaling preserves the 1280 by 720 reference canvas"] = function()
  H.eq(UIScale.factor(1280, 720), 1)
  H.eq(UIScale.factor(2560, 1440), 2)
  H.eq(UIScale.factor(800, 600), 1)
end

return T
