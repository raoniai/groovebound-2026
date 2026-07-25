-- First complete combat vertical slice: spawn, auto-fire, collisions, damage,
-- drops, pickup, progression, pooling, and run outcome.

local class = require("src.core.class")
local Pool = require("src.core.pool")
local Enemy = require("src.game.entities.enemy")
local Projectile = require("src.game.entities.projectile")
local XPGem = require("src.game.entities.xp_gem")
local SpawnDirector = require("src.game.systems.spawn_director")
local WeaponInventory = require("src.game.systems.weapon_inventory")
local WeaponRuntime = require("src.game.systems.weapon_runtime")
local XPSystem = require("src.game.systems.xp_system")
local ProgressionSystem = require("src.game.systems.progression_system")
local settings = require("src.config.settings")

local CombatSystem = class()

local function distance_sq(ax, ay, bx, by)
  local dx, dy = bx - ax, by - ay
  return dx * dx + dy * dy
end

function CombatSystem:init(opts)
  self.ctx = assert(opts.ctx)
  self.content = assert(opts.content)
  self.tuning = assert(opts.tuning)
  self.assets = opts.assets
  self.arena = assert(opts.arena)
  self.player = assert(opts.player)
  self.camera = opts.camera
  self.options = opts.options or {}

  self.enemy_pool = Pool(function() return Enemy() end)
  self.projectile_pool = Pool(function() return Projectile() end)
  self.gem_pool = Pool(function() return XPGem() end)

  self.inventory = WeaponInventory(self.content)
  assert(self.inventory:add("kazoo_pistol", 1))
  self.weapon_runtime = WeaponRuntime(self.content, self.tuning)
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
    damage = 0,
    xp = 0,
    coins = 0,
    minibosses = 0,
    bosses = 0,
    damage_by_weapon = {},
    peak_enemies = 0,
    peak_projectiles = 0,
    peak_gems = 0,
    score = 0,
    combo = 0,
    max_combo = 0,
  }
  self.last_kill_time = -math.huge
  self.frame_time_ms = 0
  self.final_boss_dead = false
  self.final_boss_spawned = false
  self.wave_notice = nil
  self.wave_notice_time = 0

  self.spawner = SpawnDirector({
    waves = self.content.waves,
    rng = self.ctx.rng.spawn,
    tuning = self.tuning,
    arena = self.arena,
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

function CombatSystem:spawn_enemy(definition, x, y)
  if definition.boss_type == "final" then
    local cx, cy = self.arena:center()
    x, y = cx + 360, cy
  end
  local enemy = self.enemy_pool:acquire({
    definition = definition,
    assets = self.assets,
    x = x,
    y = y,
  })
  if definition.boss_type == "final" then self.final_boss_spawned = true end
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
        elseif snapshot.pattern == "cross" then
          local lane = (shot - 1) % 4
          angle = base_angle + lane * math.pi / 2
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
    self.progression:grant_resolve()
    self.ctx.bus:emit("RESOLVE_GRANTED", {
      source = enemy.id,
      tokens = self.progression.resolve_tokens,
    })
  elseif enemy.definition.boss_type == "final" then
    self.stats.bosses = self.stats.bosses + 1
    self.final_boss_dead = true
  end
  local gem = self.gem_pool:acquire({
    assets = self.assets,
    x = enemy.x,
    y = enemy.y,
    value = enemy.definition.xp,
    phase = self.ctx.rng.vfx:uniform(0, math.pi * 2),
  })
  self.ctx.world:add("xp_gem", gem)
  if self.assets then self.assets:play("enemy_death", 0.05) end
  return true
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
          if candidate.kind == "enemy"
            and not candidate.dead
            and not projectile.dead
            and projectile:register_hit(candidate)
          then
            self.stats.damage = self.stats.damage + projectile.damage
            local weapon_damage = self.stats.damage_by_weapon[projectile.source_weapon_id] or 0
            self.stats.damage_by_weapon[projectile.source_weapon_id] =
              weapon_damage + projectile.damage
            candidate.x, candidate.y = self.arena:clamp(
              candidate.x + projectile.dx * projectile.knockback,
              candidate.y + projectile.dy * projectile.knockback,
              candidate.radius)
            if candidate:take_damage(projectile.damage) then
              self:_kill_enemy(candidate)
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
  local speed = self.tuning:get("enemies.speed_multiplier")
  self.ctx.world:each("enemy", function(enemy)
    enemy:update(dt, self.player, speed, self.arena)
    self.ctx.world:moved(enemy)
    local contact = self.player.radius + enemy.radius
    if enemy.contact_cooldown <= 0
      and distance_sq(self.player.x, self.player.y, enemy.x, enemy.y) <= contact * contact
    then
      enemy.contact_cooldown = settings.combat.enemy_contact_cooldown
      if self.player:take_damage(enemy.definition.damage) then
        self:_player_hit_feedback(0.28)
      end
    end
    if enemy.definition.brain == "static"
      and enemy.attack_cooldown <= 0
      and distance_sq(self.player.x, self.player.y, enemy.x, enemy.y)
        <= (enemy.definition.attack_range or 0) ^ 2
    then
      enemy.attack_cooldown = enemy.definition.attack_interval
      if self.player:take_damage(enemy.definition.damage) then
        self:_player_hit_feedback(0.38)
      end
    end
  end)
end

function CombatSystem:_update_gems(dt)
  local pickup_radius = settings.xp.pickup_radius
    * self.tuning:get("pickups.radius_multiplier")
  self.ctx.world:each("xp_gem", function(gem)
    if gem:update(dt, self.player, pickup_radius, settings.xp.pickup_speed) then
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
  for _, gem in ipairs(removed.xp_gem or {}) do self.gem_pool:release(gem) end
end

function CombatSystem:update(dt)
  local frame_started = os.clock()
  self.wave_notice_time = math.max(0, self.wave_notice_time - dt)
  self.spawner:update(dt, self.ctx.time, self.content.enemies)
  self:_update_enemies(dt)
  self:_update_weapons(dt)
  self:_update_projectiles(dt)
  self:_update_gems(dt)
  self.xp:update(dt)
  self:_release_removed()

  self.stats.peak_enemies = math.max(
    self.stats.peak_enemies, self.ctx.world:count("enemy"))
  self.stats.peak_projectiles = math.max(
    self.stats.peak_projectiles, self.ctx.world:count("projectile"))
  self.stats.peak_gems = math.max(
    self.stats.peak_gems, self.ctx.world:count("xp_gem"))
  self.frame_time_ms = (os.clock() - frame_started) * 1000

  if self.player.dead then return "defeat" end
  if self.final_boss_dead then return "victory" end
  if self.ctx.time >= settings.run.hard_timeout then return "defeat" end
  return nil
end

function CombatSystem:admin_grant_level()
  local required = self.xp:required_for(self.xp.level)
  return self.xp:add(math.max(0, required - self.xp.xp))
end

function CombatSystem:admin_prepare_evolution()
  local weapon = self.inventory:get("kazoo_pistol")
  if not weapon then return nil, "kazoo_not_owned" end
  weapon.level = self.content.weapons.kazoo_pistol.max_level
  self.inventory.revision = self.inventory.revision + 1
  if not self.progression.passives:get("breath_control") then
    local passive, reason = self.progression.passives:add("breath_control", 1)
    if not passive then return nil, reason end
  end
  self.progression:_apply_passive_effects()
  self.weapon_runtime:sync(self.inventory)
  self.progression:grant_resolve()
  self:admin_grant_level()
  return true
end

function CombatSystem:admin_spawn_final_boss()
  if self.final_boss_spawned then return nil, "final_boss_already_spawned" end
  local cx, cy = self.arena:center()
  return self:spawn_enemy(self.content.enemies.static_baron, cx + 360, cy)
end

return CombatSystem
