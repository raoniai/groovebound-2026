local class = require("src.core.class")
local AudioSettings = require("src.audio.audio_settings")
local Fonts = require("src.ui.fonts")
local Hints = require("src.ui.controller_hints")
local MenuChrome = require("src.ui.menu_chrome")
local SpatialNavigation = require("src.ui.spatial_navigation")
local settings = require("src.config.settings")

local OptionsScreen = class()
OptionsScreen.kind = "options"

local accent = { 0.28, 0.90, 1.0, 1 }
local on_color = { 0.34, 1.0, 0.68, 1 }
local off_color = { 1.0, 0.42, 0.50, 1 }

local sections = {
  {
    id = "audio", title = "MUSIC & SOUND", column = 1, sprite = 10,
    rows = {
      { key = "master_volume", label = "Master volume", kind = "slider", sprite = 10 },
      { key = "music_volume", label = "Music volume", kind = "slider", sprite = 9 },
      { key = "sfx_volume", label = "Sound effects", kind = "slider", sprite = 10 },
      { key = "muted", label = "Mute all audio", kind = "toggle", sprite = 10 },
    },
  },
  {
    id = "overall", title = "SYSTEM", column = 1, sprite = 11,
    rows = {
      { key = "fullscreen", label = "Fullscreen", kind = "toggle", sprite = 11 },
      { key = "deadzone", label = "Controller dead zone", kind = "slider", sprite = 12,
        min = 0.05, max = 0.50 },
      { key = "controls", label = "Keyboard bindings", kind = "action", sprite = 12 },
    },
  },
  {
    id = "gameplay", title = "GAMEPLAY", column = 2, sprite = 5,
    rows = {
      { key = "screen_shake", label = "Screen shake", kind = "toggle", sprite = 5 },
      { key = "hit_flash", label = "Hit flash", kind = "toggle", sprite = 5 },
      { key = "aim_assist", label = "Aim assist", kind = "toggle", sprite = 6 },
      { key = "camera_zoom", label = "Gameplay zoom", kind = "slider", sprite = 11,
        min = 0.75, max = 1.50, step = 0.25 },
      { key = "vibration", label = "Controller vibration", kind = "toggle", sprite = 12 },
    },
  },
}

local function contains(rect, x, y)
  return rect and x >= rect.x and x <= rect.x + rect.w
    and y >= rect.y and y <= rect.y + rect.h
end

local function clamp(value, minimum, maximum)
  return math.max(minimum, math.min(maximum, value))
end

function OptionsScreen:init(app)
  self.app = app
  self.selected = 1
  self.rows = {}
  self.dragging = nil
end

function OptionsScreen:enter() self:_layout() end

function OptionsScreen:_save()
  self.app.save:save(self.app.profile)
  AudioSettings.apply(self.app)
end

function OptionsScreen:_set_value(row, value, persist)
  local options = self.app.profile.options
  if row.kind == "slider" then
    local minimum, maximum = row.min or 0, row.max or 1
    value = clamp(value, minimum, maximum)
    if row.step then
      value = minimum + math.floor(
        (value - minimum) / row.step + 0.5) * row.step
    end
    options[row.key] = math.floor(value * 100 + 0.5) / 100
  elseif row.kind == "toggle" then
    options[row.key] = value == true
    if row.key == "fullscreen" then
      love.window.setFullscreen(options[row.key], "desktop")
    end
  end
  if row.key == "camera_zoom" and self.app.active_run
    and self.app.active_run.camera
  then
    self.app.active_run.camera:set_zoom(options.camera_zoom)
  end
  if persist == false then AudioSettings.apply(self.app) else self:_save() end
end

function OptionsScreen:_activate(row)
  if row.kind == "toggle" then
    self:_set_value(row, not self.app.profile.options[row.key])
  elseif row.kind == "slider" then
    self:_adjust(row, 1)
  elseif row.kind == "action" then
    local ControlsScreen = require("src.ui.screens.controls")
    self.app.states:push(ControlsScreen(self.app))
  end
end

function OptionsScreen:_adjust(row, direction)
  if row.kind == "slider" then
    self:_set_value(row,
      self.app.profile.options[row.key] + direction * (row.step or 0.01))
  elseif row.kind == "toggle" then
    self:_set_value(row, direction > 0)
  end
end

function OptionsScreen:_move(direction)
  self.selected = SpatialNavigation.find(
    self.rows, self.selected, direction, function(row) return row.rect end)
end

function OptionsScreen:_open_admin()
  if not settings.debug.admin.enabled then return end
  local AdminScreen = require("src.ui.screens.admin")
  self.app.states:push(AdminScreen(self.app, { settings_hub = true }))
end

function OptionsScreen:_layout()
  local w, h = love.graphics.getDimensions()
  self.panel = { x = 20, y = 18, w = w - 40, h = h - 36 }
  local tab_y = self.panel.y + 54
  self.options_tab = { x = w / 2 - 190, y = tab_y, w = 180, h = 42 }
  self.admin_tab = { x = w / 2 + 10, y = tab_y, w = 180, h = 42 }

  local compact = h < 680
  local content_top = tab_y + (compact and 54 or 64)
  local row_h = compact and 43 or 50
  local row_step = compact and 47 or 55
  local header_step = compact and 34 or 38
  local section_gap = compact and 10 or 16
  local gutter = 18
  local col_w = (self.panel.w - 56 - gutter) / 2
  local col_x = {
    self.panel.x + 28,
    self.panel.x + 28 + col_w + gutter,
  }
  local cursor_y = { content_top, content_top }
  self.rows = {}
  local focus = 0
  for _, section in ipairs(sections) do
    local column = section.column
    section.header = { x = col_x[column], y = cursor_y[column], w = col_w, h = 30 }
    cursor_y[column] = cursor_y[column] + header_step
    for _, definition in ipairs(section.rows) do
      focus = focus + 1
      local row = {
        key = definition.key, label = definition.label,
        kind = definition.kind, sprite = definition.sprite,
        min = definition.min, max = definition.max, step = definition.step,
        focus = focus,
        rect = { x = col_x[column], y = cursor_y[column], w = col_w, h = row_h },
      }
      row.control = {
        x = row.rect.x + row.rect.w - math.min(132, row.rect.w * 0.34),
        y = row.rect.y + 7,
        w = math.min(116, row.rect.w * 0.30), h = row_h - 14,
      }
      row.label_rect = {
        x = row.rect.x + 52, y = row.rect.y,
        w = math.max(70, row.control.x - row.rect.x - 62), h = row.rect.h,
      }
      self.rows[#self.rows + 1] = row
      cursor_y[column] = cursor_y[column] + row_step
    end
    section.bottom = cursor_y[column]
    cursor_y[column] = cursor_y[column] + section_gap
  end
  self.guide_rect = {
    x = sections[3].header.x,
    y = sections[3].bottom + (compact and 10 or 16),
    w = sections[3].header.w, h = 86,
  }
  self.selected = clamp(self.selected, 1, #self.rows)
end

function OptionsScreen:resize() self:_layout() end

function OptionsScreen:_draw_tab(rect, label, active, icon, category_cell)
  MenuChrome.panel(self.app.assets, rect, { corner = 18, alpha = active and 1 or 0.66 })
  if active then MenuChrome.focus(self.app.assets, rect, { inset = -2, corner = 18 }) end
  if icon then
    self.app.assets:draw_menu_button_icon(icon.col, icon.row,
      rect.x + 8, rect.y + 4, 34, 34,
      { color = { 1, 1, 1, active and 1 or 0.64 } })
  elseif category_cell then
    self.app.assets:draw_menu_category_icon(category_cell,
      rect.x + 8, rect.y + 4, 34,
      { color = { 1, 1, 1, active and 1 or 0.64 } })
  end
  love.graphics.setFont(Fonts.heading(15))
  love.graphics.setColor(active and { 1, 0.82, 0.28, 1 } or { 0.68, 0.68, 0.78, 1 })
  love.graphics.printf(label, rect.x + 46, rect.y + 12, rect.w - 56, "center")
end

function OptionsScreen:_draw_section(section)
  self.app.assets:draw_menu_category_icon(section.sprite,
    section.header.x, section.header.y - 2, 30, { color = { 1, 1, 1, 0.92 } })
  love.graphics.setColor(0.42, 0.94, 1.0, 1)
  love.graphics.setFont(Fonts.heading(16))
  love.graphics.print(section.title, section.header.x + 38, section.header.y + 5)
end

function OptionsScreen:_draw_row(row)
  local selected = row.focus == self.selected
  MenuChrome.panel(self.app.assets, row.rect, {
    corner = 18, alpha = selected and 1 or 0.70,
  })
  if selected then MenuChrome.focus(self.app.assets, row.rect, { corner = 19 }) end
  self.app.assets:draw_menu_category_icon(row.sprite,
    row.rect.x + 8, row.rect.y + 5, row.rect.h - 10,
    { color = { 1, 1, 1, selected and 1 or 0.68 } })
  love.graphics.setFont(Fonts.body(row.rect.w < 400 and 14 or 16))
  love.graphics.setColor(selected and { 1.0, 0.86, 0.34, 1 }
    or settings.ui.text_color)
  love.graphics.printf(row.label, row.label_rect.x,
    row.rect.y + (row.rect.h - Fonts.body(16):getHeight()) / 2,
    row.label_rect.w, "left")

  local options = self.app.profile.options
  local value, color
  if row.kind == "slider" then
    value = math.floor(options[row.key] * 100 + 0.5) .. "%"
    color = accent
  elseif row.kind == "toggle" then
    value = options[row.key] and "ON" or "OFF"
    color = options[row.key] and on_color or off_color
  else
    value, color = "OPEN", accent
  end
  love.graphics.setFont(Fonts.heading(15))
  love.graphics.setColor(color)
  love.graphics.printf(value, row.control.x, row.control.y + 7,
    row.control.w, "right")
end

function OptionsScreen:draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, w, h)
  MenuChrome.panel(self.app.assets, self.panel, { corner = 48, alpha = 0.98 })
  love.graphics.setFont(Fonts.heading(30))
  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.printf("SETTINGS", 0, self.panel.y + 13, w, "center")
  self:_draw_tab(self.options_tab, "OPTIONS", true, { col = 4, row = 1 })
  if settings.debug.admin.enabled then
    self:_draw_tab(self.admin_tab, "ADMIN", false, nil, 1)
  end
  for _, section in ipairs(sections) do self:_draw_section(section) end
  for _, row in ipairs(self.rows) do self:_draw_row(row) end

  MenuChrome.panel(self.app.assets, self.guide_rect, { corner = 24, alpha = 0.72 })
  love.graphics.setFont(Fonts.body(13))
  love.graphics.setColor(0.74, 0.76, 0.86, 1)
  love.graphics.printf("D-PAD MOVES IN FOUR DIRECTIONS",
    self.guide_rect.x + 12, self.guide_rect.y + 13,
    self.guide_rect.w - 24, "center")
  Hints.draw({
    { symbol = "cross", label = "Use / +" },
    { symbol = "square", label = "-" },
    { symbol = "triangle", label = "Admin" },
    { symbol = "circle", label = "Back" },
  }, self.guide_rect.y + 55, self.guide_rect.w,
    { x = self.guide_rect.x, font_size = 11, glyph_size = 15, gap = 10 })
end

function OptionsScreen:keypressed(key)
  if key == "escape" then self.app.states:pop() return true end
  local directions = {
    up = "up", w = "up", down = "down", s = "down",
    left = "left", a = "left", right = "right", d = "right",
  }
  if directions[key] then self:_move(directions[key]) return true end
  if key == "-" or key == "kp-" then
    self:_adjust(self.rows[self.selected], -1) return true
  elseif key == "=" or key == "+" or key == "kp+" then
    self:_adjust(self.rows[self.selected], 1) return true
  elseif key == "return" or key == "space" then
    self:_activate(self.rows[self.selected]) return true
  elseif key == "]" and settings.debug.admin.enabled then
    self:_open_admin() return true
  end
  return false
end

function OptionsScreen:gamepadpressed(_, button)
  if button == "b" then self.app.states:pop() return true end
  local directions = {
    dpup = "up", dpdown = "down", dpleft = "left", dpright = "right",
  }
  if directions[button] then self:_move(directions[button]) return true end
  if button == "a" then self:_activate(self.rows[self.selected]) return true end
  if button == "x" or button == "leftshoulder" then
    self:_adjust(self.rows[self.selected], -1) return true
  end
  if button == "rightshoulder" then
    self:_adjust(self.rows[self.selected], 1) return true
  end
  if button == "y" and settings.debug.admin.enabled then
    self:_open_admin() return true
  end
  return false
end

function OptionsScreen:mousemoved(x, y)
  for _, row in ipairs(self.rows) do
    if contains(row.rect, x, y) then self.selected = row.focus end
  end
  if self.dragging then
    local row = self.dragging
    local fraction = clamp((x - row.control.x) / row.control.w, 0, 1)
    local minimum, maximum = row.min or 0, row.max or 1
    self:_set_value(row, minimum + fraction * (maximum - minimum), false)
  end
end

function OptionsScreen:mousepressed(x, y, button)
  if button ~= 1 then return false end
  if contains(self.admin_tab, x, y) and settings.debug.admin.enabled then
    self:_open_admin() return true
  end
  for _, row in ipairs(self.rows) do
    if contains(row.rect, x, y) then
      self.selected = row.focus
      if row.kind == "slider" then
        self.dragging = row
        self:mousemoved(x, y)
      else
        self:_activate(row)
      end
      return true
    end
  end
  return false
end

function OptionsScreen:mousereleased(_, _, button)
  if button == 1 and self.dragging then
    self.dragging = nil
    self:_save()
    return true
  end
  return false
end

return OptionsScreen
