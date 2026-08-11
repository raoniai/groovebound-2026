local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local Hints = require("src.ui.controller_hints")
local UIScale = require("src.ui.scale")

local ChestRewardScreen = class()
ChestRewardScreen.kind = "chest_reward"
ChestRewardScreen.opaque = false

local COUNT_ROLL_DURATION = 1.85
local COUNT_LOCK_DURATION = 0.55
local REWARD_HOLD_DURATION = 0.95

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
  self.continue_rect = nil
  self.resolution_sound_played = false
end

function ChestRewardScreen:animation_duration()
  return COUNT_ROLL_DURATION + COUNT_LOCK_DURATION + REWARD_HOLD_DURATION
end

function ChestRewardScreen:count_roll_duration()
  return COUNT_ROLL_DURATION
end

function ChestRewardScreen:count_lock_duration()
  return COUNT_LOCK_DURATION
end

function ChestRewardScreen:reward_reveal_at()
  return COUNT_ROLL_DURATION + COUNT_LOCK_DURATION
end

-- Kept as a compatibility seam for callers/tests. Rewards do not spin.
function ChestRewardScreen:reel_spin_duration()
  return 0
end

function ChestRewardScreen:phase()
  if self.complete then return "complete" end
  if self.elapsed < COUNT_ROLL_DURATION then return "converge" end
  if self.elapsed < self:reward_reveal_at() then return "flash" end
  return "rewards"
end

function ChestRewardScreen:displayed_roll()
  return self.elapsed >= COUNT_ROLL_DURATION
    and (self.reveal.roll or #self.rewards) or nil
end

function ChestRewardScreen:visible_reel_count()
  if self.elapsed < self:reward_reveal_at() then return 0 end
  return self.reveal.roll or #self.rewards
end

-- A quadratic deceleration drives a large number of early changes and only a
-- handful near the lock. The final sample is always the authored reward count.
function ChestRewardScreen:rolling_multiplier()
  if self.elapsed >= COUNT_ROLL_DURATION then
    return self.reveal.roll or #self.rewards
  end
  local sequence = { 1, 5, 3, 1, 3, 5, 1, 5, 3 }
  local progress = math.max(0, math.min(1, self.elapsed / COUNT_ROLL_DURATION))
  local spins = math.floor((1 - (1 - progress) ^ 2.35) * 36)
  return sequence[spins % #sequence + 1]
end

function ChestRewardScreen:luck_sprite_frame()
  if self.elapsed >= COUNT_ROLL_DURATION then return 5 end
  local progress = math.max(0, self.elapsed / COUNT_ROLL_DURATION)
  local speed = 21 - progress * 16
  return math.floor(self.elapsed * speed) % 4 + 1
end

function ChestRewardScreen:reward_stage_frame()
  local reveal_elapsed = math.max(0, self.elapsed - self:reward_reveal_at())
  return math.min(5, math.floor(reveal_elapsed / 0.09) + 1)
end

function ChestRewardScreen:visible_symbol(index)
  if self.elapsed < self:reward_reveal_at() then return nil, false end
  return self.rewards[index], self.rewards[index] ~= nil
end

function ChestRewardScreen:enter()
  self:_layout()
end

function ChestRewardScreen:_layout()
  local w, h, scale = UIScale.dimensions()
  self.ui_scale = scale
  self.continue_rect = { x = w / 2 - 150, y = h - 94, w = 300, h = 50 }
end

function ChestRewardScreen:resize()
  self:_layout()
end

function ChestRewardScreen:update(dt)
  local was_rolling = self.elapsed < COUNT_ROLL_DURATION
  self.elapsed = self.elapsed + dt
  if was_rolling and self.elapsed >= COUNT_ROLL_DURATION then
    self.settled_count = #self.rewards
    if not self.resolution_sound_played and self.app.assets then
      self.app.assets:play("level_up", 0.05)
      self.resolution_sound_played = true
    end
  end
  self.complete = self.elapsed >= self:animation_duration()
end

function ChestRewardScreen:_weapon_for(symbol)
  if symbol.kind == "weapon_add" or symbol.kind == "weapon_level" then
    return self.app.content.weapons[symbol.id]
  elseif symbol.kind == "evolution" then
    local recipe = self.app.content.evolutions[symbol.id]
    return recipe and self.app.content.weapons[recipe.result_weapon]
  end
end

function ChestRewardScreen:_draw_symbol(symbol, x, y, size)
  local weapon = self:_weapon_for(symbol)
  if weapon then
    self.app.assets:draw_weapon_icon(weapon.icon, x, y, size)
    return
  end
  if symbol.kind == "passive_add" or symbol.kind == "passive_level" then
    local passive = self.app.content.passives[symbol.id]
    if passive then
      self.app.assets:draw_support_icon(passive.icon, x, y, size)
      return
    end
  elseif symbol.kind == "heal" then
    self.app.assets:draw_pickup("heal", x, y, size)
    return
  elseif symbol.kind == "guard" then
    self.app.assets:draw_pickup("defense", x, y, size)
    return
  elseif symbol.kind == "coins" then
    self.app.assets:draw_xp_gem(4, x, y, size)
    return
  end
  self.app.assets:draw_world_tour_icon(5, 1,
    x - size / 2, y - size / 2, size, size)
end

function ChestRewardScreen:_draw_reward_card(symbol, rect, index)
  local color = kind_colors[symbol.kind] or settings.ui.accent_color
  local entrance = math.min(1,
    math.max(0, self.elapsed - self:reward_reveal_at()
      - (index - 1) * 0.045) / 0.22)
  local lift = (1 - entrance) * 34
  self.app.assets:draw_ui_backplate(
    rect.x, rect.y + lift, rect.w, rect.h,
    { color = { 1, 1, 1, entrance } })

  self:_draw_symbol(symbol, rect.x + rect.w / 2,
    rect.y + rect.h * 0.28 + lift, math.min(132, rect.w * 0.58))
  love.graphics.setColor(color[1], color[2], color[3], entrance)
  love.graphics.setFont(Fonts.get(12))
  love.graphics.printf(kind_labels[symbol.kind] or "REWARD",
    rect.x + 18, rect.y + rect.h * 0.49 + lift, rect.w - 36, "center")
  love.graphics.setColor(1, 0.97, 1, entrance)
  love.graphics.setFont(Fonts.get(#self.rewards >= 5 and 15 or 19))
  love.graphics.printf(symbol.title,
    rect.x + 20, rect.y + rect.h * 0.57 + lift, rect.w - 40, "center")
  if symbol.description and rect.h >= 360 then
    love.graphics.setColor(0.78, 0.75, 0.88, entrance)
    love.graphics.setFont(Fonts.get(12))
    love.graphics.printf(symbol.description,
      rect.x + 24, rect.y + rect.h * 0.73 + lift, rect.w - 48, "center")
  end
end

local function smoothstep(value)
  value = math.max(0, math.min(1, value))
  return value * value * (3 - 2 * value)
end

function ChestRewardScreen:_draw_orbiting_chests(w, h, progress)
  local center_x = w / 2
  local center_y = math.min(h * 0.50, 310)
  local convergence = smoothstep((progress - 0.58) / 0.42)
  local radius_x = math.min(310, w * 0.31) * (1 - convergence)
  local radius_y = math.min(160, h * 0.23) * (1 - convergence)
  local chest_size = 100 + convergence * 58
  local rotation_speed = 5.4 - progress * 3.2
  for index = 1, 5 do
    local angle = self.elapsed * rotation_speed
      + (index - 1) / 5 * math.pi * 2
    local depth = 0.74 + (math.sin(angle) + 1) * 0.13
    self.app.assets:draw_reward_chest(
      (math.floor(self.elapsed * (11 + index)) + index) % 8 + 1,
      center_x + math.cos(angle) * radius_x,
      center_y + math.sin(angle) * radius_y,
      chest_size * depth,
      {
        rotation = math.sin(angle) * (1 - convergence) * 0.12,
        color = { 1, 1, 1, 0.92 - convergence * 0.42 },
      })
  end
end

function ChestRewardScreen:_draw_chest_animation(w, h, phase)
  local progress = math.min(1, self.elapsed / COUNT_ROLL_DURATION)
  local center_x = w / 2
  local center_y = math.min(h * 0.50, 310)
  if phase == "converge" then
    self:_draw_orbiting_chests(w, h, progress)
  end
  local lock_elapsed = math.max(0, self.elapsed - COUNT_ROLL_DURATION)
  if phase == "flash" then
    local flash_progress = math.min(1, lock_elapsed / COUNT_LOCK_DURATION)
    local flash = math.sin(flash_progress * math.pi)
    local size = 178 + flash * 24
    love.graphics.setBlendMode("add")
    love.graphics.setColor(1, 1, 1, flash * 0.72)
    love.graphics.circle("fill", center_x, center_y, 82 + flash * 110)
    love.graphics.setBlendMode("alpha")
    self.app.assets:draw_reward_chest(8, center_x, center_y, size, {
      color = { 1, 1, 1, 1 },
    })
  end
end

function ChestRewardScreen:draw()
  local screen_w, screen_h = love.graphics.getDimensions()
  love.graphics.setColor(0.008, 0.003, 0.026, 0.96)
  love.graphics.rectangle("fill", 0, 0, screen_w, screen_h)
  local w, h = UIScale.begin()
  local phase = self:phase()

  love.graphics.setColor(1.0, 0.76, 0.22, 1)
  love.graphics.setFont(Fonts.get(38))
  love.graphics.printf("MYSTERY CHEST", 0, 30, w, "center")
  love.graphics.setFont(Fonts.get(16))
  love.graphics.setColor(0.86, 0.84, 0.94, 1)
  love.graphics.printf(phase == "converge"
      and "CHESTS CONVERGING"
      or phase == "flash" and "DROP LOCKED"
      or "REWARDS REVEALED",
    0, 76, w, "center")

  if phase == "converge" or phase == "flash" then
    self:_draw_chest_animation(w, h, phase)
  else
    local count = self:visible_reel_count()
    local gap = count >= 5 and 10 or 18
    local available_w = math.min(1180, w - 44)
    local preferred = count == 1 and 520 or count == 3 and 370 or 226
    local card_w = math.min(preferred, (available_w - gap * (count - 1)) / count)
    local total_w = card_w * count + gap * (count - 1)
    local card_h = math.min(count == 1 and 430 or count == 3 and 400 or 350, h - 224)
    local start_x = (w - total_w) / 2
    for index, reward in ipairs(self.rewards) do
      self:_draw_reward_card(reward, {
        x = start_x + (index - 1) * (card_w + gap),
        y = 108, w = card_w, h = card_h,
      }, index)
    end
  end

  if self.complete then
    local rect = self.continue_rect
    local pulse = 0.88 + math.sin(self.elapsed * 4) * 0.10
    love.graphics.setColor(0.035, 0.012, 0.08, 0.98)
    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 8, 8)
    love.graphics.setColor(1.0, 0.76, 0.22, pulse)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 8, 8)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.get(20))
    love.graphics.printf("CONTINUE", rect.x, rect.y + 14, rect.w, "center")
  end

  love.graphics.setColor(0.012, 0.006, 0.04, 0.96)
  love.graphics.rectangle("fill", 0, h - 36, w, 36)
  Hints.draw(self.complete and {
    { symbol = "cross", label = "Continue" },
  } or {
    { symbol = "circle", label = "Skip animation" },
  }, h - 27, w, { font_size = 12, glyph_size = 17, gap = 18 })
  UIScale.finish()
end

function ChestRewardScreen:_continue()
  if not self.complete then return false end
  self.app.states:pop({ kind = "chest_reward", rewards = self.rewards })
  return true
end

function ChestRewardScreen:_skip_animation()
  if self.complete then return false end
  self.elapsed = self:animation_duration()
  self.settled_count = #self.rewards
  self.complete = true
  if not self.resolution_sound_played and self.app.assets then
    self.app.assets:play("level_up", 0.05)
    self.resolution_sound_played = true
  end
  return true
end

function ChestRewardScreen:keypressed(key)
  if key == "escape" and not self.complete then return self:_skip_animation() end
  if key == "return" or key == "space" or key == "x" then
    return self:_continue()
  end
  return false
end

function ChestRewardScreen:gamepadpressed(_, button)
  if button == "b" and not self.complete then return self:_skip_animation() end
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
