local class = require("src.core.class")
local AudioSettings = require("src.audio.audio_settings")
local Fonts = require("src.ui.fonts")
local Hints = require("src.ui.controller_hints")
local Icons = require("src.ui.icons")
local settings = require("src.config.settings")

local OptionsScreen = class()
OptionsScreen.kind = "options"

local accent = { 0.28, 0.90, 1.0, 1 }
local on_color = { 0.34, 1.0, 0.68, 1 }
local off_color = { 1.0, 0.42, 0.50, 1 }

local sections = {
  {
    id = "audio", title = "MUSIC & SOUND", column = 1,
    rows = {
      { key = "master_volume", label = "Master volume", kind = "slider", icon = "speaker" },
      { key = "music_volume", label = "Music volume", kind = "slider", icon = "music" },
      { key = "sfx_volume", label = "Sound effects", kind = "slider", icon = "wave" },
      { key = "muted", label = "Mute all audio", kind = "toggle", icon = "speaker_off" },
    },
  },
  {
    id = "overall", title = "OVERALL SETTINGS", column = 1,
    rows = {
      { key = "fullscreen", label = "Fullscreen", kind = "toggle", icon = "display" },
      { key = "deadzone", label = "Controller dead zone", kind = "slider", icon = "controller",
        min = 0.05, max = 0.50 },
      { key = "controls", label = "Keyboard bindings", kind = "action", icon = "controller" },
    },
  },
  {
    id = "gameplay", title = "GAMEPLAY", column = 2,
    rows = {
      { key = "screen_shake", label = "Screen shake", kind = "toggle", icon = "shake" },
      { key = "hit_flash", label = "Hit flash", kind = "toggle", icon = "flash" },
      { key = "aim_assist", label = "Aim assist", kind = "toggle", icon = "target" },
      { key = "camera_zoom", label = "Gameplay zoom", kind = "slider", icon = "zoom",
        min = 0.75, max = 1.50, step = 0.25 },
      { key = "vibration", label = "Controller vibration", kind = "toggle", icon = "vibration" },
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

function OptionsScreen:_open_admin()
  if not settings.debug.admin.enabled then return end
  local AdminScreen = require("src.ui.screens.admin")
  self.app.states:push(AdminScreen(self.app, { settings_hub = true }))
end

function OptionsScreen:_layout()
  local w, h = love.graphics.getDimensions()
  self.panel = { x = 24, y = 20, w = w - 48, h = h - 40 }
  local tab_y = self.panel.y + 56
  self.options_tab = { x = w / 2 - 190, y = tab_y, w = 180, h = 40 }
  self.admin_tab = { x = w / 2 + 10, y = tab_y, w = 180, h = 40 }

  local compact = h < 680
  local content_top = tab_y + (compact and 52 or 62)
  local row_h = compact and 42 or 48
  local row_step = compact and 46 or 54
  local header_step = compact and 30 or 34
  local section_gap = compact and 10 or 16
  self.layout_metrics = {
    row_step = row_step,
    header_step = header_step,
    guide_gap = compact and 10 or 18,
  }
  local gutter = 18
  local col_w = (self.panel.w - 52 - gutter) / 2
  local col_x = {
    self.panel.x + 26,
    self.panel.x + 26 + col_w + gutter,
  }
  local cursor_y = { content_top, content_top }
  self.rows = {}
  local focus = 0
  for _, section in ipairs(sections) do
    local column = section.column
    section.header = { x = col_x[column], y = cursor_y[column], w = col_w, h = 28 }
    cursor_y[column] = cursor_y[column] + header_step
    for _, definition in ipairs(section.rows) do
      focus = focus + 1
      local row = {
        key = definition.key, label = definition.label,
        kind = definition.kind, icon = definition.icon,
        min = definition.min, max = definition.max, step = definition.step,
        focus = focus,
        rect = { x = col_x[column], y = cursor_y[column], w = col_w, h = row_h },
      }
      row.control = {
        x = row.rect.x + row.rect.w - math.min(190, row.rect.w * 0.45),
        y = row.rect.y + (row_h - 28) / 2,
        w = math.min(170, row.rect.w * 0.40),
        h = 28,
      }
      row.label_rect = {
        x = row.rect.x + 42,
        y = row.rect.y,
        w = math.max(70, row.control.x - row.rect.x - 52),
        h = row.rect.h,
      }
      self.rows[#self.rows + 1] = row
      cursor_y[column] = cursor_y[column] + row_step
    end
    section.bottom = cursor_y[column]
    cursor_y[column] = cursor_y[column] + section_gap
  end
  self.guide_rect = {
    x = sections[3].header.x,
    y = sections[3].bottom + self.layout_metrics.guide_gap,
    w = sections[3].header.w,
    h = 118,
  }
  self.selected = clamp(self.selected, 1, #self.rows)
end

function OptionsScreen:resize() self:_layout() end

local function draw_tab(rect, label, selected, glyph)
  love.graphics.setColor(selected and { 0.16, 0.14, 0.25, 1 }
    or { 0.075, 0.065, 0.12, 0.95 })
  love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 6, 6)
  love.graphics.setColor(selected and accent or { 0.36, 0.33, 0.48, 1 })
  love.graphics.setLineWidth(selected and 2 or 1)
  love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 6, 6)
  Icons.draw(glyph, rect.x + 25, rect.y + 20, 18,
    selected and accent or { 0.66, 0.64, 0.75, 1 })
  love.graphics.setFont(Fonts.get(16))
  love.graphics.setColor(settings.ui.text_color)
  love.graphics.printf(label, rect.x + 42, rect.y + 12, rect.w - 52, "center")
  love.graphics.setLineWidth(1)
end

function OptionsScreen:_draw_section(section)
  local header = section.header
  love.graphics.setColor(0.42, 0.94, 1.0, 1)
  love.graphics.setFont(Fonts.get(17))
  love.graphics.print(section.title, header.x, header.y)
  love.graphics.setColor(0.24, 0.22, 0.34, 1)
  love.graphics.rectangle("fill", header.x, header.y + 24, header.w, 1)
end

function OptionsScreen:_draw_row(row)
  local selected = row.focus == self.selected
  local rect = row.rect
  love.graphics.setColor(selected and { 0.14, 0.125, 0.22, 1 }
    or { 0.085, 0.074, 0.14, 0.96 })
  love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 6, 6)
  love.graphics.setColor(selected and accent or { 0.24, 0.22, 0.34, 1 })
  love.graphics.setLineWidth(selected and 2 or 1)
  love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 6, 6)
  Icons.draw(row.icon, rect.x + 22, rect.y + 24, 20,
    selected and accent or { 0.68, 0.66, 0.78, 1 })
  local label_font = Fonts.get(rect.w < 400 and 13 or 15)
  love.graphics.setFont(label_font)
  love.graphics.setColor(settings.ui.text_color)
  local _, wrapped = label_font:getWrap(row.label, row.label_rect.w)
  local line_count = math.min(2, #wrapped)
  local label_h = line_count * label_font:getHeight()
  love.graphics.printf(row.label, row.label_rect.x,
    rect.y + (rect.h - label_h) / 2, row.label_rect.w, "left")

  local options = self.app.profile.options
  local control = row.control
  if row.kind == "slider" then
    local minimum, maximum = row.min or 0, row.max or 1
    local fraction = (options[row.key] - minimum) / (maximum - minimum)
    local percent = math.floor(options[row.key] * 100 + 0.5)
    local track_x, track_w = control.x, control.w - 44
    love.graphics.setColor(0.04, 0.035, 0.08, 1)
    love.graphics.rectangle("fill", track_x, control.y + 11, track_w, 7, 3, 3)
    love.graphics.setColor(accent)
    love.graphics.rectangle("fill", track_x, control.y + 11,
      track_w * fraction, 7, 3, 3)
    love.graphics.circle("fill", track_x + track_w * fraction, control.y + 14.5, 7)
    love.graphics.setFont(Fonts.get(14))
    love.graphics.setColor(0.96, 0.80, 0.26, 1)
    love.graphics.printf(percent .. "%", track_x + track_w + 8,
      control.y + 6, 38, "right")
  elseif row.kind == "toggle" then
    local value = options[row.key]
    local color = value and on_color or off_color
    love.graphics.setColor(color[1], color[2], color[3], 0.13)
    love.graphics.rectangle("fill", control.x + control.w - 86, control.y,
      86, 28, 14, 14)
    love.graphics.setColor(color)
    love.graphics.rectangle("line", control.x + control.w - 86, control.y,
      86, 28, 14, 14)
    love.graphics.circle("fill",
      value and control.x + control.w - 15 or control.x + control.w - 71,
      control.y + 14, 8)
    love.graphics.setFont(Fonts.get(14))
    love.graphics.printf(value and "ON" or "OFF",
      control.x + control.w - 70, control.y + 7, 54, "center")
  else
    love.graphics.setColor(accent)
    love.graphics.setFont(Fonts.get(14))
    love.graphics.printf("OPEN  >", control.x, control.y + 7, control.w, "right")
  end
  love.graphics.setLineWidth(1)
end

function OptionsScreen:draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.setColor(0.075, 0.065, 0.12, 0.99)
  love.graphics.rectangle("fill", self.panel.x, self.panel.y,
    self.panel.w, self.panel.h, 10, 10)
  love.graphics.setColor(settings.ui.button.border)
  love.graphics.rectangle("line", self.panel.x, self.panel.y,
    self.panel.w, self.panel.h, 10, 10)
  love.graphics.setFont(Fonts.get(30))
  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.printf("SETTINGS", 0, self.panel.y + 14, w, "center")
  draw_tab(self.options_tab, "OPTIONS", true, "display")
  if settings.debug.admin.enabled then
    draw_tab(self.admin_tab, "ADMIN", false, "admin")
  end
  for _, section in ipairs(sections) do self:_draw_section(section) end
  for _, row in ipairs(self.rows) do self:_draw_row(row) end

  love.graphics.setColor(0.08, 0.07, 0.13, 0.92)
  local guide = self.guide_rect
  local guide_y = guide.y
  love.graphics.rectangle("fill", guide.x, guide_y, guide.w, guide.h, 7, 7)
  love.graphics.setColor(0.76, 0.74, 0.84, 1)
  love.graphics.setFont(Fonts.get(14))
  love.graphics.print("PLAYSTATION MENU GUIDE", guide.x + 16, guide_y + 12)
  Hints.draw({
    { symbol = "dpad", label = "Move / adjust" },
    { symbol = "cross", label = "Select" },
    { symbol = "circle", label = "Back" },
  }, guide_y + 50, guide.w,
    { font_size = 13, gap = 16, x = guide.x })
  love.graphics.setFont(Fonts.get(13))
  love.graphics.setColor(0.66, 0.64, 0.74, 1)
  love.graphics.printf("Volumes move in exact 1% steps. Click or drag any slider.",
    guide.x + 16, guide_y + 88, guide.w - 32, "center")
end

function OptionsScreen:keypressed(key)
  if key == "escape" then self.app.states:pop() return true end
  if key == "up" or key == "w" then
    self.selected = ((self.selected - 2) % #self.rows) + 1
    return true
  elseif key == "down" or key == "s" then
    self.selected = (self.selected % #self.rows) + 1
    return true
  elseif key == "left" or key == "a" then
    self:_adjust(self.rows[self.selected], -1)
    return true
  elseif key == "right" or key == "d" then
    self:_adjust(self.rows[self.selected], 1)
    return true
  elseif key == "return" or key == "space" then
    self:_activate(self.rows[self.selected])
    return true
  elseif key == "]" and settings.debug.admin.enabled then
    self:_open_admin()
    return true
  end
  return false
end

function OptionsScreen:gamepadpressed(_, button)
  if button == "b" then self.app.states:pop() return true end
  if button == "a" then self:_activate(self.rows[self.selected]) return true end
  if button == "dpup" then return self:keypressed("up") end
  if button == "dpdown" then return self:keypressed("down") end
  if button == "dpleft" then return self:keypressed("left") end
  if button == "dpright" then return self:keypressed("right") end
  if button == "rightshoulder" and settings.debug.admin.enabled then
    self:_open_admin()
    return true
  end
  return false
end

function OptionsScreen:mousemoved(x, y)
  for _, row in ipairs(self.rows) do
    if contains(row.rect, x, y) then self.selected = row.focus end
  end
  if self.dragging then
    local row = self.dragging
    local track_w = row.control.w - 44
    local fraction = clamp((x - row.control.x) / track_w, 0, 1)
    local minimum, maximum = row.min or 0, row.max or 1
    self:_set_value(row, minimum + fraction * (maximum - minimum), false)
  end
end

function OptionsScreen:mousepressed(x, y, button)
  if button ~= 1 then return false end
  if contains(self.admin_tab, x, y) and settings.debug.admin.enabled then
    self:_open_admin()
    return true
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
