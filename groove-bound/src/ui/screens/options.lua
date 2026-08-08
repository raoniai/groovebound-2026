local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")

local OptionsScreen = class()
OptionsScreen.kind = "options"

function OptionsScreen:init(app)
  self.app = app
end

function OptionsScreen:enter()
  self:_layout()
end

function OptionsScreen:_save()
  self.app.save:save(self.app.profile)
  local options = self.app.profile.options
  self.app.assets:set_sfx_volume(options.master_volume * options.sfx_volume)
  self.app.music:set_volume(options.master_volume, options.music_volume)
end

function OptionsScreen:_cycle_volume(key)
  local options = self.app.profile.options
  options[key] = options[key] >= 1 and 0 or math.min(1, options[key] + 0.25)
  self:_save()
  self:_layout()
end

function OptionsScreen:_toggle(key)
  local options = self.app.profile.options
  options[key] = not options[key]
  if key == "fullscreen" then love.window.setFullscreen(options[key], "desktop") end
  self:_save()
  self:_layout()
end

function OptionsScreen:_layout()
  local w, h = love.graphics.getDimensions()
  local options = self.app.profile.options
  local bw, bh, gap = math.min(520, w - 80), 44, 8
  local x, y = (w - bw) / 2, h * 0.16
  local buttons = {}
  local function add(label, callback)
    buttons[#buttons + 1] = widgets.Button({
      label = label, x = x, y = y + (#buttons * (bh + gap)), w = bw, h = bh,
      font_size = 18, on_press = callback,
    })
  end
  add(string.format("Master volume  %d%%", options.master_volume * 100),
    function() self:_cycle_volume("master_volume") end)
  add(string.format("Music volume  %d%%", options.music_volume * 100),
    function() self:_cycle_volume("music_volume") end)
  add(string.format("SFX volume  %d%%", options.sfx_volume * 100),
    function() self:_cycle_volume("sfx_volume") end)
  add("Screen shake  " .. (options.screen_shake and "ON" or "OFF"),
    function() self:_toggle("screen_shake") end)
  add("Hit flash  " .. (options.hit_flash and "ON" or "OFF"),
    function() self:_toggle("hit_flash") end)
  add("Aim assist  " .. (options.aim_assist and "ON" or "OFF"),
    function() self:_toggle("aim_assist") end)
  add("Vibration  " .. (options.vibration and "ON" or "OFF"),
    function() self:_toggle("vibration") end)
  add(string.format("Controller dead zone  %d%%", options.deadzone * 100),
    function()
      options.deadzone = options.deadzone >= 0.40 and 0.15 or options.deadzone + 0.05
      self:_save()
      self:_layout()
    end)
  add("Fullscreen  " .. (options.fullscreen and "ON" or "OFF"),
    function() self:_toggle("fullscreen") end)
  add("Keyboard bindings", function()
    local ControlsScreen = require("src.ui.screens.controls")
    self.app.states:push(ControlsScreen(self.app))
  end)
  add("Back", function() self.app.states:pop() end)
  self.buttons = widgets.ButtonList(buttons)
end

function OptionsScreen:resize() self:_layout() end

function OptionsScreen:draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.setFont(Fonts.get(38))
  love.graphics.printf("OPTIONS", 0, h * 0.10, w, "center")
  self.buttons:draw()
end

function OptionsScreen:keypressed(key)
  if key == "escape" then self.app.states:pop() return true end
  return self.buttons:keypressed(key)
end

function OptionsScreen:gamepadpressed(_, button)
  if button == "b" then self.app.states:pop() return true end
  if button == "a" then self.buttons:confirm() return true end
  if button == "dpup" then self.buttons:move_focus(-1) return true end
  if button == "dpdown" then self.buttons:move_focus(1) return true end
  return false
end

function OptionsScreen:mousemoved(x, y) self.buttons:mousemoved(x, y) end
function OptionsScreen:mousepressed(x, y, button)
  return self.buttons:mousepressed(x, y, button)
end

return OptionsScreen
