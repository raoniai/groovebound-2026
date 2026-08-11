-- LÖVE configuration. Engine-level only; gameplay tunables live in src/config/settings.lua.
local function has_argument(expected)
  for _, value in pairs(arg or {}) do
    if value == expected then return true end
  end
  return false
end

function love.conf(t)
  local headless_smoke = has_argument("groove-bound-headless-smoke")
  t.identity = "groove-bound"
  t.version = "11.5"
  t.console = false

  t.window.title = "Groove Bound"
  t.window.icon = "assets/generated/campaign/app-icon.png"
  t.window.width = 1280
  t.window.height = 720
  t.window.resizable = true
  t.window.minwidth = 800
  t.window.minheight = 600
  t.window.vsync = 1

  -- Modules we do not use yet; disabled to keep startup lean.
  t.modules.physics = false
  t.modules.video = true
  t.modules.touch = false

  -- GitHub's hosted Windows runner has no interactive game desktop. This
  -- profile still executes the fused game and validates packaged content, but
  -- skips graphics/audio initialization; physical Windows QA owns GUI play.
  if headless_smoke then
    t.window = nil
    t.modules.audio = false
    t.modules.font = false
    t.modules.graphics = false
    t.modules.image = false
    t.modules.joystick = false
    t.modules.sound = false
    t.modules.video = false
  end
end
