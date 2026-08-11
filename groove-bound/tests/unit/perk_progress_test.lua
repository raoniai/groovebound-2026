local H = require("tests.helpers")
local Defaults = require("src.meta.defaults")
local PerkProgress = require("src.meta.perk_progress")
local Content = require("src.content.init")

local T = {}

local function fresh()
  local saves = 0
  local app = {
    active_slot_id = 1,
    slot = Defaults.new_slot(1, "now"),
    content = Content,
    profile_store = {
      save_slot = function() saves = saves + 1 return true end,
    },
  }
  return app, function() return saves end
end

T["perk unlock is idempotent and begins at rank one"] = function()
  local app = fresh()
  H.is_true(PerkProgress.unlock(app.slot, "open_ears", Content))
  H.is_false(PerkProgress.unlock(app.slot, "open_ears", Content))
  H.eq(app.slot.perks.open_ears.rank, 1)
  H.eq(app.slot.perks.open_ears.spent, 0)
end

T["perk purchase validates wallet rank and persists atomically"] = function()
  local app, saves = fresh()
  app.slot.wallet.coins = 900
  PerkProgress.unlock(app.slot, "pocket_drive", Content)
  local ownership = assert(PerkProgress.purchase(app, "pocket_drive"))
  H.eq(ownership.rank, 2)
  H.eq(ownership.spent, 250)
  H.eq(app.slot.wallet.coins, 650)
  H.eq(app.slot.wallet.lifetime_spent, 250)
  H.eq(saves(), 1)
end

T["locked maxed and unaffordable perks cannot be purchased"] = function()
  local app = fresh()
  H.eq(select(2, PerkProgress.purchase(app, "pocket_drive")), "locked")
  PerkProgress.unlock(app.slot, "spotlight_spin", Content)
  H.eq(select(2, PerkProgress.purchase(app, "spotlight_spin")), "max_rank")
  PerkProgress.unlock(app.slot, "pocket_drive", Content)
  H.eq(select(2, PerkProgress.purchase(app, "pocket_drive")), "insufficient_funds")
end

return T
