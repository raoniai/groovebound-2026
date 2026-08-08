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

local function fresh(character_id)
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
  })
  return combat, ctx, player, tuning
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
  H.eq(Content.enemies.keyboard_centipede.attack_kind, "note_bolt")
  H.is_true(Content.enemies.keyboard_centipede.projectile_speed > 0)
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
