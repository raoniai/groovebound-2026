local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local Hints = require("src.ui.controller_hints")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")
local UIScale = require("src.ui.scale")
local JourneyProgress = require("src.meta.journey_progress")

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
  JourneyProgress.begin_prologue(self.app)
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

function TitleScreen:_continue_campaign()
  if self.app.slot and self.app.slot.prologue.completed then
    local WorldTourScreen = require("src.ui.screens.world_tour")
    self.app.states:switch(WorldTourScreen(self.app))
  else
    local CharacterSelectScreen = require("src.ui.screens.character_select")
    self.app.states:switch(CharacterSelectScreen(self.app))
  end
end

function TitleScreen:_settings()
  local OptionsScreen = require("src.ui.screens.options")
  self.app.states:push(OptionsScreen(self.app))
end

function TitleScreen:_catalog()
  local WorldTourScreen = require("src.ui.screens.world_tour")
  self.app.states:switch(WorldTourScreen(self.app, {
    catalog_only = not JourneyProgress.has_campaign(self.app),
  }))
end

function TitleScreen:_perks()
  local PerkDatabaseScreen = require("src.ui.screens.perk_database")
  self.app.states:switch(PerkDatabaseScreen(self.app, {
    catalog_only = not JourneyProgress.has_campaign(self.app),
  }))
end

function TitleScreen:_replay_prologue()
  JourneyProgress.begin_prologue(self.app)
  self:_start()
end

function TitleScreen:_confirm_campaign_reset(start_after_reset)
  local CampaignResetConfirm = require("src.ui.screens.campaign_reset_confirm")
  self.app.states:push(CampaignResetConfirm(self.app, {
    start_after_reset = start_after_reset == true,
    on_reset = start_after_reset and function() self:_start() end or nil,
  }))
end

function TitleScreen:_new_game()
  if JourneyProgress.has_campaign(self.app) then
    self:_confirm_campaign_reset(true)
  else
    self:_start()
  end
end

function TitleScreen:_layout()
  local w, h, scale = UIScale.dimensions()
  self.ui_scale = scale
  local bw = math.min(560, w * 0.70)
  local gap = 10
  local x = (w - bw) / 2
  local has_campaign = JourneyProgress.has_campaign(self.app)
  local y = has_campaign
    and math.max(326, math.min(h - 270, h * 0.50))
    or math.max(344, math.min(h - 220, h * 0.53))
  local half = (bw - gap) / 2
  local draw_icon = self.app.assets and function(icon, ix, iy, iw, ih, opts)
    self.app.assets:draw_menu_button_icon(
      icon.col, icon.row, ix, iy, iw, ih, opts)
  end or nil
  local function button(opts)
    opts.draw_icon = draw_icon
    return widgets.Button(opts)
  end
  local buttons = {}
  self.dividers = {}
  if has_campaign then
    buttons[#buttons + 1] = button({
      label = "CONTINUE CAMPAIGN",
      x = x, y = y, w = bw, h = 54,
      font_size = 22, icon = { col = 1, row = 1 },
      variant = "primary",
      on_press = function() self:_continue_campaign() end,
    })
    y = y + 54 + gap
    buttons[#buttons + 1] = button({
      label = "REPLAY PROLOGUE",
      x = x, y = y, w = half, h = 42, font_size = 16,
      icon = { col = 1, row = 2 },
      on_press = function() self:_replay_prologue() end,
    })
    buttons[#buttons + 1] = button({
      label = "NEW GAME",
      x = x + half + gap, y = y, w = half, h = 42, font_size = 16,
      icon = { col = 2, row = 1 },
      on_press = function() self:_new_game() end,
    })
    y = y + 42 + gap
  end
  if not has_campaign then buttons[#buttons + 1] = button({
      label = has_campaign and "NEW GAME" or "START NEW GAME",
      x = x, y = y, w = has_campaign and half or bw,
      h = has_campaign and 46 or 54,
      font_size = has_campaign and 18 or 22,
      icon = { col = 2, row = 1 },
      variant = has_campaign and "default" or "primary",
      on_press = function() self:_new_game() end,
    }) end
  buttons[#buttons + 1] = button({
      label = has_campaign and "WORLD TOUR" or "WORLD TOUR CATALOG",
      x = x, y = has_campaign and y or y + 54 + gap,
      w = has_campaign and half or half,
      h = 46,
      font_size = has_campaign and 16 or 18,
      icon = { col = 3, row = 1 },
      on_press = function() self:_catalog() end,
    })
  buttons[#buttons + 1] = button({
    label = "PERK CATALOG", x = x + half + gap,
    y = has_campaign and y or y + 54 + gap, w = half, h = 46,
    font_size = 16, icon = { col = 5, row = 1 },
    on_press = function() self:_perks() end,
  })
  y = has_campaign and y + 46 + 7 or y + 54 + gap + 46 + 7
  self.dividers[#self.dividers + 1] = { x = x + 16, y = y, w = bw - 32, h = 14 }
  y = y + 17
  buttons[#buttons + 1] = button({
      label = "SETTINGS",
      x = x, y = y, w = half, h = 40,
      font_size = 16, icon = { col = 4, row = 1 },
      on_press = function() self:_settings() end,
    })
  buttons[#buttons + 1] = button({
      label = "QUIT",
      x = x + half + gap, y = y,
      w = half, h = 40,
      font_size = 16, icon = { col = 5, row = 1 },
      on_press = function() love.event.quit() end,
    })
  if has_campaign then
    y = y + 43
    self.dividers[#self.dividers + 1] = { x = x + 90, y = y, w = bw - 180, h = 11 }
    y = y + 13
    buttons[#buttons + 1] = button({
      label = "RESET CAMPAIGN",
      x = x + (bw - 220) / 2, y = y,
      w = 220, h = 30,
      font_size = 13, icon_size = 24,
      icon = { col = 1, row = 2 }, variant = "danger",
      on_press = function() self:_confirm_campaign_reset(false) end,
    })
  end
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
  local screen_w, screen_h = love.graphics.getDimensions()
  love.graphics.setColor(settings.ui.background_color)
  love.graphics.rectangle("fill", 0, 0, screen_w, screen_h)

  local campaign = self.app.assets and self.app.assets.campaign
  if self.menu_video then
    draw_cover(self.menu_video, screen_w, screen_h)
  elseif campaign and campaign.title_background then
    draw_cover(campaign.title_background, screen_w, screen_h)
  end
  love.graphics.setColor(0.01, 0.005, 0.035, 0.34)
  love.graphics.rectangle("fill", 0, 0, screen_w, screen_h)

  local w, h = UIScale.begin()

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

  if self.app.assets and self.app.assets.draw_menu_button_icon then
    for _, divider in ipairs(self.dividers or {}) do
      self.app.assets:draw_menu_button_icon(
        2, 2, divider.x, divider.y, divider.w, divider.h,
        { color = { 0.78, 0.50, 1.0, 0.84 } })
    end
  end

  love.graphics.setColor(0.01, 0.005, 0.035, 0.78)
  love.graphics.rectangle("fill", 0, h - 48, w, 48)
  Hints.draw({
    { symbol = "dpad", label = "Navigate" },
    { symbol = "cross", label = "Select" },
    { symbol = "options", label = "Pause in game" },
  }, h - 34, w)
  UIScale.finish()
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
  return self.button_list:gamepadpressed(button)
end

function TitleScreen:mousemoved(x, y)
  x, y = UIScale.point(x, y, self.ui_scale)
  self.button_list:mousemoved(x, y)
end
function TitleScreen:mousepressed(x, y, button)
  x, y = UIScale.point(x, y, self.ui_scale)
  return self.button_list:mousepressed(x, y, button)
end

return TitleScreen
