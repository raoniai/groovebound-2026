local H = require("tests.helpers")
local Content = require("src.content.init")
local RNG = require("src.core.rng")
local Tuning = require("src.debug.tuning")
local definitions = require("src.config.admin_controls")
local ProgressionSystem = require("src.game.systems.progression_system")
local WeaponCatalog = require("src.game.systems.weapon_catalog")
local WeaponInventory = require("src.game.systems.weapon_inventory")
local WeaponRuntime = require("src.game.systems.weapon_runtime")

local T = {}

local function live_run(level)
  local tuning = Tuning(definitions)
  local inventory = WeaponInventory(Content)
  assert(inventory:add("kazoo_pistol", level or 1))
  local runtime = WeaponRuntime(Content, tuning)
  runtime:sync(inventory)
  local progression = ProgressionSystem({
    content = Content,
    inventory = inventory,
    weapon_runtime = runtime,
    player = {
      hp = 100,
      max_hp = 100,
      base_max_hp = 100,
      passive_speed_multiplier = 1,
    },
    rng = RNG.new(7226).loot,
  })
  return {
    combat = {
      inventory = inventory,
      weapon_runtime = runtime,
      progression = progression,
    },
  }
end

T["database exposes sixteen base weapons and sixteen evolutions"] = function()
  local catalog = WeaponCatalog(Content)
  local counts = catalog:counts()
  H.eq(counts.all, 32)
  H.eq(counts.base, 16)
  H.eq(counts.evolved, 16)
  H.eq(counts.supports, 8)
  H.eq(counts.owned, 0)
  H.eq(counts.level_up, 16)
end

T["support database exposes stats ownership and fusion pairings"] = function()
  local catalog = WeaponCatalog(Content)
  local supports = catalog:list(nil, "supports")
  H.eq(#supports, 8)
  local breath = catalog:support_entry("breath_control")
  H.eq(breath.definition.stat, "cooldown_stability")
  H.eq(breath.recipes[1].result.id, "brass_barrage")
  H.eq(breath.status, "LEVEL-UP POOL")
end

T["every database entry has a valid atlas icon and complete rank data"] = function()
  local catalog = WeaponCatalog(Content)
  for _, entry in ipairs(catalog:list()) do
    H.is_true(entry.icon.col >= 1 and entry.icon.col <= 4)
    H.is_true(entry.icon.row >= 1 and entry.icon.row <= 2)
    H.eq(entry.first, entry.definition.levels[1])
    H.eq(entry.maximum, entry.definition.levels[entry.definition.max_level])
    H.is_true(entry.definition.role ~= nil)
    H.is_true(entry.definition.pattern ~= nil)
    H.is_true(entry.definition.projectile_color ~= nil)
  end
end

T["catalog cross-checks owned weapons against the active firing emitter"] = function()
  local catalog = WeaponCatalog(Content)
  local run = live_run(1)
  local kazoo = catalog:entry("kazoo_pistol", run)
  H.is_true(kazoo.owned)
  H.is_true(kazoo.active)
  H.eq(kazoo.slot, 1)
  H.eq(kazoo.level, 1)
  H.eq(kazoo.status, "ACTIVE")

  run.combat.weapon_runtime.emitters[1].weapon_id = "bass_drop"
  kazoo = catalog:entry("kazoo_pistol", run)
  H.is_true(kazoo.owned)
  H.is_false(kazoo.active)
  H.eq(kazoo.status, "OWNED")
end

T["unowned weapons leave the level-up pool when all slots are occupied"] = function()
  local catalog = WeaponCatalog(Content)
  local run = live_run(1)
  assert(run.combat.inventory:add("bass_drop", 1))
  assert(run.combat.inventory:add("cymbal_slicer", 1))
  assert(run.combat.inventory:add("feedback_loop", 1))
  run.combat.weapon_runtime:sync(run.combat.inventory)

  local synth = catalog:entry("synth_wave", run)
  H.is_false(synth.available_to_offer)
  H.is_false(synth.in_level_pool)
  H.eq(synth.status, "SLOTS FULL")
  H.eq(catalog:counts(run).owned, 4)
end

T["fusion eligibility and the evolved emitter are visible in the database"] = function()
  local catalog = WeaponCatalog(Content)
  local run = live_run(10)
  local progression = run.combat.progression
  progression:apply({ kind = "passive_add", id = "breath_control" })

  local studio = catalog:entry("brass_barrage", run)
  H.is_true(studio.evolution_eligible)
  H.eq(studio.status, "EVOLVE NOW")

  progression:apply({ kind = "evolution", id = "kazoo_studio" })
  studio = catalog:entry("brass_barrage", run)
  H.is_true(studio.owned)
  H.is_true(studio.active)
  H.eq(studio.slot, 1)
  H.eq(studio.status, "ACTIVE")
end

T["all base weapon firing snapshots preserve their unique pattern and color"] = function()
  local tuning = Tuning(definitions)
  local inventory = WeaponInventory(Content, { capacity = 16 })
  local expected = {
    kazoo_pistol = "aimed",
    bass_drop = "aimed",
    cymbal_slicer = "aimed",
    feedback_loop = "aimed",
    drum_circle = "radial",
    trumpet_burst = "aimed",
    vinyl_scratch = "cross",
    synth_wave = "wall",
    triangle_tracer = "aimed",
    cello_lance = "aimed",
    maraca_orbit = "spiral",
    tuning_fork = "front_back",
    keytar_chord = "wall",
    bell_tower = "radial",
    tape_repeater = "sideways",
    laser_harp = "aimed",
  }
  for id in pairs(expected) do assert(inventory:add(id, 1)) end
  local runtime = WeaponRuntime(Content, tuning)
  runtime:sync(inventory)
  for slot, instance in ipairs(inventory.slots) do
    local shot = runtime:projectile_snapshot(slot)
    H.eq(shot.pattern, expected[instance.id])
    H.eq(shot.color, Content.weapons[instance.id].projectile_color)
  end
end

return T
