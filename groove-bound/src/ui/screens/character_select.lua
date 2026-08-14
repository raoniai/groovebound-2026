local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local Icons = require("src.ui.icons")
local settings = require("src.config.settings")
local UIScale = require("src.ui.scale")
local JourneyProgress = require("src.meta.journey_progress")
local MenuChrome = require("src.ui.menu_chrome")

local CharacterSelectScreen = class()
CharacterSelectScreen.kind = "character_select"

local stat_order = {
  { id = "vitality", label = "VITALITY", icon = "health" },
  { id = "power", label = "POWER", icon = "damage" },
  { id = "speed", label = "SPEED", icon = "speed" },
  { id = "defense", label = "DEFENSE", icon = "guard" },
  { id = "tempo", label = "TEMPO", icon = "cooldown" },
  { id = "resonance", label = "RESONANCE", icon = "combo" },
}

function CharacterSelectScreen:init(app, opts)
  self.app = app
  self.opts = opts or {}
  self.ids = { "joe", "lyra" }
  self.selected = 1
  local selected_id = app.slot and app.slot.journey
    and app.slot.journey.character_id or ""
  for index, id in ipairs(self.ids) do
    if id == selected_id then self.selected = index end
  end
end

function CharacterSelectScreen:enter()
  self.app.log.info("state", "Character selection entered")
  self:_layout()
end

function CharacterSelectScreen:_layout()
  local w, h, scale = UIScale.dimensions()
  self.ui_scale = scale
  local gap = math.max(18, w * 0.018)
  local card_w = math.min(480, (w - gap * 3) / 2)
  local card_h = math.min(650, h - 118)
  local start_x = (w - card_w * 2 - gap) / 2
  self.cards = {
    { x = start_x, y = 78, w = card_w, h = card_h },
    { x = start_x + card_w + gap, y = 78, w = card_w, h = card_h },
  }
end

function CharacterSelectScreen:resize()
  self:_layout()
end

function CharacterSelectScreen:_confirm()
  local id = self.ids[self.selected]
  JourneyProgress.select_character(self.app, id)
  if self.opts.on_confirm then
    return self.opts.on_confirm(id)
  end
  local character = self.app.content.characters[id]
  local scene = self.app.content.narrative[character.intro_scene]
  local CutsceneScreen = require("src.ui.screens.cutscene")
  self.app.states:switch(CutsceneScreen(self.app, scene, {
    on_complete = function(app)
      local RunScreen = require("src.ui.screens.run")
      JourneyProgress.begin_run(app, "prologue")
      app.states:switch(RunScreen(app, { character_id = id }))
    end,
  }))
end

local function draw_stat(assets, stat, value, x, y, width, selected)
  Icons.draw(stat.icon, x + 11, y + 8, 19,
    selected and { 0.30, 0.92, 1.0, 0.94 }
      or { 0.62, 0.54, 0.78, 0.72 })
  love.graphics.setFont(Fonts.get(12))
  love.graphics.setColor(0.78, 0.76, 0.86, 1)
  love.graphics.print(stat.label, x + 27, y + 2)
  local fraction = math.max(0.1, math.min(1, (value - 0.75) / 0.55))
  assets:draw_segmented_bar(x + 91, y + 2, width - 91, 14, fraction, {
    frame_color = selected and { 0.54, 0.94, 1.0, 0.94 }
      or { 0.66, 0.56, 0.84, 0.78 },
    fill_color = selected and { 0.22, 0.92, 1.0, 1 }
      or { 0.54, 0.36, 0.78, 1 },
  })
end

function CharacterSelectScreen:draw()
  local screen_w, screen_h = love.graphics.getDimensions()
  local campaign = self.app.assets.campaign
  if campaign and campaign.title_background then
    local background = campaign.title_background
    local scale = math.max(screen_w / background:getWidth(),
      screen_h / background:getHeight())
    love.graphics.setColor(1, 1, 1, 0.38)
    love.graphics.draw(background, screen_w / 2, screen_h / 2, 0,
      scale, scale, background:getWidth() / 2, background:getHeight() / 2)
  end
  love.graphics.setColor(0.008, 0.004, 0.028, 0.78)
  love.graphics.rectangle("fill", 0, 0, screen_w, screen_h)

  local w = UIScale.begin()

  love.graphics.setFont(Fonts.get(34))
  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.printf("CHOOSE YOUR RESONANT", 0, 18, w, "center")
  for index, id in ipairs(self.ids) do
    local character = self.app.content.characters[id]
    local card = self.cards[index]
    local selected = index == self.selected
    love.graphics.setColor(selected and { 0.13, 0.10, 0.24, 0.94 }
      or { 0.075, 0.06, 0.13, 1 })
    love.graphics.rectangle("fill", card.x + 4, card.y + 4,
      card.w - 8, card.h - 8, 8, 8)
    MenuChrome.panel(self.app.assets, card, {
      corner = 42,
      color = selected and { 1, 0.78, 0.24, 1 }
        or { 0.58, 0.54, 0.76, 0.72 },
    })
    if selected then MenuChrome.focus(self.app.assets, card, { inset = -3 }) end

    local portrait_h = math.min(300, card.h * 0.44)
    self.app.assets:draw_portrait(
      character.portrait,
      card.x + 10, card.y + 10, card.w - 20, portrait_h)
    love.graphics.setColor(0.04, 0.025, 0.09, 0.90)
    love.graphics.rectangle(
      "fill", card.x + 10, card.y + portrait_h - 70, card.w - 20, 70)

    self.app.assets:draw_character_logo(
      id, card.x + 24, card.y + portrait_h - 72,
      card.w * 0.66, 68,
      { color = { 1, 1, 1, selected and 1 or 0.74 } })
    love.graphics.setFont(Fonts.get(14))
    love.graphics.setColor(0.30, 0.90, 1.0, 1)
    love.graphics.printf(character.title,
      card.x + card.w * 0.56, card.y + portrait_h - 27,
      card.w * 0.39, "right")
    love.graphics.setFont(Fonts.get(14))
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.printf(
      character.description, card.x + 26, card.y + portrait_h + 10,
      card.w - 52, "left")

    local stats_y = card.y + portrait_h + 55
    local stat_gap = 16
    local stat_w = (card.w - 52 - stat_gap) / 2
    for stat_index, stat in ipairs(stat_order) do
      local column = (stat_index - 1) % 2
      local row = math.floor((stat_index - 1) / 2)
      draw_stat(
        self.app.assets, stat, character.stats[stat.id],
        card.x + 26 + column * (stat_w + stat_gap),
        stats_y + row * 27, stat_w, selected)
    end

    local weapon = self.app.content.weapons[character.starting_weapon]
    local info_y = stats_y + 88
    local info_h = math.min(98, card.y + card.h - info_y - 14)
    love.graphics.setColor(0.035, 0.025, 0.08, 0.90)
    love.graphics.rectangle("fill",
      card.x + 22, info_y + 2, card.w - 44, info_h - 4, 6, 6)
    MenuChrome.panel(self.app.assets, {
      x = card.x + 20, y = info_y, w = card.w - 40, h = info_h,
    }, {
      corner = 24,
      color = selected and { 1, 0.78, 0.24, 0.92 }
        or { 0.50, 0.46, 0.68, 0.62 },
    })
    self.app.assets:draw_weapon_icon(
      weapon.icon, card.x + 61, info_y + 41, 70)
    love.graphics.setFont(Fonts.get(13))
    love.graphics.setColor(1.0, 0.64, 0.24, 1)
    love.graphics.print("STARTING WEAPON", card.x + 105, info_y + 10)
    love.graphics.setFont(Fonts.get(17))
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.print(weapon.name, card.x + 105, info_y + 29)
    love.graphics.setColor(0.46, 1.0, 0.72, 1)
    love.graphics.setFont(Fonts.get(13))
    love.graphics.print(character.trait_name, card.x + 105, info_y + 52)
    love.graphics.setFont(Fonts.get(12))
    love.graphics.setColor(0.76, 0.74, 0.84, 1)
    love.graphics.printf(
      character.trait_text, card.x + 105, info_y + 69,
      card.w - 141, "left")
  end

  UIScale.finish()
end

function CharacterSelectScreen:keypressed(key)
  if key == "left" or key == "a" then
    self.selected = ((self.selected - 2) % #self.ids) + 1
    return true
  elseif key == "right" or key == "d" then
    self.selected = self.selected % #self.ids + 1
    return true
  elseif key == "return" or key == "space" then
    self:_confirm()
    return true
  elseif key == "escape" then
    if self.opts.on_back then return self.opts.on_back() end
    local TitleScreen = require("src.ui.screens.title")
    self.app.states:switch(TitleScreen(self.app))
    return true
  end
  return false
end

function CharacterSelectScreen:mousemoved(x, y)
  x, y = UIScale.point(x, y, self.ui_scale)
  for index, card in ipairs(self.cards) do
    if x >= card.x and x <= card.x + card.w
      and y >= card.y and y <= card.y + card.h
    then
      self.selected = index
    end
  end
end

function CharacterSelectScreen:mousepressed(x, y, button)
  if button ~= 1 then return false end
  x, y = UIScale.point(x, y, self.ui_scale)
  for index, card in ipairs(self.cards) do
    if x >= card.x and x <= card.x + card.w
      and y >= card.y and y <= card.y + card.h
    then
      if self.selected == index then self:_confirm() else self.selected = index end
      return true
    end
  end
  return false
end

function CharacterSelectScreen:gamepadpressed(_, button)
  if button == "dpleft" then return self:keypressed("left") end
  if button == "dpright" then return self:keypressed("right") end
  if button == "a" then return self:keypressed("return") end
  if button == "b" then return self:keypressed("escape") end
  return false
end

return CharacterSelectScreen
