local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local Hints = require("src.ui.controller_hints")
local widgets = require("src.ui.widgets.button")
local UIScale = require("src.ui.scale")
local PerkProgress = require("src.meta.perk_progress")

local PerkDatabase = class()
PerkDatabase.kind = "perk_database"

function PerkDatabase:init(app, opts)
  self.app, self.opts = app, opts or {}
  self.catalog_only = self.opts.catalog_only == true
  self.selected, self.notice, self.notice_kind = 1, "", "neutral"
  self.perks = {}
  for _, perk in pairs(app.content.meta_perks) do self.perks[#self.perks + 1] = perk end
  table.sort(self.perks, function(a, b) return a.sprite.cell < b.sprite.cell end)
end

function PerkDatabase:enter() self:_layout() end
function PerkDatabase:resize() self:_layout() end

function PerkDatabase:_owned(perk)
  return self.app.slot and self.app.slot.perks and self.app.slot.perks[perk.id]
end

function PerkDatabase:_buy()
  local perk = self.perks[self.selected]
  local owned, err = PerkProgress.purchase(self.app, perk.id)
  self.notice = owned and ("PURCHASE COMPLETE  •  " .. perk.name .. " UPGRADED")
    or ({ locked = "CLEAR ITS SOURCE WORLD TO UNLOCK", max_rank = "MAX RANK REACHED",
      insufficient_funds = "NOT ENOUGH TOUR COINS", no_campaign = "START A CAMPAIGN FIRST" })[err]
      or "PURCHASE UNAVAILABLE"
  self.notice_kind = owned and "success" or "error"
end

function PerkDatabase:_back()
  local Title = require("src.ui.screens.title")
  self.app.states:switch(Title(self.app))
end

function PerkDatabase:_layout()
  local w, h, scale = UIScale.dimensions()
  self.ui_scale = scale
  local grid_w = math.min(700, w * 0.58)
  self.grid = { x = 28, y = 112, w = grid_w, h = h - 160 }
  self.detail = { x = self.grid.x + grid_w + 18, y = 112,
    w = w - grid_w - 74, h = h - 160 }
  local gap, cols = 8, w < 980 and 4 or 5
  local cw = (grid_w - gap * (cols - 1)) / cols
  local rows = math.ceil(#self.perks / cols)
  local ch = math.min(88, (self.grid.h - gap * (rows - 1)) / rows)
  self.card_rects = {}
  for i = 1, #self.perks do
    local col, row = (i - 1) % cols, math.floor((i - 1) / cols)
    self.card_rects[i] = { x = self.grid.x + col * (cw + gap),
      y = self.grid.y + row * (ch + gap), w = cw, h = ch }
  end
  local bw = math.min(230, self.detail.w - 20)
  local purchase_y = self.detail.y + self.detail.h - 108
  self.buttons = widgets.ButtonList({
    widgets.Button({ label = "UPGRADE PERK", x = self.detail.x + (self.detail.w - bw) / 2,
      y = purchase_y, w = bw, h = 46, variant = "primary", font_size = 15,
      on_press = function() self:_buy() end }),
    widgets.Button({ label = "RETURN TO TITLE", x = self.detail.x + (self.detail.w - bw) / 2,
      y = purchase_y + 52, w = bw, h = 42, font_size = 14,
      on_press = function() self:_back() end }),
  })
end

local function draw_rank_dots(x, y, width, rank, max_rank)
  local gap = math.min(16, width / math.max(1, max_rank))
  local total = (max_rank - 1) * gap
  local start = x + (width - total) / 2
  for index = 1, max_rank do
    local filled = index <= rank
    love.graphics.setColor(filled and { 1, 0.76, 0.20, 1 }
      or { 0.30, 0.27, 0.42, 0.9 })
    love.graphics.circle(filled and "fill" or "line",
      start + (index - 1) * gap, y, filled and 4 or 3.5)
  end
end

local function source_label(source)
  if source.type == "prologue_clear" then return "PROLOGUE CLEAR" end
  return string.upper((source.world_id or "WORLD") .. "  •  GRADE " .. (source.grade or "?"))
end

function PerkDatabase:draw()
  local sw, sh = love.graphics.getDimensions()
  love.graphics.setColor(0.008, 0.004, 0.025, 1); love.graphics.rectangle("fill", 0, 0, sw, sh)
  local w, h = UIScale.begin()
  love.graphics.setColor(0.035, 0.014, 0.075, 0.96); love.graphics.rectangle("fill", 0, 0, w, h)
  self.app.assets:draw_world_interface(5, 1, 24, 12, 92, 86)
  love.graphics.setFont(Fonts.get(30)); love.graphics.setColor(1, 0.76, 0.2, 1)
  love.graphics.print("PERK DATABASE", 122, 27)
  love.graphics.setFont(Fonts.get(13)); love.graphics.setColor(0.48, 0.9, 1, 1)
  love.graphics.print("PERMANENT WORLD TOUR LOADOUT", 124, 65)
  local wallet = self.app.slot and self.app.slot.wallet and self.app.slot.wallet.coins or 0
  self.app.assets:draw_world_interface(4, 2, w - 160, 20, 48, 48)
  love.graphics.setFont(Fonts.get(20)); love.graphics.setColor(1, 0.82, 0.3, 1)
  love.graphics.printf(tostring(wallet), w - 110, 34, 82, "left")

  for i, perk in ipairs(self.perks) do
    local r, owned = self.card_rects[i], self:_owned(perk)
    local selected = i == self.selected
    love.graphics.setColor(selected and { 0.17, 0.065, 0.24, 1 } or { 0.035, 0.018, 0.075, 1 })
    love.graphics.rectangle("fill", r.x, r.y, r.w, r.h, 8, 8)
    love.graphics.setColor(selected and { 1, 0.72, 0.18, 1 }
      or owned and { 0.2, 0.85, 1, 0.75 } or { 0.3, 0.28, 0.42, 0.7 })
    love.graphics.rectangle("line", r.x, r.y, r.w, r.h, 8, 8)
    self.app.assets:draw_meta_perk(owned and perk.sprite.cell or 20,
      r.x + 5, r.y + 5, math.min(54, r.w * 0.48), r.h - 10,
      { color = owned and { 1, 1, 1, 1 } or { 0.55, 0.5, 0.68, 0.58 } })
    love.graphics.setFont(Fonts.get(math.max(9, math.min(12, r.w * 0.1))))
    love.graphics.setColor(owned and { 0.9, 0.94, 1, 1 } or { 0.55, 0.52, 0.64, 1 })
    love.graphics.printf(owned and string.upper(perk.name) or "UNKNOWN",
      r.x + math.min(58, r.w * 0.5), r.y + 15, r.w - math.min(63, r.w * 0.5), "center")
    local rank_x = r.x + math.min(58, r.w * 0.5)
    local rank_w = r.w - math.min(63, r.w * 0.5)
    if owned then
      draw_rank_dots(rank_x, r.y + r.h - 20, rank_w,
        owned.rank, perk.max_rank)
    else
      love.graphics.setColor(1, 0.76, 0.2, 0.4)
      love.graphics.printf("LOCKED", rank_x, r.y + r.h - 27, rank_w, "center")
    end
  end

  local perk, owned = self.perks[self.selected], self:_owned(self.perks[self.selected])
  local d = self.detail
  love.graphics.setColor(0.025, 0.012, 0.06, 0.98); love.graphics.rectangle("fill", d.x, d.y, d.w, d.h, 12, 12)
  self.app.assets:draw_hud_frame(d.x, d.y, d.w, d.h, { color = { 0.68, 0.42, 1, 0.65 } })
  self.app.assets:draw_meta_perk(owned and perk.sprite.cell or 20, d.x + d.w/2 - 66, d.y + 20, 132, 132)
  love.graphics.setFont(Fonts.get(23)); love.graphics.setColor(1, 0.76, 0.2, 1)
  love.graphics.printf(owned and string.upper(perk.name) or "SEALED PERK", d.x + 16, d.y + 160, d.w - 32, "center")
  love.graphics.setFont(Fonts.get(14)); love.graphics.setColor(0.78, 0.8, 0.9, 1)
  love.graphics.printf(owned and perk.description or "Its identity remains hidden until you meet the unlock condition.",
    d.x + 28, d.y + 204, d.w - 56, "center")
  love.graphics.setColor(0.3, 0.9, 1, 1)
  love.graphics.printf(owned and source_label(perk.source)
      or "KEEP TOURING TO REVEAL ITS SOURCE",
    d.x + 20, d.y + 274, d.w - 40, "center")
  local price = owned and perk.prices[owned.rank + 1]
  local purchase_button = self.buttons.buttons[1]
  if not owned then
    purchase_button.label = "LOCKED"
  elseif not price then
    purchase_button.label = "MAX RANK"
  elseif wallet < price then
    purchase_button.label = "NEED " .. price .. " COINS"
  else
    purchase_button.label = "UPGRADE  •  " .. price .. " COINS"
  end
  love.graphics.setColor(1, 0.78, 0.24, 1)
  love.graphics.printf(owned and (price and ("NEXT RANK  •  " .. price .. " COINS") or "MAX RANK") or "LOCKED",
    d.x + 20, d.y + 315, d.w - 40, "center")
  if owned then
    draw_rank_dots(d.x + 40, d.y + 350, d.w - 80,
      owned.rank, perk.max_rank)
  end
  if self.notice ~= "" then
    local notice_y = self.buttons.buttons[1].y - 38
    love.graphics.setColor(self.notice_kind == "success"
      and { 0.08, 0.30, 0.22, 0.98 } or { 0.30, 0.06, 0.13, 0.98 })
    love.graphics.rectangle("fill", d.x + 16, notice_y,
      d.w - 32, 30, 7, 7)
    love.graphics.setColor(self.notice_kind == "success"
      and { 0.40, 1.0, 0.70, 1 } or { 1.0, 0.48, 0.58, 1 })
    love.graphics.printf(self.notice, d.x+20, notice_y + 8, d.w-40, "center")
  end
  self.buttons:draw()
  Hints.draw({ { symbol="dpad", label="Browse" },
    { symbol="cross", label="Upgrade" },
    { symbol="circle", label="Back" } }, h-24, w)
  UIScale.finish()
end

function PerkDatabase:keypressed(key)
  if key == "escape" then self:_back(); return true end
  local cols = UIScale.dimensions() < 980 and 4 or 5
  if key == "left" or key == "a" then self.selected = math.max(1, self.selected - 1); return true end
  if key == "right" or key == "d" then self.selected = math.min(#self.perks, self.selected + 1); return true end
  if key == "up" or key == "w" then self.selected = math.max(1, self.selected - cols); return true end
  if key == "down" or key == "s" then self.selected = math.min(#self.perks, self.selected + cols); return true end
  if key == "return" or key == "space" then self:_buy(); return true end
  return false
end
function PerkDatabase:gamepadpressed(_, b)
  local map = { dpleft="left", dpright="right", dpup="up", dpdown="down", a="return", b="escape" }
  return map[b] and self:keypressed(map[b]) or false
end
function PerkDatabase:mousepressed(x, y, b)
  x, y = UIScale.point(x, y, self.ui_scale)
  if b == 1 then
    for i, r in ipairs(self.card_rects) do
      if x>=r.x and x<=r.x+r.w and y>=r.y and y<=r.y+r.h then
        self.selected=i
        return true
      end
    end
  end
  return self.buttons:mousepressed(x, y, b)
end
function PerkDatabase:mousemoved(x, y) x,y=UIScale.point(x,y,self.ui_scale); self.buttons:mousemoved(x,y) end

return PerkDatabase
