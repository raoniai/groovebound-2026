local class = require("src.core.class")

local RewardChest = class()

function RewardChest:init()
  self.dead = true
end

function RewardChest:reset(opts)
  self.kind = "reward_chest"
  self.assets = opts.assets
  self.x, self.y = opts.x, opts.y
  self.radius = 24
  self.dead = false
  self.phase = opts.phase or 0
  self.special = opts.special == true
  self.unlock_delay = opts.unlock_delay or 0
end

function RewardChest:update(dt, player)
  self.phase = self.phase + dt
  self.unlock_delay = math.max(0, self.unlock_delay - dt)
  local dx, dy = player.x - self.x, player.y - self.y
  local collect = player.radius + self.radius + 5
  if self.unlock_delay <= 0 and dx * dx + dy * dy <= collect * collect then
    self.dead = true
    return true
  end
  return false
end

function RewardChest:draw()
  local frame = math.floor(self.phase * 7.5) % 8 + 1
  local pulse = 1 + math.sin(self.phase * math.pi * 2) * 0.035
  local shine = 0.32 + (math.sin(self.phase * 4.2) + 1) * 0.12

  local special_pulse = self.special and (1.12 + math.sin(self.phase * 5) * 0.10) or 1
  love.graphics.setColor(
    self.special and 0.24 or 1.0,
    self.special and 0.94 or 0.76,
    self.special and 1.0 or 0.22,
    self.special and 0.72 or shine)
  love.graphics.setLineWidth(2)
  love.graphics.circle("line", self.x, self.y, 35 * pulse * special_pulse)
  love.graphics.setLineWidth(1)

  if self.special and self.assets and self.assets.draw_stage_clear_chest then
    self.assets:draw_stage_clear_chest(
      self.x, self.y, 108 * pulse * special_pulse,
      { rotation = math.sin(self.phase * 1.7) * 0.025 })
    return
  end
  if self.assets and self.assets.draw_reward_chest then
    self.assets:draw_reward_chest(frame, self.x, self.y, 78 * pulse)
    return
  end

  love.graphics.setColor(0.34, 0.12, 0.56, 1)
  love.graphics.rectangle("fill", self.x - 24, self.y - 17, 48, 34, 5, 5)
  love.graphics.setColor(1.0, 0.74, 0.20, 1)
  love.graphics.rectangle("line", self.x - 24, self.y - 17, 48, 34, 5, 5)
  love.graphics.circle("fill", self.x, self.y, 4)
end

return RewardChest
