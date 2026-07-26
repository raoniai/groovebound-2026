-- Bootstrap only: build the app container, validate content, push the first
-- screen, and forward LÖVE callbacks to the state machine. All game logic
-- lives in src/.

local EventBus = require("src.core.event_bus")
local Log = require("src.core.log")
local Save = require("src.core.save")
local StateMachine = require("src.core.state_machine")
local Assets = require("src.assets")
local Tuning = require("src.debug.tuning")
local admin_controls = require("src.config.admin_controls")
local settings = require("src.config.settings")

local Overlay = require("src.debug.overlay")
local TitleScreen = require("src.ui.screens.title")

-- The app container: every screen receives this instead of reaching for
-- globals. App-scoped only — per-run objects live in RunContext (Phase 1).
local app = {
  bus = nil,
  states = nil,
  log = Log,
  save = nil,
  profile = nil,
  tuning = nil,
  assets = nil,
  active_run = nil,
  weapon_catalog = nil,
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
  app.save = Save({
    filename = settings.save.filename,
    defaults = settings.save.defaults,
  })
  app.profile = app.save:load()
  require("src.config.controls").apply_saved(app.profile.options.controls)
  app.tuning = Tuning(admin_controls)
  app.assets = Assets.load()
  app.assets:set_sfx_volume(
    app.profile.options.master_volume * app.profile.options.sfx_volume)

  app.states:push(TitleScreen(app))
  Log.info("boot", "Boot complete")

  -- CI boot smoke: proving LÖVE reaches this point is sufficient. The flag is
  -- never set by normal play or packaged releases.
  if os.getenv("GROOVE_BOUND_SMOKE") == "1" then
    love.event.quit(0)
  end
end

function love.update(dt)
  app.states:update(dt)
end

function love.draw()
  app.states:draw()
  Overlay.draw()
end

function love.keypressed(key)
  if Overlay.keypressed(key) then return end
  app.states:keypressed(key)
end

function love.keyreleased(key)
  app.states:keyreleased(key)
end

function love.mousepressed(x, y, button)
  app.states:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  app.states:mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
  app.states:mousemoved(x, y, dx, dy)
end

function love.gamepadpressed(joystick, button)
  app.states:gamepadpressed(joystick, button)
end

function love.resize(w, h)
  app.states:resize(w, h)
end
