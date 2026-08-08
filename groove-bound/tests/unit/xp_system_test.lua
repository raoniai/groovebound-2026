local H = require("tests.helpers")
local Content = require("src.content.init")
local EventBus = require("src.core.event_bus")
local Tuning = require("src.debug.tuning")
local definitions = require("src.config.admin_controls")
local WeaponInventory = require("src.game.systems.weapon_inventory")
local WeaponRuntime = require("src.game.systems.weapon_runtime")
local XPSystem = require("src.game.systems.xp_system")

local T = {}

local function fresh()
  local bus = EventBus()
  local tuning = Tuning(definitions)
  local inventory = WeaponInventory(Content)
  assert(inventory:add("kazoo_pistol", 1))
  local runtime = WeaponRuntime(Content, tuning)
  runtime:sync(inventory)
  local xp = XPSystem({
    bus = bus,
    tuning = tuning,
    inventory = inventory,
    weapon_runtime = runtime,
  })
  return xp, bus, tuning, inventory, runtime
end

T["one threshold queues one player decision without mutating a weapon"] = function()
  local xp, bus, _, inventory, runtime = fresh()
  local event
  bus:on("PLAYER_LEVEL_UP", function(data) event = data end)
  H.eq(xp:add(20), 1)
  H.eq(xp.level, 2)
  H.eq(xp.xp, 0)
  H.eq(xp.total_xp, 20)
  H.eq(xp.pending_choices, 1)
  H.eq(inventory:get("kazoo_pistol").level, 1)
  H.eq(runtime:get(1).level, 1)
  H.eq(event.pending_choices, 1)
  H.is_true(runtime:assert_consistent(inventory))
end

T["a large pickup crosses every earned threshold exactly once"] = function()
  local xp, bus, _, inventory, runtime = fresh()
  local events = 0
  bus:on("PLAYER_LEVEL_UP", function() events = events + 1 end)
  H.eq(xp:add(200), 4)
  H.eq(events, 4)
  H.eq(xp.level, 5)
  H.eq(xp.xp, 30)
  H.eq(xp.total_xp, 200)
  H.eq(xp.pending_choices, 4)
  H.eq(inventory:get("kazoo_pistol").level, 1)
  H.eq(runtime:get(1).level, 1)
end

T["XP multiplier affects both current and lifetime XP"] = function()
  local xp, _, tuning = fresh()
  tuning:set("rewards.xp_multiplier", 2)
  H.eq(xp:add(10), 1)
  H.eq(xp.total_xp, 20)
  H.eq(xp.xp, 0)
end

T["five-times test mode multiplies experience gain"] = function()
  local xp, _, tuning = fresh()
  tuning:set("test.enhanced_mode", true)
  xp:add(2)
  H.eq(xp.xp, 10)
  H.eq(xp.total_xp, 10)
end

T["queued choices are consumed exactly once"] = function()
  local xp = fresh()
  xp:add(2000)
  local pending = xp.pending_choices
  H.is_true(pending > 10)
  H.eq(xp:consume_choice(), pending - 1)
  H.eq(xp.pending_choices, pending - 1)
  for _ = 1, pending - 1 do xp:consume_choice() end
  H.is_false(xp:has_pending_choice())
  H.errors(function() xp:consume_choice() end)
end

T["level-up notification expires without changing progress"] = function()
  local xp = fresh()
  xp:add(20)
  H.is_true(xp.notification > 0)
  xp:update(2)
  H.eq(xp.notification, 0)
  H.eq(xp:progress(), 0)
end

return T
