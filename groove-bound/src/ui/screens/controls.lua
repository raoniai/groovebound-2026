local class = require("src.core.class")
local Controls = require("src.config.controls")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")

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
  local bw, bh, gap = math.min(440, w - 80), 40, 8
  local x, y = (w - bw) / 2, h * 0.20
  local buttons = {}
  for _, action in ipairs(actions) do
    local action_id = action
    buttons[#buttons + 1] = widgets.Button({
      label = string.upper(action_id) .. "  —  " .. Controls.keyboard[action_id][1],
      x = x, y = y + (#buttons * (bh + gap)), w = bw, h = bh, font_size = 15,
      on_press = function()
        self.capture_action = action_id
        self.message = "Press a new key for " .. string.upper(action_id)
      end,
    })
  end
  buttons[#buttons + 1] = widgets.Button({
    label = "Back", x = x, y = y + (#buttons * (bh + gap)), w = bw, h = bh,
    on_press = function() self.app.states:pop() end,
  })
  self.buttons = widgets.ButtonList(buttons)
end

function ControlsScreen:resize() self:_layout() end

function ControlsScreen:draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.setFont(Fonts.get(32))
  love.graphics.printf("KEYBOARD BINDINGS", 0, h * 0.08, w, "center")
  self.buttons:draw()
  if self.message then
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.get(14))
    love.graphics.printf(self.message, 0, h - 55, w, "center")
  end
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
