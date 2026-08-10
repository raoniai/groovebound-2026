local H = require("tests.helpers")
local Defaults = require("src.meta.defaults")
local CampaignResetConfirm = require("src.ui.screens.campaign_reset_confirm")

local T = {}

local function with_dimensions(fn)
  local previous = _G.love
  _G.love = {
    graphics = {
      getDimensions = function() return 800, 600 end,
      getWidth = function() return 800 end,
      getHeight = function() return 600 end,
    },
  }
  local ok, error_message = xpcall(fn, debug.traceback)
  _G.love = previous
  if not ok then error(error_message, 0) end
end

T["campaign reset requires two distinct confirmations"] = function()
  with_dimensions(function()
    local resets = 0
    local switched = false
    local app = {
      active_slot_id = 1,
      slot = Defaults.new_slot(1, "now"),
      profile_store = {
        reset_slot = function()
          resets = resets + 1
          return true
        end,
      },
      states = {
        pop = function() end,
        switch = function() switched = true end,
      },
    }
    local screen = CampaignResetConfirm(app)
    screen:enter()
    H.eq(screen.warning_step, 1)
    screen.buttons.buttons[2].on_press()
    H.eq(screen.warning_step, 2)
    H.eq(resets, 0)
    H.eq(screen.buttons.focus_index, 1, "final warning defaults to safe action")
    screen.buttons.buttons[2].on_press()
    H.eq(resets, 1)
    H.is_nil(app.slot)
    H.is_true(switched)
  end)
end

return T
