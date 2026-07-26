-- Modal three-card progression choice. Combat is frozen because only the top
-- state updates. Offers are generated from authoritative run state.

local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")

local LevelUpScreen = class()
LevelUpScreen.opaque = false

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

function LevelUpScreen:init(app, combat)
  self.app = app
  self.combat = combat
  self.offer = combat.progression:create_offer()
end

function LevelUpScreen:enter()
  self:_layout()
end

function LevelUpScreen:_choose(choice)
  self.combat.progression:apply(choice)
  self.combat.xp:consume_choice()
  self.app.states:pop(choice)
end

function LevelUpScreen:_skip()
  self.combat.progression:skip()
  self.combat.xp:consume_choice()
  self.app.states:pop({ kind = "skip" })
end

function LevelUpScreen:_reroll()
  local offer = self.combat.progression:reroll()
  if offer then
    self.offer = offer
    self:_layout()
  end
end

function LevelUpScreen:_layout()
  local w, h = love.graphics.getDimensions()
  local margin, gap = math.max(28, w * 0.05), 18
  local card_w = math.min(320, (w - margin * 2 - gap * 2) / 3)
  local total_w = card_w * 3 + gap * 2
  local x = (w - total_w) / 2
  local y = h * 0.28
  local card_h = 258
  local buttons = {}

  for index, choice in ipairs(self.offer) do
    buttons[#buttons + 1] = widgets.Button({
      label = "",
      x = x + (index - 1) * (card_w + gap),
      y = y,
      w = card_w,
      h = card_h,
      font_size = 16,
      on_press = function() self:_choose(choice) end,
    })
  end

  buttons[#buttons + 1] = widgets.Button({
    label = "Reroll (" .. self.combat.progression.rerolls .. ")",
    x = w / 2 - 230,
    y = y + card_h + 22,
    w = 210,
    h = 46,
    font_size = 15,
    on_press = function() self:_reroll() end,
  })
  buttons[#buttons + 1] = widgets.Button({
    label = "Skip (+5 coins)",
    x = w / 2 + 20,
    y = y + card_h + 22,
    w = 210,
    h = 46,
    font_size = 15,
    on_press = function() self:_skip() end,
  })
  self.buttons = widgets.ButtonList(buttons)
  self.guide_y = y + card_h + 84
end

function LevelUpScreen:resize()
  self:_layout()
end

function LevelUpScreen:draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(0.02, 0.015, 0.05, 0.90)
  love.graphics.rectangle("fill", 0, 0, w, h)

  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.setFont(Fonts.get(36))
  love.graphics.printf("CHOOSE YOUR NEXT RIFF", 0, h * 0.13, w, "center")
  love.graphics.setColor(settings.ui.text_color)
  love.graphics.setFont(Fonts.get(15))
  love.graphics.printf(
    string.format(
      "Level %d  •  %d weapon slots free  •  %d support slots free  •  %d fusions ready",
      self.combat.xp.level,
      self.combat.inventory.capacity - self.combat.inventory:count(),
      self.combat.progression.passives.capacity - self.combat.progression.passives:count(),
      #self.combat.progression:eligible_evolutions()),
    0, h * 0.21, w, "center")

  self.buttons:draw()
  for index, choice in ipairs(self.offer) do
    local button = self.buttons.buttons[index]
    local color = kind_colors[choice.kind] or settings.ui.accent_color
    if choice.kind == "evolution" then
      love.graphics.setColor(color)
      love.graphics.setLineWidth(3)
      love.graphics.rectangle(
        "line", button.x + 2, button.y + 2, button.w - 4, button.h - 4, 8, 8)
      love.graphics.setLineWidth(1)
    end
    love.graphics.setColor(color)
    love.graphics.setFont(Fonts.get(11))
    love.graphics.printf(
      tostring(index) .. "  " .. (choice.kind == "evolution"
        and "FUSION READY"
        or string.upper(choice.kind:gsub("_", " "))),
      button.x + 12, button.y + 10, button.w - 24, "left")
    self:_draw_choice_icon(choice, button.x + button.w / 2, button.y + 76, 92, color)

    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.get(17))
    love.graphics.printf(choice.title,
      button.x + 12, button.y + 127, button.w - 24, "center")
    love.graphics.setColor(0.74, 0.72, 0.82, 1)
    love.graphics.setFont(Fonts.get(12))
    love.graphics.printf(
      choice.description,
      button.x + 14,
      button.y + 161,
      button.w - 28,
      "center")
    local fusion_hint = self:_fusion_hint(choice)
    if fusion_hint then
      love.graphics.setColor(1.0, 0.76, 0.24, 1)
      love.graphics.setFont(Fonts.get(10))
      love.graphics.printf(
        fusion_hint,
        button.x + 12,
        button.y + 199,
        button.w - 24,
        "center")
    end
    local stats = self:_choice_stats(choice)
    if stats then
      love.graphics.setColor(color)
      love.graphics.setFont(Fonts.get(11))
      love.graphics.printf(stats,
        button.x + 12, button.y + 232, button.w - 24, "center")
    end
  end

  if self:_requirements_visible() then
    self:_draw_evolution_guide(w, h)
  end
end

function LevelUpScreen:_requirements_visible()
  return self.app.tuning:get("ui.show_evolution_requirements")
end

function LevelUpScreen:_recipe_for_base(weapon_id)
  for _, recipe in pairs(self.app.content.evolutions) do
    if recipe.base_weapon == weapon_id then return recipe end
  end
  return nil
end

function LevelUpScreen:_recipe_for_support(support_id)
  for _, recipe in pairs(self.app.content.evolutions) do
    if recipe.required_passives[1].id == support_id then return recipe end
  end
  return nil
end

function LevelUpScreen:_fusion_hint(choice)
  if not self:_requirements_visible() then return nil end
  local recipe
  local prefix
  if choice.kind == "weapon_add" or choice.kind == "weapon_level" then
    recipe = self:_recipe_for_base(choice.id)
    prefix = "R10 + SUPPORT: "
  elseif choice.kind == "passive_add" or choice.kind == "passive_level" then
    recipe = self:_recipe_for_support(choice.id)
    prefix = "PAIRS WITH: "
  end
  if not recipe then return nil end
  local base = self.app.content.weapons[recipe.base_weapon]
  local support = self.app.content.passives[recipe.required_passives[1].id]
  local result = self.app.content.weapons[recipe.result_weapon]
  if choice.kind == "weapon_add" or choice.kind == "weapon_level" then
    return prefix .. support.name .. " -> " .. result.name
  end
  return prefix .. base.name .. " R10 -> " .. result.name
end

function LevelUpScreen:_draw_evolution_guide(w, h)
  local progress = self.combat.progression:evolution_progress()
  if #progress == 0 then return end

  local shown = math.min(3, #progress)
  local panel_w = math.min(1040, w - 48)
  local panel_h = math.min(118, h - self.guide_y - 16)
  if panel_h < 72 then return end
  local panel_x = (w - panel_w) / 2
  local column_w = (panel_w - 28) / shown

  love.graphics.setColor(0.065, 0.055, 0.11, 0.98)
  love.graphics.rectangle(
    "fill", panel_x, self.guide_y, panel_w, panel_h, 8, 8)
  love.graphics.setColor(1.0, 0.72, 0.18, 1)
  love.graphics.rectangle(
    "line", panel_x, self.guide_y, panel_w, panel_h, 8, 8)
  love.graphics.setFont(Fonts.get(11))
  love.graphics.print(
    "EVOLUTION GUIDE  •  BASE WEAPON R10 + PAIRED SUPPORT"
      .. "  •  NO CHEST OR TOKEN REQUIRED",
    panel_x + 14,
    self.guide_y + 9)

  for index = 1, shown do
    local record = progress[index]
    local x = panel_x + 14 + (index - 1) * column_w
    local icon_y = self.guide_y + 70
    self.app.assets:draw_weapon_icon(
      record.base.icon, x + 19, icon_y, 34)
    self.app.assets:draw_support_icon(
      record.support.icon, x + 55, icon_y, 34)
    self.app.assets:draw_weapon_icon(
      record.result.icon, x + 91, icon_y, 34)

    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.get(11))
    love.graphics.print(record.result.name, x + 112, self.guide_y + 39)

    local missing = {}
    if not record.weapon_ready then
      missing[#missing + 1] = record.base.name .. " R"
        .. record.weapon_level .. "/" .. record.required_weapon_level
    end
    if not record.support_ready then
      missing[#missing + 1] = record.support.name
    end
    love.graphics.setColor(record.eligible
      and { 0.34, 1.0, 0.68, 1 }
      or { 1.0, 0.56, 0.34, 1 })
    love.graphics.setFont(Fonts.get(10))
    love.graphics.printf(
      record.eligible
        and "READY: SELECT THE GOLD FUSION CARD"
        or ("MISSING: " .. table.concat(missing, " + ")),
      x + 112,
      self.guide_y + 61,
      column_w - 122,
      "left")
  end

  if #progress > shown then
    love.graphics.setColor(0.65, 0.63, 0.74, 1)
    love.graphics.setFont(Fonts.get(9))
    love.graphics.printf(
      "+" .. (#progress - shown) .. " more paths in Arsenal Database",
      panel_x + panel_w - 230,
      self.guide_y + 9,
      216,
      "right")
  end
end

function LevelUpScreen:_weapon_for_choice(choice)
  if choice.kind == "weapon_add" or choice.kind == "weapon_level" then
    return self.app.content.weapons[choice.id]
  elseif choice.kind == "evolution" then
    local recipe = self.app.content.evolutions[choice.id]
    return self.app.content.weapons[recipe.result_weapon]
  end
  return nil
end

function LevelUpScreen:_draw_choice_icon(choice, x, y, size, color)
  local weapon = self:_weapon_for_choice(choice)
  if weapon then
    self.app.assets:draw_weapon_icon(weapon.icon, x, y, size, { color = { 1, 1, 1, 1 } })
    if choice.kind == "evolution" then
      local recipe = self.app.content.evolutions[choice.id]
      local base = self.app.content.weapons[recipe.base_weapon]
      local support = self.app.content.passives[recipe.required_passives[1].id]
      self.app.assets:draw_weapon_icon(base.icon, x - 39, y + 30, 38)
      self.app.assets:draw_support_icon(support.icon, x + 39, y + 30, 38)
    end
    return
  end

  if choice.kind == "passive_add" or choice.kind == "passive_level" then
    local passive = self.app.content.passives[choice.id]
    if passive and passive.icon then
      self.app.assets:draw_support_icon(passive.icon, x, y, size)
      return
    end
  end

  love.graphics.setColor(color[1], color[2], color[3], 0.16)
  love.graphics.circle("fill", x, y, size * 0.48)
  love.graphics.setColor(color)
  love.graphics.setLineWidth(5)
  if choice.kind == "guard" then
    love.graphics.polygon("line",
      x, y - 32, x + 28, y - 18, x + 22, y + 18, x, y + 34, x - 22, y + 18, x - 28, y - 18)
  elseif choice.kind == "heal" then
    love.graphics.line(x - 24, y, x + 24, y)
    love.graphics.line(x, y - 24, x, y + 24)
  elseif choice.kind == "coins" then
    love.graphics.circle("line", x, y, 28)
    love.graphics.circle("line", x, y, 18)
  elseif choice.id == "quickstep" then
    love.graphics.line(x - 28, y + 18, x + 24, y - 18)
    love.graphics.line(x - 28, y - 2, x + 4, y - 26)
  elseif choice.id == "encore" then
    love.graphics.circle("line", x - 14, y - 8, 18)
    love.graphics.circle("line", x + 14, y - 8, 18)
    love.graphics.line(x - 30, y, x, y + 30, x + 30, y)
  else
    love.graphics.circle("line", x - 13, y, 18)
    love.graphics.circle("line", x + 13, y, 18)
    love.graphics.line(x, y - 30, x, y + 30)
  end
  love.graphics.setLineWidth(1)
end

function LevelUpScreen:_choice_stats(choice)
  local weapon = self:_weapon_for_choice(choice)
  if not weapon then return nil end
  local level = 1
  if choice.kind == "weapon_level" then
    local owned = self.combat.inventory:get(choice.id)
    level = math.min(weapon.max_level, owned.level + 1)
  end
  local stats = weapon.levels[level]
  return string.format("DMG %d   CD %.2fs   ×%d   %s",
    stats.damage, stats.cooldown, stats.count or 1, string.upper(weapon.pattern))
end

function LevelUpScreen:keypressed(key)
  local number = tonumber(key)
  if number and self.offer[number] then
    self:_choose(self.offer[number])
    return true
  elseif key == "r" then
    self:_reroll()
    return true
  elseif key == "escape" or key == "x" then
    self:_skip()
    return true
  end
  return self.buttons:keypressed(key)
end

function LevelUpScreen:gamepadpressed(_, button)
  if button == "a" then
    self.buttons:confirm()
    return true
  elseif button == "x" then
    self:_reroll()
    return true
  elseif button == "b" then
    self:_skip()
    return true
  elseif button == "dpleft" or button == "dpup" then
    self.buttons:move_focus(-1)
    return true
  elseif button == "dpright" or button == "dpdown" then
    self.buttons:move_focus(1)
    return true
  end
  return false
end

function LevelUpScreen:mousemoved(x, y)
  self.buttons:mousemoved(x, y)
end

function LevelUpScreen:mousepressed(x, y, button)
  return self.buttons:mousepressed(x, y, button)
end

return LevelUpScreen
