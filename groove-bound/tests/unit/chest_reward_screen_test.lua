local H = require("tests.helpers")
local Content = require("src.content.init")
local ChestRewardScreen = require("src.ui.screens.chest_reward")

local T = {}

local function fresh()
  local popped = 0
  local app = {
    content = Content,
    states = { pop = function() popped = popped + 1 end },
  }
  local rewards = {
    { kind = "weapon_level", id = "kazoo_pistol",
      title = "Kazoo Pistol  R2", description = "More buzz." },
    { kind = "passive_add", id = "quickstep",
      title = "Quickstep", description = "Move faster." },
    { kind = "coins", id = "coins",
      title = "Tip Jar", description = "Bank 25 coins." },
  }
  return ChestRewardScreen(app, { roll = 3, rewards = rewards }),
    function() return popped end
end

T["luck reels conceal the count before revealing every exact reward"] = function()
  local screen = fresh()
  H.eq(screen:phase(), "count_roll")
  H.eq(screen:visible_reel_count(), 0)
  H.is_true(screen:rolling_multiplier() == 1
    or screen:rolling_multiplier() == 3
    or screen:rolling_multiplier() == 5)
  screen:update(screen:count_roll_duration() + 0.01)
  H.eq(screen:visible_reel_count(), 3)
  H.eq(screen:displayed_roll(), 3)
  local _, settled = screen:visible_symbol(1)
  H.is_false(settled)
  screen:update(screen:reel_spin_duration())
  local _, first_settled = screen:visible_symbol(1)
  H.is_true(first_settled)
  H.eq(screen:phase(), "settling")
  screen:update(screen:animation_duration())
  H.eq(screen:phase(), "complete")
  H.eq(screen:visible_reel_count(), 3)
  for index, expected in ipairs(screen.rewards) do
    local actual, reel_settled = screen:visible_symbol(index)
    H.eq(actual.id, expected.id)
    H.is_true(reel_settled)
  end
end

T["chest reveal cannot be skipped until the animation finishes"] = function()
  local screen, popped = fresh()
  H.is_false(screen:keypressed("return"))
  H.eq(popped(), 0)
  screen:update(screen:animation_duration())
  H.is_true(screen:keypressed("return"))
  H.eq(popped(), 1)
end

T["luck multiplier resolves before the reward reels finish"] = function()
  local screen = fresh()
  H.is_nil(screen:displayed_roll())
  screen:update(screen:count_roll_duration() + 0.01)
  H.eq(screen:displayed_roll(), 3)
  H.is_false(screen.complete)
end

return T
