local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local Hints = require("src.ui.controller_hints")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")

local TitleScreen = class()
TitleScreen.kind = "title"

local MENU_VIDEO_PATH = "assets/video/runtime/cutscene-0-main_menu.ogv"

function TitleScreen:init(app)
  self.app = app
  self.menu_video = nil
  self.menu_video_elapsed = 0
end

function TitleScreen:enter()
  self.app.log.info("state", "Title screen entered")
  self:_layout()
  self:_load_menu_video()
end

function TitleScreen:pause()
  if self.menu_video then self.menu_video:pause() end
end

function TitleScreen:resume()
  self:_layout()
  if self.menu_video then self.menu_video:play() end
end

function TitleScreen:exit()
  if self.menu_video then self.menu_video:pause() end
end

function TitleScreen:_load_menu_video()
  if self.menu_video or not love.graphics.newVideo then return false end
  if not love.filesystem.getInfo(MENU_VIDEO_PATH, "file") then return false end

  -- The exact title cue continues through MusicDirector. The generated video
  -- is the visual layer only, which keeps mute and volume settings consistent.
  local ok, video = pcall(love.graphics.newVideo, MENU_VIDEO_PATH, { audio = false })
  if not ok or not video then
    self.app.log.info("state", "Static title background fallback")
    return false
  end

  self.menu_video = video
  self.menu_video_elapsed = 0
  self.menu_video:play()
  return true
end

function TitleScreen:_start()
  local CutsceneScreen = require("src.ui.screens.cutscene")
  self.app.states:switch(CutsceneScreen(
    self.app,
    self.app.content.narrative.prologue,
    {
      on_complete = function(app)
        local CharacterSelectScreen = require("src.ui.screens.character_select")
        app.states:switch(CharacterSelectScreen(app))
      end,
    }))
end

function TitleScreen:_settings()
  local OptionsScreen = require("src.ui.screens.options")
  self.app.states:push(OptionsScreen(self.app))
end

function TitleScreen:_layout()
  local w, h = love.graphics.getDimensions()
  local bw = math.min(360, w * 0.40)
  local bh, gap = 50, 10
  local x = (w - bw) / 2
  local y = math.max(350, h * 0.53)
  local buttons = {
    widgets.Button({
      label = "START NEW GAME",
      x = x, y = y, w = bw, h = 62,
      font_size = 24,
      on_press = function() self:_start() end,
    }),
    widgets.Button({
      label = "SETTINGS",
      x = x, y = y + 62 + gap, w = bw, h = bh,
      font_size = 19,
      on_press = function() self:_settings() end,
    }),
    widgets.Button({
      label = "QUIT",
      x = x + bw * 0.18, y = y + 62 + gap + bh + gap,
      w = bw * 0.64, h = 40,
      font_size = 16,
      on_press = function() love.event.quit() end,
    }),
  }
  self.button_list = widgets.ButtonList(buttons)
end

function TitleScreen:resize() self:_layout() end
function TitleScreen:update(dt)
  if not self.menu_video then return end
  self.menu_video_elapsed = self.menu_video_elapsed + dt
  if self.menu_video_elapsed > 0.35 and not self.menu_video:isPlaying() then
    self.menu_video:rewind()
    self.menu_video:play()
    self.menu_video_elapsed = 0
  end
end

local function draw_cover(image, w, h)
  local iw, ih = image:getDimensions()
  local scale = math.max(w / iw, h / ih)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(image, w / 2, h / 2, 0, scale, scale, iw / 2, ih / 2)
end

function TitleScreen:draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, w, h)

  local campaign = self.app.assets and self.app.assets.campaign
  if self.menu_video then
    draw_cover(self.menu_video, w, h)
  elseif campaign and campaign.title_background then
    draw_cover(campaign.title_background, w, h)
  end
  love.graphics.setColor(0.01, 0.005, 0.035, 0.34)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.setColor(0.01, 0.005, 0.035, 0.28)
  love.graphics.rectangle("fill", w * 0.29, 0, w * 0.42, h)

  if campaign and campaign.logo then
    local logo = campaign.logo
    local target_w = math.min(700, w * 0.55)
    local target_h = math.min(330, h * 0.43)
    local scale = math.min(target_w / logo:getWidth(), target_h / logo:getHeight())
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(logo, w / 2, math.max(8, h * 0.015), 0,
      scale, scale, logo:getWidth() / 2, 0)
  end

  love.graphics.setFont(Fonts.get(16))
  love.graphics.setColor(0.88, 0.92, 1.0, 0.94)
  love.graphics.printf("RESTORE RHYTHM TO THE UNIVERSE",
    0, math.max(320, h * 0.465), w, "center")

  self.button_list:draw()

  love.graphics.setColor(0.01, 0.005, 0.035, 0.78)
  love.graphics.rectangle("fill", 0, h - 48, w, 48)
  Hints.draw({
    { symbol = "dpad", label = "Navigate" },
    { symbol = "cross", label = "Select" },
    { symbol = "options", label = "Pause in game" },
  }, h - 34, w)
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
  if button == "a" then self.button_list:confirm() return true end
  if button == "dpup" then self.button_list:move_focus(-1) return true end
  if button == "dpdown" then self.button_list:move_focus(1) return true end
  return false
end

function TitleScreen:mousemoved(x, y) self.button_list:mousemoved(x, y) end
function TitleScreen:mousepressed(x, y, button)
  return self.button_list:mousepressed(x, y, button)
end

return TitleScreen
