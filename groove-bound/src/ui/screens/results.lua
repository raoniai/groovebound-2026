local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")
local UIScale = require("src.ui.scale")
local MenuChrome = require("src.ui.menu_chrome")
local NumberFormat = require("src.ui.number_format")
local RankBadge = require("src.ui.rank_badge")

local ResultsScreen = class()
ResultsScreen.kind = "results"

ResultsScreen.opaque = true

local function draw_chip(assets, x, y, w, h)
  MenuChrome.cta(assets, { x = x, y = y, w = w, h = h }, { alpha = 0.78 })
end

function ResultsScreen:init(app, result)
  self.app = app
  self.result = result
end

function ResultsScreen:enter()
  self:_layout()
  self.app.log.info("state", "Run result: " .. self.result.outcome)
end

function ResultsScreen:_layout()
  local w, h, scale = UIScale.dimensions()
  self.ui_scale = scale
  local bw, bh, gap = 280, 54, 14
  local x = (w - bw) / 2
  local y = h * 0.70
  local next_label = self.result.outcome == "victory"
    and (self.result.mode == "world_tour" and "WORLD TOUR CATALOG"
      or "ENTER WORLD TOUR") or "CONTINUE CAMPAIGN"
  local function button(opts)
    opts.renderer = function(value)
      MenuChrome.action(self.app.assets, value, {
        menu_cell = opts.menu_cell,
        label = opts.label,
        font_size = opts.font_size,
      })
    end
    return widgets.Button(opts)
  end
  self.buttons = widgets.ButtonList({
    button({
      label = next_label, x = x, y = y, w = bw, h = bh,
      font_size = 21,
      menu_cell = self.result.outcome == "victory" and 3 or 1,
      variant = "primary",
      on_press = function()
        if self.result.outcome == "victory" then
          local WorldTourScreen = require("src.ui.screens.world_tour")
          self.app.states:switch(WorldTourScreen(self.app))
        else
          local CharacterSelectScreen = require("src.ui.screens.character_select")
          self.app.states:switch(CharacterSelectScreen(self.app))
        end
      end,
    }),
    button({
      label = "RETURN TO TITLE", x = x, y = y + bh + gap, w = bw, h = bh,
      font_size = 20,
      menu_cell = 8,
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
  local screen_w, screen_h = love.graphics.getDimensions()
  local victory = self.result.outcome == "victory"
  local background = victory
    and self.app.assets.campaign.title_background or self.app.assets.gameover
  if background then
    local image_w, image_h = background:getDimensions()
    local scale = math.max(screen_w / image_w, screen_h / image_h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(background, screen_w / 2, screen_h / 2, 0, scale, scale,
      image_w / 2, image_h / 2)
  end
  love.graphics.setColor(0.012, 0.008, 0.035, victory and 0.72 or 0.56)
  love.graphics.rectangle("fill", 0, 0, screen_w, screen_h)
  local w, h = UIScale.begin()

  love.graphics.setFont(Fonts.get(38))
  love.graphics.setColor(victory and { 0.96, 0.78, 0.22, 1 } or { 0.95, 0.3, 0.38, 1 })
  love.graphics.printf(victory and "THE GROOVE SURVIVES" or "THE GROOVE WAS LOST",
    0, h * 0.10, w, "center")

  if self.result.character and self.app.assets.draw_character_logo then
    self.app.assets:draw_character_logo(
      self.result.character.id, w / 2 - 145, h * 0.16,
      290, 64, { color = { 1, 1, 1, 0.94 } })
  end

  local stats = self.result.stats
  local summary = {
    { icon = 9, label = "STAGES", value = (self.result.stages_cleared or 0)
      .. "/" .. (self.result.stage_count or 2) },
    { icon = 10, label = "TIME", value = string.format("%02d:%02d",
      math.floor(self.result.time / 60), math.floor(self.result.time % 60)) },
    { icon = 11, label = "SCORE", value = NumberFormat.integer(stats.score) },
    { icon = 12, label = "MAX COMBO", value = "×" .. stats.max_combo },
    { icon = 13, label = "DAMAGE", value = NumberFormat.integer(stats.damage) },
    { icon = 14, label = "COINS", value = NumberFormat.integer(
      stats.coins + self.result.progression.coins) },
  }
  local panel_w = math.min(1040, w - 80)
  local gap = 10
  local chip_w = (panel_w - gap * 5) / 6
  local start_x = (w - panel_w) / 2
  local chip_y = h * 0.29
  for index, item in ipairs(summary) do
    local x = start_x + (index - 1) * (chip_w + gap)
    draw_chip(self.app.assets, x, chip_y, chip_w, 76)
    local compact_chip = chip_w < 130
    local icon_x = x + (compact_chip and 18 or 28)
    local text_x = x + (compact_chip and 34 or 52)
    local icon_size = compact_chip and 30 or 38
    self.app.assets:draw_menu_stat_icon(item.icon,
      icon_x - icon_size / 2, chip_y + (76 - icon_size) / 2,
      icon_size, { color = { 1, 1, 1, 0.94 } })
    love.graphics.setColor(0.68, 0.72, 0.84, 1)
    love.graphics.setFont(Fonts.get(12))
    love.graphics.printf(item.label, text_x, chip_y + 15,
      x + chip_w - text_x - 6, "left")
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.get(19))
    love.graphics.printf(item.value, text_x, chip_y + 35,
      x + chip_w - text_x - 6, "left")
  end

  local progress = {
    { label = "LEVEL", value = NumberFormat.integer(self.result.level), rank = true },
    { label = "KILLS", value = NumberFormat.integer(stats.kills), icon = 15 },
    { label = "XP GAIN", value = NumberFormat.integer(stats.xp), icon = 16 },
  }
  local progress_w = math.min(620, w - 120)
  local progress_gap = 12
  local progress_chip_w = (progress_w - progress_gap * 2) / 3
  local progress_x = (w - progress_w) / 2
  local progress_y = chip_y + 84
  for index, item in ipairs(progress) do
    local x = progress_x + (index - 1) * (progress_chip_w + progress_gap)
    draw_chip(self.app.assets, x, progress_y, progress_chip_w, 58)
    if item.rank then
      RankBadge.draw(self.app.assets, x + 14, progress_y + 8, 42,
        self.result.level)
    else
      self.app.assets:draw_menu_stat_icon(item.icon,
        x + 14, progress_y + 10, 38, { color = { 1, 1, 1, 0.94 } })
    end
    love.graphics.setColor(0.68, 0.72, 0.84, 1)
    love.graphics.setFont(Fonts.get(11))
    love.graphics.printf(item.label, x + 62, progress_y + 9,
      progress_chip_w - 72, "left")
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.get(21))
    love.graphics.printf(item.value, x + 62, progress_y + 26,
      progress_chip_w - 72, "left")
  end

  local weapons = self.result.progression.weapons
  local rack_w = math.min(620, w - 100)
  local slot_size = math.min(78, (rack_w - 10 * math.max(0, #weapons - 1))
    / math.max(1, #weapons))
  local rack_total = #weapons * slot_size + math.max(0, #weapons - 1) * 10
  local rack_x = (w - rack_total) / 2
  local rack_y = progress_y + 72
  for index, weapon in ipairs(weapons) do
    local definition = self.app.content.weapons[weapon.id]
    local x = rack_x + (index - 1) * (slot_size + 10)
    love.graphics.setColor(0.025, 0.018, 0.06, 0.52)
    love.graphics.rectangle("fill", x + 2, rack_y + 2,
      slot_size - 4, slot_size - 4, 6, 6)
    self.app.assets:draw_hud_slot(x, rack_y,
      slot_size, slot_size, { color = { 1, 1, 1, 0.86 } })
    self.app.assets:draw_weapon_icon(
      definition.icon, x + slot_size / 2, rack_y + slot_size / 2,
      slot_size * 0.75)
    RankBadge.draw(self.app.assets, x + slot_size - 28, rack_y - 7, 34,
      weapon.level, { maxed = weapon.level >= definition.max_level })
  end

  self.buttons:draw()
  UIScale.finish()
end

function ResultsScreen:keypressed(key)
  return self.buttons:keypressed(key)
end

function ResultsScreen:gamepadpressed(_, button)
  return self.buttons:gamepadpressed(button)
end

function ResultsScreen:mousemoved(x, y)
  x, y = UIScale.point(x, y, self.ui_scale)
  self.buttons:mousemoved(x, y)
end

function ResultsScreen:mousepressed(x, y, button)
  x, y = UIScale.point(x, y, self.ui_scale)
  return self.buttons:mousepressed(x, y, button)
end

return ResultsScreen
