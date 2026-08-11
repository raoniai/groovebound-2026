-- Shared sprite-backed menu presentation. Layout and labels remain screen-owned.

local Fonts = require("src.ui.fonts")
local settings = require("src.config.settings")

local MenuChrome = {}

local function pulse()
  local time = love.timer and love.timer.getTime() or 0
  return 0.90 + math.sin(time * 4.5) * 0.10
end

function MenuChrome.panel(assets, rect, opts)
  opts = opts or {}
  assets:draw_upgrade_card_frame(rect.x, rect.y, rect.w, rect.h, {
    corner = opts.corner or math.min(44, rect.h / 3),
    color = opts.color or { 1, 1, 1, opts.alpha or 0.94 },
  })
end

function MenuChrome.focus(assets, rect, opts)
  opts = opts or {}
  local inset = opts.inset or -4
  local alpha = (opts.alpha or 1) * pulse()
  assets:draw_menu_focus_frame(
    rect.x + inset, rect.y + inset,
    rect.w - inset * 2, rect.h - inset * 2,
    { corner = opts.corner or math.min(28, rect.h * 0.46),
      color = { 1, 1, 1, alpha } })
end

function MenuChrome.category_icon(assets, cell, rect, selected, color)
  assets:draw_menu_category_icon(cell, rect.x, rect.y, rect.w, {
    color = selected and { 1, 1, 1, 1 }
      or color or { 0.72, 0.70, 0.82, 0.76 },
  })
end

function MenuChrome.action(assets, button, opts)
  opts = opts or {}
  MenuChrome.panel(assets, button, {
    corner = math.min(30, button.h * 0.42),
    alpha = button.focused and 1 or 0.78,
  })
  if button.focused then MenuChrome.focus(assets, button) end

  local icon_size = math.min(button.h - 8, opts.icon_size or 52)
  if opts.icon then
    assets:draw_menu_button_icon(opts.icon.col, opts.icon.row,
      button.x + 8, button.y + (button.h - icon_size) / 2,
      icon_size, icon_size, {
        color = { 1, 1, 1, button.focused and 1 or 0.76 },
      })
  elseif opts.category_cell then
    assets:draw_menu_category_icon(opts.category_cell,
      button.x + 8, button.y + (button.h - icon_size) / 2,
      icon_size, { color = { 1, 1, 1, button.focused and 1 or 0.76 } })
  end

  local has_icon = opts.icon ~= nil or opts.category_cell ~= nil
  local text_x = button.x + (has_icon and icon_size + 18 or 14)
  local text_w = button.w - (text_x - button.x) - 14
  love.graphics.setFont(Fonts.heading(opts.font_size or 18))
  love.graphics.setColor(button.focused
    and { 1.0, 0.84, 0.30, 1 } or settings.ui.text_color)
  love.graphics.printf(opts.label or button.label, text_x,
    button.y + (opts.subtitle and 10 or (button.h - Fonts.heading(
      opts.font_size or 18):getHeight()) / 2), text_w, "left")
  if opts.subtitle then
    love.graphics.setFont(Fonts.body(opts.subtitle_size or 12))
    love.graphics.setColor(0.70, 0.75, 0.86, button.focused and 1 or 0.72)
    love.graphics.printf(opts.subtitle, text_x, button.y + button.h - 24,
      text_w, "left")
  end
end

return MenuChrome
