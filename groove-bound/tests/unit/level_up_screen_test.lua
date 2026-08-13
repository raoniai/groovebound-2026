local H = require("tests.helpers")
local Content = require("src.content.init")
local LevelUpScreen = require("src.ui.screens.level_up")

local T = {}

local function with_dimensions(w, h, fn)
  local previous = _G.love
  _G.love = { graphics = {
    getDimensions = function() return w, h end,
    getWidth = function() return w end,
    getHeight = function() return h end,
  } }
  local ok, err = xpcall(fn, debug.traceback)
  _G.love = previous
  if not ok then error(err, 0) end
end

T["evolution guide contains only recipes for currently slotted weapons"] = function()
  local screen = setmetatable({
    app = { content = Content },
    combat = {
      progression = {
        evolution_progress = function()
          return {
            { id = "kazoo_studio", base = Content.weapons.kazoo_pistol,
              support = Content.passives.breath_control,
              result = Content.weapons.brass_barrage },
          }
        end,
      },
    },
  }, LevelUpScreen)
  local records = screen:evolution_records()
  H.eq(#records, 1)
  H.eq(records[1].base.id, "kazoo_pistol")
  H.eq(records[1].result.id, "brass_barrage")
end

T["evolution recipe layout places plus and equals between all three icons"] = function()
  local screen = setmetatable({}, LevelUpScreen)
  for _, width in ipairs({ 268, 180 }) do
    local layout = screen:evolution_recipe_layout(width)
    H.eq(layout.plus.label, "+")
    H.eq(layout.equals.label, "=")
    H.is_true(layout.base_x < layout.plus.x)
    H.is_true(layout.plus.x < layout.support_x)
    H.is_true(layout.support_x < layout.equals.x)
    H.is_true(layout.equals.x < layout.result_x)
    H.is_true(layout.base_x + layout.icon_size / 2 < layout.plus.x - 6)
    H.is_true(layout.plus.x + 6 < layout.support_x - layout.icon_size / 2)
    H.is_true(layout.support_x + layout.icon_size / 2 < layout.equals.x - 6)
    H.is_true(layout.equals.x + 6 < layout.result_x - layout.result_size / 2)
  end
end

T["level-up dpad moves down to CTAs and across the CTA row"] = function()
  with_dimensions(1280, 720, function()
    local screen = setmetatable({
      offer = { {}, {}, {} },
      combat = { progression = { reroll = function() end } },
      app = { profile = { options = {} } },
    }, LevelUpScreen)
    screen:_layout()
    screen:gamepadpressed(nil, "dpdown")
    H.eq(screen.buttons.focus_index, 4)
    screen:gamepadpressed(nil, "dpright")
    H.eq(screen.buttons.focus_index, 5)
    screen:gamepadpressed(nil, "dpup")
    H.eq(screen.buttons.focus_index, 2)
    screen.buttons.focus_index = 3
    screen.buttons:_apply_focus()
    screen:gamepadpressed(nil, "dpright")
    H.eq(screen.buttons.focus_index, 3)
    screen.buttons.focus_index = 1
    screen.buttons:_apply_focus()
    screen:keypressed("a")
    H.eq(screen.buttons.focus_index, 1)
  end)
end

T["choosing a level-up evolution opens the fusion theatre without a chest intro"] = function()
  local popped, pushed, applied, consumed
  local app = {
    content = Content,
    profile = { options = {} },
    states = {
      pop = function(_, result) popped = result end,
      push = function(_, screen) pushed = screen end,
    },
  }
  local combat = {
    progression = {
      apply = function(_, choice) applied = choice end,
    },
    xp = {
      consume_choice = function() consumed = true end,
      has_pending_choice = function() return false end,
    },
  }
  local screen = setmetatable({ app = app, combat = combat }, LevelUpScreen)
  local choice = {
    kind = "evolution", id = "kazoo_studio",
    title = "EVOLVE NOW: Brass Barrage",
    description = "Kazoo Pistol plus Breath Control.",
  }

  screen:_choose(choice)

  H.eq(applied, choice)
  H.is_true(consumed)
  H.is_nil(popped)
  H.eq(pushed.kind, "chest_reward")
  H.eq(pushed.reveal.source, "level_up")
  H.is_true(pushed.reveal.skip_chest_intro)
  H.eq(pushed:evolution_count(), 1)
  H.eq(pushed:phase(), "evolution")
  screen:resume()
  H.eq(popped.kind, "level_up_complete")
end

T["one selection spends one point and refreshes the offer in place"] = function()
  with_dimensions(1280, 720, function()
    local points, offers, applied, popped = 2, 0
    local app = {
      profile = { options = {} },
      states = { pop = function(_, result) popped = result end },
    }
    local combat = {
      progression = {
        apply = function(_, choice) applied = choice end,
        create_offer = function()
          offers = offers + 1
          return { { kind = "coins", id = "coins", title = "Coins" } }
        end,
      },
      xp = {
        pending_choices = points,
        consume_choice = function(self)
          points = points - 1
          self.pending_choices = points
        end,
        has_pending_choice = function() return points > 0 end,
      },
    }
    local screen = setmetatable({
      app = app, combat = combat,
      offer = { { kind = "guard", id = "guard", title = "Guard" } },
    }, LevelUpScreen)
    screen:_choose(screen.offer[1])
    H.eq(applied.kind, "guard")
    H.eq(points, 1)
    H.eq(offers, 1)
    H.is_nil(popped)
  end)
end

T["automatic menu toggle persists without spending a point"] = function()
  local saves = 0
  local screen = setmetatable({
    app = {
      profile = { options = { automatic_level_up = false } },
      save = { save = function() saves = saves + 1 end },
    },
  }, LevelUpScreen)
  screen:_toggle_automatic()
  H.is_true(screen.app.profile.options.automatic_level_up)
  H.eq(saves, 1)
end

return T
