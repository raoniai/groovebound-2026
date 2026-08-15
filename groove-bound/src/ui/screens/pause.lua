-- Sprite-backed pause modal. The frozen run remains visible beneath it.

local class = require("src.core.class")
local AudioSettings = require("src.audio.audio_settings")
local Fonts = require("src.ui.fonts")
local Input = require("src.game.input")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")
local MenuChrome = require("src.ui.menu_chrome")
local BuildInfo = require("src.config.build_info")
local VersionTag = require("src.ui.version_tag")

local PauseScreen = class()
PauseScreen.kind = "pause"
PauseScreen.opaque = false

function PauseScreen:init(app)
  self.app = app
end

function PauseScreen:enter()
  self.app.log.info("state", "Paused")
  self:_layout()
end

function PauseScreen:_button(opts)
  opts.renderer = function(button)
    MenuChrome.action(self.app.assets, button, {
      menu_cell = opts.menu_cell,
      settings_cell = opts.settings_cell,
      label = opts.dynamic_label and opts.dynamic_label() or opts.label,
      font_size = 18,
    })
  end
  return widgets.Button(opts)
end

function PauseScreen:_layout()
  local w, h = love.graphics.getDimensions()
  local panel_w = math.min(560, w - 48)
  local panel_h = math.min(374, h - 84)
  self.panel = {
    x = (w - panel_w) / 2,
    y = math.max(24, (h - panel_h) / 2 - 8),
    w = panel_w,
    h = panel_h,
  }
  self.version_tag = VersionTag.layout(self.panel, "bottom-right", 12)
  local bw, bh, gap = panel_w - 104, 54, 8
  local x = self.panel.x + 52
  local y = self.panel.y + 82
  local buttons = {
    self:_button({
      label = "RESUME",
      menu_cell = 1,
      x = x, y = y, w = bw, h = bh,
      on_press = function() self.app.states:pop() end,
    }),
    self:_button({
      label = "MUTE", dynamic_label = function()
        return self.app.profile.options.muted and "UNMUTE" or "MUTE"
      end,
      settings_cell = 4,
      x = x, y = y + (bh + gap), w = bw, h = bh,
      on_press = function()
        AudioSettings.toggle_muted(self.app)
      end,
    }),
    self:_button({
      label = "SETTINGS",
      menu_cell = 4,
      x = x, y = y + (bh + gap) * 2, w = bw, h = bh,
      on_press = function()
        local OptionsScreen = require("src.ui.screens.options")
        self.app.states:push(OptionsScreen(self.app))
      end,
    }),
    self:_button({
      label = "QUIT TO TITLE",
      menu_cell = 6,
      x = x, y = y + (bh + gap) * 3, w = bw, h = bh,
      on_press = function()
        if self.app.active_run and not self.app.active_run.finished then
          require("src.meta.journey_progress").abandon_active_run(self.app)
        end
        local TitleScreen = require("src.ui.screens.title")
        self.app.states:switch(TitleScreen(self.app))
      end,
    }),
  }
  self.button_list = widgets.ButtonList(buttons)
end

function PauseScreen:resize() self:_layout() end

function PauseScreen:draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(0, 0, 0, 0.74)
  love.graphics.rectangle("fill", 0, 0, w, h)
  MenuChrome.panel(self.app.assets, self.panel, { corner = 52, alpha = 0.98 })

  love.graphics.setFont(Fonts.heading(38))
  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.printf("PAUSED", self.panel.x, self.panel.y + 28,
    self.panel.w, "center")

  self.button_list:draw()

  VersionTag.draw(BuildInfo.version_label(), self.version_tag)
end

function PauseScreen:keypressed(key)
  if settings.debug.admin.enabled and key == settings.debug.admin.toggle_key then
    local AdminScreen = require("src.ui.screens.admin")
    self.app.states:push(AdminScreen(self.app))
    return true
  end
  if Input.is_action(key, "pause") or Input.is_action(key, "cancel") then
    self.app.states:pop()
    return true
  end
  return self.button_list:keypressed(key)
end

function PauseScreen:gamepadpressed(_, button)
  if Input.is_gamepad_action(button, "pause")
    or Input.is_gamepad_action(button, "cancel")
  then
    self.app.states:pop()
    return true
  end
  return self.button_list:gamepadpressed(button)
end

function PauseScreen:mousemoved(x, y)
  self.button_list:mousemoved(x, y)
end

function PauseScreen:mousepressed(x, y, button)
  return self.button_list:mousepressed(x, y, button)
end

return PauseScreen
