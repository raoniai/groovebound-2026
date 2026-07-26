local H = require("tests.helpers")
local Arena = require("src.game.arena")
local Content = require("src.content.init")
local Player = require("src.game.entities.player")
local RunContext = require("src.game.run_context")
local CombatSystem = require("src.game.systems.combat_system")
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

T["campaign exposes two distinct validated ten-minute stages"] = function()
  H.eq(#Content.stages, 2)
  H.eq(Content.stages[1].base_duration, 600)
  H.eq(Content.stages[2].base_duration, 600)
  H.is_true(Content.stages[1].environment_atlas ~= Content.stages[2].environment_atlas)
  H.eq(Content.stages[2].floor_style, "orbit")
  H.eq(Content.stages[2].final_boss, "grand_orchestrator")
  H.eq(#Content.stages[2].waves, 9)
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

T["characters start with different weapons and combat stat profiles"] = function()
  local joe = fresh("joe")
  local lyra = fresh("lyra")
  H.eq(joe.inventory:get_slot(1).id, "kazoo_pistol")
  H.eq(lyra.inventory:get_slot(1).id, "keytar_chord")
  H.is_true(joe.player.max_hp > lyra.player.max_hp)
  H.is_true(lyra.player.base_speed > joe.player.base_speed)
end

return T
