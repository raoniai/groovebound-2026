local H = require("tests.helpers")
local UIScale = require("src.ui.scale")

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
