-- Sprite-backed pause modal. The frozen run remains visible beneath it.

local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local Input = require("src.game.input")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")
local Hints = require("src.ui.controller_hints")
local MenuChrome = require("src.ui.menu_chrome")

local PauseScreen = class()
PauseScreen.kind = "pause"
PauseScreen.opaque = false

function PauseScreen:init(app)
  self.app = app
  self.notice = nil
end

function PauseScreen:enter()
  self.app.log.info("state", "Paused")
  self:_layout()
end

function PauseScreen:_button(opts)
  opts.renderer = function(button)
    MenuChrome.action(self.app.assets, button, {
      icon = opts.menu_icon,
      label = opts.label,
      subtitle = opts.subtitle,
      font_size = 18,
    })
  end
  return widgets.Button(opts)
end

function PauseScreen:_layout()
  local w, h = love.graphics.getDimensions()
  local panel_w = math.min(560, w - 48)
  local panel_h = math.min(476, h - 84)
  self.panel = {
    x = (w - panel_w) / 2,
    y = math.max(24, (h - panel_h) / 2 - 8),
    w = panel_w,
    h = panel_h,
  }
  local bw, bh, gap = panel_w - 104, 68, 7
  local x = self.panel.x + 52
  local y = self.panel.y + 104
  local buttons = {
    self:_button({
      label = "RESUME", subtitle = "Return to the run",
      menu_icon = { col = 1, row = 1 },
      x = x, y = y, w = bw, h = bh,
      on_press = function() self.app.states:pop() end,
    }),
    self:_button({
      label = "COPY RUN SEED", subtitle = "Save this exact run setup",
      menu_icon = { col = 2, row = 1 },
      x = x, y = y + (bh + gap), w = bw, h = bh,
      on_press = function()
        if self.app.active_run then self.app.active_run:copy_seed() end
        self.notice = "RUN SEED COPIED"
      end,
    }),
    self:_button({
      label = "SETTINGS", subtitle = "Audio, display, gameplay and controls",
      menu_icon = { col = 4, row = 1 },
      x = x, y = y + (bh + gap) * 2, w = bw, h = bh,
      on_press = function()
        local OptionsScreen = require("src.ui.screens.options")
        self.app.states:push(OptionsScreen(self.app))
      end,
    }),
    self:_button({
      label = "QUIT TO TITLE", subtitle = "End this run and return to the title",
      menu_icon = { col = 5, row = 1 },
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
  love.graphics.setFont(Fonts.body(14))
  love.graphics.setColor(0.72, 0.76, 0.86, 1)
  love.graphics.printf("THE BEAT IS HELD", self.panel.x,
    self.panel.y + 72, self.panel.w, "center")

  self.button_list:draw()
  if self.notice then
    love.graphics.setFont(Fonts.body(13))
    love.graphics.setColor(0.34, 1.0, 0.68, 1)
    love.graphics.printf(self.notice, self.panel.x,
      self.panel.y + self.panel.h - 34, self.panel.w, "center")
  end
  Hints.draw({
    { symbol = "dpad", label = "Move" },
    { symbol = "cross", label = "Select" },
    { symbol = "circle", label = "Resume" },
    { symbol = "options", label = "Resume" },
  }, h - 28, w, { font_size = 13, glyph_size = 18, gap = 17 })
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
