-- Visual, segmented development dashboard. Every control still mutates the
-- same bounded Tuning model; categories and graphics are presentation only.

local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")

local AdminScreen = class()
AdminScreen.opaque = false

local categories = {
  { id = "All", label = "Overview", color = { 0.96, 0.76, 0.22, 1 }, glyph = "grid" },
  { id = "Simulation", label = "Simulation", color = { 0.40, 0.72, 1.0, 1 }, glyph = "clock" },
  { id = "Run", label = "Run & Stages", color = { 0.22, 0.92, 1.0, 1 }, glyph = "wave" },
  { id = "Player", label = "Player", color = { 0.34, 1.0, 0.68, 1 }, glyph = "person" },
  { id = "Combat", label = "Combat", color = { 1.0, 0.38, 0.42, 1 }, glyph = "burst" },
  { id = "Projectiles", label = "Bullets", color = { 1.0, 0.62, 0.20, 1 }, glyph = "arrow" },
  { id = "Enemies", label = "Enemies", color = { 0.92, 0.28, 0.68, 1 }, glyph = "enemy" },
  { id = "Rewards", label = "Rewards", color = { 0.42, 0.94, 0.84, 1 }, glyph = "gem" },
  { id = "Groove", label = "Groove", color = { 0.72, 0.42, 1.0, 1 }, glyph = "wave" },
}

local function contains(rect, x, y)
  return rect
    and x >= rect.x and x <= rect.x + rect.w
    and y >= rect.y and y <= rect.y + rect.h
end

local function draw_glyph(kind, x, y, size, color)
  love.graphics.setColor(color)
  love.graphics.setLineWidth(2)
  local r = size / 2
  if kind == "grid" then
    for row = -1, 0 do
      for col = -1, 0 do
        love.graphics.rectangle("line", x + col * r + 2, y + row * r + 2, r - 4, r - 4, 2, 2)
      end
    end
  elseif kind == "clock" then
    love.graphics.circle("line", x, y, r - 2)
    love.graphics.line(x, y, x, y - r * 0.55)
    love.graphics.line(x, y, x + r * 0.42, y)
  elseif kind == "person" then
    love.graphics.circle("line", x, y - r * 0.45, r * 0.28)
    love.graphics.arc("line", "open", x, y + r * 0.55, r * 0.62, math.pi, math.pi * 2)
  elseif kind == "burst" then
    love.graphics.circle("line", x, y, r * 0.35)
    for index = 0, 7 do
      local angle = index / 8 * math.pi * 2
      love.graphics.line(
        x + math.cos(angle) * r * 0.52, y + math.sin(angle) * r * 0.52,
        x + math.cos(angle) * r, y + math.sin(angle) * r)
    end
  elseif kind == "arrow" then
    love.graphics.line(x - r, y + r * 0.45, x + r, y - r * 0.45)
    love.graphics.line(x + r, y - r * 0.45, x + r * 0.35, y - r * 0.55)
    love.graphics.line(x + r, y - r * 0.45, x + r * 0.62, y + r * 0.15)
  elseif kind == "enemy" then
    love.graphics.polygon("line",
      x - r, y + r, x - r * 0.7, y - r * 0.55, x, y - r, x + r * 0.7, y - r * 0.55, x + r, y + r)
    love.graphics.circle("fill", x - r * 0.35, y, 2)
    love.graphics.circle("fill", x + r * 0.35, y, 2)
  elseif kind == "gem" then
    love.graphics.polygon("line", x, y - r, x + r, y, x, y + r, x - r, y)
  else
    love.graphics.line(x - r, y, x - r * 0.5, y - r * 0.55, x, y + r * 0.45,
      x + r * 0.5, y - r * 0.55, x + r, y)
  end
  love.graphics.setLineWidth(1)
end

function AdminScreen:init(app)
  self.app = app
  self.category_index = 1
  self.selected = 1
  self.scroll = 1
  self.rows = {}
  self.category_rects = {}
end

function AdminScreen:enter()
  self.app.log.info("state", "Admin controls opened")
  self:_refresh()
  self:_layout()
end

function AdminScreen:exit()
  self.app.log.info("state", "Admin controls closed")
end

function AdminScreen:_refresh()
  local category = categories[self.category_index].id
  self.filtered = {}
  for _, definition in ipairs(self.app.tuning:list()) do
    if category == "All" or definition.category == category then
      self.filtered[#self.filtered + 1] = definition
    end
  end
  self.selected = math.max(1, math.min(self.selected, math.max(1, #self.filtered)))
  self:_keep_selected_visible()
end

function AdminScreen:_layout()
  local w, h = love.graphics.getDimensions()
  self.panel = {
    w = math.min(1100, w - 32),
    h = math.min(690, h - 32),
  }
  self.panel.x = (w - self.panel.w) / 2
  self.panel.y = (h - self.panel.h) / 2
  self.sidebar_w = 190
  self.content_x = self.panel.x + self.sidebar_w + 18
  self.content_w = self.panel.w - self.sidebar_w - 36
  self.rows_top = self.panel.y + 108
  self.row_h = 64
  local compact_run_tools = self.app.active_run and self.content_w < 730
  local footer_space = self.app.active_run
    and (compact_run_tools and 168 or 132)
    or 86
  self.max_visible = math.max(1, math.floor(
    (self.panel.h - 108 - footer_space) / self.row_h))
  self.reset_all_rect = {
    x = self.content_x,
    y = self.panel.y + self.panel.h - 50,
    w = 130,
    h = 34,
  }
  self.arsenal_rect = {
    x = self.content_x + 142,
    y = self.panel.y + self.panel.h - 50,
    w = 180,
    h = 34,
  }
  self.close_rect = {
    x = self.panel.x + self.panel.w - 154,
    y = self.panel.y + self.panel.h - 50,
    w = 130,
    h = 34,
  }
  if self.app.active_run then
    if compact_run_tools then
      local y = self.panel.y + self.panel.h - 126
      local three_w = (self.content_w - 16) / 3
      local two_w = (self.content_w - 8) / 2
      self.run_tool_rects = {
        level = { x = self.content_x, y = y, w = three_w, h = 30 },
        evolution = {
          x = self.content_x + three_w + 8, y = y, w = three_w, h = 30,
        },
        force_evolution = {
          x = self.content_x + (three_w + 8) * 2,
          y = y, w = three_w, h = 30,
        },
        boss = {
          x = self.content_x, y = y + 36, w = two_w, h = 30,
        },
        clear_stage = {
          x = self.content_x + two_w + 8,
          y = y + 36, w = two_w, h = 30,
        },
      }
    else
      local y = self.panel.y + self.panel.h - 92
      self.run_tool_rects = {
        level = { x = self.content_x, y = y, w = 112, h = 30 },
        evolution = { x = self.content_x + 120, y = y, w = 154, h = 30 },
        force_evolution = { x = self.content_x + 282, y = y, w = 150, h = 30 },
        boss = { x = self.content_x + 440, y = y, w = 128, h = 30 },
        clear_stage = { x = self.content_x + 576, y = y, w = 136, h = 30 },
      }
    end
  else
    self.run_tool_rects = nil
  end
  self:_keep_selected_visible()
end

function AdminScreen:_definitions()
  return self.filtered or self.app.tuning:list()
end

function AdminScreen:_keep_selected_visible()
  local definitions = self:_definitions()
  local count = #definitions
  self.selected = math.max(1, math.min(self.selected, math.max(1, count)))
  local max_visible = self.max_visible or count
  if self.selected < self.scroll then
    self.scroll = self.selected
  elseif self.selected >= self.scroll + max_visible then
    self.scroll = self.selected - max_visible + 1
  end
  self.scroll = math.max(1, math.min(
    self.scroll, math.max(1, count - max_visible + 1)))
end

function AdminScreen:_set_category(index)
  self.category_index = ((index - 1) % #categories) + 1
  self.selected, self.scroll = 1, 1
  self:_refresh()
end

function AdminScreen:_adjust(direction)
  local definition = self:_definitions()[self.selected]
  if definition then self.app.tuning:adjust(definition.id, direction) end
end

function AdminScreen:resize()
  self:_layout()
end

function AdminScreen:_draw_sidebar()
  local panel = self.panel
  love.graphics.setColor(0.055, 0.048, 0.095, 1)
  love.graphics.rectangle("fill", panel.x, panel.y, self.sidebar_w, panel.h, 8, 8)
  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.setFont(Fonts.get(21))
  love.graphics.print("ADMIN", panel.x + 20, panel.y + 18)
  love.graphics.setColor(0.62, 0.60, 0.70, 1)
  love.graphics.setFont(Fonts.get(14))
  love.graphics.print("LIVE CONTROL DECK", panel.x + 20, panel.y + 48)

  self.category_rects = {}
  for index, category in ipairs(categories) do
    local rect = {
      x = panel.x + 12,
      y = panel.y + 78 + (index - 1) * 52,
      w = self.sidebar_w - 24,
      h = 44,
    }
    self.category_rects[index] = rect
    local selected = index == self.category_index
    love.graphics.setColor(selected and { 0.16, 0.14, 0.25, 1 } or { 0.08, 0.07, 0.13, 1 })
    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 5, 5)
    if selected then
      love.graphics.setColor(category.color)
      love.graphics.rectangle("fill", rect.x, rect.y, 4, rect.h, 2, 2)
    end
    draw_glyph(category.glyph, rect.x + 24, rect.y + 22, 22, category.color)
    love.graphics.setColor(selected and settings.ui.text_color or { 0.72, 0.70, 0.80, 1 })
    love.graphics.setFont(Fonts.get(15))
    love.graphics.print(category.label, rect.x + 46, rect.y + 15)
  end
end

function AdminScreen:_draw_value_bar(definition, rect, color)
  local value = self.app.tuning:get(definition.id)
  local fraction
  if definition.value_type == "boolean" then
    fraction = value and 1 or 0
  elseif definition.max and definition.min then
    fraction = (value - definition.min) / (definition.max - definition.min)
  else
    fraction = 0
  end
  love.graphics.setColor(0.07, 0.06, 0.11, 1)
  love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 3, 3)
  love.graphics.setColor(color[1], color[2], color[3], 0.82)
  love.graphics.rectangle("fill", rect.x, rect.y, rect.w * fraction, rect.h, 3, 3)
end

function AdminScreen:_draw_rows()
  local definitions = self:_definitions()
  local category = categories[self.category_index]
  self.rows = {}
  local last = math.min(#definitions, self.scroll + self.max_visible - 1)
  for index = self.scroll, last do
    local definition = definitions[index]
    local y = self.rows_top + (index - self.scroll) * self.row_h
    local row = {
      x = self.content_x,
      y = y,
      w = self.content_w,
      h = self.row_h - 8,
    }
    row.minus = { x = row.x + row.w - 194, y = y + 10, w = 40, h = 36 }
    row.plus = { x = row.x + row.w - 44, y = y + 10, w = 40, h = 36 }
    self.rows[index] = row
    local selected = index == self.selected
    love.graphics.setColor(selected and { 0.17, 0.145, 0.26, 1 } or { 0.095, 0.083, 0.15, 1 })
    love.graphics.rectangle("fill", row.x, row.y, row.w, row.h, 6, 6)
    love.graphics.setColor(selected and category.color or { 0.30, 0.27, 0.40, 1 })
    love.graphics.setLineWidth(selected and 2 or 1)
    love.graphics.rectangle("line", row.x, row.y, row.w, row.h, 6, 6)

    draw_glyph(category.glyph, row.x + 26, row.y + 28, 24, category.color)
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.get(17))
    love.graphics.print(definition.label, row.x + 50, row.y + 9)
    if self.content_w >= 650 then
      love.graphics.setColor(0.62, 0.60, 0.70, 1)
      love.graphics.setFont(Fonts.get(14))
      love.graphics.print(definition.help, row.x + 50, row.y + 32)
    end

    self:_draw_value_bar(definition, {
      x = row.x + row.w - 302, y = row.y + 38, w = 94, h = 6,
    }, category.color)
    love.graphics.setColor(category.color)
    love.graphics.setFont(Fonts.get(15))
    love.graphics.printf(
      self.app.tuning:format(definition.id),
      row.x + row.w - 310, row.y + 10, 110, "center")
    self:_draw_button(row.minus, "-", category.color)
    self:_draw_button(row.plus, "+", category.color)
  end
end

function AdminScreen:_draw_button(rect, label, color)
  love.graphics.setColor(0.12, 0.10, 0.19, 1)
  love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 4, 4)
  love.graphics.setColor(color or settings.ui.button.border)
  love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 4, 4)
  love.graphics.setColor(settings.ui.text_color)
  love.graphics.setFont(Fonts.get(14))
  love.graphics.printf(label, rect.x, rect.y + 9, rect.w, "center")
end

function AdminScreen:draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(0, 0, 0, 0.78)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.setColor(0.075, 0.065, 0.12, 0.99)
  love.graphics.rectangle(
    "fill", self.panel.x, self.panel.y, self.panel.w, self.panel.h, 8, 8)
  love.graphics.setColor(settings.ui.button.border)
  love.graphics.rectangle(
    "line", self.panel.x, self.panel.y, self.panel.w, self.panel.h, 8, 8)
  self:_draw_sidebar()

  local category = categories[self.category_index]
  love.graphics.setColor(category.color)
  love.graphics.setFont(Fonts.get(30))
  love.graphics.print(category.label, self.content_x, self.panel.y + 18)
  love.graphics.setColor(0.68, 0.66, 0.76, 1)
  love.graphics.setFont(Fonts.get(14))
  love.graphics.print(
    "Bounded live tuning  •  [ / ] or LB/RB sections  •  F1/Esc closes",
    self.content_x, self.panel.y + 54)
  self:_draw_rows()

  if self.run_tool_rects then
    self:_draw_button(self.run_tool_rects.level, "Grant Level  G", category.color)
    self:_draw_button(self.run_tool_rects.evolution, "Prepare Evolution  E", category.color)
    self:_draw_button(self.run_tool_rects.force_evolution, "Rank-1 Evolve  R", category.color)
    self:_draw_button(self.run_tool_rects.boss, "Spawn Boss  B", category.color)
    self:_draw_button(self.run_tool_rects.clear_stage, "Clear Stage  N", category.color)
  end
  self:_draw_button(self.reset_all_rect, "Reset all", category.color)
  self:_draw_button(self.arsenal_rect, "Arsenal Database", { 0.38, 0.92, 1.0, 1 })
  self:_draw_button(self.close_rect, "Close", category.color)
end

function AdminScreen:_open_arsenal()
  local ArsenalScreen = require("src.ui.screens.arsenal")
  self.app.states:push(ArsenalScreen(self.app))
end

function AdminScreen:keypressed(key)
  if key == settings.debug.admin.toggle_key or key == "escape" then
    self.app.states:pop()
    return true
  elseif key == "]" then
    self:_set_category(self.category_index + 1)
    return true
  elseif key == "[" then
    self:_set_category(self.category_index - 1)
    return true
  elseif key == "up" or key == "w" then
    self.selected = self.selected - 1
    self:_keep_selected_visible()
    return true
  elseif key == "down" or key == "s" then
    self.selected = self.selected + 1
    self:_keep_selected_visible()
    return true
  elseif key == "left" or key == "a" then
    self:_adjust(-1)
    return true
  elseif key == "right" or key == "d" or key == "return" or key == "space" then
    self:_adjust(1)
    return true
  elseif key == "backspace" then
    local definition = self:_definitions()[self.selected]
    if definition then self.app.tuning:reset(definition.id) end
    return true
  elseif key == "delete" then
    self.app.tuning:reset_all()
    return true
  elseif key == "f2" then
    self:_open_arsenal()
    return true
  elseif self.app.active_run and key == "g" then
    self.app.active_run.combat:admin_grant_level()
    return true
  elseif self.app.active_run and key == "e" then
    self.app.active_run.combat:admin_prepare_evolution()
    return true
  elseif self.app.active_run and key == "r" then
    self.app.active_run.combat:admin_force_evolution()
    return true
  elseif self.app.active_run and key == "b" then
    self.app.active_run.combat:admin_spawn_final_boss()
    return true
  elseif self.app.active_run and key == "n" then
    self.app.active_run.combat:admin_clear_stage()
    return true
  end
  return false
end

function AdminScreen:gamepadpressed(_, button)
  if button == "b" or button == "start" then
    self.app.states:pop()
    return true
  elseif button == "leftshoulder" then
    self:_set_category(self.category_index - 1)
    return true
  elseif button == "rightshoulder" then
    self:_set_category(self.category_index + 1)
    return true
  elseif button == "dpup" then
    return self:keypressed("up")
  elseif button == "dpdown" then
    return self:keypressed("down")
  elseif button == "dpleft" then
    return self:keypressed("left")
  elseif button == "dpright" or button == "a" then
    return self:keypressed("right")
  elseif button == "y" then
    local definition = self:_definitions()[self.selected]
    if definition then self.app.tuning:reset(definition.id) end
    return true
  end
  return false
end

function AdminScreen:mousemoved(x, y)
  for index, row in pairs(self.rows) do
    if contains(row, x, y) then self.selected = index return true end
  end
  return false
end

function AdminScreen:mousepressed(x, y, button)
  if button ~= 1 then return false end
  for index, rect in ipairs(self.category_rects) do
    if contains(rect, x, y) then self:_set_category(index) return true end
  end
  for index, row in pairs(self.rows) do
    if contains(row.minus, x, y) then
      self.selected = index
      self:_adjust(-1)
      return true
    elseif contains(row.plus, x, y) then
      self.selected = index
      self:_adjust(1)
      return true
    end
  end
  if contains(self.reset_all_rect, x, y) then
    self.app.tuning:reset_all()
    return true
  elseif contains(self.arsenal_rect, x, y) then
    self:_open_arsenal()
    return true
  elseif self.run_tool_rects and contains(self.run_tool_rects.level, x, y) then
    self.app.active_run.combat:admin_grant_level()
    return true
  elseif self.run_tool_rects and contains(self.run_tool_rects.evolution, x, y) then
    self.app.active_run.combat:admin_prepare_evolution()
    return true
  elseif self.run_tool_rects
    and contains(self.run_tool_rects.force_evolution, x, y)
  then
    self.app.active_run.combat:admin_force_evolution()
    return true
  elseif self.run_tool_rects and contains(self.run_tool_rects.boss, x, y) then
    self.app.active_run.combat:admin_spawn_final_boss()
    return true
  elseif self.run_tool_rects and contains(self.run_tool_rects.clear_stage, x, y) then
    self.app.active_run.combat:admin_clear_stage()
    return true
  elseif contains(self.close_rect, x, y) then
    self.app.states:pop()
    return true
  end
  return false
end

return AdminScreen
