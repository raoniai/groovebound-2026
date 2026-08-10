local SlotValidator = {}

local function non_negative_number(value)
  return type(value) == "number" and value == value and value >= 0
    and value ~= math.huge
end

local function non_negative_integer(value)
  return non_negative_number(value) and value % 1 == 0
end

function SlotValidator.validate(slot, expected_slot_id)
  if type(slot) ~= "table" then return nil, "Slot must be a table" end
  if slot.slot_id ~= expected_slot_id then return nil, "Slot ID does not match its file" end
  if slot.slot_revision ~= 1 then return nil, "unsupported Slot revision" end
  if type(slot.created_at) ~= "string" or type(slot.last_played_at) ~= "string" then
    return nil, "Slot timestamps are required"
  end
  if not non_negative_number(slot.total_play_seconds) then
    return nil, "total play time must be non-negative"
  end

  local prologue = slot.prologue
  if type(prologue) ~= "table" or type(prologue.completed) ~= "boolean"
      or not non_negative_integer(prologue.clears) then
    return nil, "invalid Prologue record"
  end

  -- Older Slot V2 files predate campaign routing. Missing journey data is
  -- accepted on decode so Save can fill current defaults without a reset.
  local journey = slot.journey
  if journey ~= nil then
    local valid_states = { empty = true, in_progress = true, complete = true }
    local valid_routes = { prologue = true, world_tour = true, funk = true }
    if type(journey) ~= "table" or not valid_states[journey.state]
        or type(journey.character_id) ~= "string"
        or not valid_routes[journey.current_route]
        or type(journey.active_world_id) ~= "string" then
      return nil, "invalid campaign journey"
    end
  end

  local wallet = slot.wallet
  if type(wallet) ~= "table" or not non_negative_integer(wallet.coins)
      or not non_negative_integer(wallet.lifetime_earned)
      or not non_negative_integer(wallet.lifetime_spent)
      or not non_negative_integer(wallet.lifetime_refunded) then
    return nil, "invalid wallet"
  end

  local required_tables = {
    "worlds", "perks", "claims", "records", "statistics", "migrations",
  }
  for _, key in ipairs(required_tables) do
    if type(slot[key]) ~= "table" then return nil, key .. " must be a table" end
  end
  if type(slot.records.prologue) ~= "table" or type(slot.records.worlds) ~= "table" then
    return nil, "invalid record book"
  end

  local statistic_keys = {
    "runs_started", "victories", "defeats", "abandoned_runs",
    "total_run_seconds", "enemies_defeated", "bosses_defeated", "damage_dealt",
    "damage_taken", "xp_collected", "chests_opened", "evolutions_completed",
    "highest_combo",
  }
  for _, key in ipairs(statistic_keys) do
    if not non_negative_integer(slot.statistics[key]) then
      return nil, "invalid statistic: " .. key
    end
  end
  return true
end

return SlotValidator
