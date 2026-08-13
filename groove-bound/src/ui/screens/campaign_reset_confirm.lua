local class = require("src.core.class")
local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")
local widgets = require("src.ui.widgets.button")
local UIScale = require("src.ui.scale")
local JourneyProgress = require("src.meta.journey_progress")
local MenuChrome = require("src.ui.menu_chrome")

local CampaignResetConfirm = class()
CampaignResetConfirm.kind = "campaign_reset_confirm"
CampaignResetConfirm.opaque = false

function CampaignResetConfirm:init(app, opts)
  self.app = app
  self.opts = opts or {}
  self.warning_step = 1
end

function CampaignResetConfirm:enter()
  self:_layout()
end

function CampaignResetConfirm:_cancel()
  self.app.states:pop(false)
end

function CampaignResetConfirm:_advance_warning()
  self.warning_step = 2
  self:_layout()
end

function CampaignResetConfirm:_reset()
  JourneyProgress.reset(self.app)
  if self.opts.on_reset then
    self.opts.on_reset()
    return
  end
  local TitleScreen = require("src.ui.screens.title")
  self.app.states:switch(TitleScreen(self.app))
end

function CampaignResetConfirm:_layout()
  local w, h, scale = UIScale.dimensions()
  self.ui_scale = scale
  local panel_w = math.min(620, w - 48)
  local panel_h = self.warning_step == 1 and 306 or 332
  self.panel = {
    x = (w - panel_w) / 2,
    y = (h - panel_h) / 2,
    w = panel_w,
    h = panel_h,
  }
  local button_w = math.min(230, (panel_w - 60) / 2)
  local button_y = self.panel.y + panel_h - 66
  local left_x = self.panel.x + panel_w / 2 - button_w - 8
  local function button(opts)
    opts.renderer = function(value)
      MenuChrome.action(self.app.assets, value, {
        menu_cell = opts.menu_cell,
        label = opts.label,
        font_size = opts.font_size,
        icon_size = 38,
      })
    end
    return widgets.Button(opts)
  end
  self.buttons = widgets.ButtonList({
    button({
      label = self.warning_step == 1 and "GO BACK" or "KEEP CAMPAIGN",
      x = left_x, y = button_y, w = button_w, h = 48,
      font_size = 16, menu_cell = 8,
      on_press = function() self:_cancel() end,
    }),
    button({
      label = self.warning_step == 1 and "SHOW FINAL WARNING" or "RESET FOREVER",
      x = left_x + button_w + 16, y = button_y,
      w = button_w, h = 48, font_size = 14,
      menu_cell = 13, variant = "danger",
      on_press = function()
        if self.warning_step == 1 then
          self:_advance_warning()
        else
          self:_reset()
        end
      end,
    }),
  })
end

function CampaignResetConfirm:resize()
  self:_layout()
end

function CampaignResetConfirm:draw()
  local screen_w, screen_h = love.graphics.getDimensions()
  love.graphics.setColor(0.005, 0.002, 0.016, 0.82)
  love.graphics.rectangle("fill", 0, 0, screen_w, screen_h)
  UIScale.begin()
  local panel = self.panel
  local second = self.warning_step == 2
  love.graphics.setColor(second and { 0.12, 0.008, 0.022, 0.99 }
    or { 0.025, 0.012, 0.060, 0.99 })
  love.graphics.rectangle("fill", panel.x, panel.y, panel.w, panel.h, 14, 14)
  if self.app.assets and self.app.assets.draw_hud_frame then
    self.app.assets:draw_hud_frame(panel.x, panel.y, panel.w, panel.h, {
      color = second and { 1.0, 0.16, 0.24, 1 }
        or { 1.0, 0.58, 0.18, 0.94 },
    })
  end
  if self.app.assets and self.app.assets.draw_menu_stat_icon then
    self.app.assets:draw_menu_stat_icon(
      13, panel.x + 32, panel.y + 38, 94,
      { color = { 1, 1, 1, 0.94 } })
  end
  love.graphics.setFont(Fonts.get(second and 30 or 27))
  love.graphics.setColor(second and { 1, 0.20, 0.28, 1 }
    or { 1, 0.74, 0.20, 1 })
  love.graphics.printf(second and "FINAL WARNING" or "RESET CAMPAIGN?",
    panel.x + 146, panel.y + 44, panel.w - 176, "left")
  love.graphics.setFont(Fonts.get(15))
  love.graphics.setColor(settings.ui.text_color)
  local action = self.opts.start_after_reset
    and "Starting a new game will replace the current campaign."
    or "This removes the current campaign from this save slot."
  local detail = second
    and ("This cannot be undone. World Tour records, unlocked worlds, "
      .. "character choice and Prologue progress will be permanently erased.")
    or action .. " You will get one more warning before anything is erased."
  love.graphics.printf(detail, panel.x + 50, panel.y + 158,
    panel.w - 100, "center")
  self.buttons:draw()
  UIScale.finish()
end

function CampaignResetConfirm:keypressed(key)
  if key == "escape" then self:_cancel() return true end
  return self.buttons:keypressed(key)
end

function CampaignResetConfirm:gamepadpressed(_, button)
  if button == "b" then self:_cancel() return true end
  return self.buttons:gamepadpressed(button)
end

function CampaignResetConfirm:mousemoved(x, y)
  x, y = UIScale.point(x, y, self.ui_scale)
  self.buttons:mousemoved(x, y)
end

function CampaignResetConfirm:mousepressed(x, y, button)
  x, y = UIScale.point(x, y, self.ui_scale)
  return self.buttons:mousepressed(x, y, button)
end

return CampaignResetConfirm
