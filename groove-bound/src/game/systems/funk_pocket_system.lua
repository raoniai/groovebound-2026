local class = require("src.core.class")

local FunkPocketSystem = class()

local function distance_sq(ax, ay, bx, by)
  local dx, dy = bx - ax, by - ay
  return dx * dx + dy * dy
end

function FunkPocketSystem:init(opts)
  self.definition = assert(opts.definition)
  self.player = assert(opts.player)
  self.time = 0
  self.cycle_index = -1
  self.activated_cycle = -1
  self.boost_remaining = 0
  self.chain = 0
  self.activations = 0
  self.opportunities = 0
  self.best_chain = 0
  self.notice = 0
  self.charge = 0
  self.success_index = nil
  self.reward_text = ""
end

function FunkPocketSystem:update(dt, time)
  self.time = time
  local cycle_seconds = self.definition.cycle_seconds
  local next_cycle = math.floor(time / cycle_seconds)
  if next_cycle ~= self.cycle_index then
    if self.cycle_index >= 0 and self.activated_cycle ~= self.cycle_index then
      self.chain = 0
    end
    self.cycle_index = next_cycle
    self.opportunities = self.opportunities + 1
  end

  local progress = (time % cycle_seconds) / cycle_seconds
  local pad_index = self.cycle_index % #self.definition.pads + 1
  local pad = self.definition.pads[pad_index]
  local active = progress >= 1 - self.definition.active_window
  local inside = distance_sq(self.player.x, self.player.y, pad.x, pad.y)
    <= self.definition.radius ^ 2
  local mechanic_id = self.definition.id
  if mechanic_id == "soul_resonance_reserve" then
    self.charge = inside and math.min(self.definition.charge_seconds,
      self.charge + dt) or math.max(0, self.charge - dt * .7)
    active = self.charge >= self.definition.charge_seconds
  end
  if active and inside and self.activated_cycle ~= self.cycle_index then
    self.activated_cycle = self.cycle_index
    self.activations = self.activations + 1
    self.chain = self.chain + 1
    self.best_chain = math.max(self.best_chain, self.chain)
    self.boost_remaining = self.definition.boost_seconds
    self.notice = 1.25
    self.success_index = pad_index
    if mechanic_id == "soul_resonance_reserve" then
      self.player.hp = math.min(self.player.max_hp,
        self.player.hp + self.player.max_hp * (self.definition.heal_fraction or 0))
      self.charge = 0
      self.reward_text = string.format("RESONANCE HIT  •  +%d%% MAX HP",
        math.floor((self.definition.heal_fraction or 0) * 100 + 0.5))
    elseif mechanic_id == "disco_spotlight_flow" then
      self.reward_text = string.format("SPOTLIGHT HIT  •  SPEED ×%.2f FOR %.1fs",
        self.definition.boost_multiplier, self.definition.boost_seconds)
    elseif mechanic_id == "jazz_improvisation" then
      self.reward_text = string.format("BLUE NOTE  •  IMPROVISE ×%.2f FOR %.1fs",
        self.definition.boost_multiplier, self.definition.boost_seconds)
    else
      self.reward_text = string.format("DOWNBEAT HIT  •  SPEED ×%.2f FOR %.1fs",
        self.definition.boost_multiplier, self.definition.boost_seconds)
    end
  end

  self.boost_remaining = math.max(0, self.boost_remaining - dt)
  self.notice = math.max(0, self.notice - dt)
  self.player.world_speed_multiplier = self.boost_remaining > 0
    and self.definition.boost_multiplier or 1
end

function FunkPocketSystem:snapshot()
  local progress = (self.time % self.definition.cycle_seconds)
    / self.definition.cycle_seconds
  local active_index = self.cycle_index % #self.definition.pads + 1
  local frame = progress >= 1 - self.definition.active_window and 5
    or math.min(4, math.floor(progress * 4) + 1)
  return {
    active_index = active_index,
    frame = frame,
    progress = progress,
    chain = self.chain,
    activations = self.activations,
    opportunities = self.opportunities,
    best_chain = self.best_chain,
    boost_remaining = self.boost_remaining,
    notice = self.notice,
    success_index = self.success_index,
    reward_text = self.reward_text,
    charge = self.charge,
  }
end

return FunkPocketSystem
