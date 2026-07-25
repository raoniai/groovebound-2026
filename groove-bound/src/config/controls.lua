-- Input bindings. The input layer translates these into abstract actions
-- (move vector, aim vector, confirm/cancel/pause) — game code never reads
-- key names directly.

local Controls = {
  keyboard = {
    up      = { "w", "up" },
    down    = { "s", "down" },
    left    = { "a", "left" },
    right   = { "d", "right" },
    confirm = { "return", "space" },
    cancel  = { "escape" },
    pause   = { "escape", "p" },
  },

  gamepad = {
    move_x  = "leftx",
    move_y  = "lefty",
    aim_x   = "rightx",
    aim_y   = "righty",
    confirm = "a",
    cancel  = "b",
    pause   = "start",
  },
}

local function copy_array(source)
  local result = {}
  for i, value in ipairs(source) do result[i] = value end
  return result
end

function Controls.bind_keyboard(action, key)
  assert(Controls.keyboard[action], "unknown action: " .. tostring(action))
  for other_action, keys in pairs(Controls.keyboard) do
    if other_action ~= action then
      for _, existing in ipairs(keys) do
        if existing == key then return nil, "key_conflict:" .. other_action end
      end
    end
  end
  Controls.keyboard[action][1] = key
  return true
end

function Controls.snapshot()
  local result = {}
  for action, keys in pairs(Controls.keyboard) do result[action] = copy_array(keys) end
  return result
end

function Controls.apply_saved(saved)
  if type(saved) ~= "table" then return end
  for action, keys in pairs(saved) do
    if Controls.keyboard[action] and type(keys) == "table" and #keys > 0 then
      Controls.keyboard[action] = copy_array(keys)
    end
  end
end

return Controls
