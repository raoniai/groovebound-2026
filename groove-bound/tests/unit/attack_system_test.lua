local H = require("tests.helpers")
local Content = require("src.content.init")
local Projectile = require("src.game.entities.projectile")
local Tuning = require("src.debug.tuning")
local definitions = require("src.config.admin_controls")
local WeaponInventory = require("src.game.systems.weapon_inventory")
local WeaponRuntime = require("src.game.systems.weapon_runtime")
local Assets = require("src.assets")

local T = {}

local base_ids = {
  "kazoo_pistol", "bass_drop", "cymbal_slicer", "feedback_loop",
  "drum_circle", "trumpet_burst", "vinyl_scratch", "synth_wave",
  "triangle_tracer", "cello_lance", "maraca_orbit", "tuning_fork",
  "keytar_chord", "bell_tower", "tape_repeater", "laser_harp",
}

local function runtime_for(id, level)
  local inventory = WeaponInventory(Content)
  assert(inventory:add(id, level))
  local runtime = WeaponRuntime(Content, Tuning(definitions))
  runtime:sync(inventory)
  return runtime:projectile_snapshot(1)
end

local function emitter_for(id, level)
  local inventory = WeaponInventory(Content)
  assert(inventory:add(id, level))
  local runtime = WeaponRuntime(Content, Tuning(definitions))
  runtime:sync(inventory)
  return runtime:get(1)
end

T["all 32 attacks own separate five-frame animation strips"] = function()
  local paths = {}
  local count = 0
  for id, weapon in pairs(Content.weapons) do
    count = count + 1
    H.is_true(type(weapon.attack_family) == "string", id)
    H.eq(weapon.visual_id, id)
    H.is_true(weapon.animation_frames >= 5, id)
    H.eq(weapon.animation_mode, "one_shot", id)
    H.eq(weapon.sprite_path, "assets/generated/projectiles/" .. id .. ".png")
    H.is_nil(paths[weapon.sprite_path], "duplicate sprite path")
    paths[weapon.sprite_path] = id
  end
  H.eq(count, 32)
end

T["power attacks leave readable recovery windows"] = function()
  local minimum_cooldowns = {
    laser_harp = 0.75,
    cello_lance = 1.20,
    improvised_solo = 0.95,
    subwoofer_supernova = 1.35,
    orbital_ovation = 0.80,
    thunderhead_ensemble = 1.25,
    golden_fortissimo = 1.10,
    gravity_groove = 1.35,
    velvet_impaler = 1.00,
    resonance_rupture = 1.10,
    stadium_keytar = 1.10,
    cathedral_overdrive = 1.50,
    infinite_mixtape = 1.00,
    aurora_harp = 0.90,
  }
  for id, minimum in pairs(minimum_cooldowns) do
    local weapon = Content.weapons[id]
    local emitter = emitter_for(id, weapon.max_level)
    H.is_true(emitter.cooldown >= minimum,
      id .. " cooldown " .. tostring(emitter.cooldown))
  end
end

T["beam animation charges peaks and ends without looping"] = function()
  local projectile = Projectile()
  local arena = { contains = function() return true end }
  projectile:reset({
    x = 0, y = 0, dx = 1, dy = 0, speed = 0,
    damage = 10, size = 8, lifetime = 2,
    attack_family = "beam", effect_radius = 80, coverage = 600,
    active_duration = 0.75, animation_frames = 5,
    animation_mode = "one_shot",
    source_weapon_id = "laser_harp", visual_id = "laser_harp",
  })
  H.eq(projectile:animation_frame(), 1)
  H.is_false(projectile:is_damage_active())
  projectile:update(0.38, arena)
  H.eq(projectile:animation_frame(), 3)
  H.is_true(projectile:is_damage_active())
  projectile:update(0.30, arena)
  H.eq(projectile:animation_frame(), 5)
  H.is_false(projectile:is_damage_active())
  projectile:update(0.08, arena)
  H.is_true(projectile.dead)
end

T["projectile stage animation advances once from launch to dissipation"] = function()
  local projectile = Projectile()
  local arena = { contains = function() return true end }
  projectile:reset({
    x = 0, y = 0, dx = 1, dy = 0, speed = 100,
    damage = 10, size = 8, lifetime = 1,
    attack_family = "linear", coverage = 1000,
    animation_frames = 5, animation_mode = "one_shot",
    source_weapon_id = "kazoo_pistol",
    visual_id = "kazoo_pistol",
  })
  local frames = { projectile:animation_frame() }
  for _ = 1, 4 do
    projectile:update(0.24, arena)
    frames[#frames + 1] = projectile:animation_frame()
  end
  H.deep_eq(frames, { 1, 2, 3, 4, 5 })
end

T["beam art keeps its authored proportions instead of stretching"] = function()
  local transform = Assets.attack_transform({
    family = "beam", x = 40, y = 50, dx = 1, dy = 0,
    beam_length = 900, beam_width = 34,
    scale_x = 0.97, scale_y = 1.03,
  })
  H.eq(transform.scale_x, transform.scale_y)
  H.eq(transform.x, 490)
  H.eq(transform.y, 50)
end

T["base roster spans the replacement attack categories"] = function()
  local found = {}
  for _, id in ipairs(base_ids) do
    found[Content.weapons[id].attack_family] = true
  end
  for _, family in ipairs({
    "linear", "boomerang", "lobbed_bomb", "area_effect", "orbital",
    "beam", "storm", "wave", "deployable",
  }) do
    H.is_true(found[family], "missing family " .. family)
  end
end

T["every rankable attack expands its protective coverage"] = function()
  local minimum = {
    linear = 560,
    boomerang = 520,
    lobbed_bomb = 480,
    area_effect = 180,
    orbital = 135,
    beam = 520,
    storm = 760,
    wave = 460,
    deployable = 180,
  }
  for _, id in ipairs(base_ids) do
    local first = runtime_for(id, 1)
    local last = runtime_for(id, Content.weapons[id].max_level)
    H.is_true(first.coverage >= minimum[first.attack_family],
      id .. " rank one coverage")
    H.is_true(last.coverage > first.coverage, id .. " rank growth")
    H.is_true(last.effect_scale > first.effect_scale, id .. " effect growth")
  end
end

T["storm evolutions reach across most of the scenario"] = function()
  for _, id in ipairs({ "improvised_solo", "thunderhead_ensemble" }) do
    local attack = runtime_for(id, 1)
    H.eq(attack.attack_family, "storm")
    H.is_true(attack.coverage >= 1000, id)
    H.is_true(attack.max_targets >= 8, id)
  end
end

T["bomb flight resolves into one bounded growing blast"] = function()
  local projectile = Projectile()
  projectile:reset({
    x = 10, y = 20, target_x = 210, target_y = 120,
    dx = 1, dy = 0, speed = 100, damage = 12, size = 8,
    lifetime = 1.2, attack_family = "lobbed_bomb",
    flight_time = 0.4, active_duration = 0.3, effect_radius = 110,
    source_weapon_id = "bass_drop", visual_id = "bass_drop",
  })
  H.is_false(projectile:is_damage_active())
  projectile:update(0.4, { contains = function() return true end })
  H.is_true(projectile:is_damage_active())
  H.eq(projectile.radius, 110)
  H.near(projectile.x, 210)
  H.near(projectile.y, 120)
  projectile:update(0.31, { contains = function() return true end })
  H.is_true(projectile.dead)
end

T["persistent areas use deterministic per-target hit intervals"] = function()
  local projectile = Projectile()
  local enemy = { x = 0, y = 0, radius = 10 }
  projectile:reset({
    x = 0, y = 0, dx = 1, dy = 0, speed = 0,
    damage = 5, size = 8, lifetime = 2,
    attack_family = "area_effect", effect_radius = 130,
    hit_cooldown = 0.5, source_weapon_id = "drum_circle",
    visual_id = "drum_circle",
  })
  H.is_true(projectile:register_hit(enemy))
  H.is_false(projectile:register_hit(enemy))
  projectile:update(0.51, { contains = function() return true end })
  H.is_true(projectile:register_hit(enemy))
  H.is_false(projectile.dead)
end

T["orbitals follow the player at their ranked radius"] = function()
  local player = { x = 100, y = 200 }
  local projectile = Projectile()
  projectile:reset({
    x = player.x, y = player.y, dx = 1, dy = 0, speed = 0,
    damage = 8, size = 10, lifetime = 2,
    attack_family = "orbital", effect_radius = 128, angular_speed = 2,
    orbit_angle = 0, player = player, source_weapon_id = "maraca_orbit",
    visual_id = "maraca_orbit",
  })
  projectile:update(0.5, { contains = function() return true end })
  H.near(projectile.x, player.x + math.cos(1) * 128)
  H.near(projectile.y, player.y + math.sin(1) * 128)
end

T["boomerangs may hit once outbound and once returning"] = function()
  local player = { x = 0, y = 0, radius = 12 }
  local enemy = { x = 20, y = 0, radius = 10 }
  local projectile = Projectile()
  projectile:reset({
    x = 0, y = 0, dx = 1, dy = 0, speed = 100,
    damage = 7, size = 12, lifetime = 2,
    attack_family = "boomerang", return_delay = 0.4,
    player = player, source_weapon_id = "cymbal_slicer",
    visual_id = "cymbal_slicer",
  })
  projectile.x = 20
  H.is_true(projectile:register_hit(enemy))
  H.is_false(projectile:register_hit(enemy))
  projectile.returning = true
  H.is_true(projectile:register_hit(enemy))
  H.is_false(projectile:register_hit(enemy))
  H.is_false(projectile.dead)
end

return T
