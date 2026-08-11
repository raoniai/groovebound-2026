-- Geometry-first focus navigation for irregular menu grids.

local SpatialNavigation = {}

local function centre(rect)
  return rect.x + rect.w / 2, rect.y + rect.h / 2
end

local function gap(a0, a1, b0, b1)
  if a1 < b0 then return b0 - a1 end
  if b1 < a0 then return a0 - b1 end
  return 0
end

function SpatialNavigation.find(items, current_index, direction, rect_for)
  local current = items[current_index]
  if not current then return current_index end
  rect_for = rect_for or function(item) return item.rect or item end
  local current_rect = rect_for(current)
  local cx, cy = centre(current_rect)
  local best_index, best_score

  for index, item in ipairs(items) do
    if index ~= current_index then
      local rect = rect_for(item)
      local x, y = centre(rect)
      local dx, dy = x - cx, y - cy
      local primary, cross, cross_gap
      if direction == "left" and dx < -0.5 then
        primary, cross = -dx, math.abs(dy)
        cross_gap = gap(current_rect.y, current_rect.y + current_rect.h,
          rect.y, rect.y + rect.h)
      elseif direction == "right" and dx > 0.5 then
        primary, cross = dx, math.abs(dy)
        cross_gap = gap(current_rect.y, current_rect.y + current_rect.h,
          rect.y, rect.y + rect.h)
      elseif direction == "up" and dy < -0.5 then
        primary, cross = -dy, math.abs(dx)
        cross_gap = gap(current_rect.x, current_rect.x + current_rect.w,
          rect.x, rect.x + rect.w)
      elseif direction == "down" and dy > 0.5 then
        primary, cross = dy, math.abs(dx)
        cross_gap = gap(current_rect.x, current_rect.x + current_rect.w,
          rect.x, rect.x + rect.w)
      end
      if primary then
        local score = primary + cross * 0.20 + cross_gap * 8
        if not best_score or score < best_score then
          best_index, best_score = index, score
        end
      end
    end
  end
  return best_index or current_index
end

return SpatialNavigation
