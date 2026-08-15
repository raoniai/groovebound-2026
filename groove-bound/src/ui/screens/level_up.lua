-- Modal three-card progression choice. Combat is frozen because only the top
-- state updates. Offers are generated from authoritative run state.

local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")
local UIScale = require("src.ui.scale")
local MenuChrome = require("src.ui.menu_chrome")
local RankBadge = require("src.ui.rank_badge")

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

local attribute_cells = {
  DMG = 1, RATE = 2, SHOT = 3, SPD = 4,
  HEALTH = 5, GUARD = 6, COINS = 7,
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
  local utility = choice.kind == "heal" or choice.kind == "coins"
    or choice.kind == "guard"
  if utility and self.combat.progression.is_auto_select_available
    and self.combat.progression:is_auto_select_available()
  then
    self.combat.progression:set_auto_fallback(choice.kind)
  end
  local result = self.combat.progression:apply(choice)
  self.combat.xp:consume_choice()
  while self.combat.xp:has_pending_choice()
    and self.combat.progression.can_auto_select
    and self.combat.progression:can_auto_select()
  do
    self.combat.progression:auto_select()
    self.combat.xp:consume_choice()
  end
  local has_more = self.combat.xp:has_pending_choice()
  if has_more then
    self.offer = self.combat.progression:create_offer()
    self:_layout()
  end
  if choice.kind == "evolution" then
    self.close_after_child = not has_more
    local ChestRewardScreen = require("src.ui.screens.chest_reward")
    self.app.states:push(ChestRewardScreen(self.app, {
      source = "level_up",
      skip_chest_intro = true,
      roll = 1,
      has_evolution = true,
      rewards = {
        {
          kind = choice.kind,
          id = choice.id,
          title = choice.title,
          description = choice.description,
          result = result,
        },
      },
    }))
  elseif not has_more then
    self.app.states:pop(choice)
  end
end

function LevelUpScreen:_skip()
  self.combat.progression:skip()
  self.combat.xp:consume_choice()
  if self.combat.xp:has_pending_choice() then
    self.offer = self.combat.progression:create_offer()
    self:_layout()
  else
    self.app.states:pop({ kind = "skip" })
  end
end

function LevelUpScreen:_reroll()
  local offer = self.combat.progression:reroll()
  if offer then
    self.offer = offer
    self:_layout()
  end
end

function LevelUpScreen:_close()
  self.app.states:pop({ kind = "level_up_closed" })
end

function LevelUpScreen:_toggle_automatic()
  local options = self.app.profile.options
  options.automatic_level_up = options.automatic_level_up ~= true
  self.app.save:save(self.app.profile)
end

function LevelUpScreen:resume()
  if self.close_after_child then
    self.close_after_child = false
    self.app.states:pop({ kind = "level_up_complete" })
  end
end

function LevelUpScreen:_layout()
  local w, h, scale = UIScale.dimensions()
  self.ui_scale = scale
  local margin, gap = math.max(22, w * 0.035), 18
  local card_w = (w - margin * 2 - gap * 2) / 3
  local total_w = card_w * 3 + gap * 2
  local x = (w - total_w) / 2
  local compact = h < 680
  local y = compact and 66 or 74
  local card_h = compact and 326 or 382
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

  local cta_gap = 10
  local cta_total_w = math.min(820, w - 44)
  local cta_w = (cta_total_w - cta_gap * 3) / 4
  local cta_x = (w - cta_total_w) / 2
  local cta_y = y + card_h + 10
  buttons[#buttons + 1] = widgets.Button({
    label = "",
    x = cta_x,
    y = cta_y,
    w = cta_w,
    h = compact and 52 or 58,
    font_size = 18,
    on_press = function() self:_reroll() end,
  })
  buttons[#buttons + 1] = widgets.Button({
    label = "",
    x = cta_x + cta_w + cta_gap,
    y = cta_y,
    w = cta_w,
    h = compact and 52 or 58,
    font_size = 18,
    on_press = function() self:_skip() end,
  })
  buttons[#buttons + 1] = widgets.Button({
    label = "",
    x = cta_x + (cta_w + cta_gap) * 2,
    y = cta_y,
    w = cta_w,
    h = compact and 52 or 58,
    font_size = 18,
    on_press = function() self:_toggle_automatic() end,
  })
  buttons[#buttons + 1] = widgets.Button({
    label = "",
    x = cta_x + (cta_w + cta_gap) * 3,
    y = cta_y,
    w = cta_w,
    h = compact and 52 or 58,
    font_size = 18,
    on_press = function() self:_close() end,
  })
  self.buttons = widgets.ButtonList(buttons)
  self.compact = compact
  self.guide_y = y + card_h + (compact and 72 or 80)
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
  love.graphics.setFont(Fonts.heading(h < 680 and 27 or 34))
  local heading_y = h < 680 and 18 or 24
  love.graphics.printf("CHOOSE YOUR NEXT RIFF",
    0, heading_y, w, "center")
  RankBadge.draw(self.app.assets, w / 2 + math.min(244, w * 0.29),
    heading_y - 3, h < 680 and 34 or 40,
    self.combat.xp.pending_choices)

  local reroll_button = self.buttons.buttons[#self.offer + 1]
  local skip_button = self.buttons.buttons[#self.offer + 2]
  local auto_button = self.buttons.buttons[#self.offer + 3]
  local close_button = self.buttons.buttons[#self.offer + 4]
  if reroll_button then self:_draw_cta(reroll_button, "reroll") end
  if skip_button then self:_draw_cta(skip_button, "skip") end
  if auto_button then self:_draw_cta(auto_button, "automatic") end
  if close_button then self:_draw_cta(close_button, "close") end
  for index, choice in ipairs(self.offer) do
    local button = self.buttons.buttons[index]
    local color = kind_colors[choice.kind] or settings.ui.accent_color
    if button.focused then
      love.graphics.setColor(color[1], color[2], color[3], 0.14)
      love.graphics.rectangle("fill", button.x - 5, button.y - 5,
        button.w + 10, button.h + 10, 12, 12)
    end
    self.app.assets:draw_upgrade_card_frame(
      button.x, button.y, button.w, button.h, { corner = self.compact and 42 or 48 })
    if button.focused then
      self.app.assets:draw_menu_focus_frame(
        button.x - 5, button.y - 5, button.w + 10, button.h + 10,
        { corner = self.compact and 34 or 40 })
    end
    love.graphics.setColor(color[1], color[2], color[3], 0.12)
    love.graphics.rectangle("fill", button.x + 18, button.y + 14,
      button.w - 36, 30, 5, 5)
    love.graphics.setColor(color)
    love.graphics.setFont(Fonts.heading(self.compact and 12 or 13))
    love.graphics.printf(tostring(index) .. "  "
      .. string.upper(choice.kind:gsub("_", " ")),
      button.x + 26, button.y + 21, button.w - 52, "left")
    if choice.kind == "weapon_add" or choice.kind == "passive_add" then
      self.app.assets:draw_new_tag(button.x + button.w - 84,
        button.y + 15, 64, 27)
    end
    local icon_size = self.compact and 68 or 84
    self:_draw_choice_icon(choice, button.x + button.w / 2,
      button.y + (self.compact and 91 or 100), icon_size, color)

    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.heading(self.compact and 17 or 19))
    local title = (choice.title or ""):gsub("%s+R%d+$", "")
    love.graphics.printf(title,
      button.x + 28, button.y + (self.compact and 132 or 148),
      button.w - 56, "center")

    local rank, maxed = self:_choice_rank(choice)
    if rank then
      RankBadge.draw(self.app.assets,
        button.x + button.w - (self.compact and 48 or 54),
        button.y + 49, self.compact and 34 or 40, rank, { maxed = maxed })
    end

    local description_y = button.y + (self.compact and 164 or 181)
    local description_h = self.compact and 49 or 58
    love.graphics.setColor(0.08, 0.055, 0.14, 0.70)
    love.graphics.rectangle("fill", button.x + 26, description_y,
      button.w - 52, description_h, 6, 6)
    love.graphics.setColor(0.80, 0.79, 0.89, 1)
    love.graphics.setFont(Fonts.body(self.compact and 11 or 12))
    love.graphics.printf(choice.description or "",
      button.x + 38, description_y + 9, button.w - 76, "center")

    local stats_y = description_y + description_h + 8
    self:_draw_attribute_group(choice, button, color, stats_y,
      button.y + button.h - stats_y - 20)
  end

  if self:_requirements_visible() then
    self:_draw_evolution_guide(w, h)
  end
  UIScale.finish()
end

function LevelUpScreen:_choice_rank(choice)
  if choice.kind == "weapon_add" then return 1, false end
  if choice.kind == "weapon_level" then
    local definition = self.app.content.weapons[choice.id]
    local owned = self.combat.inventory:get(choice.id)
    local level = math.min(definition.max_level, owned.level + 1)
    return level, level >= definition.max_level
  end
  if choice.kind == "passive_add" then return 1, false end
  if choice.kind == "passive_level" then
    local definition = self.app.content.passives[choice.id]
    local owned = self.combat.progression.passives:get(choice.id)
    local level = math.min(definition.max_level, owned.level + 1)
    return level, level >= definition.max_level
  end
  if choice.kind == "evolution" then return 0, true end
  return nil, false
end

function LevelUpScreen:_draw_cta(button, kind)
  local is_reroll = kind == "reroll"
  local automatic = kind == "automatic"
  local close = kind == "close"
  local enabled = self.app.profile.options.automatic_level_up == true
  local color = is_reroll and { 0.30, 0.92, 1.0, 1 }
    or automatic and (enabled and { 0.34, 1.0, 0.68, 1 }
      or { 0.72, 0.54, 1.0, 1 })
    or close and { 0.72, 0.74, 0.86, 1 }
    or { 0.96, 0.38, 0.72, 1 }
  local alpha = button.focused and 1 or 0.82
  MenuChrome.cta(self.app.assets, button, {
    focused = button.focused, alpha = alpha,
  })
  local icon = is_reroll and 7 or automatic and 10 or close and 6 or 1
  self.app.assets:draw_menu_stat_icon(icon,
    button.x + 10, button.y + 4, button.h - 8,
    { color = { 1, 1, 1, alpha } })
  love.graphics.setColor(color[1], color[2], color[3], alpha)
  love.graphics.setFont(Fonts.heading(15))
  local label = is_reroll and "REROLL" or automatic and "AUTO MENU"
    or close and "CLOSE" or "SKIP"
  love.graphics.printf(label,
    button.x + 62, button.y + 10, button.w - 72, "center")
  love.graphics.setColor(0.78, 0.77, 0.88, alpha)
  love.graphics.setFont(Fonts.body(10))
  local detail = is_reroll and (self.combat.progression.rerolls .. " LEFT")
    or automatic and (enabled and "ON" or "OFF")
    or close and "SAVE POINTS" or "+5 COINS"
  love.graphics.printf(detail,
    button.x + 62, button.y + 31, button.w - 72, "center")
end

function LevelUpScreen:_move_focus(direction)
  local index = self.buttons.focus_index
  local top_count = #self.offer
  local bottom_first = top_count + 1
  local bottom_last = #self.buttons.buttons
  local in_top = index <= top_count
  local first = in_top and 1 or bottom_first
  local last = in_top and top_count or bottom_last

  if direction == "left" then
    if index > first then self.buttons.focus_index = index - 1 end
  elseif direction == "right" then
    if index < last then self.buttons.focus_index = index + 1 end
  elseif direction == "down" and in_top then
    local current = self.buttons.buttons[index]
    local centre = current.x + current.w / 2
    local best, distance
    for candidate = bottom_first, bottom_last do
      local button = self.buttons.buttons[candidate]
      local candidate_centre = button.x + button.w / 2
      local delta = math.abs(candidate_centre - centre)
      if not distance or delta < distance then
        best, distance = candidate, delta
      end
    end
    self.buttons.focus_index = best or index
  elseif direction == "up" and not in_top then
    local current = self.buttons.buttons[index]
    local centre = current.x + current.w / 2
    local best, distance
    for candidate = 1, top_count do
      local button = self.buttons.buttons[candidate]
      local candidate_centre = button.x + button.w / 2
      local delta = math.abs(candidate_centre - centre)
      if not distance or delta < distance then
        best, distance = candidate, delta
      end
    end
    self.buttons.focus_index = best or index
  end
  self.buttons:_apply_focus()
  return true
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
    local function add(label, total, gain, suffix, icon)
      if not previous or gain ~= 0 then
        result[#result + 1] = {
          label = label,
          gain = (gain >= 0 and "+" or "") .. tostring(gain) .. (suffix or ""),
          total = tostring(total) .. (suffix or ""),
          icon = icon,
        }
      end
    end
    add("DMG", stats.damage, previous and stats.damage - previous.damage
      or stats.damage, nil, 1)
    if not previous or stats.cooldown ~= previous.cooldown then
      result[#result + 1] = {
        label = "RATE",
        gain = previous and string.format("-%.2fs", previous.cooldown - stats.cooldown)
          or string.format("%.2fs", stats.cooldown),
        total = string.format("%.2fs", stats.cooldown),
        icon = 2,
      }
    end
    add("SHOT", stats.count or 1, previous
      and (stats.count or 1) - (previous.count or 1) or (stats.count or 1), nil, 3)
    add("SPD", stats.speed or 0, previous
      and (stats.speed or 0) - (previous.speed or 0) or (stats.speed or 0), nil, 4)
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
      icon = 8,
    } }
  end
  local simple = {
    heal = { label = "HEALTH", gain = "+30%", total = "AUTO", icon = 5 },
    guard = { label = "GUARD", gain = "+25", total = "AUTO", icon = 6 },
    coins = { label = "COINS", gain = "+25", total = "AUTO", icon = 7 },
  }
  return simple[choice.kind] and { simple[choice.kind] } or {}
end

function LevelUpScreen:_draw_attribute_group(choice, button, color, y, height)
  local items = self:_choice_stat_items(choice)
  if #items == 0 then return end
  while #items > 4 do table.remove(items) end
  local x = button.x + 26
  local width = button.w - 52
  love.graphics.setColor(color[1], color[2], color[3], 0.10)
  love.graphics.rectangle("fill", x, y, width, height, 6, 6)
  love.graphics.setColor(color)
  love.graphics.setFont(Fonts.heading(self.compact and 11 or 12))
  love.graphics.printf("RANK GAINS  /  TOTAL",
    x + 12, y + 9, width - 24, "left")
  love.graphics.setColor(color[1], color[2], color[3], 0.45)
  love.graphics.line(x + 12, y + 28, x + width - 12, y + 28)

  local columns = #items == 1 and 1 or 2
  local rows = math.ceil(#items / columns)
  local item_w = width / columns
  local item_h = math.max(36, (height - 32) / rows)
  for index, item in ipairs(items) do
    local column = (index - 1) % columns
    local row = math.floor((index - 1) / columns)
    local item_x = x + column * item_w
    local item_y = y + 31 + row * item_h
    if column > 0 then
      love.graphics.setColor(color[1], color[2], color[3], 0.22)
      love.graphics.line(item_x, item_y + 4, item_x, item_y + item_h - 4)
    end
    if row > 0 then
      love.graphics.setColor(color[1], color[2], color[3], 0.18)
      love.graphics.line(item_x + 8, item_y, item_x + item_w - 8, item_y)
    end
    self.app.assets:draw_upgrade_attribute_icon(item.icon
      or attribute_cells[item.label] or 8,
      item_x + 8, item_y + 5, math.min(30, item_h - 10))
    love.graphics.setColor(0.90, 0.89, 0.98, 1)
    love.graphics.setFont(Fonts.heading(self.compact and 10 or 11))
    love.graphics.printf(item.label, item_x + 42, item_y + 7,
      item_w - 50, "left")
    love.graphics.setColor(0.34, 1.0, 0.68, 1)
    love.graphics.setFont(Fonts.body(self.compact and 11 or 12))
    love.graphics.printf(item.gain .. "   >   " .. item.total,
      item_x + 42, item_y + 24, item_w - 50, "left")
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
    prefix = "MAX RANK + SUPPORT: "
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
  return prefix .. base.name .. " AT MAX -> " .. result.name
end

function LevelUpScreen:evolution_recipe_layout(cell_w)
  local icon_size = math.max(30, math.min(42, cell_w * 0.19))
  return {
    base_x = cell_w * 0.16,
    plus = { x = cell_w * 0.33, label = "+" },
    support_x = cell_w * 0.50,
    equals = { x = cell_w * 0.67, label = "=" },
    result_x = cell_w * 0.84,
    icon_size = icon_size,
    result_size = math.min(48, icon_size + 6),
  }
end

function LevelUpScreen:_draw_evolution_guide(w, h)
  local records = self:evolution_records()
  if #records == 0 then return end
  local columns = math.min(4, #records)
  local rows = math.ceil(#records / columns)
  local gap = 12
  local cell_w = math.min(268, (w - 44 - gap * (columns - 1)) / columns)
  local cell_h = math.min(88, (h - self.guide_y - 42 - 20) / rows)
  if cell_h < 42 then return end
  local total_w = cell_w * columns + gap * (columns - 1)
  local start_x = (w - total_w) / 2
  love.graphics.setColor(0.74, 0.72, 0.84, 1)
  love.graphics.setFont(Fonts.heading(11))
  love.graphics.printf("YOUR EVOLUTION PATHS", start_x, self.guide_y,
    total_w, "left")
  for index, record in ipairs(records) do
    local column = (index - 1) % columns
    local row = math.floor((index - 1) / columns)
    local x = start_x + column * (cell_w + gap)
    local y = self.guide_y + 18 + row * cell_h
    local tint = record.eligible and { 1, 0.74, 0.20, 1 }
      or { 0.30, 0.92, 1.0, 1 }
    love.graphics.setColor(tint[1], tint[2], tint[3], 0.09)
    love.graphics.rectangle("fill", x, y, cell_w, cell_h - 6, 7, 7)
    self.app.assets:draw_hud_frame(x, y, cell_w, cell_h - 6,
      { corner = 8, color = { tint[1], tint[2], tint[3], 0.58 } })
    local icon_y = y + 28
    local recipe_layout = self:evolution_recipe_layout(cell_w)
    self.app.assets:draw_weapon_icon(record.base.icon,
      x + recipe_layout.base_x, icon_y, recipe_layout.icon_size,
      { color = { 1, 1, 1, 0.80 } })
    love.graphics.setColor(0.42, 0.88, 1, 0.96)
    love.graphics.setFont(Fonts.heading(cell_w < 210 and 15 or 17))
    love.graphics.printf(recipe_layout.plus.label,
      x + recipe_layout.plus.x - 12, icon_y - 9, 24, "center")
    self.app.assets:draw_support_icon(record.support.icon,
      x + recipe_layout.support_x, icon_y, recipe_layout.icon_size,
      { color = { 1, 1, 1, 0.80 } })
    love.graphics.setColor(1, 0.74, 0.20, 0.98)
    love.graphics.printf(recipe_layout.equals.label,
      x + recipe_layout.equals.x - 12, icon_y - 9, 24, "center")
    self.app.assets:draw_weapon_icon(record.result.icon,
      x + recipe_layout.result_x, icon_y, recipe_layout.result_size,
      { color = { 1, 1, 1, 1 } })
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.heading(12))
    love.graphics.printf(record.result.name, x + 8, y + cell_h - 30,
      cell_w - 16, "center")
  end
end

function LevelUpScreen:evolution_records()
  return self.combat.progression:evolution_progress()
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
      return string.format("RANK TOTAL %+d%%", math.floor(value * 100 + 0.5)),
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
  elseif key == "t" then
    self:_toggle_automatic()
    return true
  elseif key == "escape" or key == "x" then
    self:_close()
    return true
  end
  local directions = {
    up = "up", w = "up", down = "down", s = "down",
    left = "left", a = "left", right = "right", d = "right",
  }
  if directions[key] then return self:_move_focus(directions[key]) end
  return self.buttons:keypressed(key)
end

function LevelUpScreen:gamepadpressed(_, button)
  if button == "x" then
    self:_reroll()
    return true
  elseif button == "y" then
    self:_toggle_automatic()
    return true
  elseif button == "b" then
    self:_close()
    return true
  end
  local directions = {
    dpup = "up", dpdown = "down", dpleft = "left", dpright = "right",
  }
  if directions[button] then return self:_move_focus(directions[button]) end
  return self.buttons:gamepadpressed(button)
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
