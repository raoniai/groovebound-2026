local class = require("src.core.class")

local WorldMechanicSystem = class()

local function distance_sq(ax, ay, bx, by)
  local dx, dy = bx - ax, by - ay
  return dx * dx + dy * dy
end

local reward_labels = {
  funk_hold_the_pocket = "POCKET LOCK",
  soul_resonance_reserve = "RESONANCE BANKED",
  disco_spotlight_flow = "SPOTLIGHT FLOW",
  jazz_improvisation = "PHRASE LANDED",
}

function WorldMechanicSystem:init(opts)
  self.definition = assert(opts.definition)
  self.player = assert(opts.player)
  self.combat = opts.combat
  self.time = 0
  self.cycle_index = -1
  self.activated_cycle = -1
  self.boost_remaining = 0
  self.encore_remaining = 0
  self.chain = 0
  self.activations = 0
  self.opportunities = 0
  self.best_chain = 0
  self.encores = 0
  self.notice = 0
  self.charge = 0
  self.flow = 0
  self.success_index = nil
  self.reward_text = ""
end

function WorldMechanicSystem:_inside(index)
  local pad = self.definition.pads[index]
  return pad and distance_sq(self.player.x, self.player.y, pad.x, pad.y)
    <= self.definition.radius ^ 2
end

function WorldMechanicSystem:_apply_effects()
  local definition = self.definition
  self.player.world_speed_multiplier = self.boost_remaining > 0
    and definition.boost_multiplier or 1
  if self.combat and self.combat.set_world_mechanic_effects then
    self.combat:set_world_mechanic_effects({
      damage = self.boost_remaining > 0 and (definition.damage_multiplier or 1) or 1,
      cadence = self.boost_remaining > 0 and (definition.cadence_multiplier or 1) or 1,
      encore = self.encore_remaining > 0,
      boss_break = definition.boss_break or 0,
    })
  end
end

function WorldMechanicSystem:_succeed(index)
  local definition = self.definition
  self.activated_cycle = self.cycle_index
  self.activations = self.activations + 1
  self.chain = self.chain + 1
  self.best_chain = math.max(self.best_chain, self.chain)
  self.boost_remaining = definition.boost_seconds
  self.notice = 1.35
  self.success_index = index

  if definition.heal_fraction and definition.heal_fraction > 0 then
    local heal = self.player.max_hp * definition.heal_fraction
    local missing = math.max(0, self.player.max_hp - self.player.hp)
    self.player.hp = math.min(self.player.max_hp, self.player.hp + heal)
    local overflow = math.max(0, heal - missing)
    if overflow > 0 and definition.guard_fraction then
      local cap = self.player.max_hp * definition.guard_fraction
      self.player.guard = math.min(cap, (self.player.guard or 0) + overflow)
    end
    self.charge = 0
  end

  local threshold = definition.encore_threshold or 4
  if self.chain > 0 and self.chain % threshold == 0 then
    self.encores = self.encores + 1
    self.encore_remaining = definition.encore_seconds or 5
  end
  local label = reward_labels[definition.id] or "GROOVE HIT"
  self.reward_text = string.format("%s  •  CHAIN ×%d%s", label, self.chain,
    self.encore_remaining > 0 and "  •  ENCORE" or "")
end

function WorldMechanicSystem:update(dt, time)
  self.time = time
  local definition = self.definition
  local cycle_seconds = definition.cycle_seconds
  local next_cycle = math.floor(time / cycle_seconds)
  if next_cycle ~= self.cycle_index then
    if self.cycle_index >= 0 and self.activated_cycle ~= self.cycle_index then
      self.chain = 0
    end
    self.cycle_index = next_cycle
    self.opportunities = self.opportunities + 1
  end

  local progress = (time % cycle_seconds) / cycle_seconds
  local pad_index = self.cycle_index % #definition.pads + 1
  local response_index = pad_index % #definition.pads + 1
  local active = progress >= 1 - definition.active_window
  local inside = self:_inside(pad_index)
  local explicit_kind = definition.kind ~= nil
  local kind = definition.kind
    or definition.id == "soul_resonance_reserve" and "charge"
    or definition.id == "disco_spotlight_flow" and "flow"
    or definition.id == "jazz_improvisation" and "phrase"
    or "timed_zone"

  if kind == "charge" then
    self.charge = inside and math.min(definition.charge_seconds,
      self.charge + dt) or math.max(0, self.charge - dt * .7)
    active = self.charge >= definition.charge_seconds
  elseif kind == "call_response" then
    if self.charge < definition.charge_seconds then
      self.charge = inside and math.min(definition.charge_seconds,
        self.charge + dt) or math.max(0, self.charge - dt * .7)
      active = false
    else
      inside = self:_inside(response_index)
      active = progress >= 1 - definition.active_window
      pad_index = response_index
    end
  elseif kind == "flow" or kind == "prism_relay" then
    local gain = kind == "prism_relay" and 1.35 or 1
    self.flow = inside and math.min(1, self.flow + dt * gain)
      or math.max(0, self.flow - dt * .35)
    active = active and self.flow >= (definition.flow_threshold
      or explicit_kind and .30 or .05)
  elseif kind == "changes" then
    local window = definition.active_window
      * (self.cycle_index % 2 == 0 and 1 or .72)
    active = progress >= 1 - window
  end

  if active and inside and self.activated_cycle ~= self.cycle_index then
    self:_succeed(pad_index)
  end

  self.boost_remaining = math.max(0, self.boost_remaining - dt)
  self.encore_remaining = math.max(0, self.encore_remaining - dt)
  self.notice = math.max(0, self.notice - dt)
  self:_apply_effects()
end

function WorldMechanicSystem:snapshot()
  local definition = self.definition
  local progress = (self.time % definition.cycle_seconds)
    / definition.cycle_seconds
  local active_index = self.cycle_index % #definition.pads + 1
  if definition.kind == "call_response"
    and self.charge >= definition.charge_seconds
  then
    active_index = active_index % #definition.pads + 1
  end
  local frame = progress >= 1 - definition.active_window and 5
    or math.min(4, math.floor(progress * 4) + 1)
  return {
    mechanic_id = definition.id,
    stage_variant = definition.stage_variant,
    active_index = active_index,
    frame = frame,
    progress = progress,
    chain = self.chain,
    activations = self.activations,
    opportunities = self.opportunities,
    best_chain = self.best_chain,
    encores = self.encores,
    encore_remaining = self.encore_remaining,
    boost_remaining = self.boost_remaining,
    notice = self.notice,
    success_index = self.success_index,
    reward_text = self.reward_text,
    charge = self.charge,
    flow = self.flow,
  }
end

return WorldMechanicSystem
