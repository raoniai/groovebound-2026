local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")
local UIScale = require("src.ui.scale")
local JourneyProgress = require("src.meta.journey_progress")
local MenuChrome = require("src.ui.menu_chrome")
local LoadoutPreview = require("src.ui.loadout_preview")

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
    mode = "world_tour", world_id = self.world.id,
    character_id = self.character_id, starter_loadout = self:selection(),
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
  local margin, outer_gap, tile_gap = 22, 14, 6
  local side_w = math.max(236, math.min(380, w * 0.31))
  local content_w = w - margin * 2 - outer_gap - side_w
  local columns = content_w >= 690 and 5 or 4
  local tile_w = (content_w - tile_gap * (columns - 1)) / columns
  local tile_h = compact and 46 or 64
  local buttons, records = {}, {}
  local y = compact and 74 or 82

  local function add_group(kind, definitions, limit)
    if limit <= 0 then return nil end
    local rows = math.ceil(#definitions / columns)
    local group_h = rows * tile_h + (rows - 1) * tile_gap + 30
    local group = { kind = kind, x = margin, y = y,
      w = content_w, h = group_h, limit = limit }
    for index, definition in ipairs(definitions) do
      local column = (index - 1) % columns
      local row = math.floor((index - 1) / columns)
      local rect = { x = margin + column * (tile_w + tile_gap),
        y = y + 26 + row * (tile_h + tile_gap), w = tile_w, h = tile_h }
      local button = widgets.Button({ label = "", x = rect.x, y = rect.y,
        w = rect.w, h = rect.h, on_press = function()
          local changed = kind == "weapon" and self:toggle_weapon(definition.id)
            or self:toggle_passive(definition.id)
          if not changed then self.notice = 1.4 end
        end })
      buttons[#buttons + 1] = button
      records[#records + 1] = { kind = kind, definition = definition, button = button }
    end
    y = y + group_h + 8
    return group
  end

  self.weapon_group = add_group("weapon", self.weapons, self.budget.weapons)
  self.passive_group = add_group("passive", self.passives, self.budget.passives)
  local cta_y = h - (compact and 54 or 62)
  local cta_w, cta_h = math.min(236, content_w * 0.44), compact and 42 or 48
  buttons[#buttons + 1] = widgets.Button({ label = "",
    x = margin + content_w / 2 - cta_w - 5, y = cta_y,
    w = cta_w, h = cta_h, on_press = function() self:_start() end })
  self.start_button = buttons[#buttons]
  buttons[#buttons + 1] = widgets.Button({ label = "",
    x = margin + content_w / 2 + 5, y = cta_y,
    w = cta_w, h = cta_h, on_press = function() self:_back() end })
  self.back_button = buttons[#buttons]
  self.sidebar = { x = margin + content_w + outer_gap, y = compact and 74 or 82,
    w = side_w, h = cta_y + cta_h - (compact and 74 or 82) }
  self.records = records
  self.buttons = widgets.ButtonList(buttons)
end

function WorldLoadoutScreen:update(dt)
  self.notice = math.max(0, self.notice - dt)
end

function WorldLoadoutScreen:_draw_group(group, selected_count)
  if not group then return end
  love.graphics.setColor(0.035, 0.022, 0.075, 0.76)
  love.graphics.rectangle("fill", group.x, group.y, group.w, group.h, 6, 6)
  MenuChrome.panel(self.app.assets, group, { corner = 20, alpha = 0.54 })
  love.graphics.setColor(0.86, 0.85, 0.94, 1)
  love.graphics.setFont(Fonts.heading(self.compact and 10 or 12))
  local label = group.kind == "weapon" and "STARTING WEAPON" or "STARTING SUPPORT"
  love.graphics.print(label, group.x + 12, group.y + 8)
  love.graphics.setColor(0.38, 1.0, 0.70, 1)
  love.graphics.printf(selected_count .. " / " .. group.limit .. " SELECTED",
    group.x + group.w - 156, group.y + 8, 144, "right")
end

function WorldLoadoutScreen:_draw_record(record)
  local button = record.button
  local selected = record.kind == "weapon"
    and self.selected_weapons[record.definition.id]
    or self.selected_passives[record.definition.id]
  love.graphics.setColor(selected and { 0.06, 0.24, 0.19, 0.95 }
    or { 0.018, 0.012, 0.05, 0.96 })
  love.graphics.rectangle("fill", button.x + 2, button.y + 2,
    button.w - 4, button.h - 4, 4, 4)
  self.app.assets:draw_upgrade_card_frame(button.x, button.y, button.w, button.h, {
    corner = math.min(10, button.h * 0.22),
    color = selected and { 0.38, 1.0, 0.70, 0.90 }
      or { 0.35, 0.88, 1.0, button.focused and 0.86 or 0.44 },
  })
  if button.focused then MenuChrome.focus(self.app.assets, button, { corner = 15 }) end
  local icon_size = math.min(button.h - 8, self.compact and 32 or 44)
  local icon_x = button.x + 7 + icon_size / 2
  local icon_y = button.y + button.h / 2
  if record.kind == "weapon" then
    self.app.assets:draw_weapon_icon(record.definition.icon, icon_x, icon_y, icon_size)
  else
    self.app.assets:draw_support_icon(record.definition.icon, icon_x, icon_y, icon_size)
  end
  love.graphics.setFont(Fonts.heading(self.compact and 8 or 10))
  love.graphics.setColor(selected and { 0.44, 1.0, 0.72, 1 } or settings.ui.text_color)
  love.graphics.printf(record.definition.name, button.x + icon_size + 13,
    button.y + (button.h - Fonts.heading(self.compact and 8 or 10):getHeight()) / 2,
    button.w - icon_size - 19, "left")
end

function WorldLoadoutScreen:_focused_record()
  local focused = self.buttons and self.buttons.focus_index or 1
  return self.records[focused]
end

function WorldLoadoutScreen:_evolution(record)
  if not record then return nil end
  local matches = {}
  for _, recipe in pairs(self.app.content.evolutions) do
    local matches_record = record.kind == "weapon"
      and recipe.base_weapon == record.definition.id
    if record.kind == "passive" then
      for _, required in ipairs(recipe.required_passives or {}) do
        if required.id == record.definition.id then matches_record = true break end
      end
    end
    if matches_record then matches[#matches + 1] = recipe end
  end
  table.sort(matches, function(a, b) return a.name < b.name end)
  return matches[1], #matches
end

local stat_rows = {
  { id = "damage", label = "START DAMAGE", format = function(v) return tostring(math.floor(v + 0.5)) end },
  { id = "projectiles", label = "PROJECTILES", format = tostring },
  { id = "max_hp", label = "MAX HP", format = tostring },
  { id = "guard", label = "GUARD", format = tostring },
  { id = "speed", label = "MOVE SPEED", format = function(v) return string.format("%.2fx", v) end },
  { id = "fire_rate", label = "FIRE RATE", format = function(v) return string.format("%.2fx", v) end },
}

function WorldLoadoutScreen:_draw_sidebar()
  local d = self.sidebar
  love.graphics.setColor(0.022, 0.012, 0.058, 0.97)
  love.graphics.rectangle("fill", d.x, d.y, d.w, d.h, 8, 8)
  MenuChrome.panel(self.app.assets, d, { corner = 28, alpha = 0.82 })
  local record = self:_focused_record()
  local current = LoadoutPreview.compute(self.app.content, self.character_id,
    self.weapon_order, self.passive_order)
  local preview = record and LoadoutPreview.compute(self.app.content,
    self.character_id, self.weapon_order, self.passive_order,
    { kind = record.kind, id = record.definition.id }) or current
  love.graphics.setFont(Fonts.heading(13)); love.graphics.setColor(1, 0.76, 0.22, 1)
  love.graphics.print("STARTING STATS", d.x + 14, d.y + 14)
  love.graphics.setFont(Fonts.body(9)); love.graphics.setColor(0.64, 0.72, 0.86, 1)
  love.graphics.print("CURRENT", d.x + d.w - 112, d.y + 17)
  love.graphics.setColor(0.40, 1.0, 0.70, 1)
  love.graphics.print("WITH", d.x + d.w - 55, d.y + 17)
  local row_y = d.y + 44
  for _, row in ipairs(stat_rows) do
    local before, after = row.format(current[row.id]), row.format(preview[row.id])
    love.graphics.setFont(Fonts.body(9)); love.graphics.setColor(0.72, 0.74, 0.84, 1)
    love.graphics.print(row.label, d.x + 14, row_y)
    love.graphics.setColor(0.88, 0.90, 0.98, 1)
    love.graphics.printf(before, d.x + d.w - 116, row_y, 50, "right")
    love.graphics.setColor(after ~= before and { 0.40, 1.0, 0.70, 1 }
      or { 0.55, 0.58, 0.68, 1 })
    love.graphics.printf(after, d.x + d.w - 58, row_y, 46, "right")
    row_y = row_y + (self.compact and 17 or 20)
  end

  local divider_y = row_y + 4
  love.graphics.setColor(0.24, 0.74, 0.92, 0.34)
  love.graphics.rectangle("fill", d.x + 14, divider_y, d.w - 28, 1)
  local recipe, match_count = self:_evolution(record)
  love.graphics.setFont(Fonts.heading(11)); love.graphics.setColor(0.40, 0.90, 1, 1)
  love.graphics.print("EVOLUTION COMBO", d.x + 14, divider_y + 12)
  if not record then
    love.graphics.setFont(Fonts.body(9)); love.graphics.setColor(0.64, 0.67, 0.78, 1)
    love.graphics.printf("Hover a weapon or support to preview its evolution.",
      d.x + 14, divider_y + 36, d.w - 28, "left")
    return
  end
  if recipe then
    local base = self.app.content.weapons[recipe.base_weapon]
    local support = self.app.content.passives[recipe.required_passives[1].id]
    local result = self.app.content.weapons[recipe.result_weapon]
    local icon_y = divider_y + (self.compact and 62 or 70)
    local icon_size = self.compact and 34 or 42
    local centers = { d.x + d.w * 0.19, d.x + d.w * 0.50, d.x + d.w * 0.81 }
    self.app.assets:draw_weapon_icon(base.icon, centers[1], icon_y, icon_size)
    self.app.assets:draw_support_icon(support.icon, centers[2], icon_y, icon_size)
    self.app.assets:draw_weapon_icon(result.icon, centers[3], icon_y, icon_size)
    love.graphics.setFont(Fonts.heading(12)); love.graphics.setColor(1, 0.80, 0.28, 1)
    love.graphics.printf("+", centers[1] + icon_size / 2, icon_y - 7,
      centers[2] - centers[1] - icon_size, "center")
    love.graphics.printf("=", centers[2] + icon_size / 2, icon_y - 7,
      centers[3] - centers[2] - icon_size, "center")
    love.graphics.setFont(Fonts.body(8)); love.graphics.setColor(0.84, 0.85, 0.94, 1)
    local label_y = icon_y + icon_size / 2 + 7
    love.graphics.printf(base.name, d.x + 5, label_y, d.w * 0.30, "center")
    love.graphics.printf(support.name, d.x + d.w * 0.35, label_y, d.w * 0.30, "center")
    love.graphics.printf(result.name, d.x + d.w * 0.65, label_y, d.w * 0.30, "center")
    if match_count > 1 then
      love.graphics.setColor(0.55, 0.84, 0.96, 1)
      love.graphics.printf("+ " .. (match_count - 1) .. " OTHER COMBO"
        .. (match_count > 2 and "S" or ""), d.x + 14, label_y + 22,
        d.w - 28, "center")
    end
  else
    love.graphics.setFont(Fonts.body(9)); love.graphics.setColor(0.70, 0.72, 0.82, 1)
    love.graphics.printf("No evolution pairing is available.",
      d.x + 14, divider_y + 38, d.w - 28, "left")
  end
end

function WorldLoadoutScreen:_draw_cta(button, label, menu_cell, primary)
  button.variant = primary and "primary" or "default"
  MenuChrome.action(self.app.assets, button, {
    menu_cell = menu_cell, label = label,
    font_size = self.compact and 12 or 14, icon_size = button.h - 8,
  })
end

function WorldLoadoutScreen:draw()
  local sw, sh = love.graphics.getDimensions()
  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, sw, sh)
  local campaign = self.app.assets.campaign
  if campaign and campaign.title_background then
    local image = campaign.title_background
    local cover = math.max(sw / image:getWidth(), sh / image:getHeight())
    love.graphics.setColor(1, 1, 1, 0.26)
    love.graphics.draw(image, sw/2, sh/2, 0, cover, cover,
      image:getWidth()/2, image:getHeight()/2)
  end
  love.graphics.setColor(0.008, 0.004, 0.028, 0.82)
  love.graphics.rectangle("fill", 0, 0, sw, sh)
  local w = UIScale.begin()
  love.graphics.setFont(Fonts.heading(self.compact and 24 or 30))
  love.graphics.setColor(1, 0.76, 0.20, 1)
  love.graphics.printf("BUILD YOUR " .. string.upper(self.world.genre) .. " START",
    0, self.compact and 10 or 13, w, "center")
  love.graphics.setFont(Fonts.body(10)); love.graphics.setColor(0.74, 0.75, 0.86, 1)
  love.graphics.printf("Choose the free gear this world grants before the stage begins.",
    0, self.compact and 42 or 52, w, "center")
  self:_draw_group(self.weapon_group, #self.weapon_order)
  self:_draw_group(self.passive_group, #self.passive_order)
  for _, record in ipairs(self.records) do self:_draw_record(record) end
  self:_draw_sidebar()
  self:_draw_cta(self.start_button, "START WORLD", 2, true)
  self:_draw_cta(self.back_button, "BACK", 8, false)
  if self.notice > 0 then
    love.graphics.setColor(1, 0.48, 0.62, math.min(1, self.notice))
    love.graphics.setFont(Fonts.body(9))
    love.graphics.printf("Complete the free loadout selection first.",
      self.start_button.x, self.start_button.y - 18,
      self.start_button.w * 2 + 10, "center")
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
