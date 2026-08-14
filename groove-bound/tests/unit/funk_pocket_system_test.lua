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

T["four consecutive mechanic hits trigger one bounded Encore"] = function()
  local player = { x=100, y=100, world_speed_multiplier=1 }
  local effects
  local system = FunkPocketSystem({ player=player, combat={
    set_world_mechanic_effects=function(_, value) effects=value end,
  }, definition={
    id="funk_hold_the_pocket", kind="timed_zone",
    cycle_seconds=1, active_window=.5, boost_seconds=2,
    boost_multiplier=1.2, damage_multiplier=1.16,
    cadence_multiplier=1.18, encore_threshold=4, encore_seconds=5,
    radius=40, pads={{x=100,y=100}},
  } })
  for cycle=0,3 do system:update(.1, cycle + .6) end
  local snapshot = system:snapshot()
  H.eq(snapshot.chain, 4)
  H.eq(snapshot.encores, 1)
  H.is_true(snapshot.encore_remaining > 0)
  H.near(effects.damage, 1.16)
  H.near(effects.cadence, 1.18)
end

T["Soul overflow becomes bounded Guard"] = function()
  local player = {
    x=100, y=100, hp=98, max_hp=100, guard=0, world_speed_multiplier=1,
  }
  local system = FunkPocketSystem({ player=player, definition={
    id="soul_resonance_reserve", kind="charge",
    cycle_seconds=4, active_window=.7, charge_seconds=.2,
    boost_seconds=1, boost_multiplier=1.05, heal_fraction=.08,
    guard_fraction=.18, radius=40, pads={{x=100,y=100}},
  } })
  system:update(.2, .2)
  H.near(player.hp, 100)
  H.near(player.guard, 6)
end

T["Soul Stage 2 charges a call before answering on the next pad"] = function()
  local player = {
    x=100, y=100, hp=80, max_hp=100, guard=0, world_speed_multiplier=1,
  }
  local system = FunkPocketSystem({ player=player, definition={
    id="soul_resonance_reserve", kind="call_response",
    cycle_seconds=2, active_window=.25, charge_seconds=.2,
    boost_seconds=1, boost_multiplier=1.05, heal_fraction=.08,
    guard_fraction=.18, radius=40,
    pads={{x=100,y=100},{x=300,y=100}},
  } })
  system:update(.2, .2)
  H.eq(system:snapshot().activations, 0)
  H.eq(system:snapshot().active_index, 2)
  player.x = 300
  system:update(.1, 1.6)
  H.eq(system:snapshot().activations, 1)
  H.near(player.hp, 88)
end

return T
