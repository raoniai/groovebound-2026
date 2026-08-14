local H = require("tests.helpers")
local Defaults = require("src.meta.defaults")
local JourneyProgress = require("src.meta.journey_progress")

local T = {}

local function fresh()
  local saves = 0
  local app = {
    active_slot_id = 1,
    slot = Defaults.new_slot(1, "now"),
    profile_store = {
      save_slot = function() saves = saves + 1 return true end,
    },
  }
  return app, function() return saves end
end

T["campaign route and character persist through the active Slot"] = function()
  local app, saves = fresh()
  H.is_false(JourneyProgress.has_campaign(app))
  JourneyProgress.begin_prologue(app)
  JourneyProgress.select_character(app, "lyra")
  JourneyProgress.begin_run(app, "prologue")
  H.is_true(JourneyProgress.has_campaign(app))
  H.eq(app.slot.journey.character_id, "lyra")
  H.eq(app.slot.journey.current_route, "prologue")
  H.eq(app.slot.statistics.runs_started, 1)
  H.eq(saves(), 3)
end

T["Prologue victory unlocks Funk and a saved World Tour route"] = function()
  local app = fresh()
  JourneyProgress.begin_prologue(app)
  local result = {
    outcome = "victory", mode = "prologue", time = 120,
    stats = { kills = 80, bosses = 2, damage = 3000, xp = 900, coins = 320,
      chests_opened = 4, max_combo = 19 },
  }
  JourneyProgress.record_result(app, result)
  H.is_true(app.slot.prologue.completed)
  H.is_true(app.slot.worlds.funk.unlocked)
  H.eq(app.slot.perks.open_ears.rank, 1)
  H.eq(app.slot.wallet.coins, 320)
  H.eq(app.slot.journey.current_route, "world_tour")
  H.eq(app.slot.statistics.victories, 1)
  JourneyProgress.record_result(app, result)
  H.eq(app.slot.statistics.victories, 1, "result write is idempotent")
end

T["Funk victory writes visual grade pillars and best record"] = function()
  local app = fresh()
  app.content = require("src.content.init")
  local result = {
    outcome = "victory", mode = "world_tour", world_id = "funk",
    time = 210, level = 8, health_fraction = 0.82,
    stats = { kills = 105, bosses = 1, damage = 9000, xp = 1600,
      chests_opened = 5, max_combo = 28 },
    world_mechanic = { activations = 8, opportunities = 10, best_chain = 6 },
  }
  JourneyProgress.record_result(app, result)
  local record = app.slot.records.worlds.funk
  H.is_true(record.score > 0)
  H.is_true(record.pillars.groove > 0)
  H.is_true(record.pillars.mastery > 0)
  H.eq(app.slot.worlds.funk.clears, 1)
  H.eq(app.slot.journey.current_route, "world_tour")
end

T["high-grade World victories unlock their perks and the next core world"] = function()
  local app = fresh()
  app.content = require("src.content.init")
  local result = {
    outcome = "victory", mode = "world_tour", world_id = "funk",
    time = 480, level = 12, health_fraction = 1,
    stats = { kills = 170, bosses = 2, damage = 18000, xp = 3200,
      coins = 740, chests_opened = 8, max_combo = 60 },
    world_mechanic = { activations = 12, opportunities = 12, best_chain = 9 },
  }
  JourneyProgress.record_result(app, result)
  H.eq(app.slot.records.worlds.funk.grade, "S")
  H.is_true(app.slot.worlds.soul.unlocked)
  H.eq(app.slot.perks.pocket_drive.rank, 1)
  H.eq(app.slot.perks.breakstep.rank, 1)
  H.eq(app.slot.wallet.coins, 740)
end

T["Disco victory unlocks Jazz and Jazz victory unlocks House"] = function()
  local app = fresh()
  app.content = require("src.content.init")
  app.slot.prologue.completed = true
  for _, world_id in ipairs({ "disco", "jazz" }) do
    JourneyProgress.record_result(app, {
      outcome = "victory", mode = "world_tour", world_id = world_id,
      time = 600, level = 10, health_fraction = 1,
      stats = { kills = 160, bosses = 2, damage = 5000, xp = 1000 },
      world_mechanic = { activations = 10, opportunities = 10, best_chain = 8 },
    })
  end
  H.is_true(app.slot.worlds.jazz.unlocked)
  H.is_true(app.slot.worlds.house.unlocked)
end

T["campaign reset clears the active Slot and in-memory journey"] = function()
  local app = fresh()
  local reset_slot
  app.profile_store.reset_slot = function(_, slot_id)
    reset_slot = slot_id
    return true
  end
  H.is_true(JourneyProgress.reset(app))
  H.eq(reset_slot, 1)
  H.is_nil(app.slot)
end

return T
