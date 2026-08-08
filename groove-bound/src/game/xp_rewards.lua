-- Converts one enemy XP reward into a small, exact-value gem shower. Visual
-- tier reflects enemy difficulty; splitting never changes total progression.

local XPRewards = {}

function XPRewards.profile(definition)
  if definition.boss_type == "final" then return { tier = 4, count = 8 } end
  if definition.boss_type == "miniboss" then return { tier = 3, count = 5 } end
  if definition.elite then return { tier = 3, count = 3 } end
  if (definition.xp or 0) >= 30 then return { tier = 2, count = 2 } end
  return { tier = 1, count = 1 }
end

function XPRewards.split(total, definition)
  total = math.max(0, math.floor(total + 0.5))
  local profile = XPRewards.profile(definition)
  local count = math.max(1, math.min(profile.count, math.max(1, total)))
  local base = math.floor(total / count)
  local remainder = total % count
  local drops = {}
  for index = 1, count do
    drops[index] = {
      tier = profile.tier,
      value = base + (index <= remainder and 1 or 0),
    }
  end
  return drops
end

return XPRewards
