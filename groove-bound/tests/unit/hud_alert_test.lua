local H = require("tests.helpers")
local HUD = require("src.ui.hud")
local NumberFormat = require("src.ui.number_format")

local T = {}

local function fresh()
  local combat = {
    xp = { notification = 1, pending_choices = 3 },
    progression = {
      evolution_notice = 0,
      upgrade_notice = 2,
      upgrade_notice_text = "KAZOO PISTOL R2",
    },
    wave_notice_time = 0,
    pickup_notice = 2,
    pickup_notice_text = "RARE DROP  •  HEALTH",
    boss_threat_snapshot = function() return { active = false } end,
  }
  return HUD({}, {}, combat), combat
end

T["right-side alerts exclude the persistent level-point CTA"] = function()
  local hud = fresh()
  local alerts = hud:alert_entries({ notice = 0 })
  H.eq(#alerts, 2)
  H.eq(alerts[1].id, "pickup")
  H.eq(alerts[1].icon, 4)
  H.eq(alerts[2].id, "upgrade")
  H.eq(alerts[2].icon, 5)
end

T["alerts can be dismissed individually or cleared together"] = function()
  local hud = fresh()
  hud.current_alerts = hud:alert_entries({ notice = 0 })
  H.is_true(hud:dismiss_top_alert())
  local visible = hud:alert_entries({ notice = 0 })
  H.eq(#visible, 1)
  hud.current_alerts = visible
  H.is_true(hud:clear_alerts())
  H.eq(#hud:alert_entries({ notice = 0 }), 0)
end

T["score numbers use thousands separators"] = function()
  H.eq(NumberFormat.integer(999), "999")
  H.eq(NumberFormat.integer(1000), "1,000")
  H.eq(NumberFormat.integer(1234567), "1,234,567")
  H.eq(NumberFormat.integer(-4200), "-4,200")
end

T["level-point CTA opens from a primary mouse click"] = function()
  local opened = 0
  local _, combat = fresh()
  local hud = HUD({}, {}, combat, {
    on_level_up = function() opened = opened + 1; return true end,
  })
  hud.ui_scale = 1
  hud.level_up_tip_rects = {
    { x = 112, y = 233, w = 32, h = 20 },
    { x = 150, y = 233, w = 32, h = 20 },
  }
  H.is_true(hud:mousepressed(128, 243, 1))
  H.eq(opened, 1)
  H.is_true(hud:mousepressed(166, 243, 1))
  H.eq(opened, 2)
  H.is_false(hud:mousepressed(128, 243, 2))
end

T["six weapon slots remain inside the sprite panel at supported widths"] = function()
  local hud = fresh()
  hud.combat.inventory = { capacity = 6 }
  for _, width in ipairs({ 800, 1280, 2048 }) do
    local layout = hud:layout_metrics(width)
    local last_x = layout.bar_x + 5 * layout.rack_step
    H.is_true(last_x + layout.slot_size
      <= layout.panel.x + layout.panel.w - 8)
  end
end

return T
