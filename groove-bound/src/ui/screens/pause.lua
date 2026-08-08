-- Pause modal. Pushed over the run screen; the state machine stops updating
-- the run automatically (only the top state updates), so there is no paused
-- boolean to keep in sync. opaque = false lets the frozen run render below.

local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local Input = require("src.game.input")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")
local Hints = require("src.ui.controller_hints")

local PauseScreen = class()
PauseScreen.kind = "pause"

PauseScreen.opaque = false

function PauseScreen:init(app)
  self.app = app
end

function PauseScreen:enter()
  self.app.log.info("state", "Paused")
  self:_layout()
end

function PauseScreen:_layout()
  local w, h = love.graphics.getDimensions()
  local bw, bh, gap = 260, 44, 10
  local x = (w - bw) / 2
  local y = math.max(260, h * 0.43)

  local buttons = {
    widgets.Button({
      label = "Resume", x = x, y = y, w = bw, h = bh,
      on_press = function() self.app.states:pop() end,
    }),
  }

  buttons[#buttons + 1] = widgets.Button({
    label = "Copy Run Seed", x = x, y = y + (#buttons * (bh + gap)), w = bw, h = bh,
    on_press = function()
      if self.app.active_run then self.app.active_run:copy_seed() end
    end,
  })

  buttons[#buttons + 1] = widgets.Button({
    label = "Settings", x = x, y = y + (#buttons * (bh + gap)), w = bw, h = bh,
    on_press = function()
      local OptionsScreen = require("src.ui.screens.options")
      self.app.states:push(OptionsScreen(self.app))
    end,
  })

  buttons[#buttons + 1] = widgets.Button({
      label = "Quit to Title", x = x, y = y + (#buttons * (bh + gap)), w = bw, h = bh,
      on_press = function()
        local TitleScreen = require("src.ui.screens.title")
        self.app.states:switch(TitleScreen(self.app))
      end,
    })

  self.button_list = widgets.ButtonList(buttons)
end

local function requirement_color(ready, owned)
  if ready then return { 0.40, 1.0, 0.72, 1 } end
  if owned then return { 1.0, 0.72, 0.24, 0.68 } end
  return { 0.62, 0.60, 0.72, 0.25 }
end

function PauseScreen:_draw_evolution_guide(w)
  if self.app.tuning
    and not self.app.tuning:get("ui.show_evolution_requirements")
  then
    return
  end
  local run = self.app.active_run
  local progression = run and run.combat and run.combat.progression
  if not progression then return end
  local progress = progression:evolution_progress()
  local count = math.min(3, #progress)
  local x, y, gap = 28, 82, 12
  local total_w = w - 56
  local card_w = count > 0 and (total_w - gap * (count - 1)) / count or total_w
  local card_h = 132

  love.graphics.setFont(Fonts.get(15))
  love.graphics.setColor(0.76, 0.74, 0.86, 1)
  love.graphics.print("EVOLUTION CHECK  •  OPEN A MUSICAL CHEST TO EVOLVE", x, 58)
  if count == 0 then
    love.graphics.setColor(0.03, 0.018, 0.08, 0.92)
    love.graphics.rectangle("fill", x, y, total_w, 86, 10, 10)
    love.graphics.setColor(0.58, 0.56, 0.70, 0.72)
    love.graphics.printf(
      "Collect an evolvable weapon to reveal its recipe.",
      x + 18, y + 31, total_w - 36, "center")
    return
  end

  for index = 1, count do
    local item = progress[index]
    local card_x = x + (index - 1) * (card_w + gap)
    love.graphics.setColor(0.03, 0.018, 0.08, 0.94)
    love.graphics.rectangle("fill", card_x, y, card_w, card_h, 10, 10)
    love.graphics.setColor(item.eligible
      and { 0.40, 1.0, 0.72, 0.92 }
      or { 0.28, 0.72, 1.0, 0.38 })
    love.graphics.setLineWidth(item.eligible and 3 or 1)
    love.graphics.rectangle("line", card_x, y, card_w, card_h, 10, 10)

    local center_y = y + 49
    local icon_size = math.min(42, card_w * 0.14)
    local left_x = card_x + card_w * 0.18
    local support_x = card_x + card_w * 0.50
    local result_x = card_x + card_w * 0.82
    self.app.assets:draw_weapon_icon(item.base.icon, left_x, center_y, icon_size, {
      color = requirement_color(item.weapon_ready, true),
    })
    self.app.assets:draw_support_icon(item.support.icon, support_x, center_y, icon_size, {
      color = requirement_color(item.support_ready, item.support_level > 0),
    })
    self.app.assets:draw_weapon_icon(item.result.icon, result_x, center_y, icon_size, {
      color = item.eligible and { 1, 0.78, 0.26, 1 }
        or { 0.62, 0.58, 0.72, 0.25 },
    })
    love.graphics.setFont(Fonts.get(22))
    love.graphics.setColor(0.88, 0.86, 0.96, 0.92)
    love.graphics.printf("+", card_x + card_w * 0.31, center_y - 12,
      card_w * 0.08, "center")
    love.graphics.printf("=", card_x + card_w * 0.64, center_y - 12,
      card_w * 0.08, "center")

    love.graphics.setFont(Fonts.get(11))
    love.graphics.setColor(requirement_color(item.weapon_ready, true))
    love.graphics.printf(
      "R" .. item.weapon_level .. "/" .. item.required_weapon_level,
      card_x + 8, y + 77, card_w * 0.32, "center")
    love.graphics.setColor(requirement_color(
      item.support_ready, item.support_level > 0))
    love.graphics.printf(
      item.support_level > 0 and ("R" .. item.support_level .. "/"
        .. item.required_support_level) or "MISSING",
      card_x + card_w * 0.34, y + 77, card_w * 0.32, "center")
    love.graphics.setColor(item.eligible
      and { 1.0, 0.76, 0.24, 1 }
      or { 0.64, 0.60, 0.74, 0.34 })
    love.graphics.printf(item.result.name,
      card_x + card_w * 0.66, y + 77, card_w * 0.32, "center")

    love.graphics.setFont(Fonts.get(12))
    love.graphics.setColor(item.eligible
      and { 0.40, 1.0, 0.72, 1 }
      or { 0.66, 0.64, 0.76, 0.52 })
    love.graphics.printf(item.eligible and "READY FOR CHEST" or "BUILD RECIPE",
      card_x + 12, y + 107, card_w - 24, "center")
  end
  love.graphics.setLineWidth(1)
end

function PauseScreen:resize()
  self:_layout()
end

function PauseScreen:draw()
  local w, h = love.graphics.getDimensions()

  love.graphics.setColor(0, 0, 0, 0.65)
  love.graphics.rectangle("fill", 0, 0, w, h)

  love.graphics.setColor(settings.ui.accent_color)
  love.graphics.setFont(Fonts.get(40))
  love.graphics.printf("PAUSED", 0, 18, w, "center")

  self:_draw_evolution_guide(w)

  self.button_list:draw()
  love.graphics.setColor(0.01, 0.005, 0.035, 0.86)
  love.graphics.rectangle("fill", 0, h - 42, w, 42)
  Hints.draw({
    { symbol = "dpad", label = "Navigate" },
    { symbol = "cross", label = "Select" },
    { symbol = "circle", label = "Resume" },
    { symbol = "options", label = "Resume" },
  }, h - 31, w, { font_size = 13, glyph_size = 18, gap = 17 })
end

function PauseScreen:keypressed(key)
  if settings.debug.admin.enabled and key == settings.debug.admin.toggle_key then
    local AdminScreen = require("src.ui.screens.admin")
    self.app.states:push(AdminScreen(self.app))
    return true
  end
  if Input.is_action(key, "pause") or Input.is_action(key, "cancel") then
    self.app.states:pop()
    return true
  end
  return self.button_list:keypressed(key)
end

function PauseScreen:gamepadpressed(_, button)
  if Input.is_gamepad_action(button, "pause") or Input.is_gamepad_action(button, "cancel") then
    self.app.states:pop()
    return true
  end
  if Input.is_gamepad_action(button, "confirm") then
    self.button_list:confirm()
    return true
  end
  return false
end

function PauseScreen:mousemoved(x, y)
  self.button_list:mousemoved(x, y)
end

function PauseScreen:mousepressed(x, y, button)
  return self.button_list:mousepressed(x, y, button)
end

return PauseScreen
