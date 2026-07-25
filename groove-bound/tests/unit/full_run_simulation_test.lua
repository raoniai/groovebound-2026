local H = require("tests.helpers")
local Arena = require("src.game.arena")
local Content = require("src.content.init")
local Player = require("src.game.entities.player")
local RunContext = require("src.game.run_context")
local CombatSystem = require("src.game.systems.combat_system")
local Tuning = require("src.debug.tuning")
local definitions = require("src.config.admin_controls")
local settings = require("src.config.settings")

local T = {}

local function choose_progression(combat)
  while combat.xp:has_pending_choice() do
    local offer = combat.progression:create_offer()
    local selected
    local kazoo = combat.inventory:get("kazoo_pistol")
    for _, choice in ipairs(offer) do
      if choice.kind == "evolution" and choice.id == "kazoo_studio" then
        selected = choice
      end
    end
    if not selected and kazoo and kazoo.level < 10 then
      for _, choice in ipairs(offer) do
        if choice.kind == "weapon_level" and choice.id == "kazoo_pistol" then
          selected = choice
        end
      end
    end
    if not selected and not combat.progression.passives:get("breath_control") then
      for _, choice in ipairs(offer) do
        if choice.id == "breath_control" then selected = choice end
      end
    end
    combat.progression:apply(selected or offer[1])
    combat.xp:consume_choice()
  end
end

T["seeded complete run reaches fusion evolution and final victory"] = function()
  local tuning = Tuning(definitions)
  tuning:set("player.invincible", true)
  tuning:set("combat.damage_multiplier", 2)
  tuning:set("combat.fire_rate_multiplier", 2)
  tuning:set("pickups.radius_multiplier", 5)
  local ctx = RunContext({ seed = 424242, tuning = tuning })
  local arena = Arena()
  local cx, cy = arena:center()
  local player = ctx.world:add("player", Player({
    x = cx, y = cy, tuning = tuning,
  }))
  local combat = CombatSystem({
    ctx = ctx,
    content = Content,
    tuning = tuning,
    arena = arena,
    player = player,
  })

  local outcome
  for _ = 1, math.ceil(settings.run.hard_timeout / 0.05) do
    ctx:update(0.05)
    outcome = combat:update(0.05)
    choose_progression(combat)
    if outcome then break end
  end

  H.eq(outcome, "victory")
  H.eq(combat.stats.minibosses, 1)
  H.eq(combat.stats.bosses, 1)
  H.is_true(combat.stats.kills > 20)
  H.is_true(combat.xp.level >= 10)
  H.eq(combat.inventory:get_slot(1).id, "brass_barrage")
  H.eq(combat.weapon_runtime:get(1).weapon_id, "brass_barrage")
  H.eq(combat.progression.evolutions[1].branch, "fusion")
end

T["player death produces deterministic defeat before timeout"] = function()
  local tuning = Tuning(definitions)
  local ctx = RunContext({ seed = 7, tuning = tuning })
  local arena = Arena()
  local cx, cy = arena:center()
  local player = ctx.world:add("player", Player({
    x = cx, y = cy, tuning = tuning,
  }))
  local combat = CombatSystem({
    ctx = ctx,
    content = Content,
    tuning = tuning,
    arena = arena,
    player = player,
  })
  local lethal = {
    id = "lethal",
    name = "Lethal",
    hp = 999,
    speed = 0,
    size = 20,
    damage = 100,
    xp = 0,
    coins = 0,
    brain = "static",
    color = { 1, 0, 0, 1 },
  }
  combat:spawn_enemy(lethal, player.x, player.y)
  H.eq(combat:update(0.1), "defeat")
end

T["300 enemies plus 150 projectiles stay inside the reference frame budget"] = function()
  local tuning = Tuning(definitions)
  tuning:set("player.invincible", true)
  local ctx = RunContext({ seed = 88, tuning = tuning })
  local arena = Arena()
  local cx, cy = arena:center()
  local player = ctx.world:add("player", Player({
    x = cx, y = cy, tuning = tuning,
  }))
  local combat = CombatSystem({
    ctx = ctx,
    content = Content,
    tuning = tuning,
    arena = arena,
    player = player,
  })
  for index = 1, 300 do
    local angle = index / 300 * math.pi * 2
    local radius = 250 + (index % 8) * 35
    combat:spawn_enemy(
      Content.enemies.monotone,
      cx + math.cos(angle) * radius,
      cy + math.sin(angle) * radius)
  end
  local snapshot = combat.weapon_runtime:projectile_snapshot(1)
  for index = 1, 150 do
    combat:_spawn_projectile(snapshot, index / 150 * math.pi * 2)
  end
  local started = os.clock()
  combat:update(1 / 60)
  local elapsed = os.clock() - started
  H.is_true(elapsed < 0.25, "reference combat frame exceeded 250ms")
  H.is_true(combat.stats.peak_enemies >= 290)
  H.is_true(combat.stats.peak_projectiles >= 150)
end

T["boss rewards cannot be claimed twice"] = function()
  local tuning = Tuning(definitions)
  local ctx = RunContext({ seed = 9, tuning = tuning })
  local arena = Arena()
  local cx, cy = arena:center()
  local player = ctx.world:add("player", Player({
    x = cx, y = cy, tuning = tuning,
  }))
  local combat = CombatSystem({
    ctx = ctx,
    content = Content,
    tuning = tuning,
    arena = arena,
    player = player,
  })
  local boss = combat:spawn_enemy(Content.enemies.metronome_guardian, cx, cy)
  H.is_true(combat:_kill_enemy(boss))
  H.is_false(combat:_kill_enemy(boss))
  H.eq(combat.progression.rerolls, 2)
  H.eq(combat.stats.minibosses, 1)
  H.eq(ctx.world:count("xp_gem"), 1)
end

T["admin evolution preparation creates a legal consumable fusion"] = function()
  local tuning = Tuning(definitions)
  local ctx = RunContext({ seed = 10, tuning = tuning })
  local arena = Arena()
  local cx, cy = arena:center()
  local player = ctx.world:add("player", Player({
    x = cx, y = cy, tuning = tuning,
  }))
  local combat = CombatSystem({
    ctx = ctx,
    content = Content,
    tuning = tuning,
    arena = arena,
    player = player,
  })
  H.is_true(combat:admin_prepare_evolution())
  H.eq(combat.inventory:get("kazoo_pistol").level, 10)
  H.eq(combat.progression.passives:get("breath_control").level, 1)
  H.is_true(combat.xp:has_pending_choice())
  local offer = combat.progression:create_offer()
  local branches = {}
  for _, choice in ipairs(offer) do
    if choice.kind == "evolution" then branches[choice.id] = true end
  end
  H.is_true(branches.kazoo_studio)
end

return T
