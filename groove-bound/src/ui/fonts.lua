-- Cached font registry. Fonts are created once per size and reused;
-- creating fonts inside draw() is banned (it was a per-frame allocation
-- bug in the prototype).

local Fonts = {}

local cache = {}
local font_paths = {
  heading = "assets/fonts/Anton-Regular.ttf",
  body = "assets/fonts/Oswald-Variable.ttf",
}

function Fonts.get(size, role)
  role = role or (size >= 26 and "heading" or "body")
  local key = role .. ":" .. tostring(size)
  local font = cache[key]
  if not font then
    local path = font_paths[role] or font_paths.body
    if love.filesystem.getInfo(path) then
      font = love.graphics.newFont(path, size)
    else
      font = love.graphics.newFont(size)
    end
    cache[key] = font
  end
  return font
end

function Fonts.heading(size)
  return Fonts.get(size, "heading")
end

function Fonts.body(size)
  return Fonts.get(size, "body")
end

function Fonts.clear()
  cache = {}
end

return Fonts
