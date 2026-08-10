-- First complete combat vertical slice: spawn, auto-fire, collisions, damage,
-- drops, pickup, progression, pooling, and run outcome.

local class = require("src.core.class")
local Pool = require("src.core.pool")
local Enemy = require("src.game.entities.enemy")
local EnemyProjectile = require("src.game.entities.enemy_projectile")
local Projectile = require("src.game.entities.projectile")
local Pickup = require("src.game.entities.pickup")
local RewardChest = require("src.game.entities.reward_chest")
local XPGem = require("src.game.entities.xp_gem")
local SpawnDirector = require("src.game.systems.spawn_director")
local VFXSystem = require("src.game.systems.vfx_system")
local WeaponInventory = require("src.game.systems.weapon_inventory")
local WeaponRuntime = require("src.game.systems.weapon_runtime")
local XPSystem = require("src.game.systems.xp_system")
local XPRewards = require("src.game.xp_rewards")
local ProgressionSystem = require("src.game.systems.progression_system")
local TestMode = require("src.game.test_mode")
local settings = require("src.config.settings")

local CombatSystem = class()

local function distance_sq(ax, ay, bx, by)
  local dx, dy = bx - ax, by - ay
  return dx * dx + dy * dy
end

local function scaled_waves(stage, duration)
  local scale = duration / stage.wave_base_duration
  local result = {}
  for index, wave in ipairs(stage.waves) do
    result[index] = { at = wave.at * scale, enemies = {} }
    for enemy_index, entry in ipairs(wave.enemies) do
      result[index].enemies[enemy_index] = {
        id = entry.id,
        count = entry.count,
        cadence = entry.cadence,
        continuous = entry.continuous,
      }
    end
  end
  return result
end

function CombatSystem:init(opts)
  self.ctx = assert(opts.ctx)
  self.content = assert(opts.content)
  self.tuning = assert(opts.tuning)
  self.assets = opts.assets
  self.arena = assert(opts.arena)
  self.player = assert(opts.player)
  self.character = opts.character or self.content.characters.joe
  self.camera = opts.camera
  self.options = opts.options or {}

  self.enemy_pool = Pool(function() return Enemy() end)
  self.enemy_projectile_pool = Pool(function() return EnemyProjectile() end)
  self.projectile_pool = Pool(function() return Projectile() end)
  self.gem_pool = Pool(function() return XPGem() end)
  self.pickup_pool = Pool(function() return Pickup() end)
  self.reward_chest_pool = Pool(function() return RewardChest() end)
  self.vfx = VFXSystem(self.assets)

  self.inventory = WeaponInventory(self.content)
  assert(self.inventory:add(self.character.starting_weapon, 1))
  self.weapon_runtime = WeaponRuntime(
    self.content, self.tuning, { character = self.character })
  self.weapon_runtime:sync(self.inventory)
  self.last_tuning_revision = self.tuning.revision

  self.xp = XPSystem({
    bus = self.ctx.bus,
    tuning = self.tuning,
    assets = self.assets,
  })
  self.progression = ProgressionSystem({
    content = self.content,
    inventory = self.inventory,
    weapon_runtime = self.weapon_runtime,
    player = self.player,
    rng = self.ctx.rng.loot,
  })

  self.stats = {
    kills = 0,
    shots = 0,
    enemy_shots_cancelled = 0,
    damage = 0,
    xp = 0,
    coins = 0,
    minibosses = 0,
    bosses = 0,
    damage_by_weapon = {},
    peak_enemies = 0,
    peak_projectiles = 0,
    peak_gems = 0,
    chests_opened = 0,
    chest_rewards = 0,
    score = 0,
    combo = 0,
    max_combo = 0,
  }
  self.last_kill_time = -math.huge
  self.frame_time_ms = 0
  self.final_boss_dead = false
  self.final_boss_spawned = false
  self.final_boss_spawned_at = nil
  self.stage_clear_chest_opened = false
  self.music_final_phase_latched = false
  self.wave_notice = nil
  self.wave_notice_time = 0
  self.pickup_notice = 0
  self.pickup_notice_text = nil
  self.pending_chest_reveals = {}
  self.buffs = { damage = 0, defense = 0, speed = 0 }
  self.stages = self.content.stages
  self.stage_index = 0
  self.stage_started_at = 0
  self.stage_notice = 0
  self.stage_notice_text = nil
  self.stage_clear_reported = false
  self.overtime_latched = false
  self:begin_stage(1, self.arena, true)
end

function CombatSystem:_stage_duration(stage)
  if stage.duration_tuning then return self.tuning:get(stage.duration_tuning) end
  return stage.base_duration
end

function CombatSystem:_campaign_timeout()
  local duration = 0
  for _, stage in ipairs(self.stages) do
    duration = duration + self:_stage_duration(stage)
  end
  return duration + 300
end

function CombatSystem:_make_spawner(stage)
  local duration = self:_stage_duration(stage)
  return SpawnDirector({
    waves = scaled_waves(stage, duration),
    rng = self.ctx.rng.spawn,
    tuning = self.tuning,
    arena = self.arena,
    focus_position = function() return self.player.x, self.player.y end,
    count_enemies = function() return self.ctx.world:count("enemy") end,
    spawn = function(definition, x, y) self:spawn_enemy(definition, x, y) end,
    on_wave = function(index, wave)
      local boss_name
      for _, entry in ipairs(wave.enemies) do
        local definition = self.content.enemies[entry.id]
        if definition.boss_type then boss_name = definition.name break end
      end
      self.wave_notice = boss_name and ("INCOMING: " .. boss_name)
        or ("WAVE " .. index)
      self.wave_notice_time = 2.2
    end,
  })
end

function CombatSystem:begin_stage(index, arena, initial)
  local stage = assert(self.stages[index], "unknown campaign stage")
  self.stage_index = index
  self.stage_started_at = self.ctx.time
  self.stage_clear_reported = false
  self.final_boss_dead = false
  self.final_boss_spawned = false
  self.final_boss_spawned_at = nil
  self.stage_clear_chest_opened = false
  self.overtime_latched = false
  self.music_final_phase_latched = false
  self.arena = assert(arena)
  self.spawner = self:_make_spawner(stage)
  self.vfx:clear()

  if not initial then
    self.ctx.world:each("enemy", function(entity) entity.dead = true end)
    self.ctx.world:each("projectile", function(entity) entity.dead = true end)
    self.ctx.world:each("enemy_projectile", function(entity) entity.dead = true end)
    self.ctx.world:each("xp_gem", function(entity) entity.dead = true end)
    self.ctx.world:each("pickup", function(entity) entity.dead = true end)
    self.ctx.world:each("reward_chest", function(entity) entity.dead = true end)
    self:_release_removed()
    local cx, cy = self.arena:center()
    self.player.x, self.player.y = cx, cy
    self.player.hp = math.min(
      self.player.max_hp,
      self.player.hp + math.floor(self.player.max_hp * 0.25))
    self.player.guard = self.player.guard + 12
    self.stage_notice = 5
    self.stage_notice_text = stage.name .. "  •  BUILD CARRIED FORWARD"
  end
  return stage
end

function CombatSystem:stage_snapshot(time)
  local stage = self.stages[self.stage_index]
  local duration = self:_stage_duration(stage)
  local elapsed = math.max(0, time - self.stage_started_at)
  return {
    stage = self.stage_index,
    count = #self.stages,
    name = stage.name,
    subtitle = stage.subtitle,
    elapsed = elapsed,
    duration = duration,
    remaining = math.max(0, duration - elapsed),
    overtime = math.max(0, elapsed - duration),
    is_overtime = elapsed >= duration,
    notice = self.stage_notice,
    notice_text = self.stage_notice_text,
  }
end

function CombatSystem:music_snapshot()
  local selected
  self.ctx.world:each("enemy", function(enemy)
    if enemy.dead or not enemy.definition.boss_type then return end
    if not selected
      or enemy.definition.boss_type == "final"
      or selected.definition.boss_type ~= "final"
    then
      selected = enemy
    end
  end)
  if not selected then
    return {
      boss_id = nil,
      boss_hp_fraction = nil,
      boss_phase_two = self.music_final_phase_latched,
    }
  end
  local hp_fraction = selected.hp / math.max(1, selected.max_hp)
  if selected.definition.id == "grand_orchestrator" and hp_fraction <= 0.45 then
    self.music_final_phase_latched = true
  end
  return {
    boss_id = selected.definition.id,
    boss_hp_fraction = hp_fraction,
    boss_phase_two = self.music_final_phase_latched,
  }
end

function CombatSystem:_difficulty_multiplier()
  local snapshot = self:stage_snapshot(self.ctx.time)
  local progress = math.min(1, snapshot.elapsed / math.max(1, snapshot.duration))
  local ramp = self.tuning:get("run.difficulty_ramp")
  return 1 + ((self.stage_index - 1) * 0.28 + progress * 0.62) * ramp
end

function CombatSystem:boss_pressure_snapshot()
  local elapsed = self.final_boss_spawned_at
    and math.max(0, self.ctx.time - self.final_boss_spawned_at) or 0
  return {
    elapsed = elapsed,
    spawn_rate = 1 + math.min(1.35, elapsed * 0.018),
    enemy_health = 1 + math.min(1.0, elapsed * 0.012),
    enemy_speed = 1 + math.min(0.70, elapsed * 0.008),
    enemy_damage = 1 + math.min(0.80, elapsed * 0.009),
  }
end

function CombatSystem:boss_threat_snapshot()
  local selected
  self.ctx.world:each("enemy", function(enemy)
    if not enemy.dead and enemy.definition.boss_type == "final" then selected = enemy end
  end)
  if not selected then return { active = false } end
  return {
    active = true,
    boss_id = selected.definition.id,
    name = selected.definition.name,
    player_in_range = selected.target_in_attack_range == true,
    range = selected.definition.attack_range or 0,
    distance = selected.target_distance,
    windup = selected.attack_windup,
  }
end

function CombatSystem:spawn_enemy(definition, x, y)
  if definition.boss_type == "final" and self.final_boss_spawned then
    return nil
  end
  if definition.boss_type == "final" then
    local cx, cy = self.arena:center()
    x, y = cx + 360, cy
  end
  local enemy = self.enemy_pool:acquire({
    definition = definition,
    assets = self.assets,
    options = self.options,
    x = x,
    y = y,
    health_multiplier = self:_difficulty_multiplier()
      * (definition.boss_type and 1 or self:boss_pressure_snapshot().enemy_health),
  })
  if definition.boss_type == "final" then
    self.final_boss_spawned = true
    self.final_boss_spawned_at = self.ctx.time
  end
  return self.ctx.world:add("enemy", enemy)
end

function CombatSystem:_nearest_target()
  local best, best_distance = nil, settings.combat.target_range ^ 2
  self.ctx.world:each("enemy", function(enemy)
    local candidate = distance_sq(self.player.x, self.player.y, enemy.x, enemy.y)
    if candidate < best_distance then
      best, best_distance = enemy, candidate
    end
  end)
  return best
end

function CombatSystem:_spawn_projectile(snapshot, angle)
  if self.ctx.world:count("projectile") >= self.tuning:get("projectiles.max_active") then return end
  local offset = settings.combat.projectile_spawn_offset
  local dx, dy = math.cos(angle), math.sin(angle)
  local projectile = self.projectile_pool:acquire({
    assets = self.assets,
    x = self.player.x + dx * offset,
    y = self.player.y + dy * offset,
    dx = dx,
    dy = dy,
    speed = snapshot.speed,
    damage = snapshot.damage,
    size = snapshot.size,
    lifetime = snapshot.lifetime,
    pierce = snapshot.pierce,
    knockback = snapshot.knockback,
    color = snapshot.color,
    source_weapon_id = snapshot.source_weapon_id,
  })
  self.ctx.world:add("projectile", projectile)
  self.stats.shots = self.stats.shots + 1
end

function CombatSystem:_update_weapons(dt)
  if self.final_boss_dead then return end
  if self.last_tuning_revision ~= self.tuning.revision then
    self.weapon_runtime:sync(self.inventory)
    self.last_tuning_revision = self.tuning.revision
  end

  local target = self:_nearest_target()
  if not target then return end
  local base_angle
  if self.options.aim_assist == false then
    base_angle = math.atan2(self.player.aim_y, self.player.aim_x)
  else
    base_angle = math.atan2(target.y - self.player.y, target.x - self.player.x)
  end

  for slot = 1, self.inventory:count() do
    local emitter = self.weapon_runtime:get(slot)
    emitter.cooldown_remaining = emitter.cooldown_remaining - dt
    local activations = 0
    while emitter.cooldown_remaining <= 0 and activations < 3 do
      local snapshot = self.weapon_runtime:projectile_snapshot(slot)
      local count = snapshot.count
      local spread = math.rad(snapshot.spread or 0)
      for shot = 1, count do
        local angle
        if snapshot.pattern == "radial" then
          angle = (shot - 1) / count * math.pi * 2 + self.ctx.time * 0.35
        elseif snapshot.pattern == "spiral" then
          angle = (shot - 1) / count * math.pi * 2 + self.ctx.time * 2.2
        elseif snapshot.pattern == "cross" then
          local lane = (shot - 1) % 4
          angle = base_angle + lane * math.pi / 2
        elseif snapshot.pattern == "front_back" then
          local lane = (shot - 1) % 2
          local pair = math.floor((shot - 1) / 2)
          angle = base_angle + lane * math.pi + pair * spread
        elseif snapshot.pattern == "sideways" then
          local lane = (shot - 1) % 2
          local pair = math.floor((shot - 1) / 2)
          angle = base_angle + (lane == 0 and -math.pi / 2 or math.pi / 2)
            + pair * spread
        elseif snapshot.pattern == "wall" then
          local offset = (shot - (count + 1) / 2) * spread
          angle = base_angle + offset
        else
          local offset = (shot - (count + 1) / 2) * spread
          angle = base_angle + offset
        end
        self:_spawn_projectile(snapshot, angle)
      end
      emitter.cooldown_remaining = emitter.cooldown_remaining + emitter.cooldown
      activations = activations + 1
      if self.assets then self.assets:play("projectile", 0.055) end
    end
  end
end

function CombatSystem:_spawn_static_wave(enemy, damage_multiplier)
  local count = enemy.definition.projectile_count or 16
  for index = 1, count do
    local angle = (index - 1) / count * math.pi * 2
    self:_spawn_enemy_projectile(enemy, {
      kind = "static_wave",
      dx = math.cos(angle),
      dy = math.sin(angle),
    }, damage_multiplier)
  end
end

function CombatSystem:_spawn_stage_clear_chest(enemy)
  local x, y = enemy.x, enemy.y
  if self.arena.safe_drop_position then
    x, y = self.arena:safe_drop_position(x, y, 32)
  end
  local chest = self.reward_chest_pool:acquire({
    assets = self.assets,
    x = x,
    y = y,
    phase = 0,
    special = true,
    unlock_delay = 1.15,
  })
  self.wave_notice = "STAGE MASTERED  •  COLLECT THE ENCORE CHEST"
  self.wave_notice_time = 6
  return self.ctx.world:add("reward_chest", chest)
end

function CombatSystem:_enter_stage_clear_gate(enemy)
  self.ctx.world:each("enemy", function(value)
    if value ~= enemy then value.dead = true end
  end)
  self.ctx.world:each("projectile", function(value) value.dead = true end)
  self.ctx.world:each("enemy_projectile", function(value) value.dead = true end)
  self.ctx.world:each("xp_gem", function(value) value.magnetized = true end)
  self.ctx.world:each("pickup", function(value) value.magnetized = true end)
  self:_spawn_stage_clear_chest(enemy)
end

function CombatSystem:_kill_enemy(enemy)
  if enemy.rewards_claimed then return false end
  enemy.rewards_claimed = true
  self.stats.kills = self.stats.kills + 1
  if self.ctx.time - self.last_kill_time <= 2.5 then
    self.stats.combo = self.stats.combo + 1
  else
    self.stats.combo = 1
  end
  self.last_kill_time = self.ctx.time
  self.stats.max_combo = math.max(self.stats.max_combo, self.stats.combo)
  self.stats.score = self.stats.score + 100 * self.stats.combo
  self.ctx.bus:emit("ENEMY_KILLED", {
    enemy_id = enemy.id,
    xp = enemy.definition.xp,
  })
  self.stats.coins = self.stats.coins + (enemy.definition.coins or 0)
  if enemy.definition.boss_type == "miniboss" then
    self.stats.minibosses = self.stats.minibosses + 1
    self.progression.rerolls = self.progression.rerolls + 1
    self.ctx.bus:emit("REROLL_GRANTED", {
      source = enemy.id,
      rerolls = self.progression.rerolls,
    })
  elseif enemy.definition.boss_type == "final" then
    self.stats.bosses = self.stats.bosses + 1
    self.final_boss_dead = true
  end
  local reward = math.floor(
    enemy.definition.xp * ((self.character.stats or {}).resonance or 1) + 0.5)
  local drops = XPRewards.split(reward, enemy.definition)
  for index, drop in ipairs(drops) do
    local angle = self.ctx.rng.vfx:uniform(0, math.pi * 2)
    local radius = #drops == 1 and 0
      or (12 + (index % 3) * 7 + self.ctx.rng.vfx:uniform(0, 8))
    local gem = self.gem_pool:acquire({
      assets = self.assets,
      x = enemy.x + math.cos(angle) * radius,
      y = enemy.y + math.sin(angle) * radius,
      value = drop.value,
      tier = drop.tier,
      phase = self.ctx.rng.vfx:uniform(0, math.pi * 2),
    })
    self.ctx.world:add("xp_gem", gem)
  end
  if enemy.definition.boss_type ~= "final" then
    self:_try_spawn_rare_pickup(enemy)
    if not enemy.suppress_reward_chest then self:_try_spawn_reward_chest(enemy) end
  end
  self.vfx:spawn(
    "explosion", enemy.x, enemy.y,
    {
      scale = enemy.definition.boss_type and 0.62 or 0.30,
      duration = enemy.definition.boss_type and 0.72 or 0.44,
    })
  if self.assets then self.assets:play("enemy_death", 0.05) end
  if enemy.definition.boss_type == "final" then
    self:_enter_stage_clear_gate(enemy)
  end
  return true
end

function CombatSystem:_try_spawn_rare_pickup(enemy)
  local chance = enemy.definition.boss_type == "final" and 0.35
    or enemy.definition.boss_type == "miniboss" and 0.16
    or enemy.definition.elite and 0.055
    or 0.018
  if not self.ctx.rng.loot:chance(chance) then return nil end
  local roll = self.ctx.rng.loot:random()
  local kind = roll < 0.46 and "heal"
    or roll < 0.60 and "magnet"
    or roll < 0.74 and "damage"
    or roll < 0.87 and "defense"
    or "speed"
  local pickup = self.pickup_pool:acquire({
    kind = kind,
    assets = self.assets,
    x = enemy.x,
    y = enemy.y,
    phase = self.ctx.rng.vfx:uniform(0, math.pi * 2),
  })
  return self.ctx.world:add("pickup", pickup)
end

function CombatSystem:_try_spawn_reward_chest(enemy)
  local chance = self:reward_chest_chance(enemy)
  if not self.ctx.rng.loot:chance(chance) then return nil end
  local x, y = enemy.x, enemy.y
  if self.arena.safe_drop_position then
    x, y = self.arena:safe_drop_position(x, y, 24)
  end
  local chest = self.reward_chest_pool:acquire({
    assets = self.assets,
    x = x,
    y = y,
    phase = self.ctx.rng.vfx:uniform(0, math.pi * 2),
  })
  self.wave_notice = "RARE DROP  •  MUSICAL CHEST"
  self.wave_notice_time = 3.5
  return self.ctx.world:add("reward_chest", chest)
end

function CombatSystem:reward_chest_chance(enemy)
  return enemy.definition.boss_type == "final" and 0.55
    or enemy.definition.boss_type == "miniboss" and 0.22
    or enemy.definition.elite and 0.075
    or 0.0015
end

function CombatSystem:_roll_chest_reward_count()
  local roll = self.ctx.rng.loot:random()
  if roll < 0.03 then return 5 end
  if roll < 0.20 then return 3 end
  return 1
end

function CombatSystem:_open_reward_chest()
  local rolled = self:_roll_chest_reward_count()
  local rewards = self.progression:claim_chest(rolled)
  self.stats.chests_opened = self.stats.chests_opened + 1
  self.stats.chest_rewards = self.stats.chest_rewards + #rewards
  self.pickup_notice = 6
  self.pickup_notice_text = "CHEST ROLL ×" .. rolled
    .. "  •  " .. #rewards .. " REWARD" .. (#rewards == 1 and "" or "S")
  self.pending_chest_reveals[#self.pending_chest_reveals + 1] = {
    roll = rolled,
    rewards = rewards,
  }
  if self.assets then self.assets:play("level_up", 0.12) end
  return self.pending_chest_reveals[#self.pending_chest_reveals]
end

function CombatSystem:take_pending_chest_reveal()
  if #self.pending_chest_reveals == 0 then return nil end
  return table.remove(self.pending_chest_reveals, 1)
end

function CombatSystem:_apply_pickup(kind)
  if kind == "heal" then
    local amount = self.player.max_hp * 0.25
    self.player.hp = math.min(self.player.max_hp, self.player.hp + amount)
    self.pickup_notice_text = "RARE DROP  •  +25% HEALTH"
  elseif kind == "magnet" then
    self.ctx.world:each("xp_gem", function(gem) gem.magnetized = true end)
    self.ctx.world:each("pickup", function(pickup) pickup.magnetized = true end)
    self.pickup_notice_text = "RARE DROP  •  XP + ITEMS MAGNETIZED"
  else
    self.buffs[kind] = 15
    local labels = {
      damage = "+50% DAMAGE",
      defense = "+50% DEFENSE",
      speed = "+35% SPEED",
    }
    self.pickup_notice_text = "RARE DROP  •  " .. labels[kind] .. "  •  15s"
  end
  self.pickup_notice = 3.5
  if self.assets then self.assets:play("xp", 0.08) end
end

function CombatSystem:_update_pickups(dt)
  local attraction = self:pickup_snapshot()
  self.ctx.world:each("pickup", function(pickup)
    if pickup:update(dt, self.player, attraction.radius, attraction.speed) then
      self:_apply_pickup(pickup.pickup_kind)
    else
      self.ctx.world:moved(pickup)
    end
  end)
end

function CombatSystem:_update_reward_chests(dt)
  self.ctx.world:each("reward_chest", function(chest)
    if chest:update(dt, self.player) then
      if chest.special then
        self.stage_clear_chest_opened = true
        self.wave_notice = "ENCORE CHEST OPEN  •  STAGE COMPLETE"
        self.wave_notice_time = 4
        if self.assets then self.assets:play("level_up", 0.12) end
      else
        self:_open_reward_chest()
      end
    end
  end)
end

function CombatSystem:_update_buffs(dt)
  for kind, remaining in pairs(self.buffs) do
    self.buffs[kind] = math.max(0, remaining - dt)
  end
  self.weapon_runtime:set_temporary_damage_multiplier(
    self.buffs.damage > 0 and 1.5 or 1)
  self.player.temporary_defense_multiplier = self.buffs.defense > 0 and 1.5 or 1
  self.player.temporary_speed_multiplier = self.buffs.speed > 0 and 1.35 or 1
end

function CombatSystem:_update_overtime()
  local snapshot = self:stage_snapshot(self.ctx.time)
  if not snapshot.is_overtime or self.final_boss_dead then return end
  if not self.final_boss_spawned then self:admin_spawn_final_boss() end
  if self.overtime_latched then return end
  self.overtime_latched = true
  self.wave_notice = "OVERTIME  •  BOSS POWER ×3"
  self.wave_notice_time = 5
  self.ctx.world:each("enemy", function(enemy)
    if enemy.definition.boss_type == "final" then enemy:enrage_overtime(3) end
  end)
end

function CombatSystem:_update_projectiles(dt)
  self.ctx.world:each("projectile", function(projectile)
    projectile:update(dt, self.arena)
    if not projectile.dead then
      self.ctx.world:moved(projectile)
      self.ctx.world.hash:each_in_circle(
        projectile.x,
        projectile.y,
        projectile.radius,
        function(candidate)
          if candidate.kind == "enemy_projectile"
            and not candidate.dead
            and not projectile.dead
          then
            projectile.dead = true
            candidate.dead = true
            self.stats.enemy_shots_cancelled =
              self.stats.enemy_shots_cancelled + 1
            self.vfx:spawn("hit", projectile.x, projectile.y, {
              scale = 0.22,
              rotation = math.atan2(projectile.dy, projectile.dx),
            })
          elseif candidate.kind == "enemy"
            and not candidate.dead
            and not projectile.dead
            and projectile:register_hit(candidate)
          then
            self.stats.damage = self.stats.damage + projectile.damage
            local weapon_damage = self.stats.damage_by_weapon[projectile.source_weapon_id] or 0
            self.stats.damage_by_weapon[projectile.source_weapon_id] =
              weapon_damage + projectile.damage
            local push = projectile.knockback
              * self.tuning:get("combat.knockback_multiplier")
              * (self.character.knockback_mult or 1)
            candidate:push(projectile.dx, projectile.dy, push * 7)
            self.vfx:spawn(
              "hit", projectile.x, projectile.y,
              {
                scale = 0.18 + math.min(0.16, projectile.radius / 70),
                rotation = math.atan2(projectile.dy, projectile.dx),
              })
            if candidate:take_damage(projectile.damage) then
              self:_kill_enemy(candidate)
            else
              self.vfx:spawn("damage", candidate.x, candidate.y, {
                scale = 0.18,
                duration = 0.20,
              })
            end
          end
        end)
    end
  end)
end

function CombatSystem:_player_hit_feedback(trauma)
  if self.camera and self.options.screen_shake ~= false then
    self.camera:add_trauma(trauma)
  end
  if self.options.vibration ~= false and love and love.joystick then
    local joysticks = love.joystick.getJoysticks()
    if joysticks[1] and joysticks[1].setVibration then
      joysticks[1]:setVibration(0.35, 0.55, 0.12)
    end
  end
end

function CombatSystem:_update_enemies(dt)
  local difficulty = self:_difficulty_multiplier()
  local pressure = self:boss_pressure_snapshot()
  local speed = self.tuning:get("enemies.speed_multiplier")
    * (0.82 + difficulty * 0.18) * pressure.enemy_speed
  local damage_multiplier = self.tuning:get("enemies.damage_multiplier")
    * difficulty * pressure.enemy_damage
  local knockback = self.tuning:get("combat.knockback_multiplier")
  self.ctx.world:each("enemy", function(enemy)
    local action = enemy:update(dt, self.player, speed, self.arena)
    self.ctx.world:moved(enemy)
    local contact = self.player.radius + enemy.radius
    if enemy.contact_cooldown <= 0
      and distance_sq(self.player.x, self.player.y, enemy.x, enemy.y) <= contact * contact
    then
      enemy.contact_cooldown = settings.combat.enemy_contact_cooldown
      local dx, dy = self.player.x - enemy.x, self.player.y - enemy.y
      local length = math.max(0.001, math.sqrt(dx * dx + dy * dy))
      if self.player:take_damage(
        enemy.definition.damage * damage_multiplier * enemy.overtime_multiplier,
        dx / length, dy / length, 155 * knockback)
      then
        self:_player_hit_feedback(0.28)
        self.vfx:spawn("player_hurt", self.player.x, self.player.y, {
          scale = 0.24,
        })
      end
    end
    if action and action.kind == "note_bolt" then
      self:_spawn_enemy_projectile(enemy, action, damage_multiplier)
    elseif action and action.kind == "static_wave" then
      self:_spawn_static_wave(enemy, damage_multiplier)
    elseif action and action.kind == "resonance_pulse" then
      local range = enemy.definition.attack_range or 160
      if distance_sq(self.player.x, self.player.y, enemy.x, enemy.y)
        <= range * range
      then
        local dx, dy = self.player.x - enemy.x, self.player.y - enemy.y
        local length = math.max(0.001, math.sqrt(dx * dx + dy * dy))
        if self.player:take_damage(
          enemy.definition.damage * damage_multiplier * enemy.overtime_multiplier,
          dx / length, dy / length, 210 * knockback)
        then
          self:_player_hit_feedback(0.42)
          self.vfx:spawn("player_hurt", self.player.x, self.player.y, {
            scale = 0.36,
          })
        end
      end
      self.vfx:spawn("explosion", enemy.x, enemy.y, {
        scale = range / 420,
        duration = 0.42,
      })
    end
  end)
end

function CombatSystem:_spawn_enemy_projectile(enemy, action, damage_multiplier)
  local projectile = self.enemy_projectile_pool:acquire({
    assets = self.assets,
    projectile_kind = action.kind,
    x = enemy.x,
    y = enemy.y,
    dx = action.dx,
    dy = action.dy,
    speed = enemy.definition.projectile_speed or 270,
    damage = enemy.definition.damage * damage_multiplier * enemy.overtime_multiplier,
    radius = action.kind == "static_wave" and 15
      or enemy.definition.boss_type and 11 or 8,
    color = enemy.definition.color,
  })
  self.ctx.world:add("enemy_projectile", projectile)
end

function CombatSystem:_update_enemy_projectiles(dt)
  local knockback = self.tuning:get("combat.knockback_multiplier")
  self.ctx.world:each("enemy_projectile", function(projectile)
    projectile:update(dt, self.arena)
    if not projectile.dead then
      self.ctx.world:moved(projectile)
      local contact = self.player.radius + projectile.radius
      if distance_sq(self.player.x, self.player.y, projectile.x, projectile.y)
        <= contact * contact
      then
        projectile.dead = true
        if self.player:take_damage(
          projectile.damage, projectile.dx, projectile.dy, 170 * knockback)
        then
          self:_player_hit_feedback(0.34)
          self.vfx:spawn("player_hurt", self.player.x, self.player.y, {
            scale = 0.28,
          })
        end
      end
    end
  end)
end

function CombatSystem:pickup_snapshot()
  local test_factor = TestMode.factor(self.tuning)
  return {
    radius = settings.xp.pickup_radius
    * self.tuning:get("pickups.radius_multiplier")
    * (1 + self.progression:passive_bonus("magnet"))
    * test_factor,
    speed = settings.xp.pickup_speed * test_factor,
  }
end

function CombatSystem:_update_gems(dt)
  local pickup = self:pickup_snapshot()
  self.ctx.world:each("xp_gem", function(gem)
    if gem:update(dt, self.player, pickup.radius, pickup.speed) then
      self.stats.xp = self.stats.xp + gem.value
      self.xp:add(gem.value)
      if self.assets then self.assets:play("xp", 0.045) end
    else
      self.ctx.world:moved(gem)
    end
  end)
end

function CombatSystem:_release_removed()
  local removed = self.ctx.world:sweep()
  for _, enemy in ipairs(removed.enemy or {}) do self.enemy_pool:release(enemy) end
  for _, projectile in ipairs(removed.projectile or {}) do self.projectile_pool:release(projectile) end
  for _, projectile in ipairs(removed.enemy_projectile or {}) do
    self.enemy_projectile_pool:release(projectile)
  end
  for _, gem in ipairs(removed.xp_gem or {}) do self.gem_pool:release(gem) end
  for _, pickup in ipairs(removed.pickup or {}) do self.pickup_pool:release(pickup) end
  for _, chest in ipairs(removed.reward_chest or {}) do
    self.reward_chest_pool:release(chest)
  end
end

function CombatSystem:update(dt)
  local frame_started = os.clock()
  self.wave_notice_time = math.max(0, self.wave_notice_time - dt)
  self.pickup_notice = math.max(0, self.pickup_notice - dt)
  self.stage_notice = math.max(0, self.stage_notice - dt)
  self:_update_buffs(dt)
  self:_update_overtime()
  local stage_time = self.ctx.time - self.stage_started_at
  local difficulty = self:_difficulty_multiplier()
  if not self.final_boss_dead then
    self.spawner:update(
      dt, stage_time, self.content.enemies,
      (0.85 + difficulty * 0.15) * self:boss_pressure_snapshot().spawn_rate)
  end
  self:_update_enemies(dt)
  self:_update_weapons(dt)
  self:_update_projectiles(dt)
  self:_update_enemy_projectiles(dt)
  self:_update_gems(dt)
  self:_update_pickups(dt)
  self:_update_reward_chests(dt)
  self.vfx:update(dt)
  self.xp:update(dt)
  self.progression:update(dt)
  self:_release_removed()

  self.stats.peak_enemies = math.max(
    self.stats.peak_enemies, self.ctx.world:count("enemy"))
  self.stats.peak_projectiles = math.max(
    self.stats.peak_projectiles, self.ctx.world:count("projectile"))
  self.stats.peak_gems = math.max(
    self.stats.peak_gems, self.ctx.world:count("xp_gem"))
  self.frame_time_ms = (os.clock() - frame_started) * 1000

  if self.player.dead then return "defeat" end
  if self.final_boss_dead
    and self.stage_clear_chest_opened
    and not self.stage_clear_reported
  then
    self.stage_clear_reported = true
    if self.stage_index < #self.stages then return "stage_clear" end
    return "victory"
  end
  return nil
end

function CombatSystem:admin_grant_level()
  local required = self.xp:required_for(self.xp.level)
  return self.xp:add(math.max(0, required - self.xp.xp))
end

function CombatSystem:admin_prepare_evolution()
  local selected_recipe
  local recipe_ids = {}
  for id in pairs(self.content.evolutions) do recipe_ids[#recipe_ids + 1] = id end
  table.sort(recipe_ids)
  for _, id in ipairs(recipe_ids) do
    local recipe = self.content.evolutions[id]
    if self.inventory:get(recipe.base_weapon) then
      selected_recipe = recipe
      break
    end
  end
  if not selected_recipe then return nil, "no_evolvable_weapon_owned" end
  local weapon = self.inventory:get(selected_recipe.base_weapon)
  weapon.level = selected_recipe.required_weapon_level
  self.inventory.revision = self.inventory.revision + 1
  local requirement = selected_recipe.required_passives[1]
  if not self.progression.passives:get(requirement.id) then
    local passive, reason = self.progression.passives:add(
      requirement.id, requirement.min_level)
    if not passive then return nil, reason end
  end
  self.progression:_apply_passive_effects()
  self.weapon_runtime:sync(self.inventory)
  self:admin_grant_level()
  return true
end

function CombatSystem:admin_spawn_final_boss()
  if self.final_boss_spawned then return nil, "final_boss_already_spawned" end
  local cx, cy = self.arena:center()
  local stage = self.stages[self.stage_index]
  return self:spawn_enemy(self.content.enemies[stage.final_boss], cx + 360, cy)
end

function CombatSystem:admin_clear_stage()
  local stage = self.stages[self.stage_index]
  local final_definition = self.content.enemies[stage.final_boss]
  local final_enemy
  self.ctx.world:each("enemy", function(enemy)
    if not final_enemy and enemy.definition.id == final_definition.id then
      final_enemy = enemy
    end
  end)
  if not final_enemy then
    final_enemy = self:admin_spawn_final_boss()
  end
  if not final_enemy then return nil, "final_boss_unavailable" end
  final_enemy.hp = 0
  final_enemy.dead = true
  final_enemy.suppress_reward_chest = true
  self:_kill_enemy(final_enemy)
  self.ctx.world:each("reward_chest", function(chest)
    if chest.special then
      chest.x, chest.y = self.player.x, self.player.y
      chest.unlock_delay = 0
      self.ctx.world:moved(chest)
    end
  end)
  return true
end

function CombatSystem:admin_force_evolution()
  if not self.tuning:get("rewards.admin_rank1_evolution") then
    return nil, "rank1_evolution_disabled"
  end
  local selected
  for recipe_id, recipe in pairs(self.content.evolutions) do
    local _, slot = self.inventory:get(recipe.base_weapon)
    if slot then
      selected = { id = recipe_id, recipe = recipe, slot = slot }
      break
    end
  end
  if not selected then return nil, "no_evolvable_weapon_owned" end
  local replacement, reason = self.inventory:replace_at(
    selected.slot, selected.recipe.result_weapon, 1, {
      evolved_from = selected.recipe.base_weapon,
      evolution_id = selected.id,
      branch = selected.recipe.branch,
    })
  if not replacement then return nil, reason end
  self.weapon_runtime:replace_weapon(
    selected.slot, replacement, self.inventory.revision)
  self.progression.evolutions[#self.progression.evolutions + 1] = {
    id = selected.id,
    branch = selected.recipe.branch,
    result_weapon = selected.recipe.result_weapon,
    admin_bypass = true,
  }
  return true
end

return CombatSystem
