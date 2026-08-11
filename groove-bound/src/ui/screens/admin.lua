-- Visual, segmented development dashboard. Every control still mutates the
-- same bounded Tuning model; categories and graphics are presentation only.

local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local Hints = require("src.ui.controller_hints")
local MenuChrome = require("src.ui.menu_chrome")
local SpatialNavigation = require("src.ui.spatial_navigation")

local AdminScreen = class()
AdminScreen.kind = "admin"
AdminScreen.opaque = false

local categories = {
  { id = "All", label = "Overview", color = { 0.96, 0.76, 0.22, 1 }, sprite = 1 },
  { id = "Simulation", label = "Simulation", color = { 0.40, 0.72, 1.0, 1 }, sprite = 2 },
  { id = "Run", label = "Run & Stages", color = { 0.22, 0.92, 1.0, 1 }, sprite = 3 },
  { id = "Player", label = "Player", color = { 0.34, 1.0, 0.68, 1 }, sprite = 4 },
  { id = "Combat", label = "Combat", color = { 1.0, 0.38, 0.42, 1 }, sprite = 5 },
  { id = "Projectiles", label = "Bullets", color = { 1.0, 0.62, 0.20, 1 }, sprite = 6 },
  { id = "Enemies", label = "Enemies", color = { 0.92, 0.28, 0.68, 1 }, sprite = 7 },
  { id = "Rewards", label = "Rewards", color = { 0.42, 0.94, 0.84, 1 }, sprite = 8 },
  { id = "Groove", label = "Groove", color = { 0.72, 0.42, 1.0, 1 }, sprite = 9 },
}

local function contains(rect, x, y)
  return rect
    and x >= rect.x and x <= rect.x + rect.w
    and y >= rect.y and y <= rect.y + rect.h
end

function AdminScreen:init(app, opts)
  self.app = app
  self.opts = opts or {}
  self.category_index = 1
  self.selected = 1
  self.scroll = 1
  self.rows = {}
  self.category_rects = {}
  self.focus_area = "rows"
  self.action_index = 1
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
  self.options_tab = {
    x = self.content_x, y = self.panel.y + 14, w = 148, h = 38,
  }
  self.admin_tab = {
    x = self.content_x + 158, y = self.panel.y + 14, w = 148, h = 38,
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
  self.action_items = {}
  local function action(id, rect)
    self.action_items[#self.action_items + 1] = { id = id, rect = rect }
  end
  if self.run_tool_rects then
    action("level", self.run_tool_rects.level)
    action("evolution", self.run_tool_rects.evolution)
    action("force_evolution", self.run_tool_rects.force_evolution)
    action("boss", self.run_tool_rects.boss)
    action("clear_stage", self.run_tool_rects.clear_stage)
  end
  action("reset_all", self.reset_all_rect)
  action("arsenal", self.arsenal_rect)
  action("close", self.close_rect)
  self.action_index = math.max(1,
    math.min(self.action_index, #self.action_items))
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
  MenuChrome.panel(self.app.assets, {
    x = panel.x, y = panel.y, w = self.sidebar_w, h = panel.h,
  }, { corner = 38, alpha = 0.96 })
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
    MenuChrome.panel(self.app.assets, rect, {
      corner = 17, alpha = selected and 1 or 0.62,
    })
    if selected and self.focus_area == "categories" then
      MenuChrome.focus(self.app.assets, rect, { corner = 18 })
    end
    self.app.assets:draw_menu_category_icon(category.sprite,
      rect.x + 5, rect.y + 4, rect.h - 8,
      { color = { 1, 1, 1, selected and 1 or 0.66 } })
    love.graphics.setColor(selected and settings.ui.text_color or { 0.72, 0.70, 0.80, 1 })
    love.graphics.setFont(Fonts.get(15))
    love.graphics.print(category.label, rect.x + 48, rect.y + 15)
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
    MenuChrome.panel(self.app.assets, row, {
      corner = 20, alpha = selected and 1 or 0.68,
    })
    if selected and self.focus_area == "rows" then
      MenuChrome.focus(self.app.assets, row, { corner = 22 })
    end
    self.app.assets:draw_menu_category_icon(category.sprite,
      row.x + 6, row.y + 5, row.h - 10,
      { color = { 1, 1, 1, selected and 1 or 0.66 } })
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

function AdminScreen:_draw_button(rect, label, color, focused)
  MenuChrome.panel(self.app.assets, rect, {
    corner = math.min(15, rect.h * 0.42), alpha = focused and 1 or 0.72,
  })
  if focused then MenuChrome.focus(self.app.assets, rect, { corner = 15 }) end
  love.graphics.setColor(focused and { 1, 0.84, 0.28, 1 }
    or color or settings.ui.text_color)
  love.graphics.setFont(Fonts.get(14))
  love.graphics.printf(label, rect.x, rect.y + 9, rect.w, "center")
end

function AdminScreen:_action_focused(id)
  if self.focus_area ~= "actions" then return false end
  local action = self.action_items and self.action_items[self.action_index]
  return action and action.id == id
end

function AdminScreen:_activate_action()
  local action = self.action_items and self.action_items[self.action_index]
  if not action then return false end
  local id = action.id
  if id == "reset_all" then
    self.app.tuning:reset_all()
  elseif id == "arsenal" then
    self:_open_arsenal()
  elseif id == "close" then
    self.app.states:pop()
  elseif self.app.active_run and id == "level" then
    self.app.active_run.combat:admin_grant_level()
  elseif self.app.active_run and id == "evolution" then
    self.app.active_run.combat:admin_prepare_evolution()
  elseif self.app.active_run and id == "force_evolution" then
    self.app.active_run.combat:admin_force_evolution()
  elseif self.app.active_run and id == "boss" then
    self.app.active_run.combat:admin_spawn_final_boss()
  elseif self.app.active_run and id == "clear_stage" then
    self.app.active_run.combat:admin_clear_stage()
  else
    return false
  end
  return true
end

function AdminScreen:_move_action(direction)
  local next_index = SpatialNavigation.find(
    self.action_items, self.action_index, direction,
    function(action) return action.rect end)
  if next_index == self.action_index then return false end
  self.action_index = next_index
  return true
end

function AdminScreen:draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(0, 0, 0, 0.78)
  love.graphics.rectangle("fill", 0, 0, w, h)
  MenuChrome.panel(self.app.assets, self.panel, { corner = 48, alpha = 0.98 })
  self:_draw_sidebar()

  local category = categories[self.category_index]
  self:_draw_button(self.options_tab, "OPTIONS", { 0.38, 0.82, 1.0, 1 })
  self:_draw_button(self.admin_tab, "ADMIN", category.color, true)
  self.app.assets:draw_menu_button_icon(4, 1,
    self.options_tab.x + 5, self.options_tab.y + 3, 32, 32)
  self.app.assets:draw_menu_category_icon(1,
    self.admin_tab.x + 5, self.admin_tab.y + 3, 32)
  love.graphics.setColor(category.color)
  love.graphics.setFont(Fonts.get(24))
  love.graphics.print(category.label, self.content_x + 326, self.panel.y + 20)
  love.graphics.setColor(0.68, 0.66, 0.76, 1)
  love.graphics.setFont(Fonts.get(14))
  love.graphics.print(
    "D-pad moves  •  Cross adds  •  Square subtracts  •  L1/R1 sections",
    self.content_x, self.panel.y + 62)
  Hints.draw({
    { symbol = "dpad", label = "Move" },
    { symbol = "cross", label = "+ / Use" },
    { symbol = "square", label = "-" },
    { symbol = "triangle", label = "Reset selected" },
    { symbol = "circle", label = "Close" },
  }, self.panel.y + 79, self.content_w,
    { x = self.content_x, font_size = 12, glyph_size = 16, gap = 14 })
  self:_draw_rows()

  if self.run_tool_rects then
    self:_draw_button(self.run_tool_rects.level, "Grant Level", category.color,
      self:_action_focused("level"))
    self:_draw_button(self.run_tool_rects.evolution, "Prepare Evolution", category.color,
      self:_action_focused("evolution"))
    self:_draw_button(self.run_tool_rects.force_evolution, "Rank-1 Evolve", category.color,
      self:_action_focused("force_evolution"))
    self:_draw_button(self.run_tool_rects.boss, "Spawn Boss", category.color,
      self:_action_focused("boss"))
    self:_draw_button(self.run_tool_rects.clear_stage, "Clear Stage", category.color,
      self:_action_focused("clear_stage"))
  end
  self:_draw_button(self.reset_all_rect, "Reset all", category.color,
    self:_action_focused("reset_all"))
  self:_draw_button(self.arsenal_rect, "Arsenal", { 0.38, 0.92, 1.0, 1 },
    self:_action_focused("arsenal"))
  self:_draw_button(self.close_rect, "Close", category.color,
    self:_action_focused("close"))
end

function AdminScreen:_open_options()
  if self.opts.settings_hub then
    self.app.states:pop()
  else
    local OptionsScreen = require("src.ui.screens.options")
    self.app.states:push(OptionsScreen(self.app))
  end
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
    if self.focus_area == "categories" then
      self:_set_category(self.category_index - 1)
    elseif self.focus_area == "actions" then
      if not self:_move_action("up") then self.focus_area = "rows" end
    else
      self.selected = self.selected - 1
      self:_keep_selected_visible()
    end
    return true
  elseif key == "down" or key == "s" then
    if self.focus_area == "categories" then
      self:_set_category(self.category_index + 1)
    elseif self.focus_area == "actions" then
      self:_move_action("down")
    elseif self.selected >= #self:_definitions() then
      self.focus_area = "actions"
    else
      self.selected = self.selected + 1
      self:_keep_selected_visible()
    end
    return true
  elseif key == "left" or key == "a" then
    if self.focus_area == "rows" then
      self.focus_area = "categories"
    elseif self.focus_area == "actions" then
      self:_move_action("left")
    end
    return true
  elseif key == "right" or key == "d" then
    if self.focus_area == "categories" then
      self.focus_area = "rows"
    elseif self.focus_area == "actions" then
      self:_move_action("right")
    end
    return true
  elseif key == "return" or key == "space" then
    if self.focus_area == "categories" then
      self.focus_area = "rows"
    elseif self.focus_area == "actions" then
      self:_activate_action()
    else
      self:_adjust(1)
    end
    return true
  elseif key == "-" or key == "kp-" then
    if self.focus_area == "rows" then self:_adjust(-1) end
    return true
  elseif key == "=" or key == "+" or key == "kp+" then
    if self.focus_area == "rows" then self:_adjust(1) end
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
  elseif button == "dpright" then
    return self:keypressed("right")
  elseif button == "a" then
    return self:keypressed("return")
  elseif button == "x" then
    return self:keypressed("-")
  elseif button == "y" then
    local definition = self:_definitions()[self.selected]
    if definition then self.app.tuning:reset(definition.id) end
    return true
  end
  return false
end

function AdminScreen:mousemoved(x, y)
  for index, row in pairs(self.rows) do
    if contains(row, x, y) then
      self.selected = index
      self.focus_area = "rows"
      return true
    end
  end
  for index, rect in ipairs(self.category_rects) do
    if contains(rect, x, y) then
      if self.category_index ~= index then self:_set_category(index) end
      self.focus_area = "categories"
      return true
    end
  end
  for index, action in ipairs(self.action_items or {}) do
    if contains(action.rect, x, y) then
      self.action_index = index
      self.focus_area = "actions"
      return true
    end
  end
  return false
end

function AdminScreen:mousepressed(x, y, button)
  if button ~= 1 then return false end
  if contains(self.options_tab, x, y) then
    self:_open_options()
    return true
  end
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
