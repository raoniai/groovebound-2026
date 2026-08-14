local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")
local UIScale = require("src.ui.scale")
local NumberFormat = require("src.ui.number_format")
local JourneyProgress = require("src.meta.journey_progress")
local WorldTourSession = require("src.meta.world_tour_session")
local SpatialNavigation = require("src.ui.spatial_navigation")
local MenuChrome = require("src.ui.menu_chrome")

local WorldTourScreen = class()
WorldTourScreen.kind = "world_tour"

local pillar_order = {
  { id = "groove", label = "GROOVE" },
  { id = "impact", label = "IMPACT" },
  { id = "control", label = "CONTROL" },
  { id = "craft", label = "CRAFT" },
  { id = "mastery", label = "MASTERY" },
}

local grade_cells = { D = 1, C = 2, B = 3, A = 4, S = 5 }

function WorldTourScreen:init(app, opts)
  self.app = app
  self.opts = opts or {}
  self.catalog_only = self.opts.catalog_only == true
  self.selected = 1
  self.worlds = {}
  for _, world in pairs(app.content.world_tour) do
    self.worlds[#self.worlds + 1] = world
  end
  table.sort(self.worlds, function(a, b) return a.order < b.order end)
  self.notice = 0
  self.focus_area = "worlds"
end

function WorldTourScreen:enter()
  if not self.catalog_only then JourneyProgress.ensure(self.app) end
  self:_layout()
  self.app.log.info("state", "World Tour catalog entered")
end

function WorldTourScreen:_world_state(world)
  local slot = self.app.slot
  local saved = slot and slot.worlds[world.id]
  local unlocked = slot ~= nil and (world.id == "funk" and slot.prologue.completed
    or saved and saved.unlocked == true
  ) or false
  return saved or {}, unlocked
end

function WorldTourScreen:_start_selected_world(world, character_id)
  local build = WorldTourSession.get(self.app, character_id)
  local starter = world.starter_loadout or { weapons = 0, passives = 0 }
  if not build and (starter.weapons > 0 or starter.passives > 0) then
    local WorldLoadoutScreen = require("src.ui.screens.world_loadout")
    self.app.states:switch(WorldLoadoutScreen(self.app, {
      world = world,
      character_id = character_id,
    }))
    return true
  end
  JourneyProgress.begin_run(self.app, "world_tour", world.id)
  local RunScreen = require("src.ui.screens.run")
  self.app.states:switch(RunScreen(self.app, {
    mode = "world_tour", world_id = world.id, character_id = character_id,
    build = build,
  }))
  return true
end

function WorldTourScreen:_play_selected()
  if self.catalog_only or not self.app.slot then
    self.notice = 2.0
    return false
  end
  local world = self.worlds[self.selected]
  local _, unlocked = self:_world_state(world)
  if not unlocked or world.implementation_status ~= "playable" then
    self.notice = 2.0
    return false
  end
  local CharacterSelectScreen = require("src.ui.screens.character_select")
  self.app.states:switch(CharacterSelectScreen(self.app, {
    on_confirm = function(character_id)
      return self:_start_selected_world(world, character_id)
    end,
    on_back = function()
      self.app.states:switch(WorldTourScreen(self.app))
      return true
    end,
  }))
  return true
end

function WorldTourScreen:_layout()
  local w, h, scale = UIScale.dimensions()
  self.ui_scale = scale
  local left_w = math.min(470, w * 0.43)
  self.catalog_rect = { x = 24, y = 100, w = left_w - 36, h = h - 202 }
  local gap = 8
  local size = math.min(122,
    (self.catalog_rect.w - gap * 2) / 3,
    (self.catalog_rect.h - gap * 2) / 3)
  self.slot_rects = {}
  for index = 1, 9 do
    local col = (index - 1) % 3
    local row = math.floor((index - 1) / 3)
    self.slot_rects[index] = {
      x = self.catalog_rect.x + col * (size + gap),
      y = self.catalog_rect.y + row * (size + gap), w = size, h = size,
    }
  end
  self.detail_rect = {
    x = left_w + 12, y = 100, w = w - left_w - 36, h = h - 202,
  }
  local bw, bh, button_gap = math.min(330, w * 0.34), 54, 12
  local total = bw * 2 + button_gap
  local button_y = h - 82
  local buttons = {}
  local function button(opts)
    opts.renderer = function(value)
      MenuChrome.action(self.app.assets, value, {
        menu_cell = opts.menu_cell, label = value.label,
        font_size = opts.font_size, icon_size = 42,
      })
    end
    return widgets.Button(opts)
  end
  if not self.catalog_only then
    buttons[#buttons + 1] = button({
      label = "PLAY SELECTED WORLD", x = (w - total) / 2, y = button_y,
      w = bw, h = bh, font_size = 19, variant = "primary",
      menu_cell = 3,
      on_press = function() self:_play_selected() end,
    })
  end
  buttons[#buttons + 1] = button({
      label = "RETURN TO TITLE",
      x = self.catalog_only and (w - bw) / 2
        or (w - total) / 2 + bw + button_gap,
      y = button_y, w = bw, h = bh, font_size = 18, menu_cell = 8,
      on_press = function()
        local TitleScreen = require("src.ui.screens.title")
        self.app.states:switch(TitleScreen(self.app))
      end,
    })
  self.buttons = widgets.ButtonList(buttons)
  self:_apply_area_focus()
end

function WorldTourScreen:_apply_area_focus()
  if not self.buttons then return end
  for index, button in ipairs(self.buttons.buttons) do
    button.focused = self.focus_area == "actions"
      and index == self.buttons.focus_index
  end
end

function WorldTourScreen:resize() self:_layout() end

function WorldTourScreen:update(dt)
  self.notice = math.max(0, self.notice - dt)
end

local function inside(rect, x, y)
  return x >= rect.x and x <= rect.x + rect.w
    and y >= rect.y and y <= rect.y + rect.h
end

function WorldTourScreen:_draw_world_slot(world, rect, selected)
  local saved, unlocked = self:_world_state(world)
  local available = unlocked and world.implementation_status == "playable"
  love.graphics.setColor(selected and { 0.12, 0.06, 0.20, 0.98 }
    or { 0.025, 0.016, 0.06, 0.94 })
  love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 10, 10)
  self.app.assets:draw_hud_frame(rect.x, rect.y, rect.w, rect.h, {
    color = selected and { 1, 0.74, 0.20, 1 }
      or available and { 0.36, 0.92, 1, 0.78 } or { 0.42, 0.38, 0.52, 0.42 },
  })
  local col = world.id == "funk" and 2 or world.id == "soul" and 3 or 4
  if available then
    self.app.assets:draw_world_identity(world.id, col, 1,
      rect.x + rect.w * 0.16, rect.y + 5, rect.w * 0.68, rect.h * 0.68)
  else
    self.app.assets:draw_world_lock(rect.x + rect.w * 0.25, rect.y + 13,
      rect.w * 0.50, rect.h * 0.54, { color = { 0.66, 0.62, 0.76, 0.52 } })
  end
  love.graphics.setFont(Fonts.get(math.max(10, math.min(14, rect.w * 0.12))))
  love.graphics.setColor(available and settings.ui.text_color
    or { 0.55, 0.52, 0.64, 1 })
  love.graphics.printf(string.upper(world.genre), rect.x + 4,
    rect.y + rect.h - 30, rect.w - 8, "center")
  if saved.best_grade and saved.best_grade ~= "" then
    local cell = grade_cells[saved.best_grade] or 1
    self.app.assets:draw_world_tour_icon(cell, 2,
      rect.x + rect.w - 39, rect.y + 5, 34, 34)
    love.graphics.setFont(Fonts.get(12)); love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(saved.best_grade, rect.x + rect.w - 37,
      rect.y + 15, 30, "center")
  end
end

function WorldTourScreen:_draw_record(world, rect)
  local saved, unlocked = self:_world_state(world)
  local available = unlocked and world.implementation_status == "playable"
  local record = self.app.slot and self.app.slot.records.worlds[world.id]
    or { pillars = {} }
  local grade = saved.best_grade or ""
  love.graphics.setColor(0.022, 0.012, 0.058, 0.96)
  love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 14, 14)
  self.app.assets:draw_hud_frame(rect.x, rect.y, rect.w, rect.h,
    { color = available and { 0.36, 0.92, 1, 0.78 }
      or { 0.42, 0.38, 0.52, 0.46 } })

  local icon_col = world.id == "funk" and 2 or world.id == "soul" and 3 or 4
  if available then
    self.app.assets:draw_world_identity(world.id, icon_col, 1,
      rect.x + 18, rect.y + 12, 112, 112)
  else
    self.app.assets:draw_world_lock(rect.x + 36, rect.y + 25, 76, 76,
      { color = { 0.62, 0.58, 0.72, 0.50 } })
  end
  love.graphics.setFont(Fonts.get(26))
  love.graphics.setColor(available and { 1, 0.76, 0.22, 1 }
    or { 0.58, 0.55, 0.68, 1 })
  love.graphics.printf(string.upper(world.name), rect.x + 134, rect.y + 20,
    rect.w - 154, "left")
  love.graphics.setFont(Fonts.get(14))
  love.graphics.setColor(0.72, 0.72, 0.84, 1)
  love.graphics.printf(self.catalog_only and "CATALOG PREVIEW  •  START A CAMPAIGN TO PLAY"
    or unlocked and (world.implementation_status == "playable"
      and "PLAYABLE  •  WORLD MECHANIC ACTIVE" or "CATALOGED  •  COMING NEXT")
      or "LOCKED  •  CLEAR THE PREVIOUS WORLD",
    rect.x + 134, rect.y + 59, rect.w - 154, "left")

  local badge_col = grade_cells[grade] or 1
  self.app.assets:draw_world_tour_icon(badge_col, 2,
    rect.x + rect.w - 112, rect.y + 82, 92, 92,
    { color = grade ~= "" and { 1, 1, 1, 1 } or { 0.48, 0.45, 0.58, 0.42 } })
  local badge_x, badge_y, badge_w, badge_h =
    rect.x + rect.w - 112, rect.y + 82, 92, 92
  local grade_font = Fonts.get(34)
  local grade_text = grade ~= "" and grade or "—"
  local text_y = badge_y + (badge_h - grade_font:getHeight()) / 2 - 1
  love.graphics.setFont(grade_font)
  love.graphics.setColor(0.005, 0.002, 0.018, grade ~= "" and 0.95 or 0.65)
  love.graphics.printf(grade_text, badge_x + 3, text_y + 4, badge_w, "center")
  love.graphics.setColor(grade ~= "" and { 1, 0.96, 1, 1 }
    or { 0.55, 0.52, 0.64, 0.8 })
  love.graphics.printf(grade_text, badge_x, text_y, badge_w, "center")

  local bar_x, bar_y = rect.x + 28, rect.y + 154
  local bar_w = math.max(120, rect.w - 168)
  for index, pillar in ipairs(pillar_order) do
    local y = bar_y + (index - 1) * 39
    local value = record.pillars[pillar.id] or 0
    love.graphics.setFont(Fonts.get(12))
    love.graphics.setColor(0.76, 0.74, 0.86, 1)
    love.graphics.print(pillar.label, bar_x, y)
    love.graphics.setColor(0.055, 0.032, 0.10, 1)
    love.graphics.rectangle("fill", bar_x + 82, y + 3, bar_w, 14, 7, 7)
    love.graphics.setColor(index == 1 and { 1.0, 0.66, 0.18, 1 }
      or { 0.28, 0.88, 1.0, 1 })
    love.graphics.rectangle("fill", bar_x + 82, y + 3,
      bar_w * math.min(1, value / 100), 14, 7, 7)
    love.graphics.setColor(0.92, 0.92, 1, 1)
    love.graphics.printf(tostring(value), bar_x + 88 + bar_w, y,
      38, "right")
  end
  local profile = self.app.content.grade_profiles.profiles[world.grade_profile] or {}
  local focus = {}
  for _, pillar in ipairs(pillar_order) do
    focus[#focus + 1] = { label = pillar.label, value = profile[pillar.id] or 0 }
  end
  table.sort(focus, function(a, b) return a.value > b.value end)
  local guide_y = rect.y + rect.h - 100
  love.graphics.setFont(Fonts.get(10)); love.graphics.setColor(0.34, 0.90, 1, 1)
  love.graphics.print("RANK GUIDE", rect.x + 24, guide_y)
  love.graphics.setColor(0.74, 0.76, 0.86, 1)
  love.graphics.printf("BUILD " .. focus[1].label .. " " .. focus[1].value
      .. "%  •  " .. focus[2].label .. " " .. focus[2].value .. "%",
    rect.x + 108, guide_y, rect.w - 132, "left")
  local thresholds = self.app.content.grade_profiles.thresholds
  for index, entry in ipairs(thresholds) do
    local x = rect.x + 24 + (index - 1) * math.min(72, (rect.w - 52) / 5)
    self.app.assets:draw_world_tour_icon(grade_cells[entry.grade] or 1, 2,
      x, guide_y + 18, 28, 28, { color = { 1, 1, 1, 0.88 } })
    love.graphics.setFont(Fonts.get(9)); love.graphics.setColor(0.90, 0.90, 0.97, 1)
    love.graphics.print(entry.grade .. " " .. entry.minimum, x + 31, guide_y + 27)
  end
  love.graphics.setFont(Fonts.get(14))
  love.graphics.setColor(0.68, 0.66, 0.78, 1)
  love.graphics.printf("BEST SCORE " .. NumberFormat.integer(saved.best_score or 0)
      .. "  •  CLEARS " .. tostring(saved.clears or 0),
    rect.x + 24, rect.y + rect.h - 39, rect.w - 48, "center")
end

function WorldTourScreen:draw()
  local screen_w, screen_h = love.graphics.getDimensions()
  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, screen_w, screen_h)
  local campaign = self.app.assets.campaign
  if campaign and campaign.title_background then
    local image = campaign.title_background
    local scale = math.max(screen_w / image:getWidth(), screen_h / image:getHeight())
    love.graphics.setColor(1, 1, 1, 0.30)
    love.graphics.draw(image, screen_w / 2, screen_h / 2, 0, scale, scale,
      image:getWidth() / 2, image:getHeight() / 2)
  end
  love.graphics.setColor(0.008, 0.004, 0.028, 0.78)
  love.graphics.rectangle("fill", 0, 0, screen_w, screen_h)
  local w, h = UIScale.begin()
  self.app.assets:draw_menu_stat_icon(3, 24, 10, 76)
  love.graphics.setFont(Fonts.get(36))
  love.graphics.setColor(1, 0.76, 0.22, 1)
  love.graphics.print("WORLD TOUR", 108, 18)

  for index, world in ipairs(self.worlds) do
    self:_draw_world_slot(world, self.slot_rects[index], index == self.selected)
    if self.focus_area == "worlds" and index == self.selected then
      self.app.assets:draw_menu_focus_frame(
        self.slot_rects[index].x - 4, self.slot_rects[index].y - 4,
        self.slot_rects[index].w + 8, self.slot_rects[index].h + 8,
        { corner = 28 })
    end
  end
  self:_draw_record(self.worlds[self.selected], self.detail_rect)
  self.buttons:draw()
  if self.notice > 0 then
    love.graphics.setFont(Fonts.get(14))
    love.graphics.setColor(1, 0.50, 0.34, math.min(1, self.notice))
    love.graphics.printf(self.catalog_only
      and "START A NEW CAMPAIGN FROM THE MAIN MENU TO PLAY"
      or "THIS WORLD IS STILL LOCKED FOR PLAY",
      0, h - 105, w, "center")
  end
  UIScale.finish()
end

function WorldTourScreen:keypressed(key)
  if key == "escape" then
    local TitleScreen = require("src.ui.screens.title")
    self.app.states:switch(TitleScreen(self.app))
    return true
  end
  local directions = {
    left = "left", a = "left", right = "right", d = "right",
    up = "up", w = "up", down = "down", s = "down",
  }
  local direction = directions[key]
  if direction then
    if self.focus_area == "worlds" then
      local next_index = SpatialNavigation.find(
        self.slot_rects, self.selected, direction)
      if next_index == self.selected and direction == "down" then
        self.focus_area = "actions"
      else
        self.selected = next_index
      end
    else
      local moved = self.buttons:move_focus_direction(direction)
      if not moved and direction == "up" then self.focus_area = "worlds" end
    end
    self:_apply_area_focus()
    return true
  elseif key == "return" or key == "space" then
    if self.focus_area == "worlds" then self:_play_selected()
    else self.buttons:confirm() end
    return true
  end
  return false
end

function WorldTourScreen:gamepadpressed(_, button)
  if button == "b" then return self:keypressed("escape") end
  if button == "a" then return self:keypressed("return") end
  local mapping = {
    dpleft = "left", dpright = "right", dpup = "up", dpdown = "down",
  }
  if mapping[button] then return self:keypressed(mapping[button]) end
  return false
end

function WorldTourScreen:mousemoved(x, y)
  x, y = UIScale.point(x, y, self.ui_scale)
  self.buttons:mousemoved(x, y)
  for _, button in ipairs(self.buttons.buttons) do
    if button.hovered then
      self.focus_area = "actions"
      self:_apply_area_focus()
      return
    end
  end
end

function WorldTourScreen:mousepressed(x, y, button)
  if button ~= 1 then return false end
  x, y = UIScale.point(x, y, self.ui_scale)
  if self.buttons:mousepressed(x, y, button) then
    self.focus_area = "actions"
    self:_apply_area_focus()
    return true
  end
  for index, rect in ipairs(self.slot_rects) do
    if inside(rect, x, y) then
      self.selected = index
      self.focus_area = "worlds"
      self:_apply_area_focus()
      return true
    end
  end
  return false
end

return WorldTourScreen
