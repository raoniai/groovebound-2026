local class = require("src.core.class")
local AudioSettings = require("src.audio.audio_settings")
local DifficultyProfiles = require("src.config.difficulty_profiles")
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
    id = "audio", title = "MUSIC & SOUND", column = 1, sprite = 13,
    rows = {
      { key = "master_volume", label = "Master volume", kind = "slider", sprite = 1 },
      { key = "music_volume", label = "Music volume", kind = "slider", sprite = 2 },
      { key = "sfx_volume", label = "Sound effects", kind = "slider", sprite = 3 },
      { key = "muted", label = "Mute all audio", kind = "toggle", sprite = 4 },
    },
  },
  {
    id = "overall", title = "SYSTEM", column = 1, sprite = 14,
    rows = {
      { key = "fullscreen", label = "Fullscreen", kind = "toggle", sprite = 5 },
      { key = "deadzone", label = "Controller dead zone", kind = "slider", sprite = 6,
        min = 0.05, max = 0.50 },
      { key = "vibration", label = "Controller vibration", kind = "toggle", sprite = 12 },
      { key = "controls", label = "Keyboard bindings", kind = "action", sprite = 7 },
    },
  },
  {
    id = "gameplay", title = "GAMEPLAY", column = 2, sprite = 15,
    rows = {
      { key = "difficulty", label = "Difficulty", kind = "choice", sprite = 16 },
      { key = "screen_shake", label = "Screen shake", kind = "toggle", sprite = 8 },
      { key = "hit_flash", label = "Hit flash", kind = "toggle", sprite = 9 },
      { key = "aim_assist", label = "Aim assist", kind = "toggle", sprite = 10 },
      { key = "automatic_level_up", label = "Automatic level-up menu",
        kind = "toggle", sprite = 16 },
      { key = "camera_zoom", label = "Gameplay zoom", kind = "slider", sprite = 11,
        min = 0.75, max = 1.50, step = 0.25 },
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
  self.hold = nil
end

function OptionsScreen:enter() self:_layout() end

function OptionsScreen:_save()
  self.app.save:save(self.app.profile)
  AudioSettings.apply(self.app)
end

function OptionsScreen:_set_value(row, value, persist)
  local options = self.app.profile.options
  local previous = options[row.key]
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
  elseif row.kind == "choice" then
    options[row.key] = DifficultyProfiles.resolve(value)
  end
  if row.key == "camera_zoom" and self.app.active_run
    and self.app.active_run.camera
  then
    self.app.active_run.camera:set_zoom(options.camera_zoom)
  end
  if row.key == "difficulty" and self.app.active_run
    and self.app.active_run.combat
    and self.app.active_run.combat.set_difficulty
  then
    self.app.active_run.combat:set_difficulty(options.difficulty, previous)
  end
  if persist == false then AudioSettings.apply(self.app) else self:_save() end
end

function OptionsScreen:_activate(row)
  if row.kind == "toggle" then
    self:_set_value(row, not self.app.profile.options[row.key])
  elseif row.kind == "slider" then
    self:_adjust(row, 1)
  elseif row.kind == "choice" then
    self:_adjust(row, 1)
  elseif row.kind == "action" then
    local ControlsScreen = require("src.ui.screens.controls")
    self.app.states:push(ControlsScreen(self.app))
  end
end

function OptionsScreen:_adjust(row, direction, persist)
  if row.kind == "slider" then
    self:_set_value(row,
      self.app.profile.options[row.key] + direction * (row.step or 0.01), persist)
  elseif row.kind == "toggle" then
    self:_set_value(row, direction > 0, persist)
  elseif row.kind == "choice" then
    self:_set_value(row, DifficultyProfiles.step(
      self.app.profile.options[row.key], direction), persist)
  end
end

function OptionsScreen:_begin_hold(row, direction, source, control)
  if not row or row.kind ~= "slider" then return false end
  if self.hold and self.hold.source == source
    and self.hold.control == control and self.hold.row == row
  then
    return true
  end
  if self.hold then self:_end_hold(true) end
  self.hold = {
    row = row, direction = direction, source = source, control = control,
    elapsed = 0, accumulator = 0,
  }
  self:_adjust(row, direction, false)
  return true
end

function OptionsScreen:_end_hold(persist)
  if not self.hold then return false end
  self.hold = nil
  if persist ~= false then self:_save() end
  return true
end

function OptionsScreen:update(dt)
  local hold = self.hold
  if not hold then return end
  hold.elapsed = hold.elapsed + dt
  if hold.elapsed < 0.26 then return end
  hold.accumulator = hold.accumulator + dt
  local interval = hold.elapsed > 1.0 and 0.028 or 0.055
  while hold.accumulator >= interval do
    hold.accumulator = hold.accumulator - interval
    self:_adjust(hold.row, hold.direction, false)
  end
end

function OptionsScreen:exit()
  if self.dragging then self.dragging = nil self:_save() end
  self:_end_hold(true)
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
  local panel_w = math.min(980, w - 48)
  local panel_h = math.min(530, h - 36)
  self.panel = {
    x = (w - panel_w) / 2, y = (h - panel_h) / 2,
    w = panel_w, h = panel_h,
  }
  local tab_y = self.panel.y + 54
  self.options_tab = { x = w / 2 - 174, y = tab_y, w = 164, h = 40 }
  self.admin_tab = { x = w / 2 + 10, y = tab_y, w = 164, h = 40 }

  local compact = h < 680 or panel_w < 820
  local content_top = tab_y + (compact and 50 or 58)
  local row_h = compact and 39 or 45
  local row_step = compact and 42 or 48
  local header_step = compact and 28 or 32
  local section_gap = compact and 8 or 10
  local gutter = compact and 12 or 18
  local col_w = (self.panel.w - 48 - gutter) / 2
  local col_x = {
    self.panel.x + 24,
    self.panel.x + 24 + col_w + gutter,
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
        x = row.rect.x + row.rect.w - math.min(174, row.rect.w * 0.44) - 8,
        y = row.rect.y + 4,
        w = math.min(174, row.rect.w * 0.44), h = row_h - 8,
      }
      row.label_rect = {
        x = row.rect.x + 46, y = row.rect.y,
        w = math.max(62, row.control.x - row.rect.x - 54), h = row.rect.h,
      }
      if row.kind == "slider" or row.kind == "choice" then
        row.minus_rect = {
          x = row.control.x, y = row.rect.y + 6,
          w = 24, h = row.rect.h - 12,
        }
        row.plus_rect = {
          x = row.control.x + row.control.w - 24, y = row.rect.y + 6,
          w = 24, h = row.rect.h - 12,
        }
        row.track = {
          x = row.control.x + 29, y = row.rect.y + row.rect.h - 12,
          w = row.control.w - 58, h = 7,
        }
        row.value_rect = {
          x = row.track.x, y = row.rect.y + 4,
          w = row.track.w, h = row.rect.h - 16,
        }
        if row.kind == "choice" then
          row.track = nil
          row.value_rect = {
            x = row.control.x + 25, y = row.rect.y + 4,
            w = row.control.w - 50, h = row.rect.h - 8,
          }
        end
      end
      self.rows[#self.rows + 1] = row
      cursor_y[column] = cursor_y[column] + row_step
    end
    section.bottom = cursor_y[column]
    cursor_y[column] = cursor_y[column] + section_gap
  end
  self.guide_rect = {
    x = sections[3].header.x,
    y = sections[3].bottom + (compact and 8 or 12),
    w = sections[3].header.w, h = compact and 70 or 78,
  }
  self.selected = clamp(self.selected, 1, #self.rows)
end

function OptionsScreen:resize() self:_layout() end

function OptionsScreen:_draw_tab(rect, label, active, icon_cell, menu_icon)
  MenuChrome.panel(self.app.assets, rect, { corner = 18, alpha = active and 1 or 0.66 })
  if active then MenuChrome.focus(self.app.assets, rect, { inset = -2, corner = 18 }) end
  if icon_cell then
    local draw = menu_icon and self.app.assets.draw_menu_stat_icon
      or self.app.assets.draw_settings_icon
    draw(self.app.assets, icon_cell, rect.x + 8, rect.y + 4, 34,
      { color = { 1, 1, 1, active and 1 or 0.64 } })
  end
  love.graphics.setFont(Fonts.heading(15))
  love.graphics.setColor(active and { 1, 0.82, 0.28, 1 } or { 0.68, 0.68, 0.78, 1 })
  love.graphics.printf(label, rect.x + 46, rect.y + 12, rect.w - 56, "center")
end

function OptionsScreen:_draw_section(section)
  self.app.assets:draw_settings_icon(section.sprite,
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
  self.app.assets:draw_settings_icon(row.sprite,
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
  elseif row.kind == "choice" then
    value = DifficultyProfiles.label(options[row.key])
    color = accent
  else
    value, color = "OPEN", accent
  end
  love.graphics.setFont(Fonts.heading(14))
  love.graphics.setColor(color)
  if row.kind == "slider" then
    local minimum, maximum = row.min or 0, row.max or 1
    local fraction = clamp((options[row.key] - minimum) / (maximum - minimum), 0, 1)
    love.graphics.printf(value, row.value_rect.x, row.value_rect.y,
      row.value_rect.w, "center")

    love.graphics.setColor(0.015, 0.045, 0.075, 0.98)
    love.graphics.rectangle("fill", row.track.x, row.track.y,
      row.track.w, row.track.h, 3, 3)
    love.graphics.setColor(0.22, 0.82, 0.96, 0.92)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", row.track.x, row.track.y,
      row.track.w, row.track.h, 3, 3)
    local fill_w = math.max(2, row.track.w * fraction)
    love.graphics.rectangle("fill", row.track.x + 1, row.track.y + 1,
      math.max(1, fill_w - 2), row.track.h - 2, 2, 2)
    local thumb_x = row.track.x + row.track.w * fraction
    love.graphics.setColor(0.82, 0.98, 1.0, 1)
    love.graphics.rectangle("fill", thumb_x - 2, row.track.y - 3,
      4, row.track.h + 6, 2, 2)

    love.graphics.setFont(Fonts.heading(17))
    love.graphics.setColor(0.58, 0.94, 1.0, 1)
    love.graphics.printf("−", row.minus_rect.x, row.minus_rect.y + 1,
      row.minus_rect.w, "center")
    love.graphics.printf("+", row.plus_rect.x, row.plus_rect.y + 1,
      row.plus_rect.w, "center")
  elseif row.kind == "choice" then
    love.graphics.printf(value, row.value_rect.x, row.value_rect.y + 5,
      row.value_rect.w, "center")
    love.graphics.setFont(Fonts.heading(17))
    love.graphics.setColor(0.58, 0.94, 1.0, 1)
    love.graphics.printf("‹", row.minus_rect.x, row.minus_rect.y + 1,
      row.minus_rect.w, "center")
    love.graphics.printf("›", row.plus_rect.x, row.plus_rect.y + 1,
      row.plus_rect.w, "center")
  else
    love.graphics.printf(value, row.control.x, row.control.y + 5,
      row.control.w, "right")
  end
end

function OptionsScreen:draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, w, h)
  MenuChrome.panel(self.app.assets, self.panel, { corner = 48, alpha = 0.98 })
  love.graphics.setFont(Fonts.heading(30))
  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.printf("SETTINGS", 0, self.panel.y + 13, w, "center")
  self:_draw_tab(self.options_tab, "OPTIONS", true, 4, true)
  if settings.debug.admin.enabled then
    self:_draw_tab(self.admin_tab, "ADMIN", false, 14)
  end
  for _, section in ipairs(sections) do self:_draw_section(section) end
  for _, row in ipairs(self.rows) do self:_draw_row(row) end

  MenuChrome.panel(self.app.assets, self.guide_rect, { corner = 24, alpha = 0.72 })
  love.graphics.setFont(Fonts.body(13))
  love.graphics.setColor(0.74, 0.76, 0.86, 1)
  love.graphics.printf("HOLD TO ADJUST  •  DRAG THE COLOURED BAR",
    self.guide_rect.x + 12, self.guide_rect.y + 10,
    self.guide_rect.w - 24, "center")
  Hints.draw({
    { symbol = "dpad", label = "Move" },
    { symbol = "square", label = "Hold -" },
    { symbol = "options", label = "R1 Hold +" },
    { symbol = "triangle", label = "Admin" },
    { symbol = "circle", label = "Back" },
  }, self.guide_rect.y + self.guide_rect.h - 22, self.guide_rect.w,
    { x = self.guide_rect.x, font_size = 10, glyph_size = 14, gap = 8 })
end

function OptionsScreen:keypressed(key)
  if key == "escape" then self.app.states:pop() return true end
  local directions = {
    up = "up", w = "up", down = "down", s = "down",
    left = "left", a = "left", right = "right", d = "right",
  }
  if directions[key] then self:_move(directions[key]) return true end
  if key == "-" or key == "kp-" then
    if self.rows[self.selected].kind == "choice" then
      self:_adjust(self.rows[self.selected], -1) return true
    end
    return self:_begin_hold(self.rows[self.selected], -1, "keyboard", key)
  elseif key == "=" or key == "+" or key == "kp+" then
    if self.rows[self.selected].kind == "choice" then
      self:_adjust(self.rows[self.selected], 1) return true
    end
    return self:_begin_hold(self.rows[self.selected], 1, "keyboard", key)
  elseif key == "return" or key == "space" then
    self:_activate(self.rows[self.selected]) return true
  elseif key == "]" and settings.debug.admin.enabled then
    self:_open_admin() return true
  end
  return false
end

function OptionsScreen:keyreleased(key)
  if self.hold and self.hold.source == "keyboard"
    and self.hold.control == key
  then
    return self:_end_hold(true)
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
    if self.rows[self.selected].kind == "choice" then
      self:_adjust(self.rows[self.selected], -1) return true
    end
    return self:_begin_hold(self.rows[self.selected], -1, "gamepad", button)
  end
  if button == "rightshoulder" then
    if self.rows[self.selected].kind == "choice" then
      self:_adjust(self.rows[self.selected], 1) return true
    end
    return self:_begin_hold(self.rows[self.selected], 1, "gamepad", button)
  end
  if button == "y" and settings.debug.admin.enabled then
    self:_open_admin() return true
  end
  return false
end

function OptionsScreen:gamepadreleased(_, button)
  if self.hold and self.hold.source == "gamepad"
    and self.hold.control == button
  then
    return self:_end_hold(true)
  end
  return false
end

function OptionsScreen:mousemoved(x, y)
  for _, row in ipairs(self.rows) do
    if contains(row.rect, x, y) then self.selected = row.focus end
  end
  if self.dragging then
    local row = self.dragging
    local fraction = clamp((x - row.track.x) / row.track.w, 0, 1)
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
      if row.kind == "slider" or row.kind == "choice" then
        if contains(row.minus_rect, x, y) then
          if row.kind == "choice" then self:_adjust(row, -1) return true end
          return self:_begin_hold(row, -1, "mouse", "minus")
        elseif contains(row.plus_rect, x, y) then
          if row.kind == "choice" then self:_adjust(row, 1) return true end
          return self:_begin_hold(row, 1, "mouse", "plus")
        elseif row.kind == "slider" and contains(row.track, x, y) then
          self.dragging = row
          self:mousemoved(x, y)
        elseif row.kind == "choice" then
          self:_adjust(row, 1)
        end
      else
        self:_activate(row)
      end
      return true
    end
  end
  return false
end

function OptionsScreen:mousereleased(_, _, button)
  if button == 1 then
    local handled = false
    if self.dragging then
      self.dragging = nil
      self:_save()
      handled = true
    end
    if self.hold and self.hold.source == "mouse" then
      self:_end_hold(true)
      handled = true
    end
    return handled
  end
  return false
end

return OptionsScreen
