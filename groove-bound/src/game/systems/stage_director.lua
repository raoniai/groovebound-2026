-- Deterministic phase countdown. It never owns spawning; it describes which
-- stage the absolute run clock is in and emits one transition notice per gate.

local class = require("src.core.class")

local StageDirector = class()

function StageDirector:init(opts)
  self.duration = assert(opts.duration)
  self.count = assert(opts.count)
  self.stage = 1
  self.previous_stage = 1
  self.notice = 0
  self.notice_text = "STAGE 1"
end

function StageDirector:update(dt, time)
  self.notice = math.max(0, self.notice - dt)
  local next_stage = math.min(
    self.count,
    math.floor(time / self.duration) + 1)
  if next_stage > self.stage then
    self.previous_stage = self.stage
    self.stage = next_stage
    self.notice = 3.5
    self.notice_text = "STAGE " .. self.previous_stage
      .. " CLEAR  •  STAGE " .. self.stage
  end
end

function StageDirector:remaining(time)
  if self.stage >= self.count and time >= self.duration * self.count then
    return 0
  end
  local boundary = self.stage * self.duration
  return math.max(0, boundary - time)
end

function StageDirector:snapshot(time)
  return {
    stage = self.stage,
    count = self.count,
    remaining = self:remaining(time),
    notice = self.notice,
    notice_text = self.notice_text,
  }
end

return StageDirector
