local H = require("tests.helpers")
local HUD = require("src.ui.hud")

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

T["right-side alerts expose relevant sprite categories"] = function()
  local hud = fresh()
  local alerts = hud:alert_entries({ notice = 0 })
  H.eq(#alerts, 3)
  H.eq(alerts[1].id, "level")
  H.eq(alerts[1].icon, 1)
  H.eq(alerts[2].id, "pickup")
  H.eq(alerts[2].icon, 4)
  H.eq(alerts[3].id, "upgrade")
  H.eq(alerts[3].icon, 5)
end

T["alerts can be dismissed individually or cleared together"] = function()
  local hud, combat = fresh()
  hud.current_alerts = hud:alert_entries({ notice = 0 })
  H.is_true(hud:dismiss_top_alert())
  local visible = hud:alert_entries({ notice = 0 })
  H.eq(#visible, 2)
  hud.current_alerts = visible
  H.is_true(hud:clear_alerts())
  H.eq(#hud:alert_entries({ notice = 0 }), 0)
  combat.xp.notification = 0
  hud:alert_entries({ notice = 0 })
  combat.xp.notification = 1
  combat.xp.pending_choices = 4
  H.eq(hud:alert_entries({ notice = 0 })[1].id, "level")
end

return T
