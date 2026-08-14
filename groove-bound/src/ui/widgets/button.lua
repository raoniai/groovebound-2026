-- Focusable button widget: mouse hover/click, keyboard/gamepad focus + confirm.
-- Screens own a list of buttons and route input through ButtonList.

local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local SpatialNavigation = require("src.ui.spatial_navigation")

local Button = class()

function Button:init(opts)
  self.label = assert(opts.label, "button needs a label")
  self.x = opts.x or 0
  self.y = opts.y or 0
  self.w = opts.w or 200
  self.h = opts.h or 48
  self.on_press = opts.on_press or function() end
  self.focused = false
  self.hovered = false
  self.font_size = opts.font_size or 20
  self.variant = opts.variant or "default"
  self.icon = opts.icon
  self.draw_icon = opts.draw_icon
  self.icon_size = opts.icon_size
  self.renderer = opts.renderer
  self.disabled = opts.disabled == true
end

function Button:contains(px, py)
  return px >= self.x and px <= self.x + self.w
     and py >= self.y and py <= self.y + self.h
end

function Button:draw()
  if self.renderer then
    self.renderer(self)
    return
  end
  local colors = settings.ui.button
  local fill = (self.focused or self.hovered) and colors.hover or colors.fill

  if self.variant == "primary" then
    local pulse = 0.82 + math.sin((love.timer and love.timer.getTime() or 0) * 4) * 0.08
    fill = self.hovered and { 0.26, 0.16, 0.05, 0.98 }
      or { 0.12, 0.055, 0.15, 0.98 }
    love.graphics.setColor(1.0, 0.72, 0.18, 0.12 * pulse)
    love.graphics.rectangle("fill", self.x - 6, self.y - 6,
      self.w + 12, self.h + 12, 10, 10)
  elseif self.variant == "danger" then
    fill = self.hovered and { 0.28, 0.035, 0.075, 0.98 }
      or { 0.15, 0.018, 0.045, 0.96 }
  end

  love.graphics.setColor(fill)
  love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 6, 6)

  love.graphics.setColor(self.variant == "primary"
    and { 1.0, 0.74, 0.20, 1 }
    or self.variant == "danger" and { 1.0, 0.20, 0.30, 1 }
    or (self.focused and colors.focus or colors.border))
  if self.focused then
    love.graphics.setColor(0.22, 0.92, 1.0, 0.18)
    love.graphics.rectangle("fill", self.x - 7, self.y - 7,
      self.w + 14, self.h + 14, 10, 10)
    love.graphics.setColor(1.0, 0.78, 0.22, 1)
  end
  love.graphics.setLineWidth(self.focused and 4 or self.variant == "primary" and 2 or 1)
  love.graphics.rectangle("line", self.x, self.y, self.w, self.h, 6, 6)

  local text_x, text_w = self.x, self.w
  if self.icon and self.draw_icon then
    local icon_size = self.icon_size or math.min(44, self.h - 8)
    local icon_x = self.x + 8
    local icon_y = self.y + (self.h - icon_size) / 2
    self.draw_icon(self.icon, icon_x, icon_y, icon_size, icon_size, {
      color = self.variant == "danger"
        and { 1, 0.78, 0.82, 1 } or { 1, 1, 1, 1 },
    })
    text_x = icon_x + icon_size + 4
    text_w = self.w - (text_x - self.x) - 8
  end

  love.graphics.setColor(self.variant == "danger"
    and { 1, 0.78, 0.82, 1 } or settings.ui.text_color)
  local font = Fonts.get(self.font_size)
  love.graphics.setFont(font)
  local text_y = self.y + (self.h - font:getHeight()) / 2
  love.graphics.printf(self.label, text_x, text_y, text_w, "center")
end

-- Manages focus + input routing for a screen's buttons.
local ButtonList = class()

function ButtonList:init(buttons)
  self.buttons = buttons or {}
  self.focus_index = 1
  self:_apply_focus()
end

function ButtonList:_apply_focus()
  for i, b in ipairs(self.buttons) do
    b.focused = (i == self.focus_index)
  end
end

function ButtonList:move_focus(delta)
  local n = #self.buttons
  if n == 0 then return end
  self.focus_index = ((self.focus_index - 1 + delta) % n) + 1
  self:_apply_focus()
end

function ButtonList:move_focus_direction(direction)
  local next_index = SpatialNavigation.find(
    self.buttons, self.focus_index, direction)
  if next_index == self.focus_index then return false end
  self.focus_index = next_index
  self:_apply_focus()
  return true
end

function ButtonList:confirm()
  local b = self.buttons[self.focus_index]
  if b and not b.disabled then b.on_press() end
end

function ButtonList:keypressed(key)
  if key == "up" or key == "w" then
    self:move_focus_direction("up")
    return true
  elseif key == "down" or key == "s" then
    self:move_focus_direction("down")
    return true
  elseif key == "left" or key == "a" then
    self:move_focus_direction("left")
    return true
  elseif key == "right" or key == "d" then
    self:move_focus_direction("right")
    return true
  elseif key == "return" or key == "space" then
    self:confirm()
    return true
  end
  return false
end

function ButtonList:gamepadpressed(button)
  local directions = {
    dpup = "up", dpdown = "down", dpleft = "left", dpright = "right",
  }
  if directions[button] then
    self:move_focus_direction(directions[button])
    return true
  elseif button == "a" then
    self:confirm()
    return true
  end
  return false
end

function ButtonList:mousemoved(x, y)
  for i, b in ipairs(self.buttons) do
    b.hovered = b:contains(x, y)
    if b.hovered and self.focus_index ~= i then
      self.focus_index = i
      self:_apply_focus()
    end
  end
end

function ButtonList:mousepressed(x, y, mouse_button)
  if mouse_button ~= 1 then return false end
  for _, b in ipairs(self.buttons) do
    if b:contains(x, y) then
      if b.disabled then return true end
      b.on_press()
      return true
    end
  end
  return false
end

function ButtonList:draw()
  for _, b in ipairs(self.buttons) do
    b:draw()
  end
end

return { Button = Button, ButtonList = ButtonList }
