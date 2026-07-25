-- Cached font registry. Fonts are created once per size and reused;
-- creating fonts inside draw() is banned (it was a per-frame allocation
-- bug in the prototype).

local Fonts = {}

local cache = {}
local legacy_font = "assets/legacy/fonts/m6x11plus.ttf"

function Fonts.get(size)
  local font = cache[size]
  if not font then
    if love.filesystem.getInfo(legacy_font) then
      font = love.graphics.newFont(legacy_font, size)
    else
      font = love.graphics.newFont(size)
    end
    cache[size] = font
  end
  return font
end

function Fonts.clear()
  cache = {}
end

return Fonts
