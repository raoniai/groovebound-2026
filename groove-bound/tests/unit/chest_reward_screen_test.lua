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

T["spinning chests converge, flash, then reveal every exact reward"] = function()
  local screen = fresh()
  H.eq(screen:phase(), "converge")
  H.eq(screen:visible_reel_count(), 0)
  screen:update(screen:count_roll_duration() + 0.01)
  H.eq(screen:phase(), "flash")
  H.eq(screen:visible_reel_count(), 0)
  H.eq(screen:displayed_roll(), 3)
  screen:update(screen:count_lock_duration())
  H.eq(screen:visible_reel_count(), 3)
  local first, settled = screen:visible_symbol(1)
  H.is_true(settled)
  H.eq(first.id, screen.rewards[1].id)
  H.eq(screen:reel_spin_duration(), 0)
  local _, first_settled = screen:visible_symbol(1)
  H.is_true(first_settled)
  H.eq(screen:phase(), "rewards")
  screen:update(screen:animation_duration())
  H.eq(screen:phase(), "complete")
  H.eq(screen:visible_reel_count(), 3)
  for index, expected in ipairs(screen.rewards) do
    local actual, reel_settled = screen:visible_symbol(index)
    H.eq(actual.id, expected.id)
    H.is_true(reel_settled)
  end
end

T["Escape and Circle skip the chest animation directly to rewards"] = function()
  local screen, popped = fresh()
  H.is_true(screen:keypressed("escape"))
  H.eq(screen:phase(), "complete")
  H.eq(screen:visible_reel_count(), 3)
  H.eq(popped(), 0)
  H.is_true(screen:keypressed("return"))
  H.eq(popped(), 1)

  local controller, controller_popped = fresh()
  H.is_true(controller:gamepadpressed(nil, "b"))
  H.eq(controller:phase(), "complete")
  H.eq(controller_popped(), 0)
end

T["luck multiplier resolves directly into the reward cards"] = function()
  local screen = fresh()
  H.is_nil(screen:displayed_roll())
  screen:update(screen:count_roll_duration() + 0.01)
  H.eq(screen:displayed_roll(), 3)
  H.is_false(screen.complete)
  H.eq(screen:phase(), "flash")
  H.is_nil(screen:visible_symbol(3))
  screen:update(screen:count_lock_duration())
  H.eq(screen:phase(), "rewards")
  H.eq(screen:visible_symbol(3).id, screen.rewards[3].id)
end

return T
