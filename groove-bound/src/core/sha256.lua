-- Small zero-dependency SHA-256 implementation for save-file integrity.
-- LuaJIT's bit library supplies deterministic 32-bit operations in both the
-- headless test runtime and LÖVE 11.5.

local bit = require("bit")
local band, bxor, bnot = bit.band, bit.bxor, bit.bnot
local rshift, ror, tobit = bit.rshift, bit.ror, bit.tobit

local K = {
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
  0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
  0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
  0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
  0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
  0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
  0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
  0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
  0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
  0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
  0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
  0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
  0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
  0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}

local function u32(value)
  value = tobit(value)
  if value < 0 then return value + 4294967296 end
  return value
end

local function digest(message)
  assert(type(message) == "string", "sha256 expects a string")

  local bytes = { message:byte(1, -1) }
  local bit_length = #bytes * 8
  bytes[#bytes + 1] = 0x80
  while #bytes % 64 ~= 56 do bytes[#bytes + 1] = 0 end

  local high = math.floor(bit_length / 4294967296)
  local low = bit_length % 4294967296
  for shift = 24, 0, -8 do bytes[#bytes + 1] = band(rshift(high, shift), 0xff) end
  for shift = 24, 0, -8 do bytes[#bytes + 1] = band(rshift(low, shift), 0xff) end

  local h0, h1, h2, h3 = 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a
  local h4, h5, h6, h7 = 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19

  for offset = 1, #bytes, 64 do
    local w = {}
    for i = 0, 15 do
      local j = offset + i * 4
      w[i + 1] = tobit(bytes[j] * 0x1000000 + bytes[j + 1] * 0x10000
        + bytes[j + 2] * 0x100 + bytes[j + 3])
    end
    for i = 17, 64 do
      local x = w[i - 15]
      local y = w[i - 2]
      local s0 = bxor(ror(x, 7), ror(x, 18), rshift(x, 3))
      local s1 = bxor(ror(y, 17), ror(y, 19), rshift(y, 10))
      w[i] = tobit(w[i - 16] + s0 + w[i - 7] + s1)
    end

    local a, b, c, d = h0, h1, h2, h3
    local e, f, g, h = h4, h5, h6, h7
    for i = 1, 64 do
      local s1 = bxor(ror(e, 6), ror(e, 11), ror(e, 25))
      local choice = bxor(band(e, f), band(bnot(e), g))
      local temp1 = tobit(h + s1 + choice + K[i] + w[i])
      local s0 = bxor(ror(a, 2), ror(a, 13), ror(a, 22))
      local majority = bxor(band(a, b), band(a, c), band(b, c))
      local temp2 = tobit(s0 + majority)
      h, g, f, e = g, f, e, tobit(d + temp1)
      d, c, b, a = c, b, a, tobit(temp1 + temp2)
    end

    h0, h1, h2, h3 = tobit(h0 + a), tobit(h1 + b), tobit(h2 + c), tobit(h3 + d)
    h4, h5, h6, h7 = tobit(h4 + e), tobit(h5 + f), tobit(h6 + g), tobit(h7 + h)
  end

  return string.format("%08x%08x%08x%08x%08x%08x%08x%08x",
    u32(h0), u32(h1), u32(h2), u32(h3), u32(h4), u32(h5), u32(h6), u32(h7))
end

return { digest = digest }
