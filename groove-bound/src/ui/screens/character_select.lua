local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")

local CharacterSelectScreen = class()
CharacterSelectScreen.kind = "character_select"

local stat_order = {
  { id = "vitality", label = "VITALITY" },
  { id = "power", label = "POWER" },
  { id = "speed", label = "SPEED" },
  { id = "defense", label = "DEFENSE" },
  { id = "tempo", label = "TEMPO" },
  { id = "resonance", label = "RESONANCE" },
}

function CharacterSelectScreen:init(app)
  self.app = app
  self.ids = { "joe", "lyra" }
  self.selected = 1
end

function CharacterSelectScreen:enter()
  self.app.log.info("state", "Character selection entered")
  self:_layout()
end

function CharacterSelectScreen:_layout()
  local w, h = love.graphics.getDimensions()
  local gap = math.max(18, w * 0.018)
  local card_w = math.min(480, (w - gap * 3) / 2)
  local card_h = math.min(650, h - 150)
  local start_x = (w - card_w * 2 - gap) / 2
  self.cards = {
    { x = start_x, y = 108, w = card_w, h = card_h },
    { x = start_x + card_w + gap, y = 108, w = card_w, h = card_h },
  }
end

function CharacterSelectScreen:resize()
  self:_layout()
end

function CharacterSelectScreen:_confirm()
  local id = self.ids[self.selected]
  local character = self.app.content.characters[id]
  local scene = self.app.content.narrative[character.intro_scene]
  local CutsceneScreen = require("src.ui.screens.cutscene")
  self.app.states:switch(CutsceneScreen(self.app, scene, {
    on_complete = function(app)
      local RunScreen = require("src.ui.screens.run")
      app.states:switch(RunScreen(app, { character_id = id }))
    end,
  }))
end

local function draw_stat(label, value, x, y, width, selected)
  love.graphics.setFont(Fonts.get(14))
  love.graphics.setColor(0.78, 0.76, 0.86, 1)
  love.graphics.print(label, x, y)
  love.graphics.setColor(0.07, 0.055, 0.12, 1)
  love.graphics.rectangle("fill", x + 105, y + 4, width - 105, 12, 4, 4)
  love.graphics.setColor(selected and { 0.22, 0.92, 1.0, 1 }
    or { 0.54, 0.36, 0.78, 1 })
  local fraction = math.max(0.1, math.min(1, (value - 0.75) / 0.55))
  love.graphics.rectangle("fill", x + 105, y + 4, (width - 105) * fraction, 12, 4, 4)
end

function CharacterSelectScreen:draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.setColor(0.12, 0.02, 0.18, 0.55)
  for index = 1, 14 do
    local x = (index * 173) % w
    love.graphics.circle("fill", x, (index * 97) % h, 3 + index % 5)
  end

  love.graphics.setFont(Fonts.get(34))
  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.printf("CHOOSE YOUR RESONANT", 0, 28, w, "center")
  love.graphics.setFont(Fonts.get(17))
  love.graphics.setColor(0.72, 0.70, 0.82, 1)
  love.graphics.printf(
    "Shared story. Different rhythm. Your complete build carries into Stage 2.",
    0, 72, w, "center")

  for index, id in ipairs(self.ids) do
    local character = self.app.content.characters[id]
    local card = self.cards[index]
    local selected = index == self.selected
    love.graphics.setColor(selected and { 0.13, 0.10, 0.24, 1 }
      or { 0.075, 0.06, 0.13, 1 })
    love.graphics.rectangle("fill", card.x, card.y, card.w, card.h, 10, 10)
    love.graphics.setColor(selected and settings.ui.accent_color
      or { 0.32, 0.28, 0.46, 1 })
    love.graphics.setLineWidth(selected and 4 or 2)
    love.graphics.rectangle("line", card.x, card.y, card.w, card.h, 10, 10)

    local portrait_h = math.min(250, card.h * 0.38)
    self.app.assets:draw_portrait(
      character.portrait,
      card.x + 10, card.y + 10, card.w - 20, portrait_h)
    love.graphics.setColor(0.04, 0.025, 0.09, 0.90)
    love.graphics.rectangle(
      "fill", card.x + 10, card.y + portrait_h - 54, card.w - 20, 54)

    love.graphics.setFont(Fonts.get(28))
    love.graphics.setColor(selected and settings.ui.accent_color
      or settings.ui.text_color)
    love.graphics.print(character.name, card.x + 26, card.y + portrait_h - 44)
    love.graphics.setFont(Fonts.get(14))
    love.graphics.setColor(0.30, 0.90, 1.0, 1)
    love.graphics.print(character.title, card.x + 26, card.y + portrait_h + 14)
    love.graphics.setFont(Fonts.get(16))
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.printf(
      character.description, card.x + 26, card.y + portrait_h + 43,
      card.w - 52, "left")

    local stats_y = card.y + portrait_h + 92
    for stat_index, stat in ipairs(stat_order) do
      draw_stat(
        stat.label, character.stats[stat.id],
        card.x + 26, stats_y + (stat_index - 1) * 24,
        card.w - 52, selected)
    end

    local weapon = self.app.content.weapons[character.starting_weapon]
    local info_y = stats_y + #stat_order * 24 + 10
    love.graphics.setFont(Fonts.get(15))
    love.graphics.setColor(1.0, 0.64, 0.24, 1)
    love.graphics.print("STARTING WEAPON", card.x + 26, info_y)
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.print(weapon.name, card.x + 190, info_y)
    love.graphics.setColor(0.46, 1.0, 0.72, 1)
    love.graphics.print(character.trait_name, card.x + 26, info_y + 31)
    love.graphics.setFont(Fonts.get(14))
    love.graphics.setColor(0.76, 0.74, 0.84, 1)
    love.graphics.printf(
      character.trait_text, card.x + 26, info_y + 56,
      card.w - 52, "left")
  end

  love.graphics.setFont(Fonts.get(17))
  love.graphics.setColor(settings.ui.text_color)
  love.graphics.printf(
    "← / → SELECT     •     ENTER START     •     ESC BACK",
    0, h - 34, w, "center")
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
    local TitleScreen = require("src.ui.screens.title")
    self.app.states:switch(TitleScreen(self.app))
    return true
  end
  return false
end

function CharacterSelectScreen:mousemoved(x, y)
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
