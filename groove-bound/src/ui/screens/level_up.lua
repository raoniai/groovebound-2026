-- Modal three-card progression choice. Combat is frozen because only the top
-- state updates. Offers are generated from authoritative run state.

local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")
local Hints = require("src.ui.controller_hints")
local UIScale = require("src.ui.scale")

local LevelUpScreen = class()
LevelUpScreen.kind = "level_up"
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
  if choice.kind == "heal" or choice.kind == "coins" or choice.kind == "guard" then
    self.combat.progression:set_auto_fallback(choice.kind)
  end
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
  local w, h, scale = UIScale.dimensions()
  self.ui_scale = scale
  local margin, gap = math.max(28, w * 0.05), 18
  local card_w = math.min(320, (w - margin * 2 - gap * 2) / 3)
  local total_w = card_w * 3 + gap * 2
  local x = (w - total_w) / 2
  local compact = h < 680
  local y = compact and 82 or 112
  local card_h = compact and 252 or 330
  local buttons = {}

  for index, choice in ipairs(self.offer) do
    buttons[#buttons + 1] = widgets.Button({
      label = "",
      x = x + (index - 1) * (card_w + gap),
      y = y,
      w = card_w,
      h = card_h,
      font_size = 18,
      on_press = function() self:_choose(choice) end,
    })
  end

  buttons[#buttons + 1] = widgets.Button({
    label = "",
    x = w / 2 - 154,
    y = y + card_h + 10,
    w = 132,
    h = 58,
    font_size = 18,
    on_press = function() self:_reroll() end,
  })
  buttons[#buttons + 1] = widgets.Button({
    label = "",
    x = w / 2 + 22,
    y = y + card_h + 10,
    w = 132,
    h = 58,
    font_size = 18,
    on_press = function() self:_skip() end,
  })
  self.buttons = widgets.ButtonList(buttons)
  self.guide_y = y + card_h + 76
end

function LevelUpScreen:resize()
  self:_layout()
end

function LevelUpScreen:draw()
  local screen_w, screen_h = love.graphics.getDimensions()
  love.graphics.setColor(0.02, 0.015, 0.05, 0.90)
  love.graphics.rectangle("fill", 0, 0, screen_w, screen_h)
  local w, h = UIScale.begin()

  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.setFont(Fonts.heading(h < 680 and 29 or 36))
  local auto_setup = self.combat.progression:is_auto_select_available()
    and not self.combat.progression:can_auto_select()
  love.graphics.printf(auto_setup and "CHOOSE AUTO PICK" or "CHOOSE YOUR NEXT RIFF",
    0, h < 680 and 26 or 46, w, "center")

  local reroll_button = self.buttons.buttons[#self.offer + 1]
  local skip_button = self.buttons.buttons[#self.offer + 2]
  if reroll_button then
    local alpha = reroll_button.focused and 1 or 0.72
    self.app.assets:draw_menu_button_icon(5, 2,
      reroll_button.x + 30, reroll_button.y, 72, 58,
      { color = { 1, 1, 1, alpha } })
    love.graphics.setColor(0.30, 0.92, 1.0, alpha)
    love.graphics.setFont(Fonts.body(12))
    love.graphics.printf("×" .. self.combat.progression.rerolls,
      reroll_button.x + 92, reroll_button.y + 22, 35, "left")
  end
  if skip_button then
    local alpha = skip_button.focused and 1 or 0.72
    self.app.assets:draw_menu_button_icon(5, 1,
      skip_button.x + 28, skip_button.y, 72, 58,
      { color = { 1, 1, 1, alpha } })
    love.graphics.setColor(0.96, 0.38, 0.72, alpha)
    love.graphics.setFont(Fonts.body(12))
    love.graphics.printf("+5", skip_button.x + 90,
      skip_button.y + 22, 35, "left")
  end
  for index, choice in ipairs(self.offer) do
    local button = self.buttons.buttons[index]
    local color = kind_colors[choice.kind] or settings.ui.accent_color
    local alpha = button.focused and 1 or 0.78
    self.app.assets:draw_ui_backplate(button.x, button.y, button.w, button.h, {
      color = { color[1], color[2], color[3], alpha },
    })
    love.graphics.setColor(color)
    love.graphics.setFont(Fonts.body(12))
    love.graphics.printf(tostring(index) .. "  "
      .. string.upper(choice.kind:gsub("_", " ")),
      button.x + 18, button.y + 16, button.w - 36, "left")
    if choice.kind == "weapon_add" or choice.kind == "passive_add" then
      self.app.assets:draw_new_tag(button.x + button.w - 78,
        button.y + 10, 68, 29)
    end
    local icon_size = h < 680 and 82 or 104
    self:_draw_choice_icon(choice, button.x + button.w / 2,
      button.y + (h < 680 and 82 or 96), icon_size, color)

    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.body(h < 680 and 16 or 19))
    love.graphics.printf(choice.title,
      button.x + 18, button.y + (h < 680 and 134 or 158),
      button.w - 36, "center")
    self:_draw_gain_strip(choice, button, color)
  end

  if self:_requirements_visible() then
    self:_draw_evolution_guide(w, h)
  end
  love.graphics.setColor(0.015, 0.01, 0.05, 0.92)
  love.graphics.rectangle("fill", 0, h - 40, w, 40)
  Hints.draw({
    { symbol = "dpad", label = "Choose" },
    { symbol = "cross", label = "Select" },
    { symbol = "square", label = "Reroll" },
    { symbol = "circle", label = "Skip" },
  }, h - 30, w, { font_size = 13, glyph_size = 18, gap = 18 })
  UIScale.finish()
end

function LevelUpScreen:_choice_stat_items(choice)
  local weapon = self:_weapon_for_choice(choice)
  if weapon then
    local level = 1
    local previous
    if choice.kind == "weapon_level" then
      local owned = self.combat.inventory:get(choice.id)
      level = math.min(weapon.max_level, owned.level + 1)
      previous = weapon.levels[owned.level]
    end
    local stats = weapon.levels[level]
    local result = {}
    local function add(label, total, gain, suffix)
      if not previous or gain ~= 0 then
        result[#result + 1] = {
          label = label,
          gain = (gain >= 0 and "+" or "") .. tostring(gain) .. (suffix or ""),
          total = tostring(total) .. (suffix or ""),
        }
      end
    end
    add("DMG", stats.damage, previous and stats.damage - previous.damage
      or stats.damage)
    if not previous or stats.cooldown ~= previous.cooldown then
      result[#result + 1] = {
        label = "RATE",
        gain = previous and string.format("-%.2fs", previous.cooldown - stats.cooldown)
          or string.format("%.2fs", stats.cooldown),
        total = string.format("%.2fs", stats.cooldown),
      }
    end
    add("SHOT", stats.count or 1, previous
      and (stats.count or 1) - (previous.count or 1) or (stats.count or 1))
    add("SPD", stats.speed or 0, previous
      and (stats.speed or 0) - (previous.speed or 0) or (stats.speed or 0))
    return result
  end
  if choice.kind == "passive_add" or choice.kind == "passive_level" then
    local passive = self.app.content.passives[choice.id]
    local owned = self.combat.progression.passives:get(choice.id)
    local level = math.min(passive.max_level, (owned and owned.level or 0) + 1)
    return { {
      label = string.upper(passive.stat:gsub("_", " ")),
      gain = string.format("+%d%%", math.floor(passive.per_level * 100 + 0.5)),
      total = string.format("%d%%",
        math.floor(passive.per_level * level * 100 + 0.5)),
    } }
  end
  local simple = {
    heal = { label = "HEALTH", gain = "+30%", total = "AUTO" },
    guard = { label = "GUARD", gain = "+25", total = "AUTO" },
    coins = { label = "COINS", gain = "+25", total = "AUTO" },
  }
  return simple[choice.kind] and { simple[choice.kind] } or {}
end

function LevelUpScreen:_draw_gain_strip(choice, button, color)
  local items = self:_choice_stat_items(choice)
  if #items == 0 then return end
  while #items > 3 do table.remove(items) end
  local y = button.y + button.h - 68
  local icon_x = button.x + 32
  self:_draw_choice_icon(choice, icon_x, y + 30, 40, color)
  local x = button.x + 58
  local width = button.w - 72
  local item_w = width / #items
  for index, item in ipairs(items) do
    local item_x = x + (index - 1) * item_w
    love.graphics.setColor(0.76, 0.73, 0.86, 1)
    love.graphics.setFont(Fonts.body(10))
    love.graphics.printf(item.label, item_x, y + 4, item_w, "center")
    love.graphics.setColor(0.34, 1.0, 0.68, 1)
    love.graphics.setFont(Fonts.body(13))
    love.graphics.printf(item.gain .. "  →  " .. item.total,
      item_x, y + 25, item_w, "center")
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
  local records = {}
  for id, recipe in pairs(self.app.content.evolutions) do
    records[#records + 1] = {
      id = id,
      base = self.app.content.weapons[recipe.base_weapon],
      support = self.app.content.passives[recipe.required_passives[1].id],
      result = self.app.content.weapons[recipe.result_weapon],
    }
  end
  table.sort(records, function(a, b) return a.result.name < b.result.name end)
  if #records == 0 then return end
  local columns = w >= 1100 and math.min(8, #records) or math.min(5, #records)
  local rows = math.ceil(#records / columns)
  local cell_w = math.min(150, (w - 40) / columns)
  local cell_h = math.min(70, (h - self.guide_y - 42) / rows)
  if cell_h < 48 then return end
  local total_w = cell_w * columns
  local start_x = (w - total_w) / 2
  for index, record in ipairs(records) do
    local column = (index - 1) % columns
    local row = math.floor((index - 1) / columns)
    local x = start_x + column * cell_w
    local y = self.guide_y + row * cell_h
    local icon_y = y + 23
    self.app.assets:draw_weapon_icon(record.base.icon, x + 27, icon_y, 34,
      { color = { 1, 1, 1, 0.72 } })
    self.app.assets:draw_support_icon(record.support.icon,
      x + cell_w / 2, icon_y, 34, { color = { 1, 1, 1, 0.72 } })
    self.app.assets:draw_weapon_icon(record.result.icon,
      x + cell_w - 27, icon_y, 40, { color = { 1, 1, 1, 1 } })
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.body(11))
    love.graphics.printf(record.result.name, x + 4, y + 45,
      cell_w - 8, "center")
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

function LevelUpScreen:_draw_choice_icon(choice, x, y, size, _color)
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

  if choice.kind == "guard" then
    self.app.assets:draw_pickup("defense", x, y, size)
  elseif choice.kind == "heal" then
    self.app.assets:draw_pickup("heal", x, y, size)
  elseif choice.kind == "coins" then
    self.app.assets:draw_xp_gem(4, x, y, size)
  else
    self.app.assets:draw_world_interface(5, 1,
      x - size / 2, y - size / 2, size, size)
  end
end

function LevelUpScreen:_choice_stats(choice)
  local weapon = self:_weapon_for_choice(choice)
  if not weapon then
    if choice.kind == "passive_add" or choice.kind == "passive_level" then
      local passive = self.app.content.passives[choice.id]
      local owned = self.combat.progression.passives:get(choice.id)
      local from = owned and owned.level or 0
      local to = math.min(passive.max_level, from + 1)
      local value = passive.per_level * to
      local delta = passive.per_level
      return string.format("R%d  TOTAL %+d%%", to, math.floor(value * 100 + 0.5)),
        string.format("%+d%% %s", math.floor(delta * 100 + 0.5),
          string.upper(passive.stat:gsub("_", " ")))
    end
    if choice.kind == "heal" then return "RESTORE 30% MAX HP", "+30% HEALTH" end
    if choice.kind == "guard" then return "ADD 25 GUARD", "+25 DEFENSE" end
    if choice.kind == "coins" then return "BANK 25 COINS", "+25 RESULTS VALUE" end
    return nil
  end
  local level = 1
  local previous
  if choice.kind == "weapon_level" then
    local owned = self.combat.inventory:get(choice.id)
    previous = weapon.levels[owned.level]
    level = math.min(weapon.max_level, owned.level + 1)
  end
  local stats = weapon.levels[level]
  local summary = string.format("DMG %d   %.2fs   ×%d   SPD %d",
    stats.damage, stats.cooldown, stats.count or 1, stats.speed or 0)
  if not previous then
    return summary, choice.kind == "evolution" and "NEW EVOLVED ATTACK PATTERN" or "NEW ACTIVE WEAPON"
  end
  local improvements = {}
  if stats.damage ~= previous.damage then
    improvements[#improvements + 1] = string.format("%+d DMG", stats.damage - previous.damage)
  end
  if stats.cooldown ~= previous.cooldown then
    improvements[#improvements + 1] = string.format("%.2fs FASTER", previous.cooldown - stats.cooldown)
  end
  if (stats.count or 1) ~= (previous.count or 1) then
    improvements[#improvements + 1] = string.format("%+d SHOT",
      (stats.count or 1) - (previous.count or 1))
  end
  if stats.speed ~= previous.speed then
    improvements[#improvements + 1] = string.format("%+d SPEED", stats.speed - previous.speed)
  end
  return summary, table.concat(improvements, "  •  ")
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
  x, y = UIScale.point(x, y, self.ui_scale)
  self.buttons:mousemoved(x, y)
end

function LevelUpScreen:mousepressed(x, y, button)
  x, y = UIScale.point(x, y, self.ui_scale)
  return self.buttons:mousepressed(x, y, button)
end

return LevelUpScreen
