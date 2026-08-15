-- Deterministic, cumulative, once-only World Tour reward claims.

local claims = {}
local core = { "funk", "soul", "disco", "jazz", "house", "techno" }
local perks = {
  funk = { C = "pocket_drive", A = "breakstep" },
  soul = { C = "warm_current", A = "velvet_guard" },
  disco = { C = "mirrorball_tips", A = "spotlight_spin" },
  house = { C = "four_count", A = "floor_control" },
  jazz = { C = "live_wire", A = "signal_boost" },
  techno = { C = "precision_loop", A = "hard_reset" },
  cosmic_boogie = { C = "orbital_balance", A = "encore_spark" },
  soulful_garage = { C = "deep_reserve", A = "afterglow" },
  future_funk = { C = "neon_dividend", A = "first_drop" },
}
local all = {
  "funk", "soul", "disco", "jazz", "house", "techno",
  "cosmic_boogie", "soulful_garage", "future_funk",
}

for index, world_id in ipairs(all) do
  claims["world_" .. world_id .. "_first_clear"] = {
    id = "world_" .. world_id .. "_first_clear", world_id = world_id,
    kind = "first_clear", coins = 150,
    unlock_world = core[index + 1],
  }
  for _, grade in ipairs({ "C", "B", "A", "S" }) do
    local id = "world_" .. world_id .. "_grade_" .. grade:lower()
    claims[id] = {
      id = id, world_id = world_id, kind = "grade", grade = grade,
      perk_id = perks[world_id][grade],
      remix_id = grade == "B" and "remix_i" or grade == "S" and "remix_ii" or nil,
      emblem = grade == "S" and "perfect_groove" or nil,
    }
  end
end

claims.prologue_first_clear = {
  id = "prologue_first_clear", kind = "prologue_clear",
  perk_id = "open_ears", unlock_world = "funk", coins = 100,
}

return claims
