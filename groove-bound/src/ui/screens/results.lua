local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")

local ResultsScreen = class()
ResultsScreen.kind = "results"

ResultsScreen.opaque = false

function ResultsScreen:init(app, result)
  self.app = app
  self.result = result
end

function ResultsScreen:enter()
  self:_layout()
  self.app.log.info("state", "Run result: " .. self.result.outcome)
end

function ResultsScreen:_layout()
  local w, h = love.graphics.getDimensions()
  local bw, bh, gap = 280, 54, 14
  local x = (w - bw) / 2
  local y = h * 0.72
  self.buttons = widgets.ButtonList({
    widgets.Button({
      label = "Choose Character", x = x, y = y, w = bw, h = bh,
      font_size = 21,
      on_press = function()
        local CharacterSelectScreen = require("src.ui.screens.character_select")
        self.app.states:switch(CharacterSelectScreen(self.app))
      end,
    }),
    widgets.Button({
      label = "Return to Title", x = x, y = y + bh + gap, w = bw, h = bh,
      font_size = 20,
      on_press = function()
        local TitleScreen = require("src.ui.screens.title")
        self.app.states:switch(TitleScreen(self.app))
      end,
    }),
  })
end

function ResultsScreen:resize()
  self:_layout()
end

function ResultsScreen:draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(0.025, 0.018, 0.05, 0.88)
  love.graphics.rectangle("fill", 0, 0, w, h)

  local victory = self.result.outcome == "victory"
  if victory and self.app.assets.icon then
    local icon = self.app.assets.icon
    local scale = 120 / icon:getWidth()
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.draw(icon, w / 2, h * 0.22, 0, scale, scale,
      icon:getWidth() / 2, icon:getHeight() / 2)
  elseif self.app.assets.gameover then
    local image = self.app.assets.gameover
    local scale = math.min(0.72, w * 0.5 / image:getWidth())
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.draw(image, w / 2, h * 0.22, 0, scale, scale,
      image:getWidth() / 2, image:getHeight() / 2)
  end

  love.graphics.setFont(Fonts.get(38))
  love.graphics.setColor(victory and { 0.96, 0.78, 0.22, 1 } or { 0.95, 0.3, 0.38, 1 })
  love.graphics.printf(victory and "THE GROOVE SURVIVES" or "THE GROOVE WAS LOST",
    0, h * 0.36, w, "center")

  love.graphics.setFont(Fonts.get(19))
  love.graphics.setColor(settings.ui.text_color)
  local stats = self.result.stats
  local summary = string.format(
    "%s  •  %d/2 stages  •  Time %02d:%02d  •  Kills %d  •  XP %d  •  Level %d  •  Coins %d",
    self.result.character and self.result.character.name or "Joe",
    self.result.stages_cleared or 0,
    math.floor(self.result.time / 60),
    math.floor(self.result.time % 60),
    stats.kills,
    math.floor(stats.xp),
    self.result.level,
    stats.coins + self.result.progression.coins)
  love.graphics.printf(summary, 0, h * 0.48, w, "center")

  love.graphics.setColor(0.72, 0.68, 0.82, 1)
  love.graphics.printf(
    string.format("Score %d   Max combo ×%d   Shots %d   Damage %.0f   Minibosses %d   Bosses %d",
      stats.score, stats.max_combo, stats.shots, stats.damage,
      stats.minibosses, stats.bosses),
    0, h * 0.53, w, "center")

  local weapon_names = {}
  for _, weapon in ipairs(self.result.progression.weapons) do
    local definition = self.app.content.weapons[weapon.id]
    weapon_names[#weapon_names + 1] = definition.name .. " R" .. weapon.level
  end
  love.graphics.setColor(0.76, 0.72, 0.86, 1)
  love.graphics.printf("Weapons: " .. table.concat(weapon_names, "  •  "),
    w * 0.1, h * 0.58, w * 0.8, "center")

  local evolution_names = {}
  for _, evolution in ipairs(self.result.progression.evolutions) do
    local result = self.app.content.weapons[evolution.result_weapon]
    if result then
      evolution_names[#evolution_names + 1] =
        string.upper(evolution.branch) .. " " .. result.name
    end
  end
  if #evolution_names > 0 then
    love.graphics.setColor(settings.ui.accent_color)
    love.graphics.printf("Evolved: " .. table.concat(evolution_names, ", "),
      w * 0.1, h * 0.62, w * 0.8, "center")
  end

  self.buttons:draw()
end

function ResultsScreen:keypressed(key)
  return self.buttons:keypressed(key)
end

function ResultsScreen:gamepadpressed(_, button)
  if button == "a" then
    self.buttons:confirm()
    return true
  elseif button == "dpup" then
    self.buttons:move_focus(-1)
    return true
  elseif button == "dpdown" then
    self.buttons:move_focus(1)
    return true
  end
  return false
end

function ResultsScreen:mousemoved(x, y)
  self.buttons:mousemoved(x, y)
end

function ResultsScreen:mousepressed(x, y, button)
  return self.buttons:mousepressed(x, y, button)
end

return ResultsScreen
