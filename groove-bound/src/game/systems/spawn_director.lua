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
  self.next_wave = 1
  self.streams = {}
end

function SpawnDirector:_activate_ready_waves(time)
  while self.waves[self.next_wave] and self.waves[self.next_wave].at <= time do
    local wave = self.waves[self.next_wave]
    if self.on_wave then self.on_wave(self.next_wave, wave) end
    for _, entry in ipairs(wave.enemies) do
      self.streams[#self.streams + 1] = {
        id = entry.id,
        remaining = entry.count,
        cadence = entry.cadence,
        timer = 0,
      }
    end
    self.next_wave = self.next_wave + 1
  end
end

function SpawnDirector:_spawn_position(radius)
  local wall = self.arena.wall + radius + 10
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

function SpawnDirector:update(dt, time, enemy_definitions)
  self:_activate_ready_waves(time)
  local rate = self.tuning:get("enemies.spawn_rate_multiplier")
  local cap = self.tuning:get("enemies.max_active")

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
    if stream.remaining <= 0 then table.remove(self.streams, i) end
  end
end

function SpawnDirector:finished()
  return self.next_wave > #self.waves and #self.streams == 0
end

return SpawnDirector
