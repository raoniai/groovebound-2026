local H = require("tests.helpers")
local Enemy = require("src.game.entities.enemy")
local EnemyAnimation = require("src.render.enemy_animation")
local enemies = require("src.content.enemies")

local T = {}

T["every enemy resolves to its required individual state frame counts"] = function()
  local count = 0
  for id, definition in pairs(enemies) do
    count = count + 1
    H.is_true(EnemyAnimation.frame_count(id, "walk") >= 3, id .. " walk")
    H.is_true(EnemyAnimation.frame_count(id, "hit") >= 3, id .. " hit")
    H.eq(EnemyAnimation.frame_count(id, "death"), 4, id .. " death")
    if definition.attack_kind then
      H.eq(EnemyAnimation.frame_count(id, "attack"), 4, id .. " attack")
    end
  end
  H.eq(count, 49)
end

T["Breakbeat Bruiser has a four-frame identity independent of its old alias"] = function()
  H.eq(EnemyAnimation.frame_count("breakbeat_bruiser", "walk"), 4)
  H.eq(EnemyAnimation.frame_count("breakbeat_bruiser", "attack"), 4)
  H.eq(EnemyAnimation.frame_count("turntable_sentinel", "walk"), 3)
end

T["visual phases are deterministic and do not require a gameplay RNG"] = function()
  local first = EnemyAnimation.phase("monotone", 120, 80)
  local repeat_value = EnemyAnimation.phase("monotone", 120, 80)
  local second = EnemyAnimation.phase("monotone", 121, 80)
  H.eq(first, repeat_value)
  H.is_true(first >= 0 and first < 1)
  H.is_true(second >= 0 and second < 1)
  H.is_true(first ~= second)
end

T["static enemy animation advances without changing simulation state"] = function()
  local drawn = {}
  local assets = {
    draw_enemy_state = function(_, _, state, frame)
      drawn[#drawn + 1] = state .. ":" .. frame
    end,
  }
  local enemy = Enemy()
  enemy:reset({
    definition = {
      id = "static_test", hp = 40, speed = 0, size = 12, damage = 5,
      brain = "static", sprite = { col = 1, row = 1 }, sprite_size = 70,
    },
    assets = assets,
    x = 30,
    y = 40,
  })
  local start_x, start_y, start_hp = enemy.x, enemy.y, enemy.hp
  enemy:draw()
  enemy:update(0.21, { x = 80, y = 40 }, 1, {})
  enemy:draw()
  H.is_true(drawn[1] ~= drawn[2])
  H.eq(enemy.x, start_x)
  H.eq(enemy.y, start_y)
  H.eq(enemy.hp, start_hp)
end

T["animated enemy rendering preserves left-facing horizontal flip"] = function()
  local flip_x
  local assets = {
    draw_enemy_state = function(_, _, _, _, _, _, _, opts)
      flip_x = opts.flip_x
    end,
  }
  local enemy = Enemy()
  enemy:reset({
    definition = {
      id = "walker", hp = 40, speed = 20, size = 12, damage = 5,
      brain = "chase", sprite = { col = 1, row = 1 }, sprite_size = 70,
    },
    assets = assets,
    x = 50,
    y = 50,
  })
  enemy:update(0.1, { x = 10, y = 50 }, 1, {
    clamp = function(_, x, y) return x, y end,
  })
  enemy:draw()
  H.is_true(flip_x)
end

return T
