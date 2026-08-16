-- Activates validated wave streams against the run clock.

local class = require("src.core.class")

local SpawnDirector = class()

function SpawnDirector:init(opts)
  self.waves = assert(opts.waves)
  self.rng = assert(opts.rng)
  self.tuning = assert(opts.tuning)
  self.arena = assert(opts.arena)
  self.count_enemies = assert(opts.count_enemies)
  self.spawn = assert(opts.spawn)
  self.on_wave = opts.on_wave
  self.focus_position = opts.focus_position
  self.spawn_radius_min = opts.spawn_radius_min or 780
  self.spawn_radius_max = opts.spawn_radius_max or 1120
  self.next_wave = 1
  self.active_wave_index = 0
  self.streams = {}
end

function SpawnDirector:_activate_ready_waves(time)
  while self.waves[self.next_wave] and self.waves[self.next_wave].at <= time do
    local wave = self.waves[self.next_wave]
    self.active_wave_index = self.next_wave
    if self.on_wave then self.on_wave(self.next_wave, wave) end
    -- A wave owns the spawn mix until the next scheduled wave replaces it.
    -- This keeps pressure on the player even after the arena is cleared.
    self.streams = {}
    for _, entry in ipairs(wave.enemies) do
      self.streams[#self.streams + 1] = {
        id = entry.id,
        batch_count = entry.count,
        remaining = entry.count,
        cadence = entry.cadence,
        repeats = entry.continuous ~= false,
        timer = 0,
      }
    end
    self.next_wave = self.next_wave + 1
  end
end

function SpawnDirector:_spawn_position(radius)
  local wall = self.arena.wall + radius + 10
  if self.focus_position then
    local focus_x, focus_y = self.focus_position()
    local angle = self.rng:uniform(0, math.pi * 2)
    local distance = self.rng:uniform(
      self.spawn_radius_min, self.spawn_radius_max)
    local x = focus_x + math.cos(angle) * distance
    local y = focus_y + math.sin(angle) * distance
    return math.max(wall, math.min(self.arena.width - wall, x)),
      math.max(wall, math.min(self.arena.height - wall, y))
  end
  local edge = self.rng:range(1, 4)
  if edge == 1 then
    return self.rng:uniform(wall, self.arena.width - wall), wall
  elseif edge == 2 then
    return self.arena.width - wall, self.rng:uniform(wall, self.arena.height - wall)
  elseif edge == 3 then
    return self.rng:uniform(wall, self.arena.width - wall), self.arena.height - wall
  end
  return wall, self.rng:uniform(wall, self.arena.height - wall)
end

function SpawnDirector:update(dt, time, enemy_definitions, escalation_multiplier,
    amount_multiplier)
  self:_activate_ready_waves(time)
  amount_multiplier = amount_multiplier or 1
  local rate = self.tuning:get("enemies.spawn_rate_multiplier")
    * (escalation_multiplier or 1) * amount_multiplier
  local cap = math.max(1, math.floor(
    self.tuning:get("enemies.max_active") * amount_multiplier + 0.5))

  for i = #self.streams, 1, -1 do
    local stream = self.streams[i]
    stream.timer = stream.timer - dt
    local safety = 0
    while stream.remaining > 0
      and stream.timer <= 0
      and self.count_enemies() < cap
      and safety < 8
    do
      local definition = assert(enemy_definitions[stream.id], "unknown enemy " .. stream.id)
      local x, y = self:_spawn_position(definition.size)
      self.spawn(definition, x, y)
      stream.remaining = stream.remaining - 1
      stream.timer = stream.timer + stream.cadence / rate
      safety = safety + 1
    end
    if stream.remaining <= 0 then
      if stream.repeats then
        stream.remaining = stream.batch_count
      else
        table.remove(self.streams, i)
      end
    end
  end
end

function SpawnDirector:finished()
  return self.next_wave > #self.waves and #self.streams == 0
end

return SpawnDirector
