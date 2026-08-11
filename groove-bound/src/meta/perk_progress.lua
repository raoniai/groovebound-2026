-- Permanent World Tour perk ownership and purchases.

local PerkProgress = {}

local GRADE_VALUE = { D = 1, C = 2, B = 3, A = 4, S = 5 }

local function ensure_tables(slot)
  slot.perks = slot.perks or {}
  slot.wallet = slot.wallet or { coins = 0, lifetime_earned = 0, lifetime_spent = 0 }
end

function PerkProgress.unlock(slot, perk_id, content)
  ensure_tables(slot)
  local definition = content and content.meta_perks and content.meta_perks[perk_id]
  if not definition then return nil, "unknown_perk" end
  if not slot.perks[perk_id] then
    slot.perks[perk_id] = { rank = 1, spent = 0, balance_revision = definition.balance_revision }
    return true, slot.perks[perk_id]
  end
  return false, slot.perks[perk_id]
end

function PerkProgress.unlock_for_grade(slot, world_id, grade, content)
  local unlocked = {}
  for id, definition in pairs(content.meta_perks or {}) do
    local source = definition.source or {}
    if source.type == "world_grade" and source.world_id == world_id
      and (GRADE_VALUE[grade] or 0) >= (GRADE_VALUE[source.grade] or 99) then
      local did_unlock = PerkProgress.unlock(slot, id, content)
      if did_unlock then unlocked[#unlocked + 1] = id end
    end
  end
  table.sort(unlocked)
  return unlocked
end

function PerkProgress.purchase(app, perk_id)
  local slot = app.slot
  local content = app.content
  if not slot or not content then return nil, "no_campaign" end
  ensure_tables(slot)
  local definition = content.meta_perks and content.meta_perks[perk_id]
  local owned = slot.perks[perk_id]
  if not definition then return nil, "unknown_perk" end
  if not owned then return nil, "locked" end
  if owned.rank >= definition.max_rank then return nil, "max_rank" end
  local next_rank = owned.rank + 1
  local price = definition.prices[next_rank] or 0
  if slot.wallet.coins < price then return nil, "insufficient_funds" end
  slot.wallet.coins = slot.wallet.coins - price
  slot.wallet.lifetime_spent = (slot.wallet.lifetime_spent or 0) + price
  owned.rank = next_rank
  owned.spent = (owned.spent or 0) + price
  owned.balance_revision = definition.balance_revision
  local saved, error_message = app.profile_store:save_slot(app.active_slot_id, slot)
  if not saved then return nil, error_message or "save_failed" end
  return owned
end

return PerkProgress
