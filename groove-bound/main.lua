-- Bootstrap only: build the app container, validate content, push the first
-- screen, and forward LÖVE callbacks to the state machine. All game logic
-- lives in src/.

local EventBus = require("src.core.event_bus")
local Log = require("src.core.log")
local StateMachine = require("src.core.state_machine")
local ProfileStore = require("src.meta.profile_store")
local WindowsLegacyBackend = require("src.meta.windows_legacy_backend")
local Assets = require("src.assets")
local MusicCatalog = require("src.audio.music_catalog")
local MusicContext = require("src.audio.music_context")
local MusicDirector = require("src.audio.music_director")
local MusicRouter = require("src.audio.music_router")
local AudioSettings = require("src.audio.audio_settings")
local InputEventGate = require("src.game.input_event_gate")
local ControllerManager = require("src.game.controller_manager")
local Tuning = require("src.debug.tuning")
local admin_controls = require("src.config.admin_controls")
local settings = require("src.config.settings")

local Overlay = require("src.debug.overlay")
local TitleScreen = require("src.ui.screens.title")
local GlobalAudioControl = require("src.ui.global_audio_control")
local CursorPolicy = require("src.ui.cursor_policy")

-- The app container: every screen receives this instead of reaching for
-- globals. App-scoped only — per-run objects live in RunContext (Phase 1).
local app = {
  bus = nil,
  states = nil,
  log = Log,
  save = nil,
  profile_store = nil,
  profile = nil,
  slot = nil,
  active_slot_id = nil,
  tuning = nil,
  assets = nil,
  active_run = nil,
  weapon_catalog = nil,
  music = nil,
  music_catalog = nil,
  global_audio = nil,
  input_gate = nil,
}

function love.load()
  Log.configure({ channels = settings.debug.channels })
  Log.info("boot", "Groove Bound starting")

  -- Content is validated at boot; a bad table is a loud, immediate error.
  app.content = require("src.content.init")
  app.weapon_catalog = require("src.game.systems.weapon_catalog")(app.content)
  Log.info("boot", "Content validated")

  app.bus = EventBus()
  app.states = StateMachine()
  app.profile_store = ProfileStore({ legacy_backend = WindowsLegacyBackend.detect() })
  local activation
  app.profile, activation = app.profile_store:activate()
  assert(app.profile, "World Tour save activation failed: "
    .. tostring(activation and activation.status))
  -- Keep the established UI persistence seam while Device Settings and
  -- progression Slots remain independently owned by ProfileStore.
  app.save = app.profile_store.device_settings
  app.active_slot_id = app.profile.active_slot
  app.slot = app.profile_store:load_slot(app.active_slot_id)
  Log.info("save", "Device Settings " .. activation.device.status
    .. "; Windows import " .. activation.external.status
    .. "; legacy migration " .. activation.migration.status)
  if app.profile.options.fullscreen then
    love.window.setFullscreen(true, "desktop")
  end
  require("src.config.controls").apply_saved(app.profile.options.controls)
  app.tuning = Tuning(admin_controls)
  app.assets = Assets.load()
  app.music_catalog = MusicCatalog(require("src.content.music"), {
    file_exists = function(path)
      return love.filesystem.getInfo(path, "file") ~= nil
    end,
  })
  app.music = MusicDirector(app.music_catalog, {
    source_factory = function(path)
      return love.audio.newSource(path, "stream")
    end,
    master_volume = app.profile.options.master_volume,
    music_volume = app.profile.options.music_volume,
  })
  AudioSettings.apply(app)
  app.global_audio = GlobalAudioControl.new(app)
  app.input_gate = InputEventGate.new({ clock = love.timer.getTime })

  app.states:push(TitleScreen(app))
  love.mouse.setVisible(true)
  Log.info("boot", "Boot complete")

  -- CI boot smoke: proving LÖVE reaches this point is sufficient. The flag is
  -- never set by normal play or packaged releases.
  if os.getenv("GROOVE_BOUND_SMOKE") == "1" then
    love.event.quit(0)
  end
end

function love.update(dt)
  app.states:update(dt)
  love.mouse.setVisible(CursorPolicy.visible_for(app.states:top()))
  app.music:request(MusicRouter.route(MusicContext.snapshot(app)))
  app.music:update(dt)
end

function love.draw()
  app.states:draw()
  Overlay.draw()
  app.global_audio:draw()
end

function love.keypressed(key)
  if Overlay.keypressed(key) then return end
  if not app.input_gate:accept("keyboard", key) then return end
  app.states:keypressed(key)
end

function love.keyreleased(key)
  app.states:keyreleased(key)
end

function love.mousepressed(x, y, button)
  if app.global_audio:mousepressed(x, y, button) then return end
  app.states:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  app.states:mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
  app.global_audio:mousemoved(x, y)
  app.states:mousemoved(x, y, dx, dy)
end

function love.gamepadpressed(joystick, button)
  if not app.input_gate:accept("gamepad", button) then return end
  if app.input_gate:gamepad_button(button) == "pause" then
    app.states:gamepadpressed(joystick, "start")
    return
  end
  app.states:gamepadpressed(joystick, button)
end

function love.joystickpressed(joystick, button)
  if app.input_gate:joystick_button(button) ~= "pause" then return end
  if not app.input_gate:accept("joystick", button) then return end
  app.states:gamepadpressed(joystick, "start")
end

function love.joystickadded(joystick)
  ControllerManager.shared:added(joystick)
end

function love.joystickremoved(joystick)
  ControllerManager.shared:removed(joystick)
end

function love.resize(w, h)
  app.states:resize(w, h)
end

function love.focus(focused)
  if not app.music then return end
  if focused then app.music:resume_all() else app.music:pause_all() end
end
