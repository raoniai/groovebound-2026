local H = require("tests.helpers")
local CharacterSelectScreen = require("src.ui.screens.character_select")
local ResultsScreen = require("src.ui.screens.results")
local OptionsScreen = require("src.ui.screens.options")
local ControlsScreen = require("src.ui.screens.controls")
local WorldTourScreen = require("src.ui.screens.world_tour")
local PerkDatabase = require("src.ui.screens.perk_database")
local Content = require("src.content.init")
local Defaults = require("src.meta.defaults")

local T = {}

local function with_dimensions(w, h, fn)
  local previous = _G.love
  _G.love = {
    graphics = {
      getDimensions = function() return w, h end,
      getWidth = function() return w end,
      getHeight = function() return h end,
    },
  }
  local ok, err = xpcall(fn, debug.traceback)
  _G.love = previous
  if not ok then error(err, 0) end
end

local function inside(rect, w, h)
  return rect.x >= 0 and rect.y >= 0
    and rect.x + rect.w <= w and rect.y + rect.h <= h
end

local function overlaps(a, b)
  return a.x < b.x + b.w and b.x < a.x + a.w
    and a.y < b.y + b.h and b.y < a.y + a.h
end

T["World Tour slots, records and campaign actions fit supported canvases"] = function()
  for _, dimensions in ipairs({ { 800, 600 }, { 1280, 720 } }) do
    with_dimensions(dimensions[1], dimensions[2], function()
      local screen = WorldTourScreen({ content = Content })
      screen:_layout()
      H.is_true(inside(screen.catalog_rect, dimensions[1], dimensions[2]))
      H.is_true(inside(screen.detail_rect, dimensions[1], dimensions[2]))
      H.is_true(screen.catalog_rect.w > screen.detail_rect.w)
      H.is_false(overlaps(screen.catalog_rect, screen.detail_rect))
      for _, rect in ipairs(screen.slot_rects) do
        H.is_true(inside(rect, dimensions[1], dimensions[2]))
        H.is_false(overlaps(rect, screen.detail_rect))
      end
      for _, button in ipairs(screen.buttons.buttons) do
        H.is_true(inside(button, dimensions[1], dimensions[2]))
        H.is_false(overlaps(button, screen.detail_rect))
      end
    end)
  end
end

T["World Tour catalog can be inspected before a campaign exists"] = function()
  with_dimensions(800, 600, function()
    local screen = WorldTourScreen(
      { content = Content, slot = nil }, { catalog_only = true })
    screen:_layout()
    local saved, unlocked = screen:_world_state(Content.world_tour.funk)
    H.is_false(unlocked)
    H.is_nil(saved.best_score)
    H.eq(#screen.buttons.buttons, 1)
    H.eq(screen.buttons.buttons[1].label, "RETURN TO TITLE")
  end)
end

T["World Tour mouse hover never changes the clicked selection"] = function()
  with_dimensions(1280, 720, function()
    local screen = WorldTourScreen({ content = Content })
    screen:_layout()
    screen.selected = 1
    local hover = screen.slot_rects[3]
    screen:mousemoved(hover.x + 4, hover.y + 4)
    H.eq(screen.selected, 1)
    H.is_true(screen:mousepressed(hover.x + 4, hover.y + 4, 1))
    H.eq(screen.selected, 3)
    screen:mousemoved(screen.slot_rects[2].x + 4, screen.slot_rects[2].y + 4)
    H.eq(screen.selected, 3)
  end)
end

T["playable World Tour selection asks for a character before starting"] = function()
  local switched
  local slot = Defaults.new_slot(1, "now")
  slot.prologue.completed = true
  local app = {
    content = Content,
    slot = slot,
    states = { switch = function(_, screen) switched = screen end },
  }
  local screen = WorldTourScreen(app)
  H.is_true(screen:_play_selected())
  H.eq(switched.kind, "character_select")
  H.is_true(type(switched.opts.on_confirm) == "function")
  H.is_true(type(switched.opts.on_back) == "function")
end

T["Perk database CTAs sit side by side inside the detail panel"] = function()
  for _, dimensions in ipairs({ { 800, 600 }, { 1280, 720 } }) do
    with_dimensions(dimensions[1], dimensions[2], function()
      local screen = PerkDatabase({ content = Content })
      screen:_layout()
      for _, button in ipairs(screen.buttons.buttons) do
        H.is_true(inside(button, dimensions[1], dimensions[2]))
        H.is_true(button.x >= screen.detail.x)
        H.is_true(button.x + button.w <= screen.detail.x + screen.detail.w)
        H.is_true(button.y >= screen.detail.y)
        H.is_true(button.y + button.h <= screen.detail.y + screen.detail.h)
        H.is_true(button.y + button.h <= dimensions[2] - 38)
      end
      H.is_false(overlaps(screen.buttons.buttons[1], screen.buttons.buttons[2]))
      H.eq(screen.buttons.buttons[1].y, screen.buttons.buttons[2].y)
    end)
  end
end

T["character cards and result actions stay aligned at both supported canvases"] = function()
  for _, dimensions in ipairs({ { 800, 600 }, { 1280, 720 } }) do
    with_dimensions(dimensions[1], dimensions[2], function()
      local characters = CharacterSelectScreen({})
      characters:_layout()
      H.is_true(inside(characters.cards[1], dimensions[1], dimensions[2]))
      H.is_true(inside(characters.cards[2], dimensions[1], dimensions[2]))
      H.is_false(overlaps(characters.cards[1], characters.cards[2]))
      H.is_true(characters.cards[1].y + characters.cards[1].h <= dimensions[2] - 40)

      local results = ResultsScreen({}, {})
      results:_layout()
      local first, second = results.buttons.buttons[1], results.buttons.buttons[2]
      H.is_true(inside(first, dimensions[1], dimensions[2]))
      H.is_true(inside(second, dimensions[1], dimensions[2]))
      H.is_false(overlaps(first, second))

      local world_defeat = ResultsScreen({ content = Content, assets = {} }, {
        outcome = "defeat", mode = "world_tour", world_id = "funk",
        retry = { mode = "world_tour", world_id = "funk", character_id = "joe" },
      })
      world_defeat:_layout()
      H.eq(#world_defeat.buttons.buttons, 3)
      H.eq(world_defeat.buttons.buttons[1].label, "RETRY FUNK")
      H.eq(world_defeat.buttons.buttons[2].label, "RETURN TO WORLD MENU")
      H.eq(world_defeat.buttons.buttons[3].label, "RETURN TO TITLE")
      for index, action in ipairs(world_defeat.buttons.buttons) do
        H.is_true(inside(action, dimensions[1], dimensions[2]))
        if index > 1 then
          H.is_false(overlaps(world_defeat.buttons.buttons[index - 1], action))
        end
      end
    end)
  end
end

T["World Tour defeat actions retry immediately or return to the World Menu"] = function()
  with_dimensions(1280, 720, function()
    local switched
    local slot = Defaults.new_slot(1, "now")
    slot.prologue.completed = true
    local app = {
      content = Content, assets = {}, slot = slot, active_slot_id = 1,
      profile_store = { save_slot = function() return true end },
      states = { switch = function(_, state) switched = state end },
    }
    local result = {
      outcome = "defeat", mode = "world_tour", world_id = "soul",
      retry = {
        mode = "world_tour", world_id = "soul", character_id = "lyra",
        starter_loadout = { weapons = { "bell_tower" }, passives = {} },
      },
    }
    local retry = ResultsScreen(app, result)
    retry:_layout()
    retry.buttons.buttons[1].on_press()
    H.eq(switched.kind, "run")
    H.eq(switched.opts.world_id, "soul")
    H.eq(switched.opts.character_id, "lyra")
    H.eq(switched.opts.starter_loadout.weapons[1], "bell_tower")
    H.eq(app.slot.journey.active_world_id, "soul")

    local menu = ResultsScreen(app, result)
    menu:_layout()
    menu.buttons.buttons[2].on_press()
    H.eq(switched.kind, "world_tour")
    H.eq(app.slot.journey.current_route, "world_tour")
    H.eq(app.slot.journey.active_world_id, "")
  end)
end

T["settings labels, controls, rows and guide remain disjoint at compact size"] = function()
  with_dimensions(800, 600, function()
    local screen = OptionsScreen({})
    screen:_layout()
    for _, row in ipairs(screen.rows) do
      H.is_true(inside(row.rect, 800, 600))
      H.is_false(overlaps(row.label_rect, row.control))
      if row.kind == "slider" then
        H.is_true(inside(row.track, 800, 600))
        H.is_false(overlaps(row.minus_rect, row.plus_rect))
      end
    end
    H.is_true(inside(screen.guide_rect, 800, 600))
    for _, row in ipairs(screen.rows) do
      if row.rect.x == screen.guide_rect.x then
        H.is_false(overlaps(row.rect, screen.guide_rect))
      end
    end
  end)
end

T["settings remain concise and centered on widescreen canvases"] = function()
  with_dimensions(2048, 1152, function()
    local screen = OptionsScreen({})
    screen:_layout()
    H.is_true(screen.panel.w <= 980)
    H.is_true(screen.panel.h <= 530)
    H.near(screen.panel.x + screen.panel.w / 2, 1024)
    H.near(screen.panel.y + screen.panel.h / 2, 576)
    H.is_true(inside(screen.guide_rect, 2048, 1152))
  end)
end

T["keyboard binding buttons fit without overlapping on compact screens"] = function()
  with_dimensions(800, 600, function()
    local screen = ControlsScreen({ states = { pop = function() end } })
    screen:_layout()
    for index, button in ipairs(screen.buttons.buttons) do
      H.is_true(inside(button, 800, 600))
      if index > 1 then
        H.is_false(overlaps(screen.buttons.buttons[index - 1], button))
      end
    end
  end)
end

return T
