-- Single owner for XP thresholds and queued level-up decisions.

local class = require("src.core.class")
local settings = require("src.config.settings")

local XPSystem = class()

function XPSystem:init(opts)
  self.bus = assert(opts.bus)
  self.tuning = assert(opts.tuning)
  self.assets = opts.assets
  self.level = 1
  self.xp = 0
  self.total_xp = 0
  self.pending_choices = 0
  self.notification = 0
end

function XPSystem:required_for(level)
  return settings.xp.first_level + (level - 1) * settings.xp.per_level
end

function XPSystem:add(raw_value)
  local value = math.max(0, raw_value * self.tuning:get("rewards.xp_multiplier"))
  self.xp = self.xp + value
  self.total_xp = self.total_xp + value
  local levels_gained = 0

  while self.xp >= self:required_for(self.level) do
    self.xp = self.xp - self:required_for(self.level)
    self.level = self.level + 1
    levels_gained = levels_gained + 1

    self.pending_choices = self.pending_choices + 1
    self.bus:emit("PLAYER_LEVEL_UP", {
      level = self.level,
      pending_choices = self.pending_choices,
    })
  end

  if levels_gained > 0 then
    self.notification = 1.4
    if self.assets then self.assets:play("level_up", 0.1) end
  end
  return levels_gained
end

function XPSystem:has_pending_choice()
  return self.pending_choices > 0
end

function XPSystem:consume_choice()
  assert(self.pending_choices > 0, "no pending level-up choice")
  self.pending_choices = self.pending_choices - 1
  return self.pending_choices
end

function XPSystem:update(dt)
  self.notification = math.max(0, self.notification - dt)
end

function XPSystem:progress()
  return self.xp / self:required_for(self.level)
end

return XPSystem
