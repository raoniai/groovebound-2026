local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local Icons = require("src.ui.icons")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")
local UIScale = require("src.ui.scale")

local ResultsScreen = class()
ResultsScreen.kind = "results"

ResultsScreen.opaque = true

local function draw_chip(x, y, w, h)
  love.graphics.setColor(0.025, 0.018, 0.06, 0.58)
  love.graphics.rectangle("fill", x, y, w, h, 7, 7)
  love.graphics.setColor(0.38, 0.32, 0.56, 0.72)
  love.graphics.rectangle("line", x, y, w, h, 7, 7)
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
  local y = h * 0.79
  local next_label = self.result.outcome == "victory"
    and (self.result.mode == "world_tour" and "WORLD TOUR CATALOG"
      or "ENTER WORLD TOUR") or "CONTINUE CAMPAIGN"
  local draw_icon = self.app.assets and function(icon, ix, iy, iw, ih, opts)
    self.app.assets:draw_world_interface(icon.col, icon.row, ix, iy, iw, ih, opts)
  end or nil
  self.buttons = widgets.ButtonList({
    widgets.Button({
      label = next_label, x = x, y = y, w = bw, h = bh,
      font_size = 21,
      icon = { col = 3, row = 2 }, draw_icon = draw_icon,
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
    widgets.Button({
      label = "Return to Title", x = x, y = y + bh + gap, w = bw, h = bh,
      font_size = 20,
      icon = { col = 1, row = 1 }, draw_icon = draw_icon,
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
    { icon = "stage", label = "STAGES", value = (self.result.stages_cleared or 0)
      .. "/" .. (self.result.stage_count or 2) },
    { icon = "clock", label = "TIME", value = string.format("%02d:%02d",
      math.floor(self.result.time / 60), math.floor(self.result.time % 60)) },
    { icon = "score", label = "SCORE", value = tostring(stats.score) },
    { icon = "combo", label = "MAX COMBO", value = "×" .. stats.max_combo },
    { icon = "damage", label = "DAMAGE", value = tostring(math.floor(stats.damage)) },
    { icon = "chest", label = "COINS", value = tostring(
      stats.coins + self.result.progression.coins) },
  }
  local panel_w = math.min(1040, w - 80)
  local gap = 10
  local chip_w = (panel_w - gap * 5) / 6
  local start_x = (w - panel_w) / 2
  local chip_y = h * 0.29
  for index, item in ipairs(summary) do
    local x = start_x + (index - 1) * (chip_w + gap)
    draw_chip(x, chip_y, chip_w, 76)
    local compact_chip = chip_w < 130
    local icon_x = x + (compact_chip and 18 or 28)
    local text_x = x + (compact_chip and 34 or 52)
    Icons.draw(item.icon, icon_x, chip_y + 38, compact_chip and 22 or 28,
      { 0.34, 0.92, 1.0, 0.92 })
    love.graphics.setColor(0.68, 0.72, 0.84, 1)
    love.graphics.setFont(Fonts.get(12))
    love.graphics.printf(item.label, text_x, chip_y + 15,
      x + chip_w - text_x - 6, "left")
    love.graphics.setColor(settings.ui.text_color)
    love.graphics.setFont(Fonts.get(19))
    love.graphics.printf(item.value, text_x, chip_y + 35,
      x + chip_w - text_x - 6, "left")
  end

  love.graphics.setColor(0.72, 0.78, 0.90, 1)
  love.graphics.setFont(Fonts.get(15))
  love.graphics.printf(
    string.format("LEVEL %d  •  KILLS %d  •  XP %d  •  SHOTS %d  •  BOSSES %d",
      self.result.level, stats.kills, math.floor(stats.xp),
      stats.shots, stats.bosses),
    0, chip_y + 88, w, "center")

  local weapons = self.result.progression.weapons
  local rack_w = math.min(620, w - 100)
  local slot_size = math.min(78, (rack_w - 10 * math.max(0, #weapons - 1))
    / math.max(1, #weapons))
  local rack_total = #weapons * slot_size + math.max(0, #weapons - 1) * 10
  local rack_x = (w - rack_total) / 2
  local rack_y = h * 0.49
  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.setFont(Fonts.get(14))
  love.graphics.printf("FINAL SETLIST", 0, rack_y - 27, w, "center")
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
    love.graphics.setColor(settings.ui.accent_color)
    love.graphics.setFont(Fonts.get(13))
    love.graphics.printf("R" .. weapon.level, x, rack_y + slot_size - 18,
      slot_size - 5, "right")
  end

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
      w * 0.1, h * 0.64, w * 0.8, "center")
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
