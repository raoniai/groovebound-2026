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
end

function RewardChest:update(dt, player)
  self.phase = self.phase + dt
  local dx, dy = player.x - self.x, player.y - self.y
  local collect = player.radius + self.radius + 5
  if dx * dx + dy * dy <= collect * collect then
    self.dead = true
    return true
  end
  return false
end

function RewardChest:draw()
  local frame = math.floor(self.phase * 7.5) % 8 + 1
  local pulse = 1 + math.sin(self.phase * math.pi * 2) * 0.035
  local shine = 0.32 + (math.sin(self.phase * 4.2) + 1) * 0.12

  love.graphics.setColor(1.0, 0.76, 0.22, shine)
  love.graphics.setLineWidth(2)
  love.graphics.circle("line", self.x, self.y, 35 * pulse)
  love.graphics.setLineWidth(1)

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
