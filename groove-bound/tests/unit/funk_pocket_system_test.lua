local H = require("tests.helpers")
local FunkPocketSystem = require("src.game.systems.funk_pocket_system")

local T = {}

local function fresh()
  local player = { x = 100, y = 100, world_speed_multiplier = 1 }
  local system = FunkPocketSystem({
    player = player,
    definition = {
      cycle_seconds = 2,
      active_window = 0.25,
      boost_seconds = 2.5,
      boost_multiplier = 1.6,
      radius = 40,
      pads = { { x = 100, y = 100 }, { x = 300, y = 100 } },
    },
  })
  return system, player
end

T["Funk pocket locks one deterministic pad per cycle"] = function()
  local system = fresh()
  system:update(0.1, 0.2)
  H.eq(system:snapshot().active_index, 1)
  system:update(0.1, 2.2)
  H.eq(system:snapshot().active_index, 2)
end

T["catching the gold downbeat grants one boost and chain per cycle"] = function()
  local system, player = fresh()
  system:update(0.1, 1.6)
  local snapshot = system:snapshot()
  H.eq(snapshot.activations, 1)
  H.eq(snapshot.chain, 1)
  H.eq(snapshot.best_chain, 1)
  H.near(player.world_speed_multiplier, 1.6)
  system:update(0.1, 1.8)
  H.eq(system:snapshot().activations, 1)
end

T["missing a pocket cycle breaks the chain without random state"] = function()
  local system = fresh()
  system:update(0.1, 1.6)
  system:update(0.1, 2.1)
  system:update(0.1, 4.1)
  H.eq(system:snapshot().chain, 0)
  H.eq(system:snapshot().opportunities, 3)
end

T["Soul resonance charges in place and heals only once per cycle"] = function()
  local player = { x=100, y=100, hp=40, max_hp=100, world_speed_multiplier=1 }
  local system = FunkPocketSystem({ player=player, definition={
    id="soul_resonance_reserve", cycle_seconds=4, active_window=.7,
    charge_seconds=.3, boost_seconds=1, boost_multiplier=1.08,
    heal_fraction=.08, radius=40, pads={{x=100,y=100},{x=300,y=100},{x=500,y=100}},
  } })
  system:update(.15, .15)
  system:update(.15, .30)
  H.eq(system:snapshot().activations, 1)
  H.near(player.hp, 48)
  system:update(.2, .5)
  H.near(player.hp, 48)
end

T["Disco spotlight uses the rotating active pad and grants a flow boost"] = function()
  local player = { x=100, y=100, world_speed_multiplier=1 }
  local system = FunkPocketSystem({ player=player, definition={
    id="disco_spotlight_flow", cycle_seconds=2, active_window=.4,
    boost_seconds=2, boost_multiplier=1.42, radius=45,
    pads={{x=100,y=100},{x=300,y=100},{x=500,y=100}},
  } })
  system:update(.1, 1.7)
  H.eq(system:snapshot().activations, 1)
  H.near(player.world_speed_multiplier, 1.42)
end

T["successful mechanics expose an animated reward alert"] = function()
  local system = fresh()
  system:update(0.1, 1.6)
  local snapshot = system:snapshot()
  H.is_true(snapshot.notice > 0)
  H.eq(snapshot.success_index, 1)
  H.is_true(type(snapshot.reward_text) == "string")
  H.is_true(#snapshot.reward_text > 0)
end

return T
