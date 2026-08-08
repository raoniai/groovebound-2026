local H = require("tests.helpers")
local Content = require("src.content.init")
local Tuning = require("src.debug.tuning")
local definitions = require("src.config.admin_controls")
local WeaponEvolution = require("src.game.systems.weapon_evolution")
local WeaponInventory = require("src.game.systems.weapon_inventory")
local WeaponRuntime = require("src.game.systems.weapon_runtime")

local T = {}

local function ready_loadout()
  local tuning = Tuning(definitions)
  local inventory = WeaponInventory(Content)
  local weapon = assert(inventory:add("kazoo_pistol", 10))
  local passives = { breath_control = 1 }
  local runtime = WeaponRuntime(Content, tuning)
  runtime:sync(inventory)
  local evolution = WeaponEvolution(Content)
  return evolution, inventory, passives, runtime, tuning, weapon
end

T["eligible recipe requires the exact trigger"] = function()
  local evolution, inventory, passives, runtime = ready_loadout()
  local eligible, reason = evolution:can_evolve(
    "kazoo_studio", inventory, passives, "resolve_reward", runtime)
  H.is_false(eligible)
  H.eq(reason, "wrong_trigger")
  H.deep_eq(
    evolution:eligible(inventory, passives, "level_up", runtime),
    { "kazoo_studio" })
end

T["base weapon must be owned at the recipe level"] = function()
  local evolution, inventory, passives, runtime = ready_loadout()
  inventory:restore({ capacity = 4, revision = 0, slots = {} })
  runtime:sync(inventory)
  local eligible, reason = evolution:can_evolve(
    "kazoo_studio", inventory, passives, "level_up", runtime)
  H.is_false(eligible)
  H.eq(reason, "base_weapon_not_owned")

  assert(inventory:add("kazoo_pistol", 9))
  runtime:sync(inventory)
  eligible, reason = evolution:can_evolve(
    "kazoo_studio", inventory, passives, "level_up", runtime)
  H.is_false(eligible)
  H.eq(reason, "base_weapon_level_too_low")
end

T["all required passives are cross-checked by stable id and level"] = function()
  local evolution, inventory, passives, runtime = ready_loadout()
  passives.breath_control = nil
  local eligible, reason = evolution:can_evolve(
    "kazoo_studio", inventory, passives, "level_up", runtime)
  H.is_false(eligible)
  H.eq(reason, "missing_passive:breath_control")
end

T["evolution replaces the exact inventory slot atomically"] = function()
  local evolution, inventory, passives, runtime = ready_loadout()
  local result = assert(evolution:evolve(
    "kazoo_studio", inventory, passives, "level_up", runtime))
  H.eq(result.slot, 1)
  H.eq(result.old_weapon_id, "kazoo_pistol")
  H.eq(result.new_weapon_id, "brass_barrage")
  H.eq(result.branch, "fusion")
  H.eq(inventory:get_slot(1).id, "brass_barrage")
  H.eq(inventory:get_slot(1).evolved_from, "kazoo_pistol")
  H.eq(inventory:get_slot(1).evolution_id, "kazoo_studio")
  H.eq(inventory:get_slot(1).evolution_branch, "fusion")
  H.eq(inventory.capacity, 5)
  H.is_nil(passives.breath_control)
end

T["fusion capacity expansion respects the six-weapon safety cap"] = function()
  local evolution, inventory, passives, runtime = ready_loadout()
  inventory.capacity = 6
  assert(evolution:evolve(
    "kazoo_studio", inventory, passives, "level_up", runtime))
  H.eq(inventory.capacity, 6)
end

T["the active firing emitter is replaced with the evolved weapon"] = function()
  local evolution, inventory, passives, runtime = ready_loadout()
  assert(evolution:evolve("kazoo_studio", inventory, passives, "level_up", runtime))
  H.eq(runtime:get(1).weapon_id, "brass_barrage")
  H.eq(runtime:get(1).level, 1)
  H.is_true(runtime:assert_consistent(inventory))
end

T["fusion consumes the paired support and keeps the result recognizable"] = function()
  local evolution, inventory, passives, runtime = ready_loadout()
  assert(evolution:evolve("kazoo_studio", inventory, passives, "level_up", runtime))
  H.eq(inventory:get_slot(1).id, "brass_barrage")
  H.eq(inventory:get_slot(1).evolved_from, "kazoo_pistol")
  H.is_nil(passives.breath_control)
  H.eq(runtime:get(1).weapon_id, "brass_barrage")
  H.is_true(runtime:assert_consistent(inventory))
end

T["projectiles already in flight keep their original stat snapshot"] = function()
  local evolution, inventory, passives, runtime = ready_loadout()
  local old_projectile = runtime:projectile_snapshot(1)
  assert(evolution:evolve("kazoo_studio", inventory, passives, "level_up", runtime))
  local new_projectile = runtime:projectile_snapshot(1)
  H.eq(old_projectile.source_weapon_id, "kazoo_pistol")
  H.eq(old_projectile.damage, 28)
  H.eq(new_projectile.source_weapon_id, "brass_barrage")
  H.eq(new_projectile.damage, 42)
  H.eq(old_projectile.source_weapon_id, "kazoo_pistol", "old snapshot must remain unchanged")
end

T["admin projectile controls feed the exact firing snapshot"] = function()
  local _, inventory, _, runtime, tuning = ready_loadout()
  tuning:set("combat.damage_multiplier", 2)
  tuning:set("projectiles.speed_multiplier", 1.5)
  tuning:set("projectiles.per_shot_bonus", 4)
  tuning:set("combat.fire_rate_multiplier", 2)
  runtime:sync(inventory)
  local projectile = runtime:projectile_snapshot(1)
  H.eq(projectile.damage, 56)
  H.eq(projectile.speed, 750)
  H.eq(projectile.count, 7)
  H.eq(projectile.knockback, 8)
  H.near(runtime:get(1).cooldown, 0.215)
end

T["five-times test mode multiplies projectile power"] = function()
  local _, _, _, runtime, tuning = ready_loadout()
  tuning:set("test.enhanced_mode", true)
  local projectile = runtime:projectile_snapshot(1)
  H.eq(projectile.damage, 140)
end

T["evolution is refused when the active firing runtime is stale"] = function()
  local evolution, inventory, passives, runtime = ready_loadout()
  assert(inventory:level_up("kazoo_pistol") == nil) -- already max; revision unchanged
  runtime.emitters[1].weapon_id = "wrong_weapon"
  local eligible, reason = evolution:can_evolve(
    "kazoo_studio", inventory, passives, "level_up", runtime)
  H.is_false(eligible)
  H.eq(reason, "runtime_out_of_sync")
end

T["transaction failure rolls inventory and firing runtime back"] = function()
  local evolution, inventory, passives, runtime = ready_loadout()
  local original_replace = runtime.replace_weapon
  runtime.replace_weapon = function() error("injected runtime failure") end

  local result, reason = evolution:evolve(
    "kazoo_studio", inventory, passives, "level_up", runtime)
  H.is_nil(result)
  H.is_true(reason:find("evolution_transaction_failed", 1, true) ~= nil)
  H.eq(inventory:get_slot(1).id, "kazoo_pistol")
  H.eq(runtime:get(1).weapon_id, "kazoo_pistol")
  H.is_true(runtime:assert_consistent(inventory))
  runtime.replace_weapon = original_replace
end

T["an evolved result cannot be duplicated in another slot"] = function()
  local evolution, inventory, passives, runtime = ready_loadout()
  assert(inventory:add("brass_barrage", 1))
  runtime:sync(inventory)
  local eligible, reason = evolution:can_evolve(
    "kazoo_studio", inventory, passives, "level_up", runtime)
  H.is_false(eligible)
  H.eq(reason, "result_already_owned")
end

return T
