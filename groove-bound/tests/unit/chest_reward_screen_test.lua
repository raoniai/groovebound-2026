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

local function evolution_fresh(count, reduced_motion)
  local ids = { "kazoo_studio", "bass_supernova", "cymbal_ovation" }
  local rewards = {}
  for index = 1, count do
    local recipe = Content.evolutions[ids[index]]
    rewards[#rewards + 1] = {
      kind = "evolution",
      id = recipe.id,
      title = Content.weapons[recipe.result_weapon].name,
      description = recipe.name,
    }
  end
  return ChestRewardScreen({
    content = Content,
    profile = { options = { reduced_motion = reduced_motion == true } },
    states = { pop = function() end },
  }, { roll = count == 2 and 3 or 1, rewards = rewards })
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

T["evolutions play one quick fusion beat at a time before reward cards"] = function()
  local screen = evolution_fresh(2)
  H.eq(screen:evolution_count(), 2)
  H.is_true(screen:evolution_reveal_duration() < 4.8)

  screen:update(screen:count_roll_duration() + screen:count_lock_duration())
  H.eq(screen:phase(), "evolution")
  H.eq(screen:active_evolution_index(), 1)
  H.eq(screen:current_evolution().id, "kazoo_studio")
  H.eq(screen:visible_reel_count(), 0)

  screen:update(screen:evolution_reveal_duration() + 0.01)
  H.eq(screen:phase(), "evolution")
  H.eq(screen:active_evolution_index(), 2)
  H.eq(screen:current_evolution().id, "bass_supernova")
  H.eq(screen:visible_reel_count(), 0)

  screen:update(screen:evolution_reveal_duration() + 0.01)
  H.eq(screen:phase(), "rewards")
  H.eq(screen:visible_reel_count(), 3)
end

T["non-evolution rewards wait while multiple chest evolutions resolve in reward order"] = function()
  local screen = evolution_fresh(2)
  table.insert(screen.rewards, 2, {
    kind = "coins", id = "coins", title = "Tip Jar",
    description = "Bank 25 coins.",
  })
  screen.reveal.roll = 3

  H.eq(screen:evolution_count(), 2)
  screen:update(screen:count_roll_duration() + screen:count_lock_duration()
    + screen:evolution_reveal_duration() + 0.01)
  H.eq(screen:active_evolution_index(), 2)
  H.eq(screen:current_evolution().id, "bass_supernova")
  H.eq(screen:visible_reel_count(), 0)

  screen:update(screen:evolution_reveal_duration())
  H.eq(screen:phase(), "rewards")
  H.eq(screen:visible_reel_count(), 3)
end

T["reduced motion preserves sequential evolution timing with shorter static beats"] = function()
  local standard = evolution_fresh(2)
  local reduced = evolution_fresh(2, true)
  H.is_true(reduced:evolution_reveal_duration()
    < standard:evolution_reveal_duration())
  H.eq(reduced:animation_duration(),
    reduced:reward_reveal_at() + 0.95)
end

T["flash accessibility options suppress chest and evolution flashes"] = function()
  local reduced_flash = evolution_fresh(1)
  reduced_flash.app.profile.options.reduced_flash = true
  H.is_false(reduced_flash:flash_enabled())

  local disabled_flash = evolution_fresh(1)
  disabled_flash.app.profile.options.hit_flash = false
  H.is_false(disabled_flash:flash_enabled())
  H.is_true(evolution_fresh(1):flash_enabled())
end

return T
