local class = require("src.core.class")
local Controls = require("src.config.controls")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")
local Hints = require("src.ui.controller_hints")
local MenuChrome = require("src.ui.menu_chrome")

local ControlsScreen = class()
ControlsScreen.kind = "controls"

local actions = { "up", "down", "left", "right", "confirm", "cancel", "pause" }

function ControlsScreen:init(app)
  self.app = app
  self.capture_action = nil
  self.message = nil
end

function ControlsScreen:enter() self:_layout() end

function ControlsScreen:_layout()
  local w, h = love.graphics.getDimensions()
  local panel_w = math.min(590, w - 48)
  self.panel = { x = (w - panel_w) / 2, y = 28, w = panel_w, h = h - 70 }
  local bw, bh, gap = panel_w - 84, 44, 5
  local x, y = (w - bw) / 2, self.panel.y + 88
  local function renderer(button)
    MenuChrome.action(self.app.assets, button, {
      menu_cell = button.is_back and 8 or nil,
      settings_cell = button.is_back and nil or 7,
      label = button.label,
      font_size = 15,
    })
  end
  local buttons = {}
  for _, action in ipairs(actions) do
    local action_id = action
    buttons[#buttons + 1] = widgets.Button({
      label = string.upper(action_id) .. "  —  " .. Controls.keyboard[action_id][1],
      x = x, y = y + (#buttons * (bh + gap)), w = bw, h = bh, font_size = 15,
      renderer = renderer,
      on_press = function()
        self.capture_action = action_id
        self.message = "Press a new key for " .. string.upper(action_id)
      end,
    })
  end
  local back = widgets.Button({
    label = "Back", x = x, y = y + (#buttons * (bh + gap)), w = bw, h = bh,
    renderer = renderer,
    on_press = function() self.app.states:pop() end,
  })
  back.is_back = true
  buttons[#buttons + 1] = back
  self.buttons = widgets.ButtonList(buttons)
end

function ControlsScreen:resize() self:_layout() end

function ControlsScreen:draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, w, h)
  MenuChrome.panel(self.app.assets, self.panel, { corner = 46, alpha = 0.98 })
  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.setFont(Fonts.heading(30))
  love.graphics.printf("KEYBOARD BINDINGS", 0, self.panel.y + 24, w, "center")
  self.buttons:draw()
  if self.message then
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.body(13))
    love.graphics.printf(self.message, 0, h - 58, w, "center")
  end
  Hints.draw({
    { symbol = "dpad", label = "Move" },
    { symbol = "cross", label = "Rebind" },
    { symbol = "circle", label = self.capture_action and "Cancel" or "Back" },
  }, h - 27, w, { font_size = 12, glyph_size = 17, gap = 16 })
end

function ControlsScreen:gamepadpressed(_, button)
  if button == "b" then
    if self.capture_action then
      self.capture_action = nil
      self.message = "REBIND CANCELLED"
    else
      self.app.states:pop()
    end
    return true
  end
  if self.capture_action then return true end
  return self.buttons:gamepadpressed(button)
end

function ControlsScreen:keypressed(key)
  if self.capture_action then
    local ok, reason = Controls.bind_keyboard(self.capture_action, key)
    if ok then
      self.app.profile.options.controls = Controls.snapshot()
      self.app.save:save(self.app.profile)
      self.message = string.upper(self.capture_action) .. " bound to " .. key
      self.capture_action = nil
      self:_layout()
    else
      self.message = "Conflict: " .. reason:gsub("key_conflict:", "") .. " already uses " .. key
    end
    return true
  end
  if key == "escape" then self.app.states:pop() return true end
  return self.buttons:keypressed(key)
end

function ControlsScreen:mousemoved(x, y) self.buttons:mousemoved(x, y) end
function ControlsScreen:mousepressed(x, y, button)
  return self.buttons:mousepressed(x, y, button)
end

return ControlsScreen
