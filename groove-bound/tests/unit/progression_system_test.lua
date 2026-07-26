local H = require("tests.helpers")
local Content = require("src.content.init")
local RNG = require("src.core.rng")
local Tuning = require("src.debug.tuning")
local definitions = require("src.config.admin_controls")
local ProgressionSystem = require("src.game.systems.progression_system")
local WeaponInventory = require("src.game.systems.weapon_inventory")
local WeaponRuntime = require("src.game.systems.weapon_runtime")

local T = {}

local function fresh(level, seed)
  local tuning = Tuning(definitions)
  local inventory = WeaponInventory(Content)
  assert(inventory:add("kazoo_pistol", level or 1))
  local runtime = WeaponRuntime(Content, tuning)
  runtime:sync(inventory)
  local player = {
    hp = 50,
    max_hp = 100,
    base_max_hp = 100,
    passive_speed_multiplier = 1,
  }
  local progression = ProgressionSystem({
    content = Content,
    inventory = inventory,
    weapon_runtime = runtime,
    player = player,
    rng = RNG.new(seed or 99).loot,
  })
  return progression, inventory, runtime, player
end

T["ten seeded offers contain no duplicate or impossible choices"] = function()
  for seed = 1, 10 do
    local progression, inventory = fresh(1, seed)
    local offer = progression:create_offer()
    local seen = {}
    for _, choice in ipairs(offer) do
      local key = choice.kind .. ":" .. choice.id
      H.is_false(seen[key] == true)
      seen[key] = true
      if choice.kind == "weapon_level" then
        local weapon = inventory:get(choice.id)
        H.is_true(weapon ~= nil)
        H.is_true(weapon.level < Content.weapons[choice.id].max_level)
      elseif choice.kind == "weapon_add" then
        H.is_nil(inventory:get(choice.id))
      end
    end
  end
end

local function find(offer, kind, id)
  for _, choice in ipairs(offer) do
    if choice.kind == kind and (not id or choice.id == id) then return choice end
  end
  return nil
end

T["every offer has three legal and distinct player decisions"] = function()
  local progression = fresh()
  local offer = progression:create_offer()
  H.eq(#offer, 3)
  local seen = {}
  for _, choice in ipairs(offer) do
    local key = choice.kind .. ":" .. choice.id
    H.is_false(seen[key] == true)
    seen[key] = true
  end
  H.is_true(find(offer, "weapon_level", "kazoo_pistol") ~= nil)
end

T["consecutive offers rotate new weapons and supports when alternatives exist"] = function()
  local progression = fresh(1, 31415)
  local first = progression:create_offer()
  local second = progression:create_offer()
  local first_weapon = assert(find(first, "weapon_add"))
  local second_weapon = assert(find(second, "weapon_add"))
  local first_support = assert(find(first, "passive_add"))
  local second_support = assert(find(second, "passive_add"))
  H.is_false(first_weapon.id == second_weapon.id)
  H.is_false(first_support.id == second_support.id)
end

T["offer randomization remains deterministic for the same run seed"] = function()
  local first = fresh(1, 8675309)
  local second = fresh(1, 8675309)
  for _ = 1, 5 do
    local a = first:create_offer()
    local b = second:create_offer()
    for index = 1, 3 do
      H.eq(a[index].kind, b[index].kind)
      H.eq(a[index].id, b[index].id)
    end
  end
end

T["full weapon and support inventories switch offers to owned ranks"] = function()
  local progression = fresh(1, 4242)
  progression:apply({ kind = "weapon_add", id = "bass_drop" })
  progression:apply({ kind = "weapon_add", id = "cymbal_slicer" })
  progression:apply({ kind = "weapon_add", id = "feedback_loop" })
  progression:apply({ kind = "passive_add", id = "breath_control" })
  progression:apply({ kind = "passive_add", id = "quickstep" })
  progression:apply({ kind = "passive_add", id = "encore" })
  progression:apply({ kind = "passive_add", id = "power_amplifier" })

  local offer = progression:create_offer()
  local ranks = 0
  for _, choice in ipairs(offer) do
    H.is_false(choice.kind == "weapon_add")
    H.is_false(choice.kind == "passive_add")
    if choice.kind == "weapon_level" or choice.kind == "passive_level" then
      ranks = ranks + 1
    end
  end
  H.is_true(ranks >= 2)
end

T["fusion reopens both inventories so new items return to offers"] = function()
  local progression, inventory = fresh(10, 5150)
  progression:apply({ kind = "weapon_add", id = "bass_drop" })
  progression:apply({ kind = "weapon_add", id = "cymbal_slicer" })
  progression:apply({ kind = "weapon_add", id = "feedback_loop" })
  progression:apply({ kind = "passive_add", id = "breath_control" })
  progression:apply({ kind = "passive_add", id = "quickstep" })
  progression:apply({ kind = "passive_add", id = "encore" })
  progression:apply({ kind = "passive_add", id = "power_amplifier" })

  progression:apply({ kind = "evolution", id = "kazoo_studio" })
  H.eq(inventory:count(), 4)
  H.eq(inventory.capacity, 5)
  H.eq(progression.passives:count(), 3)
  H.eq(progression.passives.capacity, 4)

  local offer = progression:create_offer()
  H.is_true(find(offer, "weapon_add") ~= nil)
  H.is_true(find(offer, "passive_add") ~= nil)
end

T["weapon upgrade changes the owned weapon and active emitter together"] = function()
  local progression, inventory, runtime = fresh()
  local choice = assert(find(progression:create_offer(), "weapon_level", "kazoo_pistol"))
  progression:apply(choice)
  H.eq(inventory:get("kazoo_pistol").level, 2)
  H.eq(runtime:get(1).weapon_id, "kazoo_pistol")
  H.eq(runtime:get(1).level, 2)
  H.is_true(runtime:assert_consistent(inventory))
end

T["a new weapon occupies a real slot and immediately gains an emitter"] = function()
  local progression, inventory, runtime = fresh()
  progression:apply({
    kind = "weapon_add",
    id = "bass_drop",
  })
  H.eq(inventory:count(), 2)
  H.eq(inventory:get_slot(2).id, "bass_drop")
  H.eq(runtime:get(2).weapon_id, "bass_drop")
end

T["passives respect slots and apply real player/runtime modifiers"] = function()
  local progression, inventory, runtime, player = fresh()
  progression:apply({ kind = "passive_add", id = "quickstep" })
  H.near(player.passive_speed_multiplier, 1.1)
  progression:apply({ kind = "passive_add", id = "encore" })
  H.eq(player.max_hp, 115)
  H.eq(player.hp, 65)
  progression:apply({ kind = "passive_add", id = "breath_control" })
  H.is_true(runtime:get(1).cooldown < Content.weapons.kazoo_pistol.levels[1].cooldown)
  H.is_true(runtime:assert_consistent(inventory))
end

T["new supports change damage fire rate amount magnet health and guard"] = function()
  local progression, _, runtime, player = fresh()
  local baseline = runtime:projectile_snapshot(1)
  progression:apply({ kind = "passive_add", id = "power_amplifier" })
  progression:apply({ kind = "passive_add", id = "overdrive_pedal" })
  progression:apply({ kind = "passive_add", id = "echo_chamber" })
  progression:apply({ kind = "passive_add", id = "safety_vest" })
  local enhanced = runtime:projectile_snapshot(1)
  H.is_true(enhanced.damage > baseline.damage)
  H.is_true(runtime:get(1).cooldown < Content.weapons.kazoo_pistol.levels[1].cooldown)
  H.eq(enhanced.count, baseline.count + 1)
  H.eq(player.guard, 12)
  H.eq(progression:passive_bonus("guard"), 12)

  local magnet_progression = fresh()
  magnet_progression:apply({ kind = "passive_add", id = "pickup_magnet" })
  H.near(magnet_progression:passive_bonus("magnet"), 0.20)
end

T["a rank-ten weapon and its paired support expose a fusion card"] = function()
  local progression = fresh(10)
  progression:apply({ kind = "passive_add", id = "breath_control" })
  local offer = progression:create_offer()
  H.is_true(find(offer, "evolution", "kazoo_studio") ~= nil)
end

T["evolution progress reports every missing ingredient explicitly"] = function()
  local progression = fresh(4)
  local progress = progression:evolution_progress()
  H.eq(#progress, 1)
  H.eq(progress[1].base.id, "kazoo_pistol")
  H.eq(progress[1].result.id, "brass_barrage")
  H.eq(progress[1].support.id, "breath_control")
  H.eq(progress[1].weapon_level, 4)
  H.eq(progress[1].required_weapon_level, 10)
  H.is_false(progress[1].weapon_ready)
  H.is_false(progress[1].support_ready)
  H.is_false(progress[1].eligible)

  progression:apply({ kind = "passive_add", id = "breath_control" })
  progress = progression:evolution_progress()
  H.is_true(progress[1].support_ready)
  H.is_false(progress[1].weapon_ready)
end

T["fusion readiness raises an explicit player-facing notification"] = function()
  local progression = fresh(10)
  progression:apply({ kind = "passive_add", id = "breath_control" })
  progression:update(0.1)
  H.is_true(progression.evolution_notice > 0)
  H.is_true(
    progression.evolution_notice_text:find("YOU CAN EVOLVE NOW", 1, true) ~= nil)
end

T["evolution replaces the exact firing slot and preserves shots in flight"] = function()
  local progression, inventory, runtime = fresh(10)
  progression:apply({ kind = "passive_add", id = "breath_control" })
  local old_shot = runtime:projectile_snapshot(1)
  progression:apply({ kind = "evolution", id = "kazoo_studio" })
  H.eq(inventory:get_slot(1).id, "brass_barrage")
  H.eq(runtime:get(1).weapon_id, "brass_barrage")
  H.eq(old_shot.source_weapon_id, "kazoo_pistol")
  H.is_nil(progression.passives:get("breath_control"))
  H.eq(progression.passives:count(), 0)
  H.eq(inventory.capacity, 5)
  H.eq(progression.evolutions[1].branch, "fusion")
end

T["reroll is finite and skip returns a bounded reward"] = function()
  local progression = fresh()
  assert(progression:create_offer())
  H.is_true(progression:reroll() ~= nil)
  local offer, reason = progression:reroll()
  H.is_nil(offer)
  H.eq(reason, "no_rerolls")
  H.eq(progression:skip(), 5)
  H.eq(progression.coins, 5)
end

T["progression snapshot serializes only stable ids and run values"] = function()
  local json = require("lib.json")
  local progression = fresh()
  progression:apply({ kind = "weapon_add", id = "bass_drop" })
  progression:apply({ kind = "passive_add", id = "breath_control" })
  local encoded = json.encode(progression:snapshot())
  H.is_true(encoded:find("bass_drop", 1, true) ~= nil)
  H.is_true(encoded:find("breath_control", 1, true) ~= nil)
  H.is_false(encoded:find("Bass Drop", 1, true) ~= nil)
end

return T
