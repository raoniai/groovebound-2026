-- Title screen. Constructed per visit (instance state), receives its
-- dependencies via the app table — no ambient globals.

local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")

local TitleScreen = class()

function TitleScreen:init(app)
  self.app = app
end

function TitleScreen:enter()
  self.app.log.info("state", "Title screen entered")
  self:_layout()
end

function TitleScreen:_layout()
  local w, h = love.graphics.getDimensions()
  local bw, bh, gap = 310, 50, 11
  local x = (w - bw) / 2
  local y = math.max(300, h * 0.43)

  local buttons = {
    widgets.Button({
      label = "START NEW GAME",
      x = (w - 380) / 2, y = y, w = 380, h = 64,
      font_size = 25,
      on_press = function()
        local CutsceneScreen = require("src.ui.screens.cutscene")
        self.app.states:switch(CutsceneScreen(
          self.app,
          self.app.content.narrative.prologue,
          {
            on_complete = function(app)
              local CharacterSelectScreen = require(
                "src.ui.screens.character_select")
              app.states:switch(CharacterSelectScreen(app))
            end,
          }))
      end,
    }),
  }
  y = y + 64 + gap

  if settings.debug.admin.enabled then
    buttons[#buttons + 1] = widgets.Button({
      label = "Admin Controls", x = x, y = y, w = bw, h = bh,
      on_press = function()
        local AdminScreen = require("src.ui.screens.admin")
        self.app.states:push(AdminScreen(self.app))
      end,
    })
    y = y + bh + gap
  end

  buttons[#buttons + 1] = widgets.Button({
    label = "Arsenal Database", x = x, y = y, w = bw, h = bh,
    on_press = function()
      local ArsenalScreen = require("src.ui.screens.arsenal")
      self.app.states:push(ArsenalScreen(self.app))
    end,
  })
  y = y + bh + gap

  buttons[#buttons + 1] = widgets.Button({
    label = "Options", x = x, y = y, w = bw, h = bh,
    on_press = function()
      local OptionsScreen = require("src.ui.screens.options")
      self.app.states:push(OptionsScreen(self.app))
    end,
  })
  y = y + bh + gap

  buttons[#buttons + 1] = widgets.Button({
    label = "Quit", x = (w - 220) / 2, y = y, w = 220, h = 42,
    font_size = 18,
    on_press = function() love.event.quit() end,
  })
  self.button_list = widgets.ButtonList(buttons)
end

function TitleScreen:resize()
  self:_layout()
end

function TitleScreen:update(dt) -- luacheck: ignore 212
end

function TitleScreen:draw()
  local w, h = love.graphics.getDimensions()

  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, w, h)

  for index = 1, 20 do
    local x = (index * 193) % w
    local y = (index * 89) % h
    love.graphics.setColor(
      index % 2 == 0 and { 0.18, 0.84, 1.0, 0.12 }
        or { 0.94, 0.20, 0.82, 0.12 })
    love.graphics.circle("fill", x, y, 2 + index % 6)
  end

  if self.app.assets and self.app.assets.campaign then
    local logo = self.app.assets.campaign.logo
    local target_w = math.min(600, w * 0.58)
    local scale = target_w / logo:getWidth()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
      logo, w / 2, 8, 0, scale, scale, logo:getWidth() / 2, 0)
  end

  love.graphics.setColor(settings.ui.text_color)
  love.graphics.setFont(Fonts.get(20))
  love.graphics.printf(
    "RESTORE RHYTHM TO THE UNIVERSE",
    0, math.max(268, h * 0.37), w, "center")
  love.graphics.setFont(Fonts.get(14))
  love.graphics.setColor(0.62, 0.72, 0.86, 1)
  love.graphics.printf(
    "A TWO-STAGE SUPERNATURAL ARCADE ADVENTURE",
    0, math.max(294, h * 0.37 + 28), w, "center")

  self.button_list:draw()

  love.graphics.setFont(Fonts.get(14))
  love.graphics.setColor(0.58, 0.56, 0.70, 1)
  love.graphics.print("TAB  Debug overlay", 18, h - 28)
end

function TitleScreen:keypressed(key)
  if settings.debug.admin.enabled and key == settings.debug.admin.toggle_key then
    local AdminScreen = require("src.ui.screens.admin")
    self.app.states:push(AdminScreen(self.app))
    return true
  end
  return self.button_list:keypressed(key)
end

function TitleScreen:gamepadpressed(_, button)
  local Input = require("src.game.input")
  if Input.is_gamepad_action(button, "confirm") then
    self.button_list:confirm()
    return true
  end
  if button == "dpup" then
    self.button_list:move_focus(-1)
    return true
  end
  if button == "dpdown" then
    self.button_list:move_focus(1)
    return true
  end
  return false
end

function TitleScreen:mousemoved(x, y)
  self.button_list:mousemoved(x, y)
end

function TitleScreen:mousepressed(x, y, button)
  return self.button_list:mousepressed(x, y, button)
end

return TitleScreen
