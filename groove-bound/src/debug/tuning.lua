-- Runtime tuning model used by the development-only admin panel.
--
-- This module has no LÖVE dependency, so bounds, reset behavior, snapshots,
-- and future gameplay integrations can be tested headlessly.

local class = require("src.core.class")

local Tuning = class()

local function clamp(value, minimum, maximum)
  if minimum ~= nil and value < minimum then return minimum end
  if maximum ~= nil and value > maximum then return maximum end
  return value
end

local function round_to_step(value, step)
  if not step or step == 0 then return value end
  local rounded = math.floor(value / step + 0.5) * step
  return math.floor(rounded * 1000000 + 0.5) / 1000000
end

local function normalize(definition, value)
  if definition.value_type == "boolean" then
    assert(type(value) == "boolean", definition.id .. " expects a boolean")
    return value
  end

  assert(type(value) == "number", definition.id .. " expects a number")
  value = round_to_step(value, definition.step)
  value = clamp(value, definition.min, definition.max)
  if definition.value_type == "integer" then
    value = math.floor(value + 0.5)
  end
  return value
end

function Tuning:init(definitions)
  assert(type(definitions) == "table", "tuning definitions are required")
  self.definitions = {}
  self.order = {}
  self.values = {}
  self.revision = 0

  for _, definition in ipairs(definitions) do
    assert(type(definition.id) == "string", "tuning definition needs a stable id")
    assert(not self.definitions[definition.id], "duplicate tuning id: " .. definition.id)
    assert(
      definition.value_type == "number"
        or definition.value_type == "integer"
        or definition.value_type == "boolean",
      "unsupported tuning type for " .. definition.id)

    self.definitions[definition.id] = definition
    self.order[#self.order + 1] = definition
    self.values[definition.id] = normalize(definition, definition.default)
  end
end

function Tuning:list()
  return self.order
end

function Tuning:definition(id)
  return self.definitions[id]
end

function Tuning:get(id)
  assert(self.definitions[id], "unknown tuning id: " .. tostring(id))
  return self.values[id]
end

function Tuning:set(id, value)
  local definition = self.definitions[id]
  assert(definition, "unknown tuning id: " .. tostring(id))
  local normalized = normalize(definition, value)
  if self.values[id] ~= normalized then
    self.values[id] = normalized
    self.revision = self.revision + 1
  end
  return normalized
end

function Tuning:adjust(id, direction)
  local definition = self.definitions[id]
  assert(definition, "unknown tuning id: " .. tostring(id))
  direction = direction >= 0 and 1 or -1

  if definition.value_type == "boolean" then
    return self:set(id, not self.values[id])
  end
  return self:set(id, self.values[id] + definition.step * direction)
end

function Tuning:reset(id)
  local definition = self.definitions[id]
  assert(definition, "unknown tuning id: " .. tostring(id))
  return self:set(id, definition.default)
end

function Tuning:reset_all()
  for _, definition in ipairs(self.order) do
    self:set(definition.id, definition.default)
  end
end

function Tuning:snapshot()
  local result = {}
  for _, definition in ipairs(self.order) do
    result[definition.id] = self.values[definition.id]
  end
  return result
end

function Tuning:format(id)
  local definition = assert(self.definitions[id], "unknown tuning id: " .. tostring(id))
  local value = self.values[id]
  if definition.value_type == "boolean" then
    return value and "ON" or "OFF"
  end
  if definition.value_type == "integer" then
    if id == "beat.bpm_override" and value == 0 then return "TRACK" end
    return tostring(value)
  end
  return string.format("%." .. tostring(definition.decimals or 2) .. "f×", value)
end

return Tuning
