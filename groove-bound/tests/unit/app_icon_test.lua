local H = require("tests.helpers")

local T = {}

local function uint32_be(bytes)
  local a, b, c, d = bytes:byte(1, 4)
  return ((a * 256 + b) * 256 + c) * 256 + d
end

T["application icon is a production-size RGBA PNG wired into LÖVE"] = function()
  local file = assert(io.open(
    "assets/generated/campaign/app-icon.png", "rb"))
  local header = file:read(26)
  file:close()

  H.eq(header:sub(1, 8), "\137PNG\r\n\26\n")
  H.eq(uint32_be(header:sub(17, 20)), 512)
  H.eq(uint32_be(header:sub(21, 24)), 512)
  H.eq(header:byte(26), 6, "PNG color type must be RGBA")

  local love_stub = { conf = nil }
  local previous_love = love
  love = love_stub
  dofile("conf.lua")
  local config = { window = {}, modules = {} }
  love.conf(config)
  love = previous_love
  H.eq(config.window.icon, "assets/generated/campaign/app-icon.png")
end

return T
