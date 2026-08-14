-- Single owner for the locally saved campaign journey and World Tour records.

local JourneyProgress = {}
local PerkProgress = require("src.meta.perk_progress")
local WorldTourSession = require("src.meta.world_tour_session")

local NEXT_WORLD = {
  funk = "soul", soul = "disco", disco = "jazz", jazz = "house",
  house = "techno",
}

local function ensure_world(slot, world_id)
  slot.worlds[world_id] = slot.worlds[world_id] or {
    unlocked = false,
    clears = 0,
    best_grade = "",
    best_score = 0,
  }
  return slot.worlds[world_id]
end

function JourneyProgress.ensure(app)
  if app.slot then return app.slot end
  local slot, error_message = app.profile_store:create_slot(app.active_slot_id)
  assert(slot, "Could not create campaign Slot: " .. tostring(error_message))
  app.slot = slot
  return slot
end

function JourneyProgress.save(app)
  local slot = JourneyProgress.ensure(app)
  slot.last_played_at = os.date("!%Y-%m-%dT%H:%M:%SZ")
  local saved, error_message = app.profile_store:save_slot(app.active_slot_id, slot)
  assert(saved, "Could not save campaign Slot: " .. tostring(error_message))
  return slot
end

function JourneyProgress.has_campaign(app)
  return app.slot and app.slot.journey
    and app.slot.journey.state ~= "empty"
end

function JourneyProgress.reset(app)
  local reset, error_message = app.profile_store:reset_slot(app.active_slot_id)
  assert(reset, "Could not reset campaign Slot: " .. tostring(error_message))
  app.slot = nil
  WorldTourSession.clear(app)
  return true
end

function JourneyProgress.begin_prologue(app)
  WorldTourSession.clear(app)
  local slot = JourneyProgress.ensure(app)
  slot.journey.state = "in_progress"
  slot.journey.current_route = "prologue"
  slot.journey.active_world_id = ""
  return JourneyProgress.save(app)
end

function JourneyProgress.select_character(app, character_id)
  local slot = JourneyProgress.ensure(app)
  slot.journey.character_id = character_id
  return JourneyProgress.save(app)
end

function JourneyProgress.begin_run(app, route, world_id)
  local slot = JourneyProgress.ensure(app)
  slot.journey.state = "in_progress"
  slot.journey.current_route = route
  slot.journey.active_world_id = world_id or ""
  slot.statistics.runs_started = slot.statistics.runs_started + 1
  return JourneyProgress.save(app)
end

function JourneyProgress.abandon_active_run(app)
  if not app.slot then return end
  app.slot.statistics.abandoned_runs = app.slot.statistics.abandoned_runs + 1
  return JourneyProgress.save(app)
end

local function merge_statistics(slot, result)
  local stats = result.stats or {}
  slot.statistics.total_run_seconds = slot.statistics.total_run_seconds
    + math.max(0, math.floor((result.time or 0) + 0.5))
  slot.statistics.enemies_defeated = slot.statistics.enemies_defeated
    + (stats.kills or 0)
  slot.statistics.bosses_defeated = slot.statistics.bosses_defeated
    + (stats.bosses or 0)
  slot.statistics.damage_dealt = slot.statistics.damage_dealt
    + math.max(0, math.floor(stats.damage or 0))
  slot.statistics.xp_collected = slot.statistics.xp_collected
    + math.max(0, math.floor(stats.xp or 0))
  slot.statistics.chests_opened = slot.statistics.chests_opened
    + (stats.chests_opened or 0)
  slot.statistics.highest_combo = math.max(
    slot.statistics.highest_combo, stats.max_combo or 0)
  if result.outcome == "victory" then
    slot.statistics.victories = slot.statistics.victories + 1
  else
    slot.statistics.defeats = slot.statistics.defeats + 1
  end
end

local function calculate_world_record(result)
  local stats = result.stats or {}
  local mechanic = result.world_mechanic or {}
  local opportunities = math.max(1, mechanic.opportunities or 1)
  local pillars = {
    groove = math.min(100, math.floor((mechanic.activations or 0)
      / opportunities * 100 + 0.5)),
    impact = math.min(100, math.floor((stats.kills or 0) / 1.35)),
    control = math.max(0, math.min(100,
      math.floor((result.health_fraction or 0) * 100 + 0.5))),
    craft = math.min(100, math.floor((result.level or 1) * 9)),
    mastery = math.min(100, (mechanic.best_chain or 0) * 14),
  }
  local score = math.floor((pillars.groove + pillars.impact + pillars.control
    + pillars.craft + pillars.mastery) / 5 + 0.5)
  local grade = score >= 90 and "S" or score >= 75 and "A"
    or score >= 58 and "B" or score >= 40 and "C" or "D"
  return { score = score, grade = grade, pillars = pillars }
end

function JourneyProgress.record_result(app, result)
  if result.progress_saved then return app.slot end
  result.progress_saved = true
  local slot = JourneyProgress.ensure(app)
  local content = app.content or require("src.content.init")
  merge_statistics(slot, result)

  if result.outcome == "victory" then
    local coins = math.max(0, math.floor(((result.stats or {}).coins or 0) + 0.5))
    slot.wallet.coins = slot.wallet.coins + coins
    slot.wallet.lifetime_earned = slot.wallet.lifetime_earned + coins
  end

  if result.mode == "world_tour" then
    local world_id = assert(result.world_id)
    local world = ensure_world(slot, world_id)
    if result.outcome == "victory" then
      local record = calculate_world_record(result)
      world.clears = world.clears + 1
      if record.score > (world.best_score or 0) then
        world.best_score = record.score
        world.best_grade = record.grade
        slot.records.worlds[world_id] = record
      end
      local next_world = NEXT_WORLD[world_id]
      if next_world then ensure_world(slot, next_world).unlocked = true end
      PerkProgress.unlock_for_grade(slot, world_id, record.grade, content)
      slot.journey.current_route = "world_tour"
      slot.journey.active_world_id = ""
    end
  elseif result.outcome == "victory" then
    slot.prologue.completed = true
    slot.prologue.clears = slot.prologue.clears + 1
    ensure_world(slot, "funk").unlocked = true
    PerkProgress.unlock(slot, "open_ears", content)
    slot.journey.current_route = "world_tour"
    slot.journey.active_world_id = ""
  else
    slot.journey.current_route = "prologue"
  end

  slot.journey.state = "in_progress"
  return JourneyProgress.save(app)
end

return JourneyProgress
