local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")
local UIScale = require("src.ui.scale")
local JourneyProgress = require("src.meta.journey_progress")

local WorldLoadoutScreen = class()
WorldLoadoutScreen.kind = "world_loadout"

local function sorted_definitions(source, predicate)
  local result = {}
  for _, definition in pairs(source) do
    if not predicate or predicate(definition) then result[#result + 1] = definition end
  end
  table.sort(result, function(a, b) return a.name < b.name end)
  return result
end

function WorldLoadoutScreen:init(app, opts)
  self.app = app
  self.world = assert(opts.world)
  self.character_id = assert(opts.character_id)
  self.budget = self.world.starter_loadout or { weapons = 0, passives = 0 }
  local starter = app.content.characters[self.character_id].starting_weapon
  self.weapons = sorted_definitions(app.content.weapons, function(weapon)
    return not weapon.evolved and weapon.id ~= starter
  end)
  self.passives = sorted_definitions(app.content.passives)
  self.selected_weapons, self.selected_passives = {}, {}
  self.weapon_order, self.passive_order = {}, {}
  self.notice = 0
end

local function toggle(selected, order, id, limit)
  if selected[id] then
    selected[id] = nil
    for index, value in ipairs(order) do
      if value == id then table.remove(order, index) break end
    end
    return true
  end
  if #order >= limit then return false end
  selected[id] = true
  order[#order + 1] = id
  return true
end

function WorldLoadoutScreen:toggle_weapon(id)
  return toggle(self.selected_weapons, self.weapon_order, id, self.budget.weapons)
end

function WorldLoadoutScreen:toggle_passive(id)
  return toggle(self.selected_passives, self.passive_order, id, self.budget.passives)
end

function WorldLoadoutScreen:ready()
  return #self.weapon_order == self.budget.weapons
    and #self.passive_order == self.budget.passives
end

function WorldLoadoutScreen:selection()
  local weapons, passives = {}, {}
  for index, id in ipairs(self.weapon_order) do weapons[index] = id end
  for index, id in ipairs(self.passive_order) do passives[index] = id end
  return { weapons = weapons, passives = passives }
end

function WorldLoadoutScreen:_start()
  if not self:ready() then self.notice = 2 return false end
  JourneyProgress.begin_run(self.app, "world_tour", self.world.id)
  local RunScreen = require("src.ui.screens.run")
  self.app.states:switch(RunScreen(self.app, {
    mode = "world_tour",
    world_id = self.world.id,
    character_id = self.character_id,
    starter_loadout = self:selection(),
  }))
  return true
end

function WorldLoadoutScreen:_back()
  local WorldTourScreen = require("src.ui.screens.world_tour")
  self.app.states:switch(WorldTourScreen(self.app))
end

function WorldLoadoutScreen:enter() self:_layout() end
function WorldLoadoutScreen:resize() self:_layout() end

function WorldLoadoutScreen:_layout()
  local w, h, scale = UIScale.dimensions()
  self.ui_scale = scale
  local compact = h < 680
  self.compact = compact
  local margin, gap = 34, 10
  local columns = w >= 760 and 8 or 6
  local tile_w = (w - margin * 2 - gap * (columns - 1)) / columns
  local tile_h = compact and 72 or 92
  local buttons, records = {}, {}
  local y = compact and 86 or 96

  local function add_group(kind, definitions, limit)
    if limit <= 0 then return nil end
    local rows = math.ceil(#definitions / columns)
    local group_h = rows * tile_h + (rows - 1) * gap + 48
    local group = { kind = kind, x = margin, y = y,
      w = w - margin * 2, h = group_h, limit = limit }
    for index, definition in ipairs(definitions) do
      local column = (index - 1) % columns
      local row = math.floor((index - 1) / columns)
      local rect = {
        x = margin + column * (tile_w + gap),
        y = y + 38 + row * (tile_h + gap), w = tile_w, h = tile_h,
      }
      local button = widgets.Button({ label = "", x = rect.x, y = rect.y,
        w = rect.w, h = rect.h, on_press = function()
          local changed = kind == "weapon"
            and self:toggle_weapon(definition.id)
            or self:toggle_passive(definition.id)
          if not changed then self.notice = 1.4 end
        end })
      buttons[#buttons + 1] = button
      records[#records + 1] = {
        kind = kind, definition = definition, button = button,
      }
    end
    y = y + group_h + 12
    return group
  end

  self.weapon_group = add_group("weapon", self.weapons, self.budget.weapons)
  self.passive_group = add_group("passive", self.passives, self.budget.passives)
  local cta_y = h - (compact and 66 or 74)
  local cta_w, cta_h = 248, compact and 48 or 54
  buttons[#buttons + 1] = widgets.Button({ label = "",
    x = w / 2 - cta_w - 8, y = cta_y, w = cta_w, h = cta_h,
    on_press = function() self:_start() end })
  self.start_button = buttons[#buttons]
  buttons[#buttons + 1] = widgets.Button({ label = "",
    x = w / 2 + 8, y = cta_y, w = cta_w, h = cta_h,
    on_press = function() self:_back() end })
  self.back_button = buttons[#buttons]
  self.records = records
  self.buttons = widgets.ButtonList(buttons)
end

function WorldLoadoutScreen:update(dt)
  self.notice = math.max(0, self.notice - dt)
end

function WorldLoadoutScreen:_draw_group(group, selected_count)
  if not group then return end
  love.graphics.setColor(0.035, 0.022, 0.075, 0.76)
  love.graphics.rectangle("fill", group.x, group.y, group.w, group.h, 10, 10)
  self.app.assets:draw_hud_frame(group.x, group.y, group.w, group.h,
    { corner = 9, color = { 0.36, 0.92, 1.0, 0.40 } })
  love.graphics.setColor(0.86, 0.85, 0.94, 1)
  love.graphics.setFont(Fonts.heading(14))
  local label = group.kind == "weapon" and "FREE STARTING WEAPONS"
    or "FREE STARTING SUPPORTS"
  love.graphics.print(label, group.x + 18, group.y + 13)
  love.graphics.setColor(0.34, 1.0, 0.68, 1)
  love.graphics.printf(selected_count .. " / " .. group.limit .. " SELECTED",
    group.x, group.y + 13, group.w - 18, "right")
end

function WorldLoadoutScreen:_draw_record(record)
  local button = record.button
  local selected = record.kind == "weapon"
    and self.selected_weapons[record.definition.id]
    or self.selected_passives[record.definition.id]
  local color = record.kind == "weapon"
    and { 0.30, 0.92, 1.0, 1 } or { 0.78, 0.42, 1.0, 1 }
  if selected or button.focused then
    love.graphics.setColor(color[1], color[2], color[3], selected and 0.18 or 0.09)
    love.graphics.rectangle("fill", button.x - 3, button.y - 3,
      button.w + 6, button.h + 6, 8, 8)
  end
  self.app.assets:draw_upgrade_card_frame(button.x, button.y, button.w, button.h,
    { corner = 24, color = { 1, 1, 1, selected and 1 or 0.78 } })
  if button.focused then
    self.app.assets:draw_menu_focus_frame(
      button.x - 4, button.y - 4, button.w + 8, button.h + 8,
      { corner = 25 })
  end
  if record.kind == "weapon" then
    self.app.assets:draw_weapon_icon(record.definition.icon,
      button.x + button.w / 2, button.y + (self.compact and 27 or 34),
      self.compact and 38 or 50)
  else
    self.app.assets:draw_support_icon(record.definition.icon,
      button.x + button.w / 2, button.y + (self.compact and 27 or 34),
      self.compact and 38 or 50)
  end
  love.graphics.setColor(selected and { 0.42, 1.0, 0.70, 1 }
    or settings.ui.text_color)
  love.graphics.setFont(Fonts.heading(self.compact and 9 or 11))
  love.graphics.printf(record.definition.name, button.x + 8,
    button.y + button.h - 25, button.w - 16, "center")
  if selected then
    self.app.assets:draw_upgrade_attribute_icon(8,
      button.x + button.w - 29, button.y + 7, 22)
  end
end

function WorldLoadoutScreen:_draw_cta(button, label, icon_col, primary)
  local alpha = button.focused and 1 or 0.82
  local color = primary and { 1, 0.74, 0.20, 1 } or { 0.30, 0.92, 1.0, 1 }
  self.app.assets:draw_upgrade_card_frame(button.x, button.y, button.w, button.h,
    { corner = 23, color = { 1, 1, 1, alpha } })
  if button.focused then
    self.app.assets:draw_menu_focus_frame(
      button.x - 4, button.y - 4, button.w + 8, button.h + 8,
      { corner = 24 })
  end
  self.app.assets:draw_world_interface(icon_col, 1,
    button.x + 10, button.y + 4, button.h - 8, button.h - 8,
    { color = { 1, 1, 1, alpha } })
  love.graphics.setColor(color[1], color[2], color[3], alpha)
  love.graphics.setFont(Fonts.heading(15))
  love.graphics.printf(label, button.x + 58,
    button.y + (button.h - Fonts.heading(15):getHeight()) / 2,
    button.w - 68, "center")
end

function WorldLoadoutScreen:draw()
  local screen_w, screen_h = love.graphics.getDimensions()
  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, screen_w, screen_h)
  local background = self.app.assets.campaign.title_background
  local background_scale = math.max(
    screen_w / background:getWidth(), screen_h / background:getHeight())
  love.graphics.setColor(1, 1, 1, 0.20)
  love.graphics.draw(background, screen_w / 2, screen_h / 2, 0,
    background_scale, background_scale,
    background:getWidth() / 2, background:getHeight() / 2)
  love.graphics.setColor(0.008, 0.004, 0.028, 0.82)
  love.graphics.rectangle("fill", 0, 0, screen_w, screen_h)
  local w, h = UIScale.begin()

  love.graphics.setColor(1, 0.76, 0.22, 1)
  love.graphics.setFont(Fonts.heading(h < 680 and 27 or 34))
  love.graphics.printf("BUILD YOUR " .. string.upper(self.world.genre) .. " START",
    0, 22, w, "center")
  love.graphics.setColor(0.78, 0.77, 0.88, 1)
  love.graphics.setFont(Fonts.body(13))
  love.graphics.printf("Choose the free gear this world grants before the stage begins.",
    0, 59, w, "center")

  self:_draw_group(self.weapon_group, #self.weapon_order)
  self:_draw_group(self.passive_group, #self.passive_order)
  for _, record in ipairs(self.records) do self:_draw_record(record) end
  self:_draw_cta(self.start_button, "START WORLD", 2, true)
  self:_draw_cta(self.back_button, "BACK", 1, false)
  if self.notice > 0 then
    love.graphics.setColor(1, 0.48, 0.62, math.min(1, self.notice))
    love.graphics.setFont(Fonts.body(12))
    love.graphics.printf("Complete the free loadout selection first.",
      0, h - 98, w, "center")
  end
  UIScale.finish()
end

function WorldLoadoutScreen:keypressed(key)
  if key == "escape" then self:_back() return true end
  return self.buttons:keypressed(key)
end

function WorldLoadoutScreen:gamepadpressed(_, button)
  if button == "b" then self:_back() return true end
  return self.buttons:gamepadpressed(button)
end

function WorldLoadoutScreen:mousemoved(x, y)
  x, y = UIScale.point(x, y, self.ui_scale)
  self.buttons:mousemoved(x, y)
end

function WorldLoadoutScreen:mousepressed(x, y, button)
  x, y = UIScale.point(x, y, self.ui_scale)
  return self.buttons:mousepressed(x, y, button)
end

return WorldLoadoutScreen
