-- Pure animation mapping for the generated enemy movement atlases.
--
-- This module intentionally has no LÖVE or RNG dependency. Enemy animation is
-- visual-only, deterministic, and cannot perturb gameplay simulation order.

local EnemyAnimation = {}

local atlas_aliases = {
  stage2 = "orbit",
}

function EnemyAnimation.atlas_id(icon)
  if not icon then return nil end
  return atlas_aliases[icon.atlas] or icon.atlas or "backbeat"
end

function EnemyAnimation.frame_count(icon)
  return EnemyAnimation.atlas_id(icon) == "jazz" and 4 or 3
end

function EnemyAnimation.cell(icon, frame)
  if not icon then return nil, nil end
  local count = EnemyAnimation.frame_count(icon)
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

function EnemyAnimation.fps(definition)
  if not definition then return 7 end
  if definition.boss_type == "final" then return 4 end
  if definition.boss_type == "miniboss" then return 5 end
  if definition.brain == "static" then return 5 end
  if definition.brain == "zigzag" then return 10 end
  if definition.brain == "orbit" then return 9 end
  if definition.brain == "pulse" then return 6 end
  return 7
end

function EnemyAnimation.frame(definition, elapsed, phase)
  local count = EnemyAnimation.frame_count(definition and definition.sprite)
  local cursor = (elapsed or 0) * EnemyAnimation.fps(definition)
    + (phase or 0) * count
  return math.floor(cursor) % count + 1
end

return EnemyAnimation
