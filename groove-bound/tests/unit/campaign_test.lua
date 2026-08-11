local H = require("tests.helpers")
local Arena = require("src.game.arena")
local Content = require("src.content.init")
local Player = require("src.game.entities.player")
local RunContext = require("src.game.run_context")
local CombatSystem = require("src.game.systems.combat_system")
local EnemyProjectile = require("src.game.entities.enemy_projectile")
local Projectile = require("src.game.entities.projectile")
local Tuning = require("src.debug.tuning")
local definitions = require("src.config.admin_controls")

local T = {}

local function fresh(character_id, opts)
  opts = opts or {}
  local tuning = Tuning(definitions)
  local ctx = RunContext({ seed = 123, tuning = tuning })
  local stage = Content.stages[1]
  local arena = Arena({ stage = stage })
  local cx, cy = arena:center()
  local character = Content.characters[character_id or "joe"]
  local player = ctx.world:add("player", Player({
    x = cx, y = cy, tuning = tuning, character = character,
  }))
  local combat = CombatSystem({
    ctx = ctx,
    content = Content,
    tuning = tuning,
    arena = arena,
    player = player,
    character = character,
    mode = opts.mode,
    fresh_world_entry = opts.fresh_world_entry,
  })
  return combat, ctx, player, tuning
end

T["fresh standalone World Tour entries receive bounded starter-build scaling"] = function()
  local assisted = fresh("joe", {
    mode = "world_tour", fresh_world_entry = true,
  })
  local carried = fresh("joe", {
    mode = "world_tour", fresh_world_entry = false,
  })
  local assist = assisted:fresh_entry_factors()
  H.is_true(assist.health < 1)
  H.is_true(assist.damage < 1)
  H.is_true(assist.spawn < 1)
  H.eq(carried:fresh_entry_factors().health, 1)
  H.is_true(assisted:_difficulty_multiplier()
    < carried:_difficulty_multiplier())
end

T["campaign exposes two distinct validated three-minute stages"] = function()
  H.eq(#Content.stages, 2)
  H.eq(Content.stages[1].base_duration, 180)
  H.eq(Content.stages[2].base_duration, 180)
  H.is_true(Content.stages[1].environment_atlas ~= Content.stages[2].environment_atlas)
  H.eq(Content.stages[2].floor_style, "orbit")
  H.eq(Content.stages[2].final_boss, "grand_orchestrator")
  H.eq(#Content.stages[2].waves, 9)
end

T["both campaign arenas are five times larger with varied stage props"] = function()
  local baseline_area = 2000 * 1600
  for _, stage in ipairs(Content.stages) do
    H.eq(stage.width * stage.height, baseline_area * 5)
    H.is_true(stage.width > stage.height)
    H.is_true(#stage.obstacles >= 20)
    H.is_true(#stage.decorations >= 24)
  end

  local stage1_arena = Arena({ stage = Content.stages[1] })
  local stage2_arena = Arena({ stage = Content.stages[2] })
  H.eq(stage1_arena.width, Content.stages[1].width)
  H.eq(stage1_arena.height, Content.stages[1].height)
  H.eq(stage2_arena.width, Content.stages[2].width)
  H.eq(stage2_arena.height, Content.stages[2].height)

  local has_backbeat_tree = false
  for _, decoration in ipairs(Content.stages[1].decorations) do
    if decoration.atlas == "backbeat_expansion"
      and decoration.icon.col == 1
    then
      has_backbeat_tree = true
    end
  end
  H.is_true(has_backbeat_tree)

  local has_orbit_tree = false
  for _, decoration in ipairs(Content.stages[2].decorations) do
    if decoration.atlas == "orbit_expansion"
      and decoration.icon.col == 1
    then
      has_orbit_tree = true
    end
  end
  H.is_true(has_orbit_tree)
end

T["player shots cancel enemy shots and both are consumed"] = function()
  local combat, ctx = fresh("joe")
  local player_shot = Projectile()
  player_shot:reset({
    x = 120, y = 120, dx = 1, dy = 0, speed = 0,
    damage = 12, lifetime = 2, source_weapon_id = "kazoo_pistol",
  })
  local enemy_shot = EnemyProjectile()
  enemy_shot:reset({
    x = 120, y = 120, dx = -1, dy = 0, speed = 0,
    damage = 10, lifetime = 2,
  })
  ctx.world:add("projectile", player_shot)
  ctx.world:add("enemy_projectile", enemy_shot)

  combat:_update_projectiles(0)

  H.is_true(player_shot.dead)
  H.is_true(enemy_shot.dead)
  H.eq(combat.stats.enemy_shots_cancelled, 1)
end

T["shots hit the visible enemy sprite outside its compact body radius"] = function()
  local combat, ctx = fresh("joe")
  local enemy = combat:spawn_enemy(Content.enemies.monotone, 150, 120)
  enemy.x, enemy.y = 150, 120
  ctx.world:moved(enemy)
  local hp = enemy.hp
  local shot = Projectile()
  shot:reset({
    x = 126, y = 120, dx = 1, dy = 0, speed = 0,
    damage = 5, lifetime = 2, source_weapon_id = "kazoo_pistol",
  })
  H.is_true(24 > enemy.body_radius + shot.radius)
  H.is_true(24 < enemy.hurt_radius + shot.radius)
  ctx.world:add("projectile", shot)
  combat:_update_projectiles(0)
  H.is_true(enemy.hp < hp)
end

T["later waves are dense and add shootable ranged pressure"] = function()
  local function authored_count(waves)
    local total = 0
    for _, wave in ipairs(waves) do
      for _, stream in ipairs(wave.enemies) do
        total = total + stream.count
      end
    end
    return total
  end

  H.is_true(authored_count(Content.stages[1].waves) >= 340)
  H.is_true(authored_count(Content.stages[2].waves) >= 360)
  H.eq(Content.enemies.noise_turret.attack_kind, "note_bolt")
  H.is_true(Content.enemies.noise_turret.attack_interval >= 3)
  for _, wave in ipairs(Content.stages[1].waves) do
    for _, stream in ipairs(wave.enemies) do
      if stream.id == "noise_turret" then
        H.is_true(stream.count <= 4)
        H.is_true(stream.cadence >= 3.8)
      end
    end
  end
  H.eq(Content.enemies.keyboard_centipede.attack_kind, "note_bolt")
  H.is_true(Content.enemies.keyboard_centipede.projectile_speed > 0)
end

T["Static Baron telegraphs range and emits visible radial wave projectiles"] = function()
  local combat, ctx, player = fresh("joe")
  local boss = combat:admin_spawn_final_boss()
  boss.x, boss.y = player.x + 160, player.y
  boss.attack_cooldown = 0

  combat:_update_enemies(0.01)
  local threat = combat:boss_threat_snapshot()
  H.eq(threat.boss_id, "static_baron")
  H.is_true(threat.player_in_range)
  H.is_true(threat.windup > 0)
  H.eq(ctx.world:count("enemy_projectile"), 0)

  combat:_update_enemies(Content.enemies.static_baron.windup)
  H.is_true(ctx.world:count("enemy_projectile") >= 12)
end

T["boss pressure increases spawn rate health speed and damage over time"] = function()
  local combat, ctx = fresh("joe")
  combat:admin_spawn_final_boss()
  local initial = combat:boss_pressure_snapshot()
  ctx.time = ctx.time + 45
  local later = combat:boss_pressure_snapshot()
  H.is_true(later.spawn_rate > initial.spawn_rate)
  H.is_true(later.enemy_health > initial.enemy_health)
  H.is_true(later.enemy_speed > initial.enemy_speed)
  H.is_true(later.enemy_damage > initial.enemy_damage)
end

T["final boss death clears combat magnetizes gems and gates progress behind a special chest"] = function()
  local combat, ctx, player = fresh("joe")
  local boss = combat:admin_spawn_final_boss()
  local minion = combat:spawn_enemy(Content.enemies.monotone, player.x + 80, player.y)
  local player_shot = Projectile()
  player_shot:reset({
    x = player.x, y = player.y, dx = 1, dy = 0, speed = 0,
    damage = 1, lifetime = 2, source_weapon_id = "kazoo_pistol",
  })
  local enemy_shot = EnemyProjectile()
  enemy_shot:reset({
    x = player.x, y = player.y, dx = -1, dy = 0, speed = 0,
    damage = 1, lifetime = 2,
  })
  ctx.world:add("projectile", player_shot)
  ctx.world:add("enemy_projectile", enemy_shot)
  boss.hp = 0
  boss.dead = true
  H.is_true(combat:_kill_enemy(boss))
  H.is_true(minion.dead)
  H.is_true(player_shot.dead)
  H.is_true(enemy_shot.dead)
  local gem
  ctx.world:each("xp_gem", function(value) gem = value end)
  H.is_true(gem ~= nil)
  H.is_true(gem.magnetized)

  local special
  ctx.world:each("reward_chest", function(chest)
    if chest.special then special = chest end
  end)
  H.is_true(special ~= nil)
  H.is_false(combat.stage_clear_chest_opened)

  special.unlock_delay = 0
  player.x, player.y = special.x, special.y
  H.eq(combat:update(0), "stage_clear")
  H.is_true(combat.stage_clear_chest_opened)
end

T["stage transition carries the complete build and restores some health"] = function()
  local combat, _, player = fresh("joe")
  combat.inventory:level_up("kazoo_pistol")
  player.hp = 20
  local stage2_arena = Arena({ stage = Content.stages[2] })
  combat:begin_stage(2, stage2_arena)
  H.eq(combat.stage_index, 2)
  H.eq(combat.inventory:get("kazoo_pistol").level, 2)
  H.is_true(player.hp > 20)
  H.eq(combat:stage_snapshot(combat.ctx.time).name, "THE ORBIT LINE")
end

T["collected chests queue complete reveal payloads in pickup order"] = function()
  local combat = fresh("joe")
  local first = combat:_open_reward_chest()
  local second = combat:_open_reward_chest()
  H.is_true(#first.rewards >= 1)
  H.eq(first.roll, #first.rewards)
  H.eq(combat:take_pending_chest_reveal(), first)
  H.eq(combat:take_pending_chest_reveal(), second)
  H.is_nil(combat:take_pending_chest_reveal())
end

T["rank-one evolution is impossible until its Admin-only toggle is enabled"] = function()
  local combat, _, _, tuning = fresh("joe")
  local ok, reason = combat:admin_force_evolution()
  H.is_nil(ok)
  H.eq(reason, "rank1_evolution_disabled")
  tuning:set("rewards.admin_rank1_evolution", true)
  H.is_true(combat:admin_force_evolution())
  H.eq(combat.inventory:get_slot(1).id, "brass_barrage")
  H.eq(combat.inventory:get_slot(1).level, 1)
  H.is_true(combat.progression.evolutions[1].admin_bypass)
end

T["Admin clear-stage tool follows the real two-stage outcome path"] = function()
  local combat = fresh("joe")
  H.is_true(combat:admin_clear_stage())
  H.eq(combat:update(0), "stage_clear")
  combat:begin_stage(2, Arena({ stage = Content.stages[2] }))
  H.is_true(combat:admin_clear_stage())
  H.eq(combat:update(0), "victory")
  H.eq(combat.stats.bosses, 2)
end

T["campaign timeout expands with both Admin stage durations"] = function()
  local combat, _, _, tuning = fresh("joe")
  tuning:set("run.stage1_duration", 1200)
  tuning:set("run.stage2_duration", 1200)
  H.eq(combat:_campaign_timeout(), 2700)
end

T["final bosses arrive with thirty seconds remaining at default duration"] = function()
  local stage1 = Content.stages[1]
  local stage2 = Content.stages[2]
  local stage1_boss_at = stage1.waves[#stage1.waves].at
    * stage1.base_duration / stage1.wave_base_duration
  local stage2_boss_at = stage2.waves[#stage2.waves].at
    * stage2.base_duration / stage2.wave_base_duration
  H.eq(stage1.base_duration - stage1_boss_at, 30)
  H.eq(stage2.base_duration - stage2_boss_at, 30)
end

T["stage overtime spawns and triples the final boss without returning defeat"] = function()
  local combat, ctx, player, tuning = fresh("joe")
  tuning:set("player.invincible", true)
  local duration = combat:stage_snapshot(ctx.time).duration
  ctx.time = duration + 1
  combat:_update_overtime()
  H.is_true(combat.overtime_latched)
  H.is_true(combat.final_boss_spawned)
  local boss
  ctx.world:each("enemy", function(enemy)
    if enemy.definition.boss_type == "final" then boss = enemy end
  end)
  H.is_true(boss.overtime_enraged)
  H.eq(boss.overtime_multiplier, 3)
  H.eq(combat:stage_snapshot(ctx.time).overtime, 1)
  player.dead = false
  H.is_nil(combat:update(0))
end

T["temporary damage pickup multiplies weapon output and expires"] = function()
  local combat = fresh("joe")
  local base = combat.weapon_runtime:projectile_snapshot(1).damage
  combat:_apply_pickup("damage")
  combat:_update_buffs(0)
  H.near(combat.weapon_runtime:projectile_snapshot(1).damage, base * 1.5)
  combat:_update_buffs(15)
  H.near(combat.weapon_runtime:projectile_snapshot(1).damage, base)
end

T["five-times test mode expands XP-gem attraction range and pull speed"] = function()
  local combat, _, _, tuning = fresh("joe")
  tuning:set("test.enhanced_mode", true)
  local pickup = combat:pickup_snapshot()
  H.eq(pickup.radius, 900)
  H.eq(pickup.speed, 1800)
end

T["characters start with different weapons and combat stat profiles"] = function()
  local joe = fresh("joe")
  local lyra = fresh("lyra")
  H.eq(joe.inventory:get_slot(1).id, "kazoo_pistol")
  H.eq(lyra.inventory:get_slot(1).id, "keytar_chord")
  H.is_true(joe.player.max_hp > lyra.player.max_hp)
  H.is_true(lyra.player.base_speed > joe.player.base_speed)
end

return T
