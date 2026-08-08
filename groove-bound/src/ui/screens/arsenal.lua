-- Navigable in-game weapon database. Uses the same stable content and live
-- progression state as the level-up generator.

local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")

local ArsenalScreen = class()
ArsenalScreen.kind = "arsenal"

local filters = {
  { id = "all", label = "ALL" },
  { id = "base", label = "BASE" },
  { id = "evolved", label = "EVOLVED" },
  { id = "supports", label = "SUPPORTS" },
  { id = "owned", label = "OWNED" },
  { id = "level_up", label = "LEVEL-UP POOL" },
}

local rarity_colors = {
  common = { 0.52, 0.72, 0.94, 1 },
  uncommon = { 0.32, 0.92, 0.70, 1 },
  rare = { 0.78, 0.40, 1.0, 1 },
  evolved = { 1.0, 0.70, 0.18, 1 },
}

local support_color = { 0.72, 0.42, 1.0, 1 }
local support_stat_names = {
  speed = "MOVE SPEED",
  max_hp = "MAX HEALTH",
  damage = "DAMAGE",
  magnet = "PICKUP RANGE",
  cooldown_stability = "COOLDOWN",
  fire_rate = "FIRE RATE",
  amount = "PROJECTILE AMOUNT",
  guard = "GUARD",
}

local function support_value(definition)
  if definition.stat == "amount" or definition.stat == "guard" then
    return "+" .. definition.per_level .. " PER RANK"
  end
  return "+" .. math.floor(definition.per_level * 100 + 0.5) .. "% PER RANK"
end

function ArsenalScreen:init(app)
  self.app = app
  self.filter_index = 1
  self.selected = 1
  self.page = 1
  self.card_rects = {}
  self.tab_rects = {}
end

function ArsenalScreen:enter()
  self:_refresh()
  self:_layout()
end

function ArsenalScreen:_run()
  return self.app.active_run
end

function ArsenalScreen:_refresh()
  local filter = filters[self.filter_index].id
  self.entries = self.app.weapon_catalog:list(self:_run(), filter)
  self.counts = self.app.weapon_catalog:counts(self:_run())
  self.selected = math.max(1, math.min(self.selected, math.max(1, #self.entries)))
end

function ArsenalScreen:_layout()
  local w, h = love.graphics.getDimensions()
  self.header_h = 126
  self.footer_h = 54
  self.detail_w = math.max(290, math.min(390, w * 0.31))
  self.grid_x = 24
  self.grid_y = self.header_h + 16
  self.grid_w = w - self.detail_w - 64
  self.grid_h = h - self.grid_y - self.footer_h
  self.columns = self.grid_w >= 720 and 2 or 1
  self.card_gap = 12
  self.card_h = 132
  self.card_w = (self.grid_w - self.card_gap * (self.columns - 1)) / self.columns
  self.rows = math.max(1, math.floor((self.grid_h + self.card_gap) / (self.card_h + self.card_gap)))
  self.per_page = self.columns * self.rows
  self.max_page = math.max(1, math.ceil(#self.entries / self.per_page))
  self.page = math.max(1, math.min(self.page, self.max_page))
  self.detail = {
    x = w - self.detail_w - 24,
    y = self.grid_y,
    w = self.detail_w,
    h = self.grid_h,
  }
end

function ArsenalScreen:resize()
  self:_layout()
end

function ArsenalScreen:_set_filter(index)
  self.filter_index = ((index - 1) % #filters) + 1
  self.selected, self.page = 1, 1
  self:_refresh()
  self:_layout()
end

function ArsenalScreen:_ensure_page()
  self.page = math.floor((self.selected - 1) / self.per_page) + 1
end

local function draw_chip(text, x, y, color)
  local font = Fonts.get(14)
  local width = font:getWidth(text) + 18
  love.graphics.setColor(color[1], color[2], color[3], 0.16)
  love.graphics.rectangle("fill", x, y, width, 26, 3, 3)
  love.graphics.setColor(color)
  love.graphics.setFont(font)
  love.graphics.print(text, x + 9, y + 5)
  return width
end

function ArsenalScreen:_draw_header(w)
  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.setFont(Fonts.get(34))
  love.graphics.print("ARSENAL DATABASE", 24, 18)
  love.graphics.setColor(0.72, 0.70, 0.80, 1)
  love.graphics.setFont(Fonts.get(16))
  love.graphics.print(
    string.format("%d weapons  •  %d base  •  %d evolutions  •  %d currently owned",
      self.counts.all, self.counts.base, self.counts.evolved, self.counts.owned),
    26, 58)

  self.tab_rects = {}
  local x = 24
  for index, tab in ipairs(filters) do
    local count = self.counts[tab.id]
    local label = tab.label .. " " .. count
    local width = Fonts.get(15):getWidth(label) + 30
    local rect = { x = x, y = 84, w = width, h = 30 }
    self.tab_rects[index] = rect
    local selected = index == self.filter_index
    love.graphics.setColor(selected and { 0.28, 0.23, 0.45, 1 } or { 0.10, 0.09, 0.16, 1 })
    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 4, 4)
    love.graphics.setColor(selected and settings.ui.accent_color or settings.ui.button.border)
    love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 4, 4)
    love.graphics.setFont(Fonts.get(15))
    love.graphics.printf(label, rect.x, rect.y + 6, rect.w, "center")
    x = x + width + 8
  end
  love.graphics.setColor(0.32, 0.28, 0.42, 1)
  love.graphics.line(24, 122, w - 24, 122)
end

function ArsenalScreen:_draw_card(entry, rect, index)
  if entry.kind == "support" then
    local selected = index == self.selected
    love.graphics.setColor(
      selected and { 0.18, 0.15, 0.28, 1 } or { 0.09, 0.08, 0.14, 0.96 })
    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 7, 7)
    love.graphics.setColor(selected and settings.ui.accent_color or support_color)
    love.graphics.setLineWidth(selected and 3 or 1)
    love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 7, 7)
    self.app.assets:draw_support_icon(
      entry.icon, rect.x + 62, rect.y + rect.h / 2, 100)
    local text_x = rect.x + 122
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.get(16))
    love.graphics.print(entry.definition.name, text_x, rect.y + 14)
    love.graphics.setColor(support_color)
    love.graphics.setFont(Fonts.get(14))
    love.graphics.print(
      support_stat_names[entry.definition.stat] or string.upper(entry.definition.stat),
      text_x, rect.y + 39)
    draw_chip(entry.status, text_x, rect.y + 63, support_color)
    love.graphics.setColor(0.68, 0.66, 0.76, 1)
    love.graphics.setFont(Fonts.get(14))
    love.graphics.print(support_value(entry.definition), text_x, rect.y + 98)
    return
  end

  local selected = index == self.selected
  local rarity = rarity_colors[entry.definition.rarity] or rarity_colors.common
  love.graphics.setColor(selected and { 0.18, 0.15, 0.28, 1 } or { 0.09, 0.08, 0.14, 0.96 })
  love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 7, 7)
  love.graphics.setColor(selected and settings.ui.accent_color or { rarity[1], rarity[2], rarity[3], 0.55 })
  love.graphics.setLineWidth(selected and 3 or 1)
  love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 7, 7)

  self.app.assets:draw_weapon_icon(
    entry.icon, rect.x + 62, rect.y + rect.h / 2, 102,
    { color = entry.definition.evolved and { 1, 0.82, 0.34, 1 } or { 1, 1, 1, 1 } })
  local text_x = rect.x + 122
  love.graphics.setColor(settings.ui.text_color)
  love.graphics.setFont(Fonts.get(16))
  love.graphics.print(entry.definition.name, text_x, rect.y + 14)
  love.graphics.setColor(rarity)
  love.graphics.setFont(Fonts.get(14))
  love.graphics.print(string.upper(entry.definition.role), text_x, rect.y + 39)
  draw_chip(entry.status, text_x, rect.y + 63,
    entry.active and { 0.30, 1.0, 0.68, 1 } or rarity)
  love.graphics.setColor(0.68, 0.66, 0.76, 1)
  love.graphics.setFont(Fonts.get(14))
  love.graphics.print(
    string.format("DMG %d  •  CD %.2fs  •  ×%d",
      entry.first.damage, entry.first.cooldown, entry.first.count or 1),
    text_x, rect.y + 98)
end

function ArsenalScreen:_draw_detail(entry)
  if entry.kind == "support" then
    self:_draw_support_detail(entry)
    return
  end
  local rect = self.detail
  local compact = rect.h < 500
  love.graphics.setColor(0.075, 0.065, 0.12, 0.98)
  love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 8, 8)
  local rarity = rarity_colors[entry.definition.rarity] or rarity_colors.common
  love.graphics.setColor(rarity)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 8, 8)
  self.app.assets:draw_weapon_icon(
    entry.icon,
    rect.x + rect.w / 2,
    rect.y + (compact and 55 or 100),
    compact and 90 or 170)

  love.graphics.setColor(settings.ui.text_color)
  love.graphics.setFont(Fonts.get(compact and 19 or 23))
  love.graphics.printf(
    entry.definition.name,
    rect.x + 16,
    rect.y + (compact and 104 or 182),
    rect.w - 32,
    "center")
  love.graphics.setColor(rarity)
  love.graphics.setFont(Fonts.get(15))
  love.graphics.printf(
    string.upper(entry.definition.role) .. "  •  " .. string.upper(entry.definition.rarity),
    rect.x + 16, rect.y + (compact and 132 or 215), rect.w - 32, "center")
  love.graphics.setColor(0.76, 0.74, 0.84, 1)
  love.graphics.setFont(Fonts.get(compact and 14 or 16))
  love.graphics.printf(entry.definition.description,
    rect.x + 24, rect.y + (compact and 158 or 248), rect.w - 48, "left")

  local y = rect.y + (compact and 218 or 310)
  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.setFont(Fonts.get(16))
  love.graphics.print("RANK 1  →  RANK " .. entry.definition.max_level, rect.x + 24, y)
  love.graphics.setColor(settings.ui.text_color)
  love.graphics.setFont(Fonts.get(15))
  love.graphics.print(
    string.format("Damage       %d  →  %d", entry.first.damage, entry.maximum.damage),
    rect.x + 24, y + 30)
  love.graphics.print(
    string.format("Cooldown     %.2fs  →  %.2fs", entry.first.cooldown, entry.maximum.cooldown),
    rect.x + 24, y + 53)
  love.graphics.print(
    string.format("Projectiles  %d  →  %d", entry.first.count or 1, entry.maximum.count or 1),
    rect.x + 24, y + 76)
  love.graphics.print(
    "Pattern      " .. string.upper(entry.definition.pattern),
    rect.x + 24, y + 99)

  love.graphics.setColor(rarity)
  love.graphics.setFont(Fonts.get(16))
  love.graphics.print("ACQUISITION", rect.x + 24, y + (compact and 118 or 138))
  love.graphics.setColor(0.76, 0.74, 0.84, 1)
  love.graphics.setFont(Fonts.get(15))
  local acquisition
  if entry.recipe then
    local support = self.app.content.passives[
      entry.recipe.required_passives[1].id]
    acquisition = "Evolution only: "
      .. self.app.content.weapons[entry.recipe.base_weapon].name
      .. " R" .. entry.recipe.required_weapon_level
      .. " + " .. support.name .. ". Both components are consumed."
  elseif entry.active then
    acquisition = "Active in weapon slot " .. entry.slot
      .. ". Rank upgrades remain in the level-up pool."
  elseif entry.available_to_offer then
    acquisition = "Purchasable from normal level-up cards while a weapon slot is free."
  else
    acquisition = "Not currently purchasable because all weapon slots are occupied."
  end
  love.graphics.printf(
    acquisition,
    rect.x + 24,
    y + (compact and 141 or 163),
    rect.w - 48,
    "left")
end

function ArsenalScreen:_draw_support_detail(entry)
  local rect = self.detail
  local compact = rect.h < 500
  love.graphics.setColor(0.075, 0.065, 0.12, 0.98)
  love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 8, 8)
  love.graphics.setColor(support_color)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 8, 8)
  self.app.assets:draw_support_icon(
    entry.icon, rect.x + rect.w / 2, rect.y + (compact and 68 or 108),
    compact and 105 or 178)

  love.graphics.setColor(settings.ui.text_color)
  love.graphics.setFont(Fonts.get(compact and 19 or 23))
  love.graphics.printf(
    entry.definition.name, rect.x + 16, rect.y + (compact and 126 or 200),
    rect.w - 32, "center")
  love.graphics.setColor(support_color)
  love.graphics.setFont(Fonts.get(15))
  love.graphics.printf(
    support_stat_names[entry.definition.stat] or string.upper(entry.definition.stat),
    rect.x + 16, rect.y + (compact and 154 or 234), rect.w - 32, "center")
  love.graphics.setColor(0.76, 0.74, 0.84, 1)
  love.graphics.setFont(Fonts.get(16))
  love.graphics.printf(
    entry.definition.description,
    rect.x + 24, rect.y + (compact and 184 or 270), rect.w - 48, "left")

  local y = rect.y + (compact and 242 or 334)
  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.setFont(Fonts.get(16))
  love.graphics.print("ENHANCEMENT", rect.x + 24, y)
  love.graphics.setColor(settings.ui.text_color)
  love.graphics.setFont(Fonts.get(15))
  love.graphics.print(support_value(entry.definition), rect.x + 24, y + 28)
  love.graphics.print(
    "Maximum rank  " .. entry.definition.max_level,
    rect.x + 24, y + 51)

  love.graphics.setColor(support_color)
  love.graphics.setFont(Fonts.get(16))
  love.graphics.print("FUSION PAIRINGS", rect.x + 24, y + 90)
  love.graphics.setColor(0.76, 0.74, 0.84, 1)
  love.graphics.setFont(Fonts.get(15))
  if #entry.recipes == 0 then
    love.graphics.print("No fusion recipe authored yet.", rect.x + 24, y + 116)
  else
    for index, record in ipairs(entry.recipes) do
      love.graphics.printf(
        record.base.name .. " R" .. record.recipe.required_weapon_level
          .. "  →  " .. record.result.name,
        rect.x + 24, y + 116 + (index - 1) * 24, rect.w - 48, "left")
    end
  end
end

function ArsenalScreen:draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, w, h)
  self:_draw_header(w)

  self.card_rects = {}
  local first = (self.page - 1) * self.per_page + 1
  local last = math.min(#self.entries, first + self.per_page - 1)
  for index = first, last do
    local visible = index - first
    local col = visible % self.columns
    local row = math.floor(visible / self.columns)
    local rect = {
      x = self.grid_x + col * (self.card_w + self.card_gap),
      y = self.grid_y + row * (self.card_h + self.card_gap),
      w = self.card_w,
      h = self.card_h,
    }
    self.card_rects[index] = rect
    self:_draw_card(self.entries[index], rect, index)
  end

  if self.entries[self.selected] then self:_draw_detail(self.entries[self.selected]) end
  love.graphics.setColor(0.62, 0.60, 0.70, 1)
  love.graphics.setFont(Fonts.get(15))
  love.graphics.printf(
    string.format("Arrows/WASD navigate  •  [ / ] changes filter  •  Esc/B closes  •  Page %d/%d",
      self.page, self.max_page),
    24, h - 32, w - 48, "center")
end

function ArsenalScreen:keypressed(key)
  if key == "escape" then self.app.states:pop() return true end
  if key == "]" then self:_set_filter(self.filter_index + 1) return true end
  if key == "[" then self:_set_filter(self.filter_index - 1) return true end
  local delta
  if key == "left" or key == "a" then delta = -1
  elseif key == "right" or key == "d" then delta = 1
  elseif key == "up" or key == "w" then delta = -self.columns
  elseif key == "down" or key == "s" then delta = self.columns end
  if delta and #self.entries > 0 then
    self.selected = ((self.selected - 1 + delta) % #self.entries) + 1
    self:_ensure_page()
    return true
  end
  return false
end

function ArsenalScreen:gamepadpressed(_, button)
  if button == "b" then self.app.states:pop() return true end
  if button == "leftshoulder" then self:_set_filter(self.filter_index - 1) return true end
  if button == "rightshoulder" then self:_set_filter(self.filter_index + 1) return true end
  local mapping = { dpleft = "left", dpright = "right", dpup = "up", dpdown = "down" }
  if mapping[button] then return self:keypressed(mapping[button]) end
  return false
end

function ArsenalScreen:mousemoved(x, y)
  for index, rect in pairs(self.card_rects) do
    if x >= rect.x and x <= rect.x + rect.w and y >= rect.y and y <= rect.y + rect.h then
      self.selected = index
      return true
    end
  end
  return false
end

function ArsenalScreen:mousepressed(x, y, button)
  if button ~= 1 then return false end
  for index, rect in ipairs(self.tab_rects) do
    if x >= rect.x and x <= rect.x + rect.w and y >= rect.y and y <= rect.y + rect.h then
      self:_set_filter(index)
      return true
    end
  end
  return self:mousemoved(x, y)
end

return ArsenalScreen
