-- Small code-drawn pixel-friendly UI glyphs. Keeping them in one family makes
-- settings, mute, and controller UI visually consistent without emoji fonts.

local Icons = {}

local function line_width(size)
  return math.max(1, math.floor(size / 11))
end

function Icons.draw(kind, x, y, size, color)
  local r = size / 2
  love.graphics.setColor(color or { 1, 1, 1, 1 })
  love.graphics.setLineWidth(line_width(size))

  if kind == "speaker" or kind == "speaker_off" then
    love.graphics.polygon("line",
      x - r, y - r * 0.25,
      x - r * 0.48, y - r * 0.25,
      x + r * 0.05, y - r * 0.70,
      x + r * 0.05, y + r * 0.70,
      x - r * 0.48, y + r * 0.25,
      x - r, y + r * 0.25)
    if kind == "speaker" then
      love.graphics.arc("line", "open", x + r * 0.02, y, r * 0.62,
        -math.pi * 0.34, math.pi * 0.34)
    else
      love.graphics.line(x + r * 0.28, y - r * 0.45,
        x + r * 0.92, y + r * 0.45)
      love.graphics.line(x + r * 0.92, y - r * 0.45,
        x + r * 0.28, y + r * 0.45)
    end
  elseif kind == "music" then
    love.graphics.line(x - r * 0.15, y - r * 0.72,
      x + r * 0.68, y - r * 0.92,
      x + r * 0.68, y + r * 0.40)
    love.graphics.line(x - r * 0.15, y - r * 0.72,
      x - r * 0.15, y + r * 0.62)
    love.graphics.circle("line", x - r * 0.48, y + r * 0.66, r * 0.34)
    love.graphics.circle("line", x + r * 0.35, y + r * 0.42, r * 0.34)
  elseif kind == "wave" then
    love.graphics.line(x - r, y,
      x - r * 0.66, y,
      x - r * 0.42, y - r * 0.68,
      x - r * 0.12, y + r * 0.72,
      x + r * 0.16, y - r * 0.44,
      x + r * 0.42, y + r * 0.26,
      x + r, y + r * 0.26)
  elseif kind == "shake" then
    love.graphics.rectangle("line", x - r * 0.55, y - r * 0.7,
      r * 1.1, r * 1.4, 2, 2)
    love.graphics.line(x - r, y - r * 0.42, x - r * 0.72, y - r * 0.42)
    love.graphics.line(x - r, y + r * 0.42, x - r * 0.72, y + r * 0.42)
    love.graphics.line(x + r * 0.72, y - r * 0.42, x + r, y - r * 0.42)
    love.graphics.line(x + r * 0.72, y + r * 0.42, x + r, y + r * 0.42)
  elseif kind == "flash" then
    love.graphics.polygon("line",
      x + r * 0.12, y - r,
      x - r * 0.56, y + r * 0.06,
      x - r * 0.04, y + r * 0.06,
      x - r * 0.18, y + r,
      x + r * 0.66, y - r * 0.20,
      x + r * 0.12, y - r * 0.20)
  elseif kind == "target" or kind == "aim" or kind == "zoom" then
    love.graphics.circle("line", x, y, r * 0.82)
    love.graphics.circle("line", x, y, r * 0.28)
    love.graphics.line(x - r, y, x - r * 0.58, y)
    love.graphics.line(x + r * 0.58, y, x + r, y)
    love.graphics.line(x, y - r, x, y - r * 0.58)
    love.graphics.line(x, y + r * 0.58, x, y + r)
    if kind == "zoom" then
      love.graphics.line(x + r * 0.58, y + r * 0.58,
        x + r, y + r)
    end
  elseif kind == "health" then
    love.graphics.polygon("line",
      x, y + r * 0.88,
      x - r * 0.86, y,
      x - r * 0.58, y - r * 0.68,
      x, y - r * 0.24,
      x + r * 0.58, y - r * 0.68,
      x + r * 0.86, y)
  elseif kind == "guard" then
    love.graphics.polygon("line",
      x, y - r, x + r * 0.78, y - r * 0.62,
      x + r * 0.62, y + r * 0.42, x, y + r,
      x - r * 0.62, y + r * 0.42, x - r * 0.78, y - r * 0.62)
  elseif kind == "damage" or kind == "score" then
    for index = 0, 7 do
      local a = index * math.pi / 4
      local radius = index % 2 == 0 and r or r * 0.46
      local next_a = a + math.pi / 8
      local next_radius = index % 2 == 0 and r * 0.46 or r
      love.graphics.line(x + math.cos(a) * radius, y + math.sin(a) * radius,
        x + math.cos(next_a) * next_radius, y + math.sin(next_a) * next_radius)
    end
  elseif kind == "cooldown" or kind == "clock" then
    love.graphics.circle("line", x, y, r * 0.86)
    love.graphics.line(x, y, x, y - r * 0.56)
    love.graphics.line(x, y, x + r * 0.44, y + r * 0.20)
  elseif kind == "count" then
    love.graphics.line(x - r * 0.72, y - r * 0.72,
      x + r * 0.72, y + r * 0.72)
    love.graphics.line(x + r * 0.72, y - r * 0.72,
      x - r * 0.72, y + r * 0.72)
  elseif kind == "speed" or kind == "skip" then
    love.graphics.polygon("line",
      x - r * 0.82, y - r * 0.72,
      x + r * 0.16, y,
      x - r * 0.82, y + r * 0.72)
    love.graphics.polygon("line",
      x - r * 0.08, y - r * 0.72,
      x + r * 0.90, y,
      x - r * 0.08, y + r * 0.72)
  elseif kind == "reroll" then
    love.graphics.arc("line", "open", x, y, r * 0.78,
      math.pi * 0.18, math.pi * 1.55)
    love.graphics.polygon("line",
      x + r * 0.22, y - r * 0.92,
      x + r * 0.82, y - r * 0.70,
      x + r * 0.56, y - r * 0.12)
  elseif kind == "combo" then
    love.graphics.line(x - r * 0.82, y + r * 0.50,
      x - r * 0.20, y - r * 0.42,
      x + r * 0.20, y + r * 0.22,
      x + r * 0.82, y - r * 0.64)
    love.graphics.circle("line", x - r * 0.82, y + r * 0.50, r * 0.16)
    love.graphics.circle("line", x + r * 0.82, y - r * 0.64, r * 0.16)
  elseif kind == "stage" or kind == "level" then
    love.graphics.polygon("line",
      x, y - r, x + r * 0.28, y - r * 0.28,
      x + r, y, x + r * 0.28, y + r * 0.28,
      x, y + r, x - r * 0.28, y + r * 0.28,
      x - r, y, x - r * 0.28, y - r * 0.28)
  elseif kind == "chest" then
    love.graphics.rectangle("line", x - r * 0.90, y - r * 0.20,
      r * 1.80, r * 0.95, 2, 2)
    love.graphics.arc("line", "open", x, y - r * 0.16, r * 0.82,
      math.pi, math.pi * 2)
    love.graphics.rectangle("line", x - r * 0.12, y + r * 0.05,
      r * 0.24, r * 0.36)
  elseif kind == "warning" or kind == "critical" then
    love.graphics.polygon("line",
      x, y - r, x + r * 0.90, y + r * 0.82,
      x - r * 0.90, y + r * 0.82)
    love.graphics.line(x, y - r * 0.45, x, y + r * 0.28)
    love.graphics.circle("fill", x, y + r * 0.58, r * 0.08)
  elseif kind == "vibration" then
    love.graphics.rectangle("line", x - r * 0.52, y - r * 0.56,
      r * 1.04, r * 1.12, 4, 4)
    love.graphics.arc("line", "open", x, y, r * 0.86,
      math.pi * 0.72, math.pi * 1.28)
    love.graphics.arc("line", "open", x, y, r * 0.86,
      -math.pi * 0.28, math.pi * 0.28)
  elseif kind == "controller" then
    love.graphics.arc("line", "open", x, y + r * 0.12, r * 0.94,
      math.pi * 1.08, math.pi * 1.92)
    love.graphics.line(x - r * 0.92, y, x - r * 0.72, y + r * 0.72)
    love.graphics.line(x + r * 0.92, y, x + r * 0.72, y + r * 0.72)
    love.graphics.line(x - r * 0.50, y, x - r * 0.16, y)
    love.graphics.line(x - r * 0.33, y - r * 0.17, x - r * 0.33, y + r * 0.17)
    love.graphics.circle("fill", x + r * 0.38, y - r * 0.08, r * 0.09)
    love.graphics.circle("fill", x + r * 0.58, y + r * 0.12, r * 0.09)
  elseif kind == "display" then
    love.graphics.rectangle("line", x - r, y - r * 0.72, size, r * 1.25, 3, 3)
    love.graphics.line(x - r * 0.40, y + r * 0.92,
      x + r * 0.40, y + r * 0.92)
    love.graphics.line(x, y + r * 0.53, x, y + r * 0.92)
  elseif kind == "admin" then
    love.graphics.circle("line", x, y, r * 0.38)
    for index = 0, 7 do
      local angle = index / 8 * math.pi * 2
      love.graphics.line(
        x + math.cos(angle) * r * 0.58,
        y + math.sin(angle) * r * 0.58,
        x + math.cos(angle) * r,
        y + math.sin(angle) * r)
    end
  else
    love.graphics.circle("line", x, y, r * 0.82)
  end
  love.graphics.setLineWidth(1)
end

return Icons
