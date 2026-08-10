-- The playfield: a rectangle with walls. Owns bounds math (clamp/contains)
-- and its own rendering. Entities query it; nothing else knows arena size.

local class = require("src.core.class")
local settings = require("src.config.settings")

local Arena = class()

function Arena:init(opts)
  opts = opts or {}
  local cfg = settings.arena
  self.stage = opts.stage or {}
  self.width = opts.width or self.stage.width or cfg.width
  self.height = opts.height or self.stage.height or cfg.height
  self.wall = opts.wall or cfg.wall
  self.assets = opts.assets
  self.obstacles = opts.obstacles or self.stage.obstacles or {
    { x = 420, y = 360, w = 120, h = 180, icon = { col = 1, row = 1 } },
    { x = 910, y = 280, w = 150, h = 120, icon = { col = 2, row = 1 } },
    { x = 1420, y = 420, w = 150, h = 120, icon = { col = 3, row = 1 } },
    { x = 650, y = 980, w = 180, h = 115, icon = { col = 4, row = 1 } },
    { x = 1300, y = 1080, w = 130, h = 180, icon = { col = 1, row = 1 } },
  }
  self.decorations = opts.decorations or self.stage.decorations or {
    { x = 280, y = 790, size = 120, icon = { col = 1, row = 2 } },
    { x = 1120, y = 700, size = 105, icon = { col = 2, row = 2 } },
    { x = 1700, y = 820, size = 135, icon = { col = 3, row = 2 } },
    { x = 980, y = 1330, size = 100, icon = { col = 4, row = 2 } },
  }
  self.collision_rects = nil
end

function Arena:center()
  return self.width / 2, self.height / 2
end

-- Clamp a point so a body of the given radius stays inside the walls.
function Arena:clamp(x, y, radius)
  radius = radius or 0
  local lo = self.wall + radius
  return math.max(lo, math.min(x, self.width - self.wall - radius)),
         math.max(lo, math.min(y, self.height - self.wall - radius))
end

function Arena:contains(x, y, radius)
  radius = radius or 0
  local lo = self.wall + radius
  return x >= lo and y >= lo
     and x <= self.width - self.wall - radius
     and y <= self.height - self.wall - radius
end

local function circle_hits_rect(x, y, radius, rect)
  local nearest_x = math.max(rect.x, math.min(x, rect.x + rect.w))
  local nearest_y = math.max(rect.y, math.min(y, rect.y + rect.h))
  local dx, dy = x - nearest_x, y - nearest_y
  return dx * dx + dy * dy < radius * radius
end

local function passes_behind(obstacle)
  if obstacle.pass_behind ~= nil then return obstacle.pass_behind end
  return obstacle.h > obstacle.w * 1.12
end

local function collision_rect(obstacle)
  if not passes_behind(obstacle) then return obstacle end
  -- Only trim the upper edge. This keeps equipment solid while leaving a
  -- small visual lane for the player to pass behind tall scenery.
  local ratio = obstacle.hitbox_ratio or 0.90
  local height = obstacle.h * ratio
  return {
    x = obstacle.x,
    y = obstacle.y + obstacle.h - height,
    w = obstacle.w,
    h = height,
  }
end

local function decoration_collision_rect(decoration)
  local size = decoration.size or 0
  local width = decoration.hitbox_w or size * 0.58
  local height = decoration.hitbox_h or size * 0.24
  local offset_x = decoration.hitbox_offset_x or 0
  local offset_y = decoration.hitbox_offset_y or size * 0.30
  return {
    x = decoration.x + offset_x - width / 2,
    y = decoration.y + offset_y - height / 2,
    w = width,
    h = height,
  }
end

function Arena:_collision_rects()
  if self.collision_rects then return self.collision_rects end
  local result = {}
  for _, obstacle in ipairs(self.obstacles) do
    result[#result + 1] = collision_rect(obstacle)
  end
  for _, decoration in ipairs(self.decorations) do
    if decoration.blocks_base then
      result[#result + 1] = decoration_collision_rect(decoration)
    end
  end
  self.collision_rects = result
  return result
end

local function segment_hits_expanded_rect(x1, y1, x2, y2, rect, padding)
  -- Shrinking by a hair makes a route that touches an expanded corner valid.
  -- The real circle/rectangle collision remains authoritative during movement.
  local epsilon = 0.01
  local left = rect.x - padding + epsilon
  local right = rect.x + rect.w + padding - epsilon
  local top = rect.y - padding + epsilon
  local bottom = rect.y + rect.h + padding - epsilon
  local dx, dy = x2 - x1, y2 - y1
  local t_min, t_max = 0, 1

  local function clip(origin, delta, minimum, maximum)
    if math.abs(delta) < 0.000001 then
      return origin > minimum and origin < maximum
    end
    local a = (minimum - origin) / delta
    local b = (maximum - origin) / delta
    if a > b then a, b = b, a end
    t_min = math.max(t_min, a)
    t_max = math.min(t_max, b)
    return t_max > t_min
  end

  return clip(x1, dx, left, right) and clip(y1, dy, top, bottom)
end

local function draw_floor_surface(arena, style, tint, veil)
  local atlas = arena.assets and arena.assets.floor_surfaces
    and arena.assets.floor_surfaces[style]
  if not atlas then return false end
  local quads = arena.assets.floor_surface_quads[style]
  local cell_w = arena.assets.floor_surface_cell_w[style]
  local cell_h = arena.assets.floor_surface_cell_h[style]
  local tile_size = 256
  love.graphics.setColor(tint)
  for row = 0, math.ceil(arena.height / tile_size) - 1 do
    for column = 0, math.ceil(arena.width / tile_size) - 1 do
      local variant = (column * 17 + row * 31 + column * row * 3) % 4
      local col = variant % 2 + 1
      local quad_row = math.floor(variant / 2) + 1
      love.graphics.draw(
        atlas, quads[quad_row][col],
        column * tile_size, row * tile_size, 0,
        (tile_size + 1) / cell_w, (tile_size + 1) / cell_h)
    end
  end
  love.graphics.setColor(veil)
  love.graphics.rectangle("fill", 0, 0, arena.width, arena.height)
  return true
end

function Arena:blocked(x, y, radius)
  for _, collider in ipairs(self:_collision_rects()) do
    if circle_hits_rect(x, y, radius, collider) then
      return true
    end
  end
  return false
end

function Arena:segment_clear(x1, y1, x2, y2, radius)
  radius = radius or 0
  if not self:contains(x1, y1, radius)
    or not self:contains(x2, y2, radius)
  then
    return false
  end
  for _, collider in ipairs(self:_collision_rects()) do
    if segment_hits_expanded_rect(
      x1, y1, x2, y2, collider, radius + 2)
    then
      return false
    end
  end
  return true
end

function Arena:navigation_direction(x, y, target_x, target_y, radius)
  local direct_x, direct_y = target_x - x, target_y - y
  local direct_length = math.sqrt(direct_x * direct_x + direct_y * direct_y)
  if direct_length <= 0.001 then return 0, 0, false end
  if self:segment_clear(x, y, target_x, target_y, radius) then
    return direct_x / direct_length, direct_y / direct_length, false
  end

  -- Build a tiny visibility graph around the stage equipment. With only the
  -- obstacle corners as candidates, enemies get a true shortest detour without
  -- paying for a full navigation grid every frame.
  local nodes = {
    { x = x, y = y },
    { x = target_x, y = target_y },
  }
  local clearance = (radius or 0) + 6
  for _, collider in ipairs(self:_collision_rects()) do
    for _, point in ipairs({
      { x = collider.x - clearance, y = collider.y - clearance },
      { x = collider.x + collider.w + clearance,
        y = collider.y - clearance },
      { x = collider.x - clearance,
        y = collider.y + collider.h + clearance },
      { x = collider.x + collider.w + clearance,
        y = collider.y + collider.h + clearance },
    }) do
      if self:contains(point.x, point.y, radius)
        and not self:blocked(point.x, point.y, radius)
      then
        nodes[#nodes + 1] = point
      end
    end
  end

  local distance, previous, visited = { [1] = 0 }, {}, {}
  while true do
    local current, best
    for index = 1, #nodes do
      if not visited[index] and distance[index]
        and (not best or distance[index] < best)
      then
        current, best = index, distance[index]
      end
    end
    if not current or current == 2 then break end
    visited[current] = true
    for candidate = 1, #nodes do
      if not visited[candidate] and candidate ~= current
        and self:segment_clear(
          nodes[current].x, nodes[current].y,
          nodes[candidate].x, nodes[candidate].y, radius)
      then
        local edge_x = nodes[candidate].x - nodes[current].x
        local edge_y = nodes[candidate].y - nodes[current].y
        local alternative = best + math.sqrt(edge_x * edge_x + edge_y * edge_y)
        if not distance[candidate] or alternative < distance[candidate] then
          distance[candidate] = alternative
          previous[candidate] = current
        end
      end
    end
  end

  if not distance[2] then
    return direct_x / direct_length, direct_y / direct_length, false
  end
  local waypoint = 2
  while previous[waypoint] and previous[waypoint] ~= 1 do
    waypoint = previous[waypoint]
  end
  local route_x = nodes[waypoint].x - x
  local route_y = nodes[waypoint].y - y
  local route_length = math.sqrt(route_x * route_x + route_y * route_y)
  if route_length <= 0.001 then
    return direct_x / direct_length, direct_y / direct_length, false
  end
  return route_x / route_length, route_y / route_length, true
end

function Arena:safe_drop_position(x, y, radius)
  radius = radius or 0
  x, y = self:clamp(x, y, radius)
  if not self:blocked(x, y, radius) then return x, y end
  for ring = 1, 12 do
    local distance = ring * 32
    for step = 0, 15 do
      local angle = step / 16 * math.pi * 2
      local candidate_x, candidate_y = self:clamp(
        x + math.cos(angle) * distance,
        y + math.sin(angle) * distance,
        radius)
      if not self:blocked(candidate_x, candidate_y, radius) then
        return candidate_x, candidate_y
      end
    end
  end
  return self:center()
end

function Arena:resolve_movement(old_x, old_y, x, y, radius)
  x, y = self:clamp(x, y, radius)
  if self:blocked(x, old_y, radius) then x = old_x end
  if self:blocked(x, y, radius) then y = old_y end
  if self:blocked(x, y, radius) then return old_x, old_y end
  return x, y
end

function Arena:draw()
  local cfg = settings.arena
  local floor_tint = self.stage.floor_tint or { 0.58, 0.54, 0.66, 0.78 }
  local veil_color = self.stage.veil_color or { 0.08, 0.06, 0.13, 0.42 }
  local environment_atlas = self.stage.environment_atlas or "stage1"

  -- Floor.
  love.graphics.setColor(cfg.floor_color)
  love.graphics.rectangle("fill", 0, 0, self.width, self.height)

  if not draw_floor_surface(
    self, self.stage.floor_style or "backbeat", floor_tint, veil_color)
    and self.assets and self.assets.floor
  then
    love.graphics.setColor(floor_tint)
    local tile_size = 128
    local columns = math.ceil(self.width / tile_size)
    local rows = math.ceil(self.height / tile_size)
    for row = 0, rows - 1 do
      for column = 0, columns - 1 do
        local index = (column * 17 + row * 31) % #self.assets.floor_quads + 1
        love.graphics.draw(
          self.assets.floor,
          self.assets.floor_quads[index],
          column * tile_size,
          row * tile_size)
      end
    end

    love.graphics.setColor(veil_color)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
  end

  if self.assets and self.assets.environment then
    for _, decoration in ipairs(self.decorations) do
      self.assets:draw_environment(
        decoration.icon, decoration.x, decoration.y, decoration.size,
        {
          color = { 1, 1, 1, 0.72 },
          atlas = decoration.atlas or environment_atlas,
        })
    end
  end

  if self.assets and self.assets.environment then
    for _, obstacle in ipairs(self.obstacles) do
      self.assets:draw_environment(
        obstacle.icon,
        obstacle.x + obstacle.w / 2,
        obstacle.y + obstacle.h / 2,
        math.max(obstacle.w, obstacle.h),
        { atlas = obstacle.atlas or environment_atlas })
    end
  end

  -- Walls.
  love.graphics.setColor(cfg.wall_color)
  love.graphics.rectangle("fill", 0, 0, self.width, self.wall)
  love.graphics.rectangle("fill", 0, self.height - self.wall, self.width, self.wall)
  love.graphics.rectangle("fill", 0, 0, self.wall, self.height)
  love.graphics.rectangle("fill", self.width - self.wall, 0, self.wall, self.height)
end

function Arena:draw_overlays()
  if not self.assets or not self.assets.draw_environment_upper then return end
  local environment_atlas = self.stage.environment_atlas or "stage1"
  for _, decoration in ipairs(self.decorations) do
    self.assets:draw_environment_upper(
      decoration.icon, decoration.x, decoration.y, decoration.size,
      {
        color = { 1, 1, 1, 0.72 },
        atlas = decoration.atlas or environment_atlas,
        fraction = decoration.overlay_fraction or 0.54,
      })
  end
  for _, obstacle in ipairs(self.obstacles) do
    if passes_behind(obstacle) then
      self.assets:draw_environment_upper(
        obstacle.icon,
        obstacle.x + obstacle.w / 2,
        obstacle.y + obstacle.h / 2,
        math.max(obstacle.w, obstacle.h),
        {
          atlas = obstacle.atlas or environment_atlas,
          fraction = obstacle.overlay_fraction or 0.58,
        })
    end
  end
end

return Arena
