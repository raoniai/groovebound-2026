local H = require("tests.helpers")
local Enemy = require("src.game.entities.enemy")
local EnemyProjectile = require("src.game.entities.enemy_projectile")
local Projectile = require("src.game.entities.projectile")
local XPGem = require("src.game.entities.xp_gem")
local Pickup = require("src.game.entities.pickup")
local RewardChest = require("src.game.entities.reward_chest")
local CombatSystem = require("src.game.systems.combat_system")

local T = {}

local arena = {
  contains = function(_, x, y, radius)
    return x - radius >= 0 and y - radius >= 0 and x + radius <= 100 and y + radius <= 100
  end,
  clamp = function(_, x, y, radius)
    return math.max(radius, math.min(100 - radius, x)),
      math.max(radius, math.min(100 - radius, y))
  end,
}

T["projectiles move by their normalized direction and speed"] = function()
  local projectile = Projectile()
  projectile:reset({
    x = 20, y = 20, dx = 1, dy = 0, speed = 50, damage = 10, lifetime = 2,
  })
  projectile:update(0.5, arena)
  H.eq(projectile.x, 45)
  H.eq(projectile.y, 20)
  H.near(projectile.lifetime, 1.5)
  H.is_false(projectile.dead)
end

T["projectile render pose loops subtle scale and position motion"] = function()
  local projectile = Projectile()
  projectile:reset({
    x = 20, y = 20, dx = 1, dy = 0, speed = 50, damage = 10,
    lifetime = 2, source_weapon_id = "kazoo_pistol",
  })
  local first = projectile:render_pose()
  projectile:update(0.25, arena)
  local second = projectile:render_pose()
  H.is_true(first.x ~= second.x or first.y ~= second.y)
  H.is_true(first.scale_x ~= second.scale_x or first.scale_y ~= second.scale_y)
  H.is_true(second.scale_x >= 0.90 and second.scale_x <= 1.10)
  H.is_true(second.scale_y >= 0.90 and second.scale_y <= 1.10)
  H.is_true(math.abs(second.x - projectile.x) <= 4)
  H.is_true(math.abs(second.y - projectile.y) <= 4)
end

T["enemy projectiles render with the generated projectile sprite"] = function()
  local drawn
  local projectile = EnemyProjectile()
  projectile:reset({
    assets = {
      draw_enemy_projectile = function(_, kind)
        drawn = kind
        return true
      end,
    },
    projectile_kind = "note_bolt",
    x = 20, y = 20, dx = 1, dy = 0,
  })
  projectile:draw()
  H.eq(drawn, "note_bolt")
end

T["projectile pierce is consumed once per distinct enemy"] = function()
  local projectile = Projectile()
  projectile:reset({
    x = 20, y = 20, dx = 1, dy = 0, speed = 50, damage = 10,
    lifetime = 2, pierce = 1,
  })
  local first, second = {}, {}
  H.is_true(projectile:register_hit(first))
  H.eq(projectile.pierce, 0)
  H.is_false(projectile.dead)
  H.is_false(projectile:register_hit(first))
  H.is_false(projectile.dead)
  H.is_true(projectile:register_hit(second))
  H.is_true(projectile.dead)
end

T["pooled projectiles clear previous hit identities on reset"] = function()
  local projectile = Projectile()
  local enemy = {}
  projectile:reset({
    x = 20, y = 20, dx = 1, dy = 0, speed = 50, damage = 10, lifetime = 2,
  })
  H.is_true(projectile:register_hit(enemy))
  projectile:reset({
    x = 20, y = 20, dx = 1, dy = 0, speed = 50, damage = 10, lifetime = 2,
  })
  H.is_true(projectile:register_hit(enemy))
end

T["XP gems attract inside pickup range and collect on contact"] = function()
  local gem = XPGem()
  gem:reset({ x = 50, y = 50, value = 10 })
  local player = { x = 30, y = 50, radius = 8 }
  H.is_false(gem:update(0.1, player, 100, 40))
  H.is_true(gem.x < 50)
  gem.x = 39
  H.is_true(gem:update(0, player, 100, 40))
  H.is_true(gem.dead)
end

T["magnetized XP gems travel from anywhere on the stage"] = function()
  local gem = XPGem()
  gem:reset({ x = 90, y = 90, value = 10 })
  gem.magnetized = true
  local player = { x = 10, y = 10, radius = 8 }
  H.is_false(gem:update(0.1, player, 1, 40))
  H.is_true(gem.x < 90 and gem.y < 90)
end

T["rare pickups collect on player contact"] = function()
  local pickup = Pickup()
  pickup:reset({ kind = "heal", x = 20, y = 20 })
  H.is_true(pickup:update(0, { x = 20, y = 20, radius = 8 }))
  H.is_true(pickup.dead)
end

T["consumables use gem attraction while reward chests never magnetize"] = function()
  local player = { x = 10, y = 10, radius = 8 }
  local pickup = Pickup()
  pickup:reset({ kind = "speed", x = 90, y = 90 })
  pickup.magnetized = true
  H.is_false(pickup:update(0.1, player, 1, 40))
  H.is_true(pickup.x < 90 and pickup.y < 90)

  local chest = RewardChest()
  chest:reset({ x = 90, y = 90 })
  chest:update(0.1, player)
  H.eq(chest.x, 90)
  H.eq(chest.y, 90)
  H.is_nil(chest.magnetized)
end

T["enemies chase, respect arena bounds, and die at zero HP"] = function()
  local enemy = Enemy()
  enemy:reset({
    definition = {
      id = "test", size = 10, hp = 20, speed = 50, damage = 5,
    },
    x = 95,
    y = 50,
  })
  enemy:update(1, { x = 200, y = 50 }, 2, arena)
  H.eq(enemy.x, 90)
  H.is_false(enemy:take_damage(19))
  H.eq(enemy.hp, 1)
  H.is_true(enemy:take_damage(1))
  H.is_true(enemy.dead)
end

T["enemy projectile hurt areas follow visible sprite size without enlarging movement"] = function()
  local enemy = Enemy()
  enemy:reset({
    definition = {
      id = "visible", size = 12, sprite_size = 70,
      hp = 20, speed = 50, damage = 5,
    },
    x = 30, y = 50,
  })
  H.eq(enemy.body_radius, 12)
  H.is_true(enemy.hurt_radius >= 26)
  H.eq(enemy.radius, enemy.hurt_radius)
  local resolved_radius
  local movement_arena = {
    resolve_movement = function(_, _, _, next_x, next_y, radius)
      resolved_radius = radius
      return next_x, next_y
    end,
  }
  enemy:update(0.1, { x = 90, y = 50 }, 1, movement_arena)
  H.eq(resolved_radius, enemy.body_radius)
end

T["enemy movement avoids the expensive visibility graph hot path"] = function()
  local enemy = Enemy()
  enemy:reset({
    definition = {
      id = "pathing", size = 10, hp = 20, speed = 50,
      damage = 5, brain = "chase",
    },
    x = 30,
    y = 50,
  })
  local navigation_calls = 0
  local pathing_arena = {
    navigation_direction = function()
      navigation_calls = navigation_calls + 1
      return 0, -1, true
    end,
    resolve_movement = function(_, _, _, next_x, next_y)
      return next_x, next_y
    end,
  }
  enemy:update(0.5, { x = 90, y = 50 }, 1, pathing_arena)
  H.eq(enemy.x, 55)
  H.eq(enemy.y, 50)
  H.eq(navigation_calls, 0)
end

T["overtime enrages a boss exactly once with triple health and speed"] = function()
  local enemy = Enemy()
  enemy:reset({
    definition = { id = "boss", size = 10, hp = 100, speed = 10, damage = 5 },
    x = 20, y = 20,
  })
  H.is_true(enemy:enrage_overtime(3))
  H.eq(enemy.hp, 300)
  H.eq(enemy.max_hp, 300)
  H.eq(enemy.overtime_multiplier, 3)
  H.is_false(enemy:enrage_overtime(3))
  enemy:update(1, { x = 90, y = 20 }, 1, arena)
  H.eq(enemy.x, 50)
end

T["every World Tour stage guarantees a chest by its thirty-sixth kill"] = function()
  H.is_false(CombatSystem.reward_chest_is_guaranteed({
    mode = "world_tour", stage_reward_chest_kills = 35,
    stage_reward_chests_spawned = 0,
  }))
  H.is_true(CombatSystem.reward_chest_is_guaranteed({
    mode = "world_tour", stage_reward_chest_kills = 36,
    stage_reward_chests_spawned = 0,
  }))
  H.is_false(CombatSystem.reward_chest_is_guaranteed({
    mode = "world_tour", stage_reward_chest_kills = 80,
    stage_reward_chests_spawned = 1,
  }))
  H.is_false(CombatSystem.reward_chest_is_guaranteed({
    mode = "prologue", stage_reward_chest_kills = 80,
    stage_reward_chests_spawned = 0,
  }))
end

return T
