local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local widgets = require("src.ui.widgets.button")
local UIScale = require("src.ui.scale")
local PerkProgress = require("src.meta.perk_progress")
local PerkSummary = require("src.ui.perk_summary")
local RankBadge = require("src.ui.rank_badge")
local MenuChrome = require("src.ui.menu_chrome")

local PerkDatabase = class()
PerkDatabase.kind = "perk_database"

function PerkDatabase:init(app, opts)
  self.app, self.opts = app, opts or {}
  self.catalog_only = self.opts.catalog_only == true
  self.selected, self.notice, self.notice_kind = 1, "", "neutral"
  self.perks = {}
  for _, perk in pairs(app.content.meta_perks) do
    self.perks[#self.perks + 1] = perk
  end
  table.sort(self.perks, function(a, b) return a.sprite.cell < b.sprite.cell end)
end

function PerkDatabase:enter() self:_layout() end
function PerkDatabase:resize() self:_layout() end

function PerkDatabase:_owned(perk)
  return self.app.slot and self.app.slot.perks
    and self.app.slot.perks[perk.id]
end

function PerkDatabase:_buy()
  local perk = self.perks[self.selected]
  local owned, err = PerkProgress.purchase(self.app, perk.id)
  self.notice = owned and (string.upper(perk.name) .. " UPGRADED")
    or ({ locked = "CONTINUE THE WORLD TOUR TO UNLOCK",
      max_rank = "MAX RANK REACHED", insufficient_funds = "NOT ENOUGH TOUR COINS",
      no_campaign = "START A CAMPAIGN FIRST" })[err] or "PURCHASE UNAVAILABLE"
  self.notice_kind = owned and "success" or "error"
end

function PerkDatabase:_back()
  local Title = require("src.ui.screens.title")
  self.app.states:switch(Title(self.app))
end

function PerkDatabase:_layout()
  local w, h, scale = UIScale.dimensions()
  self.ui_scale = scale
  local margin, gap = 24, 14
  local grid_w = math.floor((w - margin * 2 - gap) * 0.66)
  self.grid = { x = margin, y = 96, w = grid_w, h = h - 120 }
  self.detail = { x = margin + grid_w + gap, y = 96,
    w = w - margin * 2 - grid_w - gap, h = h - 120 }
  self.columns = w < 980 and 3 or 4
  local card_gap = h < 680 and 5 or 7
  local cw = (grid_w - card_gap * (self.columns - 1)) / self.columns
  local rows = math.ceil(#self.perks / self.columns)
  local ch = (self.grid.h - card_gap * (rows - 1)) / rows
  self.card_rects = {}
  for i = 1, #self.perks do
    local col, row = (i - 1) % self.columns, math.floor((i - 1) / self.columns)
    self.card_rects[i] = { x = self.grid.x + col * (cw + card_gap),
      y = self.grid.y + row * (ch + card_gap), w = cw, h = ch }
  end
  local cta_gap = 8
  local cta_w = (self.detail.w - 20 - cta_gap) / 2
  local cta_y = self.detail.y + self.detail.h - 60
  local function button(opts)
    opts.renderer = function(value)
      MenuChrome.action(self.app.assets, value, {
        menu_cell = opts.menu_cell, label = value.label,
        font_size = opts.font_size, icon_size = 34,
      })
    end
    return widgets.Button(opts)
  end
  self.buttons = widgets.ButtonList({
    button({ label = "UPGRADE", x = self.detail.x + 6, y = cta_y,
      w = cta_w, h = 46, variant = "primary", font_size = 12, menu_cell = 5,
      on_press = function() self:_buy() end }),
    button({ label = "BACK", x = self.detail.x + 6 + cta_w + cta_gap,
      y = cta_y, w = cta_w, h = 46, font_size = 12, menu_cell = 8,
      on_press = function() self:_back() end }),
  })
end

local function source_label(source)
  if source.type == "prologue_clear" then return "COMPLETE THE PROLOGUE" end
  return "REACH " .. string.upper((source.world_id or "WORLD"):gsub("_", " "))
    .. " GRADE " .. (source.grade or "?")
end

local function draw_device(assets, x, y, size, value, maxed)
  RankBadge.draw(assets, x, y, size, value, { maxed = maxed })
end

function PerkDatabase:_draw_card(index, perk)
  local r, owned = self.card_rects[index], self:_owned(perk)
  local selected = index == self.selected
  love.graphics.setColor(selected and { 0.17, 0.065, 0.24, 0.90 }
    or { 0.035, 0.018, 0.075, 0.84 })
  love.graphics.rectangle("fill", r.x + 3, r.y + 3, r.w - 6, r.h - 6, 4, 4)
  self.app.assets:draw_upgrade_card_frame(r.x, r.y, r.w, r.h, {
    corner = math.min(14, r.h * 0.22),
    color = selected and { 1, 0.76, 0.22, 0.98 }
      or owned and { 0.32, 0.92, 1, 0.72 } or { 0.48, 0.44, 0.62, 0.40 },
  })
  local icon_size = math.min(58, r.h - 10, r.w * 0.31)
  local icon_x, icon_y = r.x + 7, r.y + (r.h - icon_size) / 2
  self.app.assets:draw_meta_perk(owned and perk.sprite.cell or 20,
    icon_x, icon_y, icon_size, icon_size,
    { color = owned and { 1, 1, 1, 1 } or { 0.50, 0.46, 0.60, 0.56 } })
  local badge_size = math.min(29, r.h * 0.34)
  local text_x = icon_x + icon_size + 7
  if owned then
    draw_device(self.app.assets, text_x, r.y + (r.h - badge_size) / 2,
      badge_size, owned.rank, owned.rank >= perk.max_rank)
    text_x = text_x + badge_size + 6
  end
  local text_w = r.x + r.w - text_x - 7
  local name_font = Fonts.get(math.max(9, math.min(12, r.w * 0.066)))
  love.graphics.setFont(name_font)
  love.graphics.setColor(owned and { 0.94, 0.96, 1, 1 }
    or { 0.56, 0.53, 0.65, 1 })
  local name = owned and string.upper(perk.name) or "UNKNOWN"
  local block_y = r.y + (r.h - name_font:getHeight()) / 2
  if owned then block_y = block_y - 8 end
  love.graphics.printf(name, text_x, block_y, text_w, "left")
  if owned then
    love.graphics.setFont(Fonts.get(math.max(8, math.min(10, r.w * 0.052))))
    love.graphics.setColor(0.40, 0.88, 0.98, 0.92)
    love.graphics.printf(string.upper(PerkSummary.attribute(perk)),
      text_x, block_y + 17, text_w, "left")
  end
end

function PerkDatabase:_draw_summary(d, top)
  local summary = PerkSummary.collect(self.app.content, self.app.slot)
  self.app.assets:draw_segmented_bar(d.x + 14, top - 18, d.w - 28, 12, 0, {
    frame_color = { 0.40, 0.92, 1.0, 0.72 },
  })
  love.graphics.setFont(Fonts.get(15))
  love.graphics.setColor(0.38, 0.90, 1, 1)
  love.graphics.print("YOUR PERK LOADOUT", d.x + 14, top)
  local device_size = 46
  draw_device(self.app.assets, d.x + 14, top + 24, device_size,
    summary.owned, summary.owned >= summary.total)
  love.graphics.setFont(Fonts.get(13)); love.graphics.setColor(0.88, 0.90, 0.97, 1)
  love.graphics.print(summary.owned .. " / " .. summary.total .. " PERKS",
    d.x + 70, top + 29)
  love.graphics.setColor(0.72, 0.75, 0.86, 1)
  love.graphics.print(summary.ranks .. " TOTAL RANKS", d.x + 70, top + 49)

  local list_y = top + 82
  local available_h = math.max(1, self.buttons.buttons[1].y - 38 - list_y)
  local row_h = math.min(32, math.max(18,
    available_h / math.max(1, #summary.entries)))
  for index, entry in ipairs(summary.entries) do
    local y = list_y + (index - 1) * row_h
    if y + row_h > self.buttons.buttons[1].y - 30 then break end
    local x = d.x + 14
    local icon_size = math.min(24, row_h - 3)
    self.app.assets:draw_meta_perk(entry.perk.sprite.cell, x, y, icon_size, icon_size)
    love.graphics.setFont(Fonts.get(row_h >= 27 and 11 or 9))
    love.graphics.setColor(0.83, 0.85, 0.94, 1)
    love.graphics.printf(string.upper(entry.perk.name), x + icon_size + 10,
      y + (icon_size - Fonts.get(row_h >= 27 and 11 or 9):getHeight()) / 2,
      d.w - icon_size - 98, "left")
    love.graphics.setColor(0.40, 1.0, 0.70, 1)
    love.graphics.printf(entry.value, d.x + d.w - 94, y + 3, 78, "right")
  end
end

function PerkDatabase:draw()
  local sw, sh = love.graphics.getDimensions()
  love.graphics.setColor(0.008, 0.004, 0.025, 1)
  love.graphics.rectangle("fill", 0, 0, sw, sh)
  local w, h = UIScale.begin()
  love.graphics.setColor(0.035, 0.014, 0.075, 0.96)
  love.graphics.rectangle("fill", 0, 0, w, h)
  self.app.assets:draw_world_interface(5, 1, 20, 9, 78, 74)
  love.graphics.setFont(Fonts.get(28)); love.graphics.setColor(1, 0.76, 0.2, 1)
  love.graphics.print("PERK DATABASE", 104, 22)
  love.graphics.setFont(Fonts.get(11)); love.graphics.setColor(0.48, 0.9, 1, 1)
  love.graphics.print("PERMANENT WORLD TOUR LOADOUT", 106, 57)
  local wallet = self.app.slot and self.app.slot.wallet and self.app.slot.wallet.coins or 0
  self.app.assets:draw_world_interface(4, 2, w - 142, 17, 42, 42)
  love.graphics.setFont(Fonts.get(18)); love.graphics.setColor(1, 0.82, 0.3, 1)
  love.graphics.printf(tostring(wallet), w - 94, 28, 70, "left")

  for i, perk in ipairs(self.perks) do self:_draw_card(i, perk) end

  local perk, owned = self.perks[self.selected], self:_owned(self.perks[self.selected])
  local d = self.detail
  love.graphics.setColor(0.025, 0.012, 0.06, 0.98)
  love.graphics.rectangle("fill", d.x, d.y, d.w, d.h, 10, 10)
  MenuChrome.panel(self.app.assets, d, { corner = 36, alpha = 0.86 })
  local icon_size = math.min(88, d.w * 0.26)
  self.app.assets:draw_meta_perk(owned and perk.sprite.cell or 20,
    d.x + 14, d.y + 14, icon_size, icon_size)
  local title_x = d.x + 24 + icon_size
  love.graphics.setFont(Fonts.get(
    math.max(16, math.min(22, d.w * 0.060))))
  love.graphics.setColor(1, 0.76, 0.2, 1)
  love.graphics.printf(owned and string.upper(perk.name) or "SEALED PERK",
    title_x, d.y + 20, d.w - (title_x - d.x) - 16, "left")
  if owned then
    draw_device(self.app.assets, title_x, d.y + 52, 34, owned.rank,
      owned.rank >= perk.max_rank)
    love.graphics.setFont(Fonts.get(10)); love.graphics.setColor(0.40, 0.90, 1, 1)
    love.graphics.print(string.upper(PerkSummary.attribute(perk)), title_x + 42, d.y + 60)
  end
  love.graphics.setFont(Fonts.get(13)); love.graphics.setColor(0.78, 0.80, 0.90, 1)
  love.graphics.printf(owned and perk.description
      or "Continue the World Tour to unlock this perk.",
    d.x + 14, d.y + 110, d.w - 28, "left")
  love.graphics.setColor(0.34, 0.92, 1, 1)
  love.graphics.printf(source_label(perk.source), d.x + 14, d.y + 143, d.w - 28, "left")

  local price = owned and perk.prices[owned.rank + 1]
  local purchase = self.buttons.buttons[1]
  purchase.disabled = not owned or not price or wallet < price
  purchase.label = not owned and "LOCKED" or not price and "MAX RANK"
    or wallet < price and ("NEED " .. price) or ("UPGRADE  " .. price)
  self:_draw_summary(d, d.y + 202)

  if self.notice ~= "" then
    local notice_y = purchase.y - 30
    love.graphics.setColor(self.notice_kind == "success"
      and { 0.08, 0.30, 0.22, 0.98 } or { 0.30, 0.06, 0.13, 0.98 })
    love.graphics.rectangle("fill", d.x + 8, notice_y, d.w - 16, 24, 4, 4)
    love.graphics.setFont(Fonts.get(9))
    love.graphics.setColor(self.notice_kind == "success"
      and { 0.40, 1.0, 0.70, 1 } or { 1.0, 0.48, 0.58, 1 })
    love.graphics.printf(self.notice, d.x + 12, notice_y + 7, d.w - 24, "center")
  end
  self.buttons:draw()
  UIScale.finish()
end

function PerkDatabase:keypressed(key)
  if key == "escape" then self:_back(); return true end
  if key == "left" or key == "a" then self.selected = math.max(1, self.selected - 1); return true end
  if key == "right" or key == "d" then self.selected = math.min(#self.perks, self.selected + 1); return true end
  if key == "up" or key == "w" then self.selected = math.max(1, self.selected - self.columns); return true end
  if key == "down" or key == "s" then
    self.selected = math.min(#self.perks, self.selected + self.columns)
    return true
  end
  if key == "return" or key == "space" then
    if not self.buttons.buttons[1].disabled then self:_buy() end
    return true
  end
  return false
end

function PerkDatabase:gamepadpressed(_, button)
  local map = { dpleft="left", dpright="right", dpup="up", dpdown="down",
    a="return", b="escape" }
  return map[button] and self:keypressed(map[button]) or false
end

function PerkDatabase:mousepressed(x, y, button)
  x, y = UIScale.point(x, y, self.ui_scale)
  if button == 1 then
    for i, r in ipairs(self.card_rects) do
      if x >= r.x and x <= r.x + r.w and y >= r.y and y <= r.y + r.h then
        self.selected = i
        return true
      end
    end
  end
  return self.buttons:mousepressed(x, y, button)
end

function PerkDatabase:mousemoved(x, y)
  x, y = UIScale.point(x, y, self.ui_scale)
  self.buttons:mousemoved(x, y)
end

return PerkDatabase
