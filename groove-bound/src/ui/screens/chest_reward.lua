local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local Hints = require("src.ui.controller_hints")
local UIScale = require("src.ui.scale")

local ChestRewardScreen = class()
ChestRewardScreen.kind = "chest_reward"
ChestRewardScreen.opaque = false

local COUNT_ROLL_DURATION = 1.65
local REEL_SPIN_DURATION = 2.25
local REEL_STAGGER = 0.16
local FINAL_HOLD = 0.65

local kind_colors = {
  weapon_add = { 0.28, 0.92, 1.0, 1 },
  weapon_level = { 0.36, 1.0, 0.68, 1 },
  passive_add = { 0.78, 0.42, 1.0, 1 },
  passive_level = { 0.78, 0.42, 1.0, 1 },
  evolution = { 1.0, 0.72, 0.18, 1 },
  heal = { 1.0, 0.34, 0.46, 1 },
  guard = { 0.32, 0.62, 1.0, 1 },
  coins = { 1.0, 0.82, 0.24, 1 },
}

local kind_labels = {
  weapon_add = "NEW WEAPON",
  weapon_level = "WEAPON UPGRADE",
  passive_add = "NEW SUPPORT",
  passive_level = "SUPPORT UPGRADE",
  evolution = "FUSION JACKPOT",
  heal = "HEALTH",
  guard = "GUARD",
  coins = "COINS",
}

local function contains(rect, x, y)
  return rect and x >= rect.x and y >= rect.y
    and x <= rect.x + rect.w and y <= rect.y + rect.h
end

function ChestRewardScreen:init(app, reveal)
  self.app = app
  self.reveal = assert(reveal)
  self.rewards = assert(reveal.rewards)
  self.elapsed = 0
  self.complete = false
  self.settled_count = 0
  self.symbols = self:_build_symbols()
  self.continue_rect = nil
end

function ChestRewardScreen:_build_symbols()
  local symbols = {}
  local weapon_ids = {}
  for id, definition in pairs(self.app.content.weapons) do
    if not definition.evolved then weapon_ids[#weapon_ids + 1] = id end
  end
  table.sort(weapon_ids)
  for _, id in ipairs(weapon_ids) do
    local definition = self.app.content.weapons[id]
    symbols[#symbols + 1] = {
      kind = "weapon_add", id = id, title = definition.name,
    }
  end
  local passive_ids = {}
  for id in pairs(self.app.content.passives) do
    passive_ids[#passive_ids + 1] = id
  end
  table.sort(passive_ids)
  for _, id in ipairs(passive_ids) do
    local definition = self.app.content.passives[id]
    symbols[#symbols + 1] = {
      kind = "passive_add", id = id, title = definition.name,
    }
  end
  return symbols
end

function ChestRewardScreen:animation_duration()
  return COUNT_ROLL_DURATION + REEL_SPIN_DURATION
    + math.max(0, #self.rewards - 1) * REEL_STAGGER
    + FINAL_HOLD
end

function ChestRewardScreen:count_roll_duration()
  return COUNT_ROLL_DURATION
end

function ChestRewardScreen:reel_spin_duration()
  return REEL_SPIN_DURATION
end

function ChestRewardScreen:_settle_time(index)
  return COUNT_ROLL_DURATION + REEL_SPIN_DURATION
    + (index - 1) * REEL_STAGGER
end

function ChestRewardScreen:phase()
  if self.complete then return "complete" end
  if self.elapsed < COUNT_ROLL_DURATION then return "count_roll" end
  if self.elapsed >= COUNT_ROLL_DURATION + REEL_SPIN_DURATION then
    return "settling"
  end
  return "spinning"
end

function ChestRewardScreen:displayed_roll()
  return self.elapsed >= COUNT_ROLL_DURATION
    and (self.reveal.roll or #self.rewards) or nil
end

function ChestRewardScreen:visible_reel_count()
  if self.elapsed < COUNT_ROLL_DURATION then return 0 end
  return math.max(1, self.reveal.roll or #self.rewards)
end

function ChestRewardScreen:rolling_multiplier()
  if self.elapsed >= COUNT_ROLL_DURATION then
    return self.reveal.roll or #self.rewards
  end
  local sequence = { 1, 3, 5, 3, 1, 5 }
  local progress = math.max(0, math.min(1, self.elapsed / COUNT_ROLL_DURATION))
  local eased = 1 - (1 - progress) ^ 3
  local step = math.floor(eased * 24)
  return sequence[step % #sequence + 1]
end

function ChestRewardScreen:_cycle_symbol(index, offset)
  if #self.symbols == 0 then return self.rewards[index] end
  local reel_elapsed = math.max(0, self.elapsed - COUNT_ROLL_DURATION)
  local progress = math.min(1, reel_elapsed / REEL_SPIN_DURATION)
  local distance = reel_elapsed * (19 + index * 0.85)
    - reel_elapsed * reel_elapsed * 2.1 * progress
  local step = math.floor(distance) + index * 5 + (offset or 0)
  return self.symbols[step % #self.symbols + 1]
end

function ChestRewardScreen:visible_symbol(index)
  if index <= self.settled_count and self.rewards[index] then
    return self.rewards[index], true
  end
  return self:_cycle_symbol(index, 0), false
end

function ChestRewardScreen:enter()
  self:_layout()
end

function ChestRewardScreen:_layout()
  local w, h, scale = UIScale.dimensions()
  self.ui_scale = scale
  self.continue_rect = {
    x = w / 2 - 150,
    y = h - 104,
    w = 300,
    h = 52,
  }
end

function ChestRewardScreen:resize()
  self:_layout()
end

function ChestRewardScreen:update(dt)
  self.elapsed = self.elapsed + dt
  if self.complete then return end
  local settled = 0
  for index = 1, #self.rewards do
    if self.elapsed >= self:_settle_time(index) then settled = index end
  end
  if settled > self.settled_count and self.app.assets
    and self.app.assets.play
  then
    self.app.assets:play("xp", 0.05)
  end
  self.settled_count = settled
  self.complete = self.elapsed >= self:animation_duration()
end

function ChestRewardScreen:_weapon_for(symbol)
  if symbol.kind == "weapon_add" or symbol.kind == "weapon_level" then
    return self.app.content.weapons[symbol.id]
  elseif symbol.kind == "evolution" then
    local recipe = self.app.content.evolutions[symbol.id]
    return recipe and self.app.content.weapons[recipe.result_weapon]
  end
  return nil
end

function ChestRewardScreen:_draw_symbol(symbol, x, y, size, alpha)
  alpha = alpha or 1
  local weapon = self:_weapon_for(symbol)
  if weapon and self.app.assets and self.app.assets.draw_weapon_icon then
    self.app.assets:draw_weapon_icon(
      weapon.icon, x, y, size, { color = { 1, 1, 1, alpha } })
    return
  end
  if symbol.kind == "passive_add" or symbol.kind == "passive_level" then
    local passive = self.app.content.passives[symbol.id]
    if passive and self.app.assets and self.app.assets.draw_support_icon then
      self.app.assets:draw_support_icon(
        passive.icon, x, y, size, { color = { 1, 1, 1, alpha } })
      return
    end
  end
  local color = kind_colors[symbol.kind] or settings.ui.accent_color
  love.graphics.setColor(color[1], color[2], color[3], alpha)
  if symbol.kind == "coins" then
    love.graphics.circle("fill", x, y, size * 0.32)
    love.graphics.setColor(0.25, 0.10, 0.03, alpha)
    love.graphics.circle("line", x, y, size * 0.20)
  elseif symbol.kind == "heal" then
    love.graphics.rectangle("fill", x - size * 0.10, y - size * 0.34,
      size * 0.20, size * 0.68, 3, 3)
    love.graphics.rectangle("fill", x - size * 0.34, y - size * 0.10,
      size * 0.68, size * 0.20, 3, 3)
  else
    love.graphics.polygon("fill",
      x, y - size * 0.36, x + size * 0.31, y - size * 0.15,
      x + size * 0.24, y + size * 0.32, x, y + size * 0.42,
      x - size * 0.24, y + size * 0.32, x - size * 0.31, y - size * 0.15)
  end
end

function ChestRewardScreen:_draw_reel(index, rect)
  local symbol, settled = self:visible_symbol(index)
  local color = settled
    and (kind_colors[symbol.kind] or settings.ui.accent_color)
    or { 0.26, 0.86, 1.0, 1 }
  love.graphics.setColor(0.035, 0.02, 0.075, 0.98)
  love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 12, 12)
  love.graphics.setColor(color)
  love.graphics.setLineWidth(settled and 3 or 2)
  love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 12, 12)
  love.graphics.setLineWidth(1)

  if settled then
    love.graphics.setColor(color[1], color[2], color[3], 0.14)
    love.graphics.circle("fill", rect.x + rect.w / 2, rect.y + 98, 68)
    self:_draw_symbol(symbol, rect.x + rect.w / 2, rect.y + 98, 94, 1)
  else
    local previous_scissor = { love.graphics.getScissor() }
    love.graphics.setScissor(rect.x + 4, rect.y + 4, rect.w - 8, 174)
    local reel_elapsed = math.max(0, self.elapsed - COUNT_ROLL_DURATION)
    local progress = math.min(1, reel_elapsed / REEL_SPIN_DURATION)
    local distance = reel_elapsed * (19 + index * 0.85)
      - reel_elapsed * reel_elapsed * 2.1 * progress
    local fraction = distance % 1
    local jitter = math.sin(self.elapsed * (24 + index))
      * math.max(0, 1 - progress) * 3
    for offset = -1, 1 do
      local rolling = self:_cycle_symbol(index, offset)
      local symbol_y = rect.y + 98 + jitter + (offset + fraction) * 92
      local alpha = offset == 0 and 1 - fraction * 0.45 or 0.40
      self:_draw_symbol(
        rolling, rect.x + rect.w / 2, symbol_y, 78, alpha)
    end
    if previous_scissor[1] then
      love.graphics.setScissor(
        previous_scissor[1], previous_scissor[2],
        previous_scissor[3], previous_scissor[4])
    else
      love.graphics.setScissor()
    end
  end

  love.graphics.setColor(color)
  love.graphics.setFont(Fonts.get(13))
  love.graphics.printf(
    settled and (kind_labels[symbol.kind] or "REWARD") or "ROLLING...",
    rect.x + 8, rect.y + 174, rect.w - 16, "center")
  love.graphics.setColor(settings.ui.text_color)
  love.graphics.setFont(Fonts.get(#self.rewards >= 5 and 16 or 19))
  love.graphics.printf(
    settled and symbol.title or "SPINNING",
    rect.x + 10, rect.y + 204, rect.w - 20, "center")
  if settled and symbol.description then
    love.graphics.setColor(0.72, 0.70, 0.82, 1)
    love.graphics.setFont(Fonts.get(13))
    love.graphics.printf(
      symbol.description,
      rect.x + 12, rect.y + 244, rect.w - 24, "center")
  end
end

function ChestRewardScreen:draw()
  local screen_w, screen_h = love.graphics.getDimensions()
  love.graphics.setColor(0.01, 0.005, 0.035, 0.94)
  love.graphics.rectangle("fill", 0, 0, screen_w, screen_h)
  local w, h = UIScale.begin()

  local phase = self:phase()
  love.graphics.setColor(1.0, 0.76, 0.22, 1)
  love.graphics.setFont(Fonts.get(38))
  love.graphics.printf("MYSTERY CHEST", 0, 42, w, "center")
  love.graphics.setColor(settings.ui.text_color)
  love.graphics.setFont(Fonts.get(18))
  local displayed_roll = self:displayed_roll()
  love.graphics.printf(
    "LUCK " .. (displayed_roll and ("×" .. displayed_roll) or "ROLLING") .. "  •  "
      .. (phase == "count_roll" and "WILL IT BE 1, 3, OR 5?"
        or phase == "complete" and "YOUR REWARDS ARE LOCKED IN"
        or phase == "settling" and "THE REELS ARE DECELERATING..."
        or "THE GROOVE IS ROLLING..."),
    0, 94, w, "center")

  local count = self:visible_reel_count()
  if phase == "count_roll" then
    local multiplier = self:rolling_multiplier()
    local progress = math.min(1, self.elapsed / COUNT_ROLL_DURATION)
    local shake = math.sin(self.elapsed * 34) * (1 - progress) * 9
    local pulse = 1 + math.sin(self.elapsed * 13) * 0.06
    love.graphics.setColor(0.10, 0.04, 0.19, 0.98)
    love.graphics.circle("fill", w / 2 + shake, h / 2 - 4, 132 * pulse)
    love.graphics.setColor(0.28, 0.92, 1.0, 0.22)
    love.graphics.circle("fill", w / 2 + shake, h / 2 - 4, 104 * pulse)
    love.graphics.setColor(1.0, 0.76, 0.22, 1)
    love.graphics.setLineWidth(5)
    love.graphics.circle("line", w / 2 + shake, h / 2 - 4, 132 * pulse)
    love.graphics.setLineWidth(1)
    love.graphics.setFont(Fonts.get(68))
    love.graphics.printf("×" .. multiplier, w / 2 - 130 + shake,
      h / 2 - 51, 260, "center")
    love.graphics.setFont(Fonts.get(16))
    love.graphics.setColor(0.82, 0.80, 0.90, 1)
    love.graphics.printf("1  •  3  •  5", w / 2 - 150, h / 2 + 92, 300, "center")
  else
    local gap = math.max(10, math.min(18, w * 0.012))
    local available_w = math.min(1120, w - 48)
    local reel_w = math.min(300, (available_w - gap * (count - 1)) / count)
    local total_w = reel_w * count + gap * (count - 1)
    local start_x = (w - total_w) / 2
    local reel_y = 130
    local reel_h = math.min(324, h - 270)
    for index = 1, count do
      self:_draw_reel(index, {
        x = start_x + (index - 1) * (reel_w + gap),
        y = reel_y,
        w = reel_w,
        h = reel_h,
      })
    end
  end

  if self.complete then
    local rect = self.continue_rect
    local pulse = 0.86 + math.sin(self.elapsed * 4) * 0.08
    love.graphics.setColor(0.08, 0.04, 0.14, 0.98)
    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 8, 8)
    love.graphics.setColor(1.0, 0.76, 0.22, pulse)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 8, 8)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.get(20))
    love.graphics.printf("CONTINUE", rect.x, rect.y + 15, rect.w, "center")
  end

  love.graphics.setColor(0.015, 0.01, 0.05, 0.94)
  love.graphics.rectangle("fill", 0, h - 40, w, 40)
  Hints.draw(self.complete and {
    { symbol = "cross", label = "Continue" },
    { symbol = "circle", label = "Close" },
  } or {
    { symbol = "options", label = phase == "count_roll"
      and "Rolling 1 / 3 / 5" or "Reward reels spinning" },
  }, h - 30, w, { font_size = 13, glyph_size = 18, gap = 18 })
  UIScale.finish()
end

function ChestRewardScreen:_continue()
  if not self.complete then return false end
  self.app.states:pop({ kind = "chest_reward", rewards = self.rewards })
  return true
end

function ChestRewardScreen:keypressed(key)
  if key == "return" or key == "space" or key == "escape" or key == "x" then
    return self:_continue()
  end
  return false
end

function ChestRewardScreen:gamepadpressed(_, button)
  if button == "a" or button == "b" then return self:_continue() end
  return false
end

function ChestRewardScreen:mousepressed(x, y, button)
  x, y = UIScale.point(x, y, self.ui_scale)
  if button == 1 and contains(self.continue_rect, x, y) then
    return self:_continue()
  end
  return false
end

return ChestRewardScreen
