-- Pure state/frame selection for individual enemy animation strips.
-- Visual clocks never consume gameplay RNG or affect simulation outcomes.

local EnemyAnimation = {}

local four_frame_walk = {
  breakbeat_bruiser = true,
  syncopated_imp = true,
  blue_note_bat = true,
  walking_bass_bot = true,
  scat_cannon = true,
  bebop_behemoth = true,
  brushfire_skitter = true,
  brass_regent = true,
  midnight_maestro = true,
}

local four_frame_hit = {}
for id in pairs(four_frame_walk) do four_frame_hit[id] = true end

local atlas_aliases = { stage2 = "orbit" }

function EnemyAnimation.atlas_id(icon)
  if not icon then return nil end
  return atlas_aliases[icon.atlas] or icon.atlas or "backbeat"
end

-- Compatibility mapping for the pre-v0.9.4 movement atlas fallback.
function EnemyAnimation.cell(icon, frame)
  if not icon then return nil, nil end
  local count = EnemyAnimation.atlas_id(icon) == "jazz" and 4 or 3
  frame = math.max(1, math.min(count, math.floor(frame or 1)))
  if EnemyAnimation.atlas_id(icon) == "jazz" then
    return (icon.row - 1) * 4 + icon.col, frame
  end
  return (icon.row - 1) * 3 + frame, icon.col
end

function EnemyAnimation.phase(id, x, y)
  local hash = 0
  for index = 1, #(id or "enemy") do
    hash = hash + string.byte(id, index) * index * 17
  end
  hash = hash + math.floor((x or 0) * 31) + math.floor((y or 0) * 47)
  return (hash % 997) / 997
end

function EnemyAnimation.frame_count(id, state)
  if state == "walk" then
    return four_frame_walk[id] and 4 or 3
  end
  if state == "hit" then return four_frame_hit[id] and 4 or 3 end
  return 4
end

function EnemyAnimation.fps(definition, state)
  if state == "hit" then return 14 end
  if state == "attack" then return 9 end
  if state == "death" then return 7 end
  if not definition then return 7 end
  if definition.boss_type == "final" then return 4 end
  if definition.boss_type == "miniboss" then return 5 end
  if definition.brain == "static" then return 5 end
  if definition.brain == "zigzag" then return 10 end
  if definition.brain == "orbit" then return 9 end
  if definition.brain == "pulse" then return 6 end
  return 7
end

function EnemyAnimation.frame(definition, state, elapsed, phase, progress)
  local count = EnemyAnimation.frame_count(definition and definition.id, state)
  if progress then
    progress = math.max(0, math.min(0.999, progress))
    return math.floor(progress * count) + 1
  end
  local cursor = (elapsed or 0) * EnemyAnimation.fps(definition, state)
  if state == "walk" then cursor = cursor + (phase or 0) * count end
  return math.floor(cursor) % count + 1
end

return EnemyAnimation
